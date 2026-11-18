import 'dart:convert';

import 'package:fast_base58/fast_base58.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/near_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/sui_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/egld_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/ada_api.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/algo_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/btc_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/fil_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/xrp_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/xlm_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/xtz_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/zil_api.dart';
import 'package:n42_wallet/features/wallet/api/sender/evm_sender.dart';
import 'package:n42_wallet/features/wallet/api/token_view_api.dart';
import 'package:n42_wallet/features/wallet/models/btc_transaction_recode_model.dart';
import 'package:n42_wallet/features/wallet/models/transation_record_model.dart';
import 'package:n42_wallet/features/wallet/utils/chain/memo_expiry_proof.dart';

/// 交易状态解析器 — 纯网络查询，无副作用。
///
/// 返回值约定：
///   1 = 成功上链
///   2 = 失败（reverted）
///  -1 = 无法确定（RPC 错误、数据尚未就绪）
///   0 = 尚未确认（仍在 pending 中）
class TransactionStateResolver {
  /// A record still pending this long after it was sent has gone through
  /// many polling rounds (every 10 s) without a chain result. It is shown as
  /// "not confirmed" instead of "pending"; its stored state is unchanged and
  /// it keeps being checked.
  static const unknownAfter = Duration(minutes: 30);

  /// Whether [record] is pending past [unknownAfter]. Display only.
  static bool isUnconfirmed(TransationRecordModel record, {DateTime? now}) {
    if (record.state != 0) return false;
    final raw = int.tryParse(record.txTime);
    if (raw == null || raw <= 0) return false;
    final sentAt = DateTime.fromMillisecondsSinceEpoch(
      record.txTime.length == 13 ? raw : raw * 1000,
    );
    return (now ?? DateTime.now()).difference(sentAt) > unknownAfter;
  }

  final TokenViewApi _tokenViewApi;

  final XlmApi _xlmApi;
  final AdaApi _adaApi;
  final EgldApi _egldApi;
  final NearApi Function(bool) _nearApiFactory;
  final SuiApi Function(bool) _suiApiFactory;

  TransactionStateResolver({
    SuiApi Function(bool)? suiApiFactory,
    TokenViewApi? tokenViewApi,
    XlmApi? xlmApi,
    AdaApi? adaApi,
    EgldApi? egldApi,
    NearApi Function(bool)? nearApiFactory,
  }) : _tokenViewApi = tokenViewApi ?? TokenViewApi(),
       _xlmApi = xlmApi ?? XlmApi(),
       _egldApi = egldApi ?? EgldApi(),
       _nearApiFactory = nearApiFactory ?? ((test) => NearApi(isTest: test)),
       _suiApiFactory = suiApiFactory ?? ((test) => SuiApi(isTest: test)),
       _adaApi =
           adaApi ??
           AdaApi(
             projectId: const String.fromEnvironment('BLOCKFROST_PROJECT_ID'),
           );

  /// 根据区块链类型查询 [trm] 的上链状态。
  Future<int> resolveState(TransationRecordModel trm) async {
    final BlockchainType bt = BlockchainType.values.firstWhere(
      (e) => e.name == trm.coin['blockchainType'],
    );
    switch (bt) {
      case BlockchainType.Ethereum:
        return _resolveEth(trm);
      case BlockchainType.Solana:
        return _resolveSolana(trm);
      case BlockchainType.Tron:
        return _resolveTron(trm);
      case BlockchainType.Algorand:
        return _resolveAlgorand(trm);
      case BlockchainType.Tezos:
        return _resolveTezos(trm);
      case BlockchainType.Ripple:
        return _resolveRipple(trm);
      case BlockchainType.Cardano:
        return _orNeverLands(trm, 'ADA', _resolveCardano, _cardanoNeverLands);
      case BlockchainType.MultiversX:
        return _orNeverLands(trm, 'EGLD', _resolveEgld, _egldNeverLands);
      case BlockchainType.Near:
        return _orNeverLands(trm, 'NEAR', _resolveNear, _nearNeverLands);
      case BlockchainType.Stellar:
        return _orNeverLands(trm, 'XLM', _resolveStellar, _stellarNeverLands);
      case BlockchainType.Sui:
        return (await _resolveSuiDetailed(trm)).$1;
      case BlockchainType.Filecoin:
        return _resolveFilecoin(trm);
      case BlockchainType.Harmony:
      case BlockchainType.IoTeX:
      case BlockchainType.Theta:
        // EVM compatible - uses Ethereum RPC
        return _resolveEvmCompatible(trm);
      case BlockchainType.Zilliqa:
        return _resolveZilliqa(trm);
      default:
        // Unsupported chain type — return 0 (unknown confirmation count)
        return 0;
    }
  }

