import 'dart:async';

import '../../../native/aptos_reference_vectors.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:n42_wallet/features/wallet/services/apt_submission_journal.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/apt_api.dart';

class _FailingStorage extends FlutterSecureStorage {
  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => throw StateError('durable storage unavailable');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));
  Future<AptPendingSubmission> send(
    AptSubmissionJournal journal, {
    Future<void> Function(AptPendingSubmission)? dispatch,
    bool Function()? current,
    int chain = 1,
    String sender = '0x1',
    String bytes = '00ff',
  }) => journal.broadcast(
    chainId: chain,
    sender: sender,
    sequence: BigInt.zero,
    signedTx: bytes,
    isCurrent: current ?? () => true,
    send: dispatch ?? (_) async {},
  );
  AptApi api(
    String hash, {
    String type = 'user_transaction',
    bool success = true,
  }) => AptApi(
    read: (url) async => url.endsWith('/v1/')
        ? {'chain_id': 1, 'ledger_timestamp': '1000000'}
        : {
            'type': type,
            'hash': hash,
            'sender': '0x1',
            'sequence_number': '0',
            if (type == 'user_transaction') ...{
              'success': success,
              'version': '1',
            },
          },
  );

  test(
    'signed expiry survives reload and unlocks only after saved expired result',
    () async {
      final vector = aptosReferenceVectors.first;
      final signed = vector['signed'] as String;
      final sender = '0x${(vector['raw'] as String).substring(0, 64)}';
      final journal = AptSubmissionJournal();
      final expiry = BigInt.from(2000000000);
      await journal.broadcast(
        chainId: 1,
        sender: sender,
        sequence: BigInt.zero,
        signedTx: signed,
        expirationSeconds: expiry,
        isCurrent: () => true,
        send: (_) async {},
      );
      expect(
        (await AptSubmissionJournal().pending(1, sender))!.expirationSeconds,
        expiry,
      );
      var saved = 0;
      final result = await AptSubmissionJournal().reconcile(
        chainId: 1,
        sender: sender,
        api: AptApi(
          read: (url) async {
            if (url.endsWith('/v1/')) {
              return {
                'chain_id': 1,
                'ledger_timestamp': '2000000001000000',
                'ledger_version': '99',
              };
            }
            if (url.contains('by_hash')) throw StateError('not found');
            expect(Uri.parse(url).queryParameters['ledger_version'], '99');
            return {'sequence_number': '0'};
          },
        ),
        saveResult: (_, receipt) async {
          saved++;
          expect(receipt.status, AptTransactionStatus.expired);
        },
      );
      expect(result!.status, AptTransactionStatus.expired);
      expect(saved, 1);
      expect(await journal.pending(1, sender), isNull);
    },
  );
  test('expiry metadata cannot differ from signed transaction', () async {
    final vector = aptosReferenceVectors.first;
    final journal = AptSubmissionJournal();
    final sender = '0x${(vector['raw'] as String).substring(0, 64)}';
    await expectLater(
      journal.broadcast(
        chainId: 1,
        sender: sender,
        sequence: BigInt.zero,
        signedTx: vector['signed'] as String,
        expirationSeconds: BigInt.one,
        isCurrent: () => true,
        send: (_) async => fail('must not submit'),
      ),
      throwsFormatException,
    );
    expect(await journal.pending(1, sender), isNull);
  });
  test(
    'timeout persists before dispatch and blocks another instance',
    () async {
      final journal = AptSubmissionJournal();
      var calls = 0;
      await expectLater(
        send(
          journal,
          dispatch: (record) async {
            calls++;
            expect(
              (await AptSubmissionJournal().pending(1, '0x01'))!.hash,
              record.hash,
            );
            throw TimeoutException('unknown');
          },
        ),
        throwsA(isA<TimeoutException>()),
      );
      await expectLater(
        send(AptSubmissionJournal(), bytes: '01'),
        throwsA(isA<AptSubmissionPending>()),
      );
      expect(calls, 1);
    },
  );
  test('storage failure prevents dispatch', () async {
    var calls = 0;
    await expectLater(
      send(
        AptSubmissionJournal(storage: _FailingStorage()),
        dispatch: (_) async {
          calls++;
        },
      ),
      throwsStateError,
    );
    expect(calls, 0);
  });
  test('owner loss after durable write cancels without dispatch', () async {
    var checks = 0;
    var calls = 0;
    final journal = AptSubmissionJournal();
    await expectLater(
      send(
        journal,
        current: () => ++checks == 1,
        dispatch: (_) async {
          calls++;
        },
      ),
      throwsStateError,
    );
    expect(calls, 0);
    expect(await journal.pending(1, '0x1'), isNull);
  });
  test('two instances serialize equivalent account addresses', () async {
    final entered = Completer<void>();
    final release = Completer<void>();
    var calls = 0;
    final first = send(
      AptSubmissionJournal(),
      dispatch: (_) async {
        calls++;
        entered.complete();
        await release.future;
      },
    );
    await entered.future;
    final second = send(
      AptSubmissionJournal(),
      sender: '0x01',
      dispatch: (_) async {
        calls++;
      },
    );
    final rejected = expectLater(second, throwsA(isA<AptSubmissionPending>()));
    release.complete();
    await first;
    await rejected;
    expect(calls, 1);
  });
  test('different chain or account remains usable', () async {
    final journal = AptSubmissionJournal();
    await send(journal);
    await send(journal, chain: 2);
    await send(journal, sender: '0x2');
    expect(await journal.pending(1, '0x1'), isNotNull);
  });
  for (final success in [true, false]) {
    test('save terminal success=$success before clearing', () async {
      final journal = AptSubmissionJournal();
      final record = await send(journal);
      var saves = 0;
      final receipt = await journal.reconcile(
        chainId: 1,
        sender: '0x1',
        api: api(record.hash, success: success),
        saveResult: (pending, result) async {
          saves++;
          expect(
            (await AptSubmissionJournal().pending(1, '0x1'))!.hash,
            pending.hash,
          );
          expect(
            result.status,
            success
                ? AptTransactionStatus.succeeded
                : AptTransactionStatus.failed,
          );
        },
      );
      expect(receipt, isNotNull);
      expect(saves, 1);
      expect(await journal.pending(1, '0x1'), isNull);
      await send(journal, bytes: '02');
    });
  }
  test('save failure retains record for idempotent recovery', () async {
    final journal = AptSubmissionJournal();
    final record = await send(journal);
    await expectLater(
      journal.reconcile(
        chainId: 1,
        sender: '0x1',
        api: api(record.hash),
        saveResult: (_, _) async => throw StateError('disk'),
      ),
      throwsStateError,
    );
    expect((await AptSubmissionJournal().pending(1, '0x1'))!.hash, record.hash);
  });
  test('pending, unrelated and unavailable results never clear', () async {
    final journal = AptSubmissionJournal();
    final record = await send(journal);
    for (final rpc in [
      api(record.hash, type: 'pending_transaction'),
      api('0x${'ab' * 32}'),
      AptApi(read: (_) async => throw TimeoutException('offline')),
    ]) {
      await journal.reconcile(
        chainId: 1,
        sender: '0x1',
        api: rpc,
        saveResult: (_, _) async => fail('must not finalize'),
      );
      expect((await journal.pending(1, '0x1'))!.hash, record.hash);
    }
  });
  test('corrupt durable record fails closed', () async {
    FlutterSecureStorage.setMockInitialValues({
      'n42.apt.pending.v1.1.0x${'0' * 63}1': '{bad',
    });
    await expectLater(send(AptSubmissionJournal()), throwsFormatException);
  });
}
