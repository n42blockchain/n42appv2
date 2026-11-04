import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:n42_wallet/features/wallet/services/batch_submission_journal.dart';

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
  const sender = '0x1111111111111111111111111111111111111111';
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));
  test('cancellation before dispatch releases the intent and permits a new transfer', () async {
    final journal = BatchSubmissionJournal();
    var sends = 0;
    await expectLater(
      journal.broadcast(
        chainId: 1,
        sender: sender,
        signedTx: '0x01',
        isCurrent: () => false,
        send: (_) async {
          sends++;
        },
      ),
      throwsA(isA<BatchSubmissionCancelled>()),
    );
    expect(sends, 0);
    expect(await journal.pendingHash(1, sender), isNull);
    await journal.broadcast(
      chainId: 1,
      sender: sender,
      signedTx: '0x02',
      send: (_) async {
        sends++;
      },
    );
    expect(sends, 1);
  });
  test('storage failure prevents the network call', () async {
    final journal = BatchSubmissionJournal(storage: _FailingStorage());
    var sent = false;
    await expectLater(
      journal.broadcast(
        chainId: 1,
        sender: sender,
        signedTx: '0x01',
        send: (_) async {
          sent = true;
        },
      ),
      throwsStateError,
    );
    expect(sent, isFalse);
  });
  test('timeout persists the original hash across restarts and blocks different bytes', () async {
    final journal = BatchSubmissionJournal();
    String? expected;
    await expectLater(
      journal.broadcast(
        chainId: 1,
        sender: sender,
        signedTx: '0x01',
        send: (hash) async {
          expected = hash;
          expect(await journal.pendingHash(1, sender), hash);
          throw StateError('timeout');
        },
      ),
      throwsStateError,
    );
    final restored = BatchSubmissionJournal();
    expect(await restored.pendingHash(1, sender), expected);
    var sent = false;
    await expectLater(
      restored.broadcast(
        chainId: 1,
        sender: sender,
        signedTx: '0x02',
        send: (_) async {
          sent = true;
        },
      ),
      throwsA(isA<BatchSubmissionPending>()),
    );
    expect(sent, isFalse);
    expect(
      await restored.resolve(1, sender, expected!, () async => false),
      isFalse,
    );
    expect(await restored.pendingHash(1, sender), expected);
    expect(
      await restored.resolve(1, sender, expected!, () async => true),
      isTrue,
    );
    expect(await restored.pendingHash(1, sender), isNull);
  });
  test('simultaneous facades admit only one submission per account', () async {
    var sends = 0;
    Future<bool> submit() async {
      try {
        await BatchSubmissionJournal().broadcast(
          chainId: 1,
          sender: sender,
          signedTx: '0x01',
          send: (_) async {
            sends++;
          },
        );
        return true;
      } on BatchSubmissionPending {
        return false;
      }
    }

    final results = await Future.wait([submit(), submit()]);
    expect(results.where((v) => v), hasLength(1));
    expect(sends, 1);
  });
  test('invalid bytes never write a pending record or call send', () async {
    final journal = BatchSubmissionJournal();
    await expectLater(
      journal.broadcast(
        chainId: 1,
        sender: sender,
        signedTx: 'bad',
        send: (_) async => fail('must not send'),
      ),
      throwsArgumentError,
    );
    expect(await journal.pendingHash(1, sender), isNull);
  });
}