  /// Resolve [trm] and, for a failure the chain reported itself, its reason.
  /// Chains without a reason report null.
  Future<(int, String?)> resolveStateWithReason(
    TransationRecordModel trm,
  ) async {
    if (trm.coin['blockchainType'] == BlockchainType.Sui.name) {
      return _resolveSuiDetailed(trm);
    }
    return (await resolveState(trm), null);
  }

  static String? _suiAddress(Object? value) {
    if (value is! String || !RegExp(r'^0x[0-9a-fA-F]{1,64}$').hasMatch(value)) {
      return null;
    }
    return '0x${value.substring(2).toLowerCase().padLeft(64, '0')}';
  }

  /// Sui (GraphQL `transaction(digest:)`): only the stored digest's own
  /// effects decide. Success or failure counts once the effects name the
  /// checkpoint that finalized them; effects without one stay pending. Not
  /// found (null: never executed, not yet indexed or pruned), GraphQL or
  /// transport errors and unfamiliar replies are unknown (-1): absence alone
  /// never proves a Sui transaction can no longer execute.
  Future<(int, String?)> _resolveSuiDetailed(
    TransationRecordModel record,
  ) async {
    final digest = record.txHash;
    final network = record.isTest;
    final sender = _suiAddress(record.from1);
    try {
      final bytes = Base58Decode(digest);
      if (bytes.length != 32 ||
          Base58Encode(bytes) != digest ||
          sender == null ||
          ![0, 1].contains(network) ||
          record.contract.isNotEmpty) {
        return (-1, null);
      }
      final response = await _suiApiFactory(network == 1)
          .getTransactionBlock(digest);
      if (record.txHash != digest ||
          record.isTest != network ||
          _suiAddress(record.from1) != sender ||
          response.error) {
        return (-1, null);
      }
      final data = response.data;
      if (data is! Map || data['digest'] != digest) return (-1, null);
      final senderInfo = data['sender'];
      if (senderInfo is! Map || _suiAddress(senderInfo['address']) != sender) {
        return (-1, null);
      }
      final effects = data['effects'];
      if (effects is! Map ||
          (effects['digest'] != null && effects['digest'] != digest)) {
        return (-1, null);
      }
      final checkpoint = effects['checkpoint'];
      final finalized =
          SuiApi.amount(
            checkpoint is Map ? checkpoint['sequenceNumber'] : null,
          ) !=
          null;
      switch (effects['status']) {
        case 'SUCCESS':
          return (finalized ? 1 : 0, null);
        case 'FAILURE':
          if (!finalized) return (0, null);
          final failure = effects['executionError'];
          final error = failure is Map ? failure['message'] : null;
          return (
            2,
            error is String && error.isNotEmpty
                ? 'Sui transaction failed: $error'
                : 'Sui transaction failed',
          );
        default:
          return (-1, null);
      }
    } catch (_) {
      return (-1, null);
    }
  }

  /// 查询 BTC 类交易的确认数，更新 [trm] 并返回最新确认数（-1 表示查询失败）。
  Future<int> resolveBtcConfirmations(BtcTransactionRecodeModel trm) async {
    if (trm.isTest == 1) {
      final MessageModel mm = await BtcApi(test: true).getTxState(trm.txHash);
      if (mm.error) return -1;
      return mm.data['confirmed'] == true ? 6 : 0;
    } else {
      final MessageModel mm = await _tokenViewApi.getTxConfirmation(
        trm.coin['coinType'],
        trm.txHash,
      );
      if (mm.error) return -1;
      return mm.data as int? ?? 0;
    }
  }

  // ---------- chain-proven expiry (ADA/XLM/EGLD/NEAR memo sends) ----------

