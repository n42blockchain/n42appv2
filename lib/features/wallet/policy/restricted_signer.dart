import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wallet/wallet.dart' show EthereumAddress;

/// Host-owned policy. Never give its database, admin API or raw signer to an agent.
/// This is an opt-in signer boundary, not an on-chain Safe Guard.
final class SigningPolicy {
  SigningPolicy({
    required this.chainId,
    required this.account,
    required this.asset,
    required Set<String> recipients,
    required this.perTransfer,
    required this.perPeriod,
    required this.periodSeconds,
    required this.expiresAt,
    required this.maxFee,
  }) : recipients = Set.unmodifiable(recipients.map(_address)) {
    _address(account);
    if (asset != 'native') _address(asset);
    if (chainId <= 0 ||
        perTransfer <= BigInt.zero ||
        perPeriod < perTransfer ||
        periodSeconds <= 0 ||
        expiresAt <= 0 ||
        maxFee < BigInt.zero ||
        recipients.isEmpty) {
      throw ArgumentError('Invalid signing policy');
    }
  }
  final int chainId, periodSeconds, expiresAt;
  final String account, asset;
  final Set<String> recipients;
  final BigInt perTransfer, perPeriod, maxFee;

  Map<String, Object> toJson() => {
    'chainId': chainId,
    'account': _address(account),
    'asset': asset.toLowerCase(),
    'recipients': recipients.toList()..sort(),
    'perTransfer': '$perTransfer',
    'perPeriod': '$perPeriod',
    'periodSeconds': periodSeconds,
    'expiresAt': expiresAt,
    'maxFee': '$maxFee',
  };
  factory SigningPolicy.fromJson(Map<String, dynamic> j) => SigningPolicy(
    chainId: j['chainId'] as int,
    account: j['account'] as String,
    asset: j['asset'] as String,
    recipients: (j['recipients'] as List).cast<String>().toSet(),
    perTransfer: BigInt.parse(j['perTransfer'] as String),
    perPeriod: BigInt.parse(j['perPeriod'] as String),
    periodSeconds: j['periodSeconds'] as int,
    expiresAt: j['expiresAt'] as int,
    maxFee: BigInt.parse(j['maxFee'] as String),
  );
}

String _address(String value) {
  if (!RegExp(r'^0x[0-9a-fA-F]{40}$').hasMatch(value) ||
      BigInt.parse(value.substring(2), radix: 16) == BigInt.zero) {
    throw ArgumentError('Expected nonzero EVM address');
  }
  return EthereumAddress.fromHex(value, enforceEip55: true).with0x;
}

/// The sole transaction representation used by preview, policy and signer.
/// Native transfers and ERC20 transfer only. Approve, delegatecall, arbitrary
/// calldata, batches and policy changes have no agent-facing encoding path.
final class RestrictedTransfer {
  RestrictedTransfer({
    required this.chainId,
    required String account,
    required String recipient,
    required String asset,
    required this.units,
    required this.nonce,
    required this.gasLimit,
    required this.gasPrice,
  }) : account = _address(account),
       recipient = _address(recipient),
       asset = asset == 'native' ? asset : _address(asset) {
    final max = (BigInt.one << 256) - BigInt.one;
    if (chainId <= 0 ||
        units <= BigInt.zero ||
        units > max ||
        nonce < BigInt.zero ||
        nonce > max ||
        gasLimit <= BigInt.zero ||
        gasPrice <= BigInt.zero ||
        gasLimit * gasPrice > max) {
      throw ArgumentError('Invalid transfer integers');
    }
  }
  final int chainId;
  final String account, recipient, asset;
  final BigInt units, nonce, gasLimit, gasPrice;
  String get selector => asset == 'native' ? '0x' : '0xa9059cbb';
  String get data => asset == 'native'
      ? '0x'
      : '$selector${recipient.substring(2).padLeft(64, '0')}${units.toRadixString(16).padLeft(64, '0')}';
  Map<String, Object> get payload => Map.unmodifiable({
    'chainId': chainId,
    'from': account,
    'to': asset == 'native' ? recipient : asset,
    'value': asset == 'native' ? '$units' : '0',
    'data': data,
    'nonce': '$nonce',
    'gasLimit': '$gasLimit',
    'gasPrice': '$gasPrice',
  });
  String get digest =>
      sha256.convert(utf8.encode(jsonEncode(payload))).toString();
}

/// Durable reservations are consumed even if signing times out. No automatic
/// retry or quota refund: a signature may have escaped to an external service.
final class RestrictedSigner {
  factory RestrictedSigner({
    required Database database,
    required String scope,
    required Future<String> Function(RestrictedTransfer) sign,
    required Future<bool> Function(RestrictedTransfer) approve,
    required int Function() now,
  }) => RestrictedSigner._(database, scope, sign, approve, now);
  RestrictedSigner._(
    this._db,
    this.scope,
    this._sign,
    this._approve,
    this._now,
  );
  final Database _db;
  final String scope;
  final Future<String> Function(RestrictedTransfer) _sign;
  final Future<bool> Function(RestrictedTransfer) _approve;
  final int Function() _now;

