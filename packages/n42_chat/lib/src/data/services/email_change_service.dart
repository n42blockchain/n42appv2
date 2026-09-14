import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:matrix/matrix.dart';
import 'package:uuid/uuid.dart';

import '../datasources/local/secure_storage_datasource.dart';

/// Owns the email validation session; binding is still authorized by Matrix.
class EmailChangeService {
  static const sessionKey = 'email_change_session_v1';
  final Client? Function() currentClient;
  final bool Function() isLoggedIn;
  final SecureStorageDataSource storage;
  final http.Client Function() _httpClient;
  final DateTime Function() _now;
  bool _busy = false;
  int _generation = 0;
  bool? requiresCode;

  EmailChangeService({
    required this.currentClient,
    required this.isLoggedIn,
    required this.storage,
    http.Client Function()? httpClient,
    DateTime Function()? now,
  }) : _httpClient = httpClient ?? http.Client.new,
       _now = now ?? DateTime.now;

  void reset() {
    _generation++;
    requiresCode = null;
  }

  Future<T> _run<T>(Future<T> Function(_EmailContext) action) async {
    if (_busy) throw StateError('Email verification is already in progress');
    final client = currentClient();
    if (!isLoggedIn() ||
        client == null ||
        client.userID == null ||
        client.homeserver == null) {
      throw StateError('Not logged in: cannot change email');
    }
    final context = _EmailContext(client, _generation);
    _busy = true;
    try {
      return await action(context);
    } finally {
      _busy = false;
    }
  }

  void _checkContext(_EmailContext context) {
    if (!isLoggedIn() ||
        !identical(currentClient(), context.client) ||
        context.generation != _generation ||
        context.client.userID != context.userId ||
        context.client.homeserver.toString() != context.homeserver ||
        context.client.accessToken != context.accessToken ||
        context.client.deviceID != context.deviceId) {
      throw StateError('Account changed during email verification');
    }
  }

  Future<_EmailSession?> _load() async {
    final json = await storage.read(sessionKey);
    // Legacy split keys lack account binding and must never be reused.
    return json == null ? null : _EmailSession.parse(json);
  }

  Future<bool> request({required String newEmail}) => _run((context) async {
    final email = newEmail.trim();
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      throw const FormatException('Invalid email address');
    }
    // A damaged/obsolete session can be replaced by a fresh request, but
    // confirmation always requires a fully valid persisted session.
    _EmailSession? previous;
    try {
      previous = await _load();
    } on FormatException {
      previous = null;
    }
    _checkContext(context);
    final reuse =
        previous != null &&
        previous.matches(context, email) &&
        _now().isBefore(previous.expiresAt);
    final secret = reuse ? previous.secret : const Uuid().v4();
    final attempt = reuse ? previous.attempt + 1 : 1;
    final response = await context.client.requestTokenTo3PIDEmail(
      secret,
      email,
      attempt,
    );
    _checkContext(context);
    final session = _EmailSession(
      userId: context.userId,
      homeserver: context.homeserver,
      deviceId: context.deviceId,
      email: email,
      secret: secret,
      sid: response.sid,
      attempt: attempt,
      expiresAt: _now().add(const Duration(hours: 1)),
      submitUrl: response.submitUrl,
    );
    session.validate();
    // One record is published only after a complete server response.
    await storage.write(sessionKey, jsonEncode(session.toJson()));
    _checkContext(context);
    requiresCode = session.submitUrl != null;
    return true;
  });

  Future<bool> confirm({
    required String newEmail,
    required String code,
    String? password,
  }) => _run((context) async {
    final session = await _load();
    _checkContext(context);
    if (session == null || !session.matches(context, newEmail.trim())) {
      throw StateError(
        'Email verification session does not match this account and address',
      );
    }
    void check() {
      _checkContext(context);
      if (!_now().isBefore(session.expiresAt)) {
        throw StateError('Email verification session expired');
      }
    }

    check();
    if (session.submitUrl != null) {
      if (!session.tokenValidated) {
        if (code.trim().isEmpty) {
          throw const FormatException('Verification token is required');
        }
        await _submitToken(session, code);
        check();
        // A token can be consumed before add3PID fails (for example, on a
        // wrong UIA password). Persist progress before attempting the binding
        // so retries, including after restart, do not consume the token again.
        // This records validation only; the server still authorizes add3PID.
        await storage.write(
          sessionKey,
          jsonEncode(session.withValidatedToken().toJson()),
        );
        check();
      }
    } else if (code.isNotEmpty) {
      throw const FormatException('Verify the email link before confirming');
    }
    try {
      await context.client.add3PID(session.secret, session.sid);
    } on MatrixException catch (error) {
      check();
      final canUsePassword =
          error.requireAdditionalAuthentication &&
          (error.authenticationFlows?.any((flow) {
                final remaining = flow.stages
                    .where(
                      (stage) =>
                          !error.completedAuthenticationFlows.contains(stage),
                    )
                    .toList();
                return remaining.length == 1 &&
                    remaining.single == 'm.login.password';
              }) ??
              false);
      if (!canUsePassword || password == null || password.isEmpty) rethrow;
      await context.client.add3PID(
        session.secret,
        session.sid,
        auth: AuthenticationPassword(
          session: error.session,
          password: password,
          identifier: AuthenticationUserIdentifier(user: context.userId),
        ),
      );
    }
    _checkContext(context);
    requiresCode = null;
    // The server has already committed the binding. Cleanup failure must
    // not tell the page that the successful binding failed.
    try {
      await storage.delete(sessionKey);
    } catch (_) {
      // A later request replaces the record; never log verification data.
    }
    _checkContext(context);
    return true;
  });

  Future<void> _submitToken(_EmailSession session, String code) async {
    final client = _httpClient();
    try {
      final request = http.Request('POST', session.submitUrl!)
        ..followRedirects = false
        ..headers['content-type'] = 'application/json'
        ..body = jsonEncode({
          'client_secret': session.secret,
          'sid': session.sid,
          // Tokens are opaque and must be sent without normalization.
          'token': code,
        });
      final response = await client
          .send(request)
          .then(http.Response.fromStream)
          .timeout(const Duration(seconds: 30));
      if (response.statusCode != 200) {
        throw MatrixException.fromJson({
          'errcode': 'M_THREEPID_AUTH_FAILED',
          'error': 'Email verification was not accepted',
        });
      }
      final body = jsonDecode(response.body);
      if (body is! Map || body['success'] != true) {
        throw MatrixException.fromJson({
          'errcode': 'M_THREEPID_AUTH_FAILED',
          'error': 'Email verification was not accepted',
        });
      }
    } finally {
      client.close();
    }
  }
}