  /// Chain point at which each pending record was first proven unable to
  /// land, keyed by chain, network, row and hash. A record is closed as failed
  /// only when a later, independent poll proves it again at an advanced chain
  /// point, so one lagging node or indexer behind a load balancer cannot fail
  /// a transaction that actually landed.
  final Map<String, BigInt> _neverLandsSince = {};

  /// Minimum chain advance between the two proofs.
  static final Map<String, BigInt> _minimumAdvance = {
    'XLM': BigInt.from(3), // ledgers (~15 s)
    'ADA': BigInt.from(60), // slots (~60 s)
    'EGLD': BigInt.from(3), // metachain blocks (~18 s)
    'NEAR': BigInt.from(10), // final blocks (~10 s)
  };

  /// Cardano stability window 3k/f (k = 2160, f = 0.05): blocks older than
  /// this can no longer be rolled back, so no fork can still include the
  /// transaction once the tip is this far past its TTL.
  static final BigInt cardanoStabilitySlots = BigInt.from(129600);

  Future<int> _orNeverLands(
    TransationRecordModel record,
    String chain,
    Future<int> Function(TransationRecordModel) resolve,
    Future<BigInt?> Function(TransationRecordModel, Map<String, String>) prove,
  ) async {
    final hash = record.txHash.toLowerCase();
    final network = record.isTest;
    final sender = record.from1;
    final key = '$chain:$network:${record.trId}:$hash';
    final state = await resolve(record);
    final proof = MemoExpiryProof.decode(record.memoExpiry, chain);
    if (state != -1 ||
        proof == null ||
        record.state != 0 ||
        record.coinMiniName.toUpperCase() != chain ||
        sender.isEmpty ||
        ![0, 1].contains(network)) {
      _neverLandsSince.remove(key);
      return state;
    }
    BigInt? point;
    try {
      point = await prove(record, proof);
    } catch (_) {
      point = null;
    }
    if (record.txHash.toLowerCase() != hash ||
        record.isTest != network ||
        record.from1 != sender) {
      return -1;
    }
    if (point == null) {
      // Unknown again: the next proof must start over.
      _neverLandsSince.remove(key);
      return -1;
    }
    final first = _neverLandsSince[key];
    if (first == null || point < first) {
      _neverLandsSince[key] = point;
      return -1;
    }
    if (point - first >= _minimumAdvance[chain]!) {
      _neverLandsSince.remove(key);
      return 2;
    }
    return -1;
  }

  static int? _int(Object? value) => value is int ? value : null;

  static BigInt? _decimal(Object? value) {
    final text = value is int ? '$value' : value;
    if (text is! String || !RegExp(r'^(0|[1-9][0-9]{0,30})$').hasMatch(text)) {
      return null;
    }
    return BigInt.parse(text);
  }

  /// Stellar: a transaction applies only with sequence == account sequence +
  /// 1. Once the account sequence reached the signed sequence, this envelope
  /// can never apply; if Horizon (whose history covers the signing ledger)
  /// does not know the hash, it never did.
  Future<BigInt?> _stellarNeverLands(
    TransationRecordModel record,
    Map<String, String> proof,
  ) async {
    final sequence = MemoExpiryProof.unsigned(proof, 'seq');
    final signedAfter = MemoExpiryProof.unsigned(proof, 'ledger');
    final hash = record.txHash.toLowerCase();
    final isTest = record.isTest == 1;
    if (sequence == null ||
        signedAfter == null ||
        !RegExp(r'^[0-9a-f]{64}$').hasMatch(hash)) {
      return null;
    }
    final root = await _xlmApi.lookup('/', isTest: isTest);
    final rootData = root.jsonObject;
    final elder = _int(rootData?['history_elder_ledger']);
    final latest = _int(rootData?['history_latest_ledger']);
    if (root.statusCode != 200 ||
        elder == null ||
        latest == null ||
        BigInt.from(elder) > signedAfter ||
        BigInt.from(latest) < signedAfter) {
      return null;
    }
    final account = await _xlmApi.lookup(
      '/accounts/${record.from1}',
      isTest: isTest,
    );
    final accountData = account.jsonObject;
    final current = _decimal(accountData?['sequence']);
    if (account.statusCode != 200 ||
        accountData?['account_id'] != record.from1 ||
        current == null ||
        current < sequence) {
      return null;
    }
    final tx = await _xlmApi.lookup('/transactions/$hash', isTest: isTest);
    final type = tx.jsonObject?['type'];
    if (tx.statusCode != 404 ||
        type is! String ||
        !type.endsWith('/not_found')) {
      return null;
    }
    return BigInt.from(latest);
  }