  /// Must be initialized by the trusted host before exposing this facade.
  static Future<void> initialize(Database db) async {
    await db.execute(
      'CREATE TABLE IF NOT EXISTS signing_policies '
      '(scope TEXT PRIMARY KEY, active TEXT NOT NULL, pending TEXT, ready INTEGER, frozen INTEGER NOT NULL DEFAULT 0)',
    );
    await db.execute(
      'CREATE TABLE IF NOT EXISTS signing_reservations '
      '(scope TEXT, request TEXT, digest TEXT, amount TEXT, at INTEGER, nonce TEXT, '
      'PRIMARY KEY(scope, request), UNIQUE(scope, nonce))',
    );
  }

  Future<String> sign(String requestId, RestrictedTransfer tx) async {
    if (requestId.isEmpty || requestId.length > 128) {
      throw ArgumentError('Invalid request ID');
    }
    // This callback belongs to the host, not the caller. Re-read policy after UI.
    if (!await _approve(tx)) throw StateError('Human approval required');
    await _db.transaction((db) async {
      final rows = await db.query(
        'signing_policies',
        where: 'scope = ?',
        whereArgs: [scope],
      );
      if (rows.length != 1 || rows.single['frozen'] != 0) {
        throw StateError('Policy unavailable');
      }
      final p = SigningPolicy.fromJson(
        jsonDecode(rows.single['active'] as String) as Map<String, dynamic>,
      );
      final now = _now();
      if (now < 0 ||
          now >= p.expiresAt ||
          tx.chainId != p.chainId ||
          tx.account != _address(p.account) ||
          tx.asset != p.asset.toLowerCase() ||
          !p.recipients.contains(tx.recipient) ||
          tx.units > p.perTransfer ||
          tx.gasLimit * tx.gasPrice > p.maxFee) {
        throw StateError('Policy denied');
      }
      final reservations = await db.query(
        'signing_reservations',
        where: 'scope = ?',
        whereArgs: [scope],
      );
      var spent = BigInt.zero;
      for (final r in reservations) {
        final at = r['at'] as int;
        if (at > now) throw StateError('Clock rollback');
        if (r['request'] == requestId || r['nonce'] == '${tx.nonce}') {
          throw StateError('Already reserved; reconcile without signing again');
        }
        // Rolling window, so policy changes cannot reset quota at a boundary.
        if (at > now - p.periodSeconds) {
          spent += BigInt.parse(r['amount'] as String);
        }
      }
      if (spent + tx.units > p.perPeriod) throw StateError('Period limit');
      await db.insert('signing_reservations', {
        'scope': scope,
        'request': requestId,
        'digest': tx.digest,
        'amount': '${tx.units}',
        'at': now,
        'nonce': '${tx.nonce}',
      });
    });
    // Reservation is committed before external signing. No await between this
    // point and starting the host signer; it receives the exact approved object.
    final signature = await _sign(tx);
    if (signature.isEmpty) {
      throw StateError('Empty signature; reservation retained');
    }
    return signature;
  }
}

/// Trusted-owner capability, kept separate from RestrictedSigner.
/// Changing account/asset requires a new scope, never a quota reset in place.
final class SigningPolicyAdmin {
  factory SigningPolicyAdmin(
    Database db, {
    required int delaySeconds,
    required int Function() now,
  }) {
    if (delaySeconds <= 0) {
      throw ArgumentError('Positive timelock required');
    }
    return SigningPolicyAdmin._(db, delaySeconds, now);
  }
  SigningPolicyAdmin._(this._db, this.delaySeconds, this._now);
  final Database _db;
  final int delaySeconds;
  final int Function() _now;
  Future<void> install(String scope, SigningPolicy p) => _db
      .insert('signing_policies', {
        'scope': scope,
        'active': jsonEncode(p.toJson()),
      })
      .then((_) {});
  Future<void> propose(String scope, SigningPolicy p) =>
      _db.transaction((db) async {
        final rows = await db.query(
          'signing_policies',
          where: 'scope = ?',
          whereArgs: [scope],
        );
        if (rows.length != 1) throw StateError('Missing policy');
        final old = SigningPolicy.fromJson(
          jsonDecode(rows.single['active'] as String) as Map<String, dynamic>,
        );
        if (p.chainId != old.chainId ||
            _address(p.account) != _address(old.account) ||
            p.asset.toLowerCase() != old.asset.toLowerCase()) {
          throw StateError('Scope identity cannot change');
        }
        await db.update(
          'signing_policies',
          {'pending': jsonEncode(p.toJson()), 'ready': _now() + delaySeconds},
          where: 'scope = ?',
          whereArgs: [scope],
        );
      });
  Future<void> activate(String scope) => _db.transaction((db) async {
    final rows = await db.query(
      'signing_policies',
      where: 'scope = ?',
      whereArgs: [scope],
    );
    if (rows.length != 1 ||
        rows.single['pending'] == null ||
        _now() < (rows.single['ready'] as int)) {
      throw StateError('Timelock not ready');
    }
    await db.update(
      'signing_policies',
      {
        'active': rows.single['pending'],
        'pending': null,
        'ready': null,
        'frozen': 0,
      },
      where: 'scope = ?',
      whereArgs: [scope],
    );
  });

  /// Recovery owner can immediately freeze and cancel a pending relaxation.
  Future<void> freeze(String scope) => _db
      .update(
        'signing_policies',
        {'frozen': 1, 'pending': null, 'ready': null},
        where: 'scope = ?',
        whereArgs: [scope],
      )
      .then((_) {});
}