class _EmailContext {
  final Client client;
  final int generation;
  final String userId;
  final String homeserver;
  final String? deviceId;
  final String? accessToken;
  _EmailContext(this.client, this.generation)
    : userId = client.userID!,
      homeserver = client.homeserver.toString(),
      deviceId = client.deviceID,
      accessToken = client.accessToken;
}

class _EmailSession {
  final String userId, homeserver, email, secret, sid;
  final String? deviceId;
  final int attempt;
  final DateTime expiresAt;
  final Uri? submitUrl;
  final bool tokenValidated;
  _EmailSession({
    required this.userId,
    required this.homeserver,
    required this.deviceId,
    required this.email,
    required this.secret,
    required this.sid,
    required this.attempt,
    required this.expiresAt,
    required this.submitUrl,
    this.tokenValidated = false,
  });

  static _EmailSession parse(String source) {
    try {
      final json = jsonDecode(source) as Map<String, dynamic>;
      if (json['version'] != 1) {
        throw const FormatException('Unsupported email session');
      }
      final session = _EmailSession(
        userId: json['userId'] as String,
        homeserver: json['homeserver'] as String,
        deviceId: json['deviceId'] as String?,
        email: json['email'] as String,
        secret: json['secret'] as String,
        sid: json['sid'] as String,
        attempt: json['attempt'] as int,
        expiresAt: DateTime.parse(json['expiresAt'] as String),
        submitUrl: json['submitUrl'] == null
            ? null
            : Uri.parse(json['submitUrl'] as String),
        tokenValidated: json.containsKey('tokenValidated')
            ? json['tokenValidated'] as bool
            : false,
      );
      session.validate();
      return session;
    } catch (_) {
      throw const FormatException('Invalid email verification session');
    }
  }

  void validate() {
    final opaque = RegExp(r'^[0-9a-zA-Z.=_-]{1,255}$');
    final url = submitUrl;
    if (userId.isEmpty ||
        homeserver.isEmpty ||
        email.isEmpty ||
        attempt < 1 ||
        !opaque.hasMatch(sid) ||
        !opaque.hasMatch(secret) ||
        (url != null &&
            (url.scheme != 'https' ||
                url.host.isEmpty ||
                url.userInfo.isNotEmpty ||
                url.hasFragment))) {
      throw const FormatException('Invalid email verification session');
    }
  }

  bool matches(_EmailContext context, String address) =>
      userId == context.userId &&
      homeserver == context.homeserver &&
      deviceId == context.deviceId &&
      email == address;

  _EmailSession withValidatedToken() => _EmailSession(
    userId: userId,
    homeserver: homeserver,
    deviceId: deviceId,
    email: email,
    secret: secret,
    sid: sid,
    attempt: attempt,
    expiresAt: expiresAt,
    submitUrl: submitUrl,
    tokenValidated: true,
  );

  Map<String, dynamic> toJson() => {
    'version': 1,
    'userId': userId,
    'homeserver': homeserver,
    'deviceId': deviceId,
    'email': email,
    'secret': secret,
    'sid': sid,
    'attempt': attempt,
    'expiresAt': expiresAt.toIso8601String(),
    'submitUrl': submitUrl?.toString(),
    'tokenValidated': tokenValidated,
  };
}