  /// Cardano: a transaction is invalid from its TTL slot on. Once the tip is a
  /// full stability window past the TTL and the hash is unknown, no chain
  /// (including any fork) can contain it.
  Future<BigInt?> _cardanoNeverLands(
    TransationRecordModel record,
    Map<String, String> proof,
  ) async {
    final ttl = MemoExpiryProof.unsigned(proof, 'ttl');
    final hash = record.txHash.toLowerCase();
    final isTest = record.isTest == 1;
    if (ttl == null ||
        _adaApi.projectId.trim().isEmpty ||
        !RegExp(r'^[0-9a-f]{64}$').hasMatch(hash)) {
      return null;
    }
    final tip = await _adaApi.lookup('/blocks/latest', isTest: isTest);
    final slot = _int(tip.jsonObject?['slot']);
    if (tip.statusCode != 200 ||
        slot == null ||
        BigInt.from(slot) < ttl + cardanoStabilitySlots) {
      return null;
    }
    final tx = await _adaApi.lookup('/txs/$hash', isTest: isTest);
    if (tx.statusCode != 404 || tx.jsonObject?['status_code'] != 404) {
      return null;
    }
    return BigInt.from(slot);
  }

  /// MultiversX: a transaction executes only with nonce == account nonce.
  /// Once the account nonce moved past the signed nonce and the hash is
  /// unknown, another transaction consumed it and this one can never land.
  Future<BigInt?> _egldNeverLands(
    TransationRecordModel record,
    Map<String, String> proof,
  ) async {
    final nonce = MemoExpiryProof.unsigned(proof, 'nonce');
    final hash = record.txHash.toLowerCase();
    final isTest = record.isTest == 1;
    if (nonce == null || !RegExp(r'^[0-9a-f]{64}$').hasMatch(hash)) {
      return null;
    }
    final meta = await _egldApi.lookup(
      '/blocks?shard=4294967295&size=1&fields=nonce,shard',
      isTest: isTest,
    );
    final blocks = meta.data;
    final metaNonce =
        blocks is List && blocks.length == 1 && blocks.single is Map
        ? _int((blocks.single as Map)['nonce'])
        : null;
    if (meta.statusCode != 200 || metaNonce == null) return null;
    final account = await _egldApi.lookup(
      '/accounts/${record.from1}',
      isTest: isTest,
    );
    final accountData = account.jsonObject;
    final current = _int(accountData?['nonce']);
    if (account.statusCode != 200 ||
        accountData?['address'] != record.from1 ||
        current == null ||
        BigInt.from(current) <= nonce) {
      return null;
    }
    final tx = await _egldApi.lookup('/transactions/$hash', isTest: isTest);
    if (tx.statusCode != 404 || tx.jsonObject?['statusCode'] != 404) {
      return null;
    }
    return BigInt.from(metaNonce);
  }

  /// NEAR: a transaction is valid only while its access-key nonce is unused
  /// and its reference block is within the validity period. When either is
  /// over at a final height, and the node (whose garbage-collected window
  /// still covers the reference block) does not know the hash, it never
  /// landed and cannot land.
  Future<BigInt?> _nearNeverLands(
    TransationRecordModel record,
    Map<String, String> proof,
  ) async {
    final nonce = MemoExpiryProof.unsigned(proof, 'nonce');
    final reference = MemoExpiryProof.unsigned(proof, 'height');
    final publicKey = proof['publicKey'];
    final hash = record.txHash;
    if (nonce == null ||
        reference == null ||
        publicKey == null ||
        !publicKey.startsWith('ed25519:')) {
      return null;
    }
    final api = _nearApiFactory(record.isTest == 1);
    final config = (await api.rpcRaw('EXPERIMENTAL_protocol_config', {
      'finality': 'final',
    }))?['result'];
    final validity = config is Map
        ? _int(config['transaction_validity_period'])
        : null;
    final epoch = config is Map ? _int(config['epoch_length']) : null;
    if (validity == null || validity <= 0 || epoch == null || epoch <= 0) {
      return null;
    }
    final block = (await api.rpcRaw('block', {'finality': 'final'}))?['result'];
    final header = block is Map ? block['header'] : null;
    final height = header is Map ? _int(header['height']) : null;
    if (height == null) return null;
    final current = BigInt.from(height);
    // Nodes keep about five epochs of history; beyond four epochs an unknown
    // hash is no longer evidence of anything.
    if (current < reference ||
        current - reference > BigInt.from(epoch) * BigInt.from(4)) {
      return null;
    }
    final key = (await api.rpcRaw('query', {
      'request_type': 'view_access_key',
      'finality': 'final',
      'account_id': record.from1,
      'public_key': publicKey,
    }))?['result'];
    final keyNonce = key is Map ? _decimal(key['nonce']) : null;
    final nonceUsed = keyNonce != null && keyNonce >= nonce;
    final expired = current > reference + BigInt.from(validity);
    if (!nonceUsed && !expired) return null;
    final tx = await api.rpcRaw('tx', {
      'tx_hash': hash,
      'sender_account_id': record.from1,
      'wait_until': 'NONE',
    });
    final error = tx?['error'];
    final cause = error is Map ? error['cause'] : null;
    if (tx?['result'] != null ||
        cause is! Map ||
        cause['name'] != 'UNKNOWN_TRANSACTION') {
      return null;
    }
    return current;
  }

  Future<int> _resolveNear(TransationRecordModel record) async {
    Object identity() => (
      record.txHash,
      record.isTest,
      record.userUuid,
      record.walletIndex,
      record.coinId,
      record.from1,
      record.to1,
      record.price,
      record.contract,
    );
    final original = identity();
    final hash = record.txHash;
    final network = record.isTest;
    try {
      if (hash.length < 32 ||
          hash.length > 44 ||
          ![0, 1].contains(network) ||
          record.from1.isEmpty ||
          record.to1.isEmpty ||
          record.price <= BigInt.zero ||
          record.contract.isNotEmpty) {
        return -1;
      }
      final bytes = Base58Decode(hash);
      if (bytes.length != 32 || Base58Encode(bytes) != hash) return -1;
      final response = await _nearApiFactory(network == 1)
          .getTransactionStatus(hash, record.from1);
      if (identity() != original || response.error) return -1;
      final data = response.data;
      if (data is! Map) return -1;
      final tx = data['transaction'];
      if (tx is! Map ||
          tx['hash'] != hash ||
          tx['signer_id'] != record.from1 ||
          tx['receiver_id'] != record.to1) {
        return -1;
      }
      final actions = tx['actions'];
      if (actions is! List || actions.length != 1) return -1;
      final action = actions.single;
      if (action is! Map || action.length != 1) return -1;
      final transfer = action['Transfer'];
      if (transfer is! Map || transfer['deposit'] != record.price.toString()) {
        return -1;
      }
      // Inclusion or optimistic execution is insufficient to close history.
      if (data['final_execution_status'] != 'FINAL') return -1;
      final status = data['status'];
      if (status is! Map || status.length != 1) return -1;
      if (status.containsKey('SuccessValue')) {
        final value = status['SuccessValue'];
        if (value is! String || base64Encode(base64Decode(value)) != value) {
          return -1;
        }
        return 1;
      }
      final failure = status['Failure'];
      if (failure is Map && failure.isNotEmpty) return 2;
      return -1;
    } catch (_) {
      // Not-found and timeouts cannot prove a failed or safely retryable send.
      return -1;
    }
  }

  Future<int> _resolveEgld(TransationRecordModel record) async {
    final hash = record.txHash;
    final network = record.isTest;
    final identity = (
      record.userUuid,
      record.walletIndex,
      record.coinId,
      record.from1,
      record.to1,
      record.price,
      record.contract,
    );
    final hashPattern = RegExp(r'^[0-9a-fA-F]{64}$');
    if (hash.length != 64 ||
        !hashPattern.hasMatch(hash) ||
        ![0, 1].contains(network) ||
        record.from1.isEmpty ||
        record.to1.isEmpty ||
        record.price <= BigInt.zero ||
        record.contract.isNotEmpty) {
      return -1;
    }
    try {
      final data = await _egldApi.getTransaction(hash, isTest: network == 1);
      if (record.txHash != hash ||
          record.isTest != network ||
          (
                record.userUuid,
                record.walletIndex,
                record.coinId,
                record.from1,
                record.to1,
                record.price,
                record.contract,
              ) !=
              identity) {
        return -1;
      }
      if (data is! Map ||
          data['txHash'] is! String ||
          (data['txHash'] as String).toLowerCase() != hash.toLowerCase() ||
          data['sender'] != record.from1 ||
          data['receiver'] != record.to1 ||
          data['value'] != record.price.toString()) {
        return -1;
      }
      if (data['status'] == 'pending') return 0;
      // Only included terminal receipts release a reservation. Not-found,
      // transport errors and unfamiliar statuses must never authorize a retry.
      if (data['miniBlockHash'] is! String ||
          (data['miniBlockHash'] as String).length != 64 ||
          !hashPattern.hasMatch(data['miniBlockHash'] as String) ||
          data['timestamp'] is! int ||
          (data['timestamp'] as int) <= 0) {
        return -1;
      }
      return switch (data['status']) {
        'success' => 1,
        'fail' || 'invalid' => 2,
        _ => -1,
      };
    } catch (_) {
      return -1;
    }
  }

  Future<int> _resolveCardano(TransationRecordModel record) async {
    final hash = record.txHash;
    final network = record.isTest;
    final identity = (
      record.userUuid,
      record.walletIndex,
      record.from1,
      record.coinId,
    );
    final hashPattern = RegExp(r'^[0-9a-fA-F]{64}$');
    if (_adaApi.projectId.trim().isEmpty ||
        !hashPattern.hasMatch(hash) ||
        hash.length != 64 ||
        ![0, 1].contains(network) ||
        record.from1.isEmpty) {
      return -1;
    }
    try {
      final response = await _adaApi.getTransaction(hash, isTest: network == 1);
      if (response.error) return -1;
      final data = response.data;
      if (data is! Map ||
          data['hash'] is! String ||
          (data['hash'] as String).toLowerCase() != hash.toLowerCase() ||
          data['block'] is! String ||
          (data['block'] as String).length != 64 ||
          !hashPattern.hasMatch(data['block'] as String) ||
          data['block_height'] is! int ||
          (data['block_height'] as int) < 0 ||
          data['valid_contract'] is! bool) {
        return -1;
      }
      if (record.txHash != hash ||
          record.isTest != network ||
          (record.userUuid, record.walletIndex, record.from1, record.coinId) !=
              identity) {
        return -1;
      }
      // Inclusion with a failed script is not a successful payment. Not-found
      // and transport errors above remain unknown, never an instruction to resend.
      return data['valid_contract'] == true ? 1 : 2;
    } catch (_) {
      return -1;
    }
  }

  Future<int> _resolveStellar(TransationRecordModel record) async {
    // Capture the persisted identity before awaiting network data.
    final hash = record.txHash;
    final sender = record.from1;
    final network = record.isTest;
    final owner = (record.userUuid, record.walletIndex);
    if (!RegExp(r'^[0-9a-fA-F]{64}$').hasMatch(hash) ||
        sender.isEmpty ||
        ![0, 1].contains(network)) {
      return -1;
    }
    try {
      final response = await _xlmApi.getTransaction(hash, isTest: network == 1);
      if (response.error) return -1;
      final data = response.data;
      if (data is! Map ||
          data['hash'] is! String ||
          (data['hash'] as String).toLowerCase() != hash.toLowerCase() ||
          data['source_account'] != sender ||
          data['successful'] is! bool ||
          data['ledger'] is! int ||
          (data['ledger'] as int) <= 0 ||
          (data['ledger'] as int) > 4294967295) {
        return -1;
      }
      // Do not apply a receipt to a record whose identity changed in flight.
      if (record.txHash != hash ||
          record.from1 != sender ||
          record.isTest != network ||
          (record.userUuid, record.walletIndex) != owner) {
        return -1;
      }
      return data['successful'] == true ? 1 : 2;
    } catch (_) {
      // Not found/timeout is not evidence that the original send failed.
      return -1;
    }
  }

  // ---------- per-chain resolvers ----------

  Future<int> _resolveEth(TransationRecordModel trm) async {
    final bool isTest = trm.isTest != 0;
    final String? customRpc = _receiptRpc(trm);
    final MessageModel mm = await _tokenViewApi.getTransactionReceiptEth(
      trm.coin['coinType'],
      trm.txHash,
      isTest: isTest,
      rpc: customRpc,
    );
    if (mm.error) return -1;
    dynamic receipt = mm.data;
    if (customRpc == null) {
      if (receipt is! Map ||
          receipt['error'] is! Map ||
          receipt['error']['code'] != 0) {
        return -1;
      }
      receipt = receipt['result'];
    }
    if (receipt == null) return 0;
    if (receipt is! Map ||
        (receipt['transactionHash'] != null &&
            receipt['transactionHash'].toString().toLowerCase() !=
                trm.txHash.toLowerCase())) {
      return -1;
    }
    return _statusFromHex(receipt['status']);
  }

  Future<int> _resolveSolana(TransationRecordModel trm) async {
    final MessageModel mm = await _tokenViewApi.getTransactionSolana(
      trm.txHash,
      trm.isTest == 0 ? 'main' : 'test',
    );
    if (mm.error) return 0;
    if (mm.data.length == 0) return 0;

    final errObj = mm.data['Err'];
    if (errObj != null && errObj['InstructionError'] != null) return 2;
    final ok = mm.data['Ok'];
    return ok == null ? 1 : 0;
  }

  Future<int> _resolveTron(TransationRecordModel trm) async {
    final MessageModel mm = await _tokenViewApi.getTransactionReceiptTrx(
      trm.txHash,
      isTest: trm.isTest != 0,
    );
    if (mm.error) return 0;
    if (mm.data['error']['code'] != 0) return -1;
    return _statusFromHex(mm.data['result']['status']);
  }

  Future<int> _resolveAlgorand(TransationRecordModel trm) async {
    final MessageModel mm = await AlgoApi().getTransactionsInfo(
      trm.txHash,
      isTest: trm.isTest != 0,
    );
    if (mm.error) return 0;
    return 1;
  }

  Future<int> _resolveTezos(TransationRecordModel trm) async {
    final MessageModel mm = await XtzApi().getTxInfoXtz(
      trm.txHash,
      trm.isTest != 0,
    );
    if (mm.error) return 0;
    final List<dynamic> rData = mm.data;
    if (rData.isNotEmpty && rData[0]['is_success'] == true) return 1;
    return 0;
  }

  Future<int> _resolveRipple(TransationRecordModel trm) async {
    final MessageModel mm = await XrpApi().getTxInfoXrp(
      trm.txHash,
      trm.isTest != 0,
    );
    if (mm.error) return 0;
    return mm.data == 'tesSUCCESS' ? 1 : 0;
  }

  Future<int> _resolveFilecoin(TransationRecordModel trm) async {
    final MessageModel mm = await FilApi().getMessageInfo(trm.txHash);
    if (mm.error) return 0;
    return 1;
  }

  Future<int> _resolveEvmCompatible(TransationRecordModel trm) =>
      _resolveEth(trm);

  Future<int> _resolveZilliqa(TransationRecordModel trm) async {
    final ZilApi zilApi = ZilApi(isTest: trm.isTest != 0);
    final MessageModel mm = await zilApi.getTransaction(trm.txHash);
    if (mm.error) return 0;
    // Transaction found and confirmed
    final receipt = mm.data['receipt'];
    if (receipt == null) return 0;
    return receipt['success'] == true ? 1 : 2;
  }

  // ---------- helpers ----------

  /// 从 EVM status hex 字符串（"0x1" / "0x0"）转换为状态码
  int _statusFromHex(dynamic status) {
    if (status == '0x1' || status == 1 || status == true) return 1;
    if (status == '0x0' || status == 0 || status == false) return 2;
    return -1;
  }

  /// 返回 EVM 交易记录的链 RPC。与发送侧（EvmSender.resolveRpcOverride）保持
  /// 同一套解析：凡配置了链 RPC 的都直连查收据，否则经交易在链上广播成功、
  /// 收据却走不路由该链的 TokenView 后端，会永远停在 pending。
  String? _receiptRpc(TransationRecordModel trm) =>
      EvmSender.resolveRpcOverride(trm.coin, isTest: trm.isTest != 0);
}
