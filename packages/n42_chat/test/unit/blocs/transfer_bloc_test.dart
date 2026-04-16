import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/domain/entities/transfer_entity.dart';
import 'package:n42_chat/src/domain/repositories/transfer_repository.dart';
import 'package:n42_chat/src/integration/wallet_bridge.dart';
import 'package:n42_chat/src/presentation/blocs/bloc_message_keys.dart';
import 'package:n42_chat/src/presentation/blocs/transfer/transfer_bloc.dart';
import 'package:n42_chat/src/presentation/blocs/transfer/transfer_event.dart';
import 'package:n42_chat/src/presentation/blocs/transfer/transfer_state.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockTransferRepository extends Mock implements ITransferRepository {}

class MockWalletBridge extends Mock implements IWalletBridge {}

// Fallback values for mocktail argument matchers
class FakePaymentRequest extends Fake implements PaymentRequest {}

// ---------------------------------------------------------------------------
// Test fixtures
// ---------------------------------------------------------------------------

const _testWalletAddress = '0xAbCdEf0123456789AbCdEf0123456789AbCdEf01';

const _testTokens = <TokenInfo>[
  TokenInfo(symbol: 'ETH', name: 'Ethereum', decimals: 18, isNative: true),
  TokenInfo(
    symbol: 'USDT',
    name: 'Tether USD',
    decimals: 6,
    contractAddress: '0xdac17f958d2ee523a2206206994597c13d831ec7',
  ),
];

const _testBalances = <String, String>{
  'ETH': '2.5',
  'USDT': '1000.00',
};

final _testTransferSuccess = TransferEntity(
  id: 'tx-001',
  senderAddress: _testWalletAddress,
  receiverAddress: '0x1111111111111111111111111111111111111111',
  amount: '0.5',
  token: 'ETH',
  status: TransferStatus.completed,
  transactionHash: '0xabcdef1234567890',
  createdAt: DateTime(2026, 1, 1),
);

final _testTransferFailed = TransferEntity(
  id: 'tx-002',
  senderAddress: _testWalletAddress,
  receiverAddress: '0x1111111111111111111111111111111111111111',
  amount: '0.5',
  token: 'ETH',
  status: TransferStatus.failed,
  failureReason: 'Insufficient funds',
  createdAt: DateTime(2026, 1, 1),
);

final _testTransferCancelled = TransferEntity(
  id: 'tx-003',
  senderAddress: _testWalletAddress,
  receiverAddress: '0x1111111111111111111111111111111111111111',
  amount: '0.5',
  token: 'ETH',
  status: TransferStatus.cancelled,
  createdAt: DateTime(2026, 1, 1),
);

final _testPaymentRequest = PaymentRequest(
  requestId: 'pay-001',
  amount: '10.0',
  token: 'USDT',
  receiverAddress: _testWalletAddress,
  memo: 'Dinner split',
  qrCodeData: 'n42://pay?address=$_testWalletAddress&amount=10.0&token=USDT',
  createdAt: DateTime(2026, 1, 1),
);

const _testUserInfo = WalletUserInfo(
  address: '0x1111111111111111111111111111111111111111',
  username: 'alice',
  matrixUserId: '@alice:n42.io',
);

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Seed state that simulates a wallet already loaded (tokens + balances).
TransferState _walletLoadedState() {
  return const TransferState(
    status: TransferBlocStatus.walletLoaded,
    isWalletConnected: true,
    walletAddress: _testWalletAddress,
    tokens: _testTokens,
    balances: _testBalances,
  );
}

void main() {
  late MockTransferRepository mockRepository;
  late MockWalletBridge mockWalletBridge;

  setUpAll(() {
    registerFallbackValue(FakePaymentRequest());
  });

  setUp(() {
    mockRepository = MockTransferRepository();
    mockWalletBridge = MockWalletBridge();
  });

  // =========================================================================
  // TransferBloc tests
  // =========================================================================
  group('TransferBloc', () {
    // -----------------------------------------------------------------------
    // 1. Initial state
    // -----------------------------------------------------------------------
    group('initial state', () {
      test('is TransferState.initial with status == initial', () {
        final bloc = TransferBloc(mockRepository, mockWalletBridge);
        addTearDown(bloc.close);

        expect(bloc.state, equals(const TransferState.initial()));
        expect(bloc.state.status, TransferBlocStatus.initial);
        expect(bloc.state.isWalletConnected, isFalse);
        expect(bloc.state.walletAddress, isNull);
        expect(bloc.state.tokens, isEmpty);
        expect(bloc.state.balances, isEmpty);
        expect(bloc.state.lastTransfer, isNull);
        expect(bloc.state.errorMessage, isNull);
        expect(bloc.state.isProcessing, isFalse);
      });
    });

    // -----------------------------------------------------------------------
    // 2. LoadWalletInfo
    // -----------------------------------------------------------------------
    group('LoadWalletInfo', () {
      blocTest<TransferBloc, TransferState>(
        'emits walletLoaded with tokens and balances on success',
        setUp: () {
          when(() => mockWalletBridge.isWalletConnected).thenReturn(true);
          when(() => mockWalletBridge.walletAddress)
              .thenReturn(_testWalletAddress);
          when(() => mockWalletBridge.getSupportedTokens())
              .thenAnswer((_) async => _testTokens);
          when(() => mockWalletBridge.getBalance('ETH'))
              .thenAnswer((_) async => '2.5');
          when(() => mockWalletBridge.getBalance('USDT'))
              .thenAnswer((_) async => '1000.00');
        },
        build: () => TransferBloc(mockRepository, mockWalletBridge),
        act: (bloc) => bloc.add(const LoadWalletInfo()),
        expect: () => [
          isA<TransferState>()
              .having((s) => s.status, 'status',
                  TransferBlocStatus.walletLoaded)
              .having((s) => s.isWalletConnected, 'isWalletConnected', true)
              .having(
                  (s) => s.walletAddress, 'walletAddress', _testWalletAddress)
              .having((s) => s.tokens, 'tokens', _testTokens)
              .having((s) => s.balances, 'balances', _testBalances),
        ],
        verify: (_) {
          verify(() => mockWalletBridge.getSupportedTokens()).called(1);
          verify(() => mockWalletBridge.getBalance('ETH')).called(1);
          verify(() => mockWalletBridge.getBalance('USDT')).called(1);
        },
      );

      blocTest<TransferBloc, TransferState>(
        'emits walletLoaded with 0 balance when individual getBalance fails',
        setUp: () {
          when(() => mockWalletBridge.isWalletConnected).thenReturn(true);
          when(() => mockWalletBridge.walletAddress)
              .thenReturn(_testWalletAddress);
          when(() => mockWalletBridge.getSupportedTokens())
              .thenAnswer((_) async => _testTokens);
          when(() => mockWalletBridge.getBalance('ETH'))
              .thenAnswer((_) async => '2.5');
          // USDT balance fetch throws
          when(() => mockWalletBridge.getBalance('USDT'))
              .thenThrow(Exception('RPC error'));
        },
        build: () => TransferBloc(mockRepository, mockWalletBridge),
        act: (bloc) => bloc.add(const LoadWalletInfo()),
        expect: () => [
          isA<TransferState>()
              .having((s) => s.status, 'status',
                  TransferBlocStatus.walletLoaded)
              .having((s) => s.balances['ETH'], 'ETH balance', '2.5')
              .having((s) => s.balances['USDT'], 'USDT balance (fallback)', '0'),
        ],
      );

      blocTest<TransferBloc, TransferState>(
        'emits failure when getSupportedTokens throws',
        setUp: () {
          when(() => mockWalletBridge.isWalletConnected).thenReturn(true);
          when(() => mockWalletBridge.walletAddress)
              .thenReturn(_testWalletAddress);
          when(() => mockWalletBridge.getSupportedTokens())
              .thenThrow(Exception('Network error'));
        },
        build: () => TransferBloc(mockRepository, mockWalletBridge),
        act: (bloc) => bloc.add(const LoadWalletInfo()),
        expect: () => [
          isA<TransferState>()
              .having(
                  (s) => s.status, 'status', TransferBlocStatus.failure)
              .having((s) => s.errorMessage, 'errorMessage', isNotNull),
        ],
      );

      blocTest<TransferBloc, TransferState>(
        'reports wallet disconnected when isWalletConnected is false',
        setUp: () {
          when(() => mockWalletBridge.isWalletConnected).thenReturn(false);
          when(() => mockWalletBridge.walletAddress).thenReturn(null);
          when(() => mockWalletBridge.getSupportedTokens())
              .thenAnswer((_) async => []);
        },
        build: () => TransferBloc(mockRepository, mockWalletBridge),
        act: (bloc) => bloc.add(const LoadWalletInfo()),
        expect: () => [
          isA<TransferState>()
              .having((s) => s.status, 'status',
                  TransferBlocStatus.walletLoaded)
              .having((s) => s.isWalletConnected, 'isWalletConnected', false)
              .having((s) => s.walletAddress, 'walletAddress', isNull)
              .having((s) => s.tokens, 'tokens', isEmpty),
        ],
      );
    });

    // -----------------------------------------------------------------------
    // 3. LoadTokens
    // -----------------------------------------------------------------------
    group('LoadTokens', () {
      blocTest<TransferBloc, TransferState>(
        'delegates to LoadWalletInfo when status is initial',
        setUp: () {
          // LoadWalletInfo will be triggered internally, so we need to stub it
          when(() => mockWalletBridge.isWalletConnected).thenReturn(true);
          when(() => mockWalletBridge.walletAddress)
              .thenReturn(_testWalletAddress);
          when(() => mockWalletBridge.getSupportedTokens())
              .thenAnswer((_) async => _testTokens);
          when(() => mockWalletBridge.getBalance(any()))
              .thenAnswer((_) async => '0');
        },
        build: () => TransferBloc(mockRepository, mockWalletBridge),
        act: (bloc) => bloc.add(const LoadTokens()),
        // When status==initial, LoadTokens adds LoadWalletInfo internally,
        // so we expect the walletLoaded emission from LoadWalletInfo.
        expect: () => [
          isA<TransferState>().having(
              (s) => s.status, 'status', TransferBlocStatus.walletLoaded),
        ],
      );

      blocTest<TransferBloc, TransferState>(
        'loads tokens from repository when wallet is already loaded',
        setUp: () {
          when(() => mockRepository.getSupportedTokens())
              .thenAnswer((_) async => _testTokens);
        },
        build: () => TransferBloc(mockRepository, mockWalletBridge),
        // Seed with empty tokens so the newly-loaded tokens differ from seed,
        // avoiding Equatable dedup suppression.
        seed: () => _walletLoadedState().copyWith(tokens: const []),
        act: (bloc) => bloc.add(const LoadTokens()),
        expect: () => [
          isA<TransferState>()
              .having((s) => s.tokens, 'tokens', _testTokens),
        ],
      );

      blocTest<TransferBloc, TransferState>(
        'emits failure when repository.getSupportedTokens throws',
        setUp: () {
          when(() => mockRepository.getSupportedTokens())
              .thenThrow(Exception('fetch failed'));
        },
        build: () => TransferBloc(mockRepository, mockWalletBridge),
        seed: () => _walletLoadedState(),
        act: (bloc) => bloc.add(const LoadTokens()),
        expect: () => [
          isA<TransferState>()
              .having((s) => s.status, 'status', TransferBlocStatus.failure)
              .having((s) => s.errorMessage, 'errorMessage', isNotNull),
        ],
      );
    });

    // -----------------------------------------------------------------------
    // 4. LoadTokenBalance
    // -----------------------------------------------------------------------
    group('LoadTokenBalance', () {
      blocTest<TransferBloc, TransferState>(
        'updates balance for a specific token',
        setUp: () {
          when(() => mockRepository.getTokenBalance('ETH'))
              .thenAnswer((_) async => '3.14');
        },
        build: () => TransferBloc(mockRepository, mockWalletBridge),
        seed: () => _walletLoadedState(),
        act: (bloc) => bloc.add(const LoadTokenBalance('ETH')),
        expect: () => [
          isA<TransferState>()
              .having((s) => s.balances['ETH'], 'ETH balance', '3.14')
              // USDT balance should be preserved
              .having((s) => s.balances['USDT'], 'USDT balance', '1000.00'),
        ],
      );

      blocTest<TransferBloc, TransferState>(
        'emits nothing when getTokenBalance throws (silently ignores)',
        setUp: () {
          when(() => mockRepository.getTokenBalance('ETH'))
              .thenThrow(Exception('RPC timeout'));
        },
        build: () => TransferBloc(mockRepository, mockWalletBridge),
        seed: () => _walletLoadedState(),
        act: (bloc) => bloc.add(const LoadTokenBalance('ETH')),
        expect: () => <TransferState>[],
      );
    });

    // -----------------------------------------------------------------------
    // 5. ValidateAddress
    // -----------------------------------------------------------------------
    group('ValidateAddress', () {
      const validAddress = '0x1111111111111111111111111111111111111111';
      const invalidAddress = 'not-an-address';

      blocTest<TransferBloc, TransferState>(
        'emits addressValidated with isAddressValid=true and userInfo on valid address',
        setUp: () {
          when(() => mockRepository.isValidAddress(validAddress))
              .thenReturn(true);
          when(() => mockWalletBridge.getUserInfoByAddress(validAddress))
              .thenAnswer((_) async => _testUserInfo);
        },
        build: () => TransferBloc(mockRepository, mockWalletBridge),
        seed: () => _walletLoadedState(),
        act: (bloc) => bloc.add(const ValidateAddress(validAddress)),
        expect: () => [
          isA<TransferState>()
              .having((s) => s.status, 'status',
                  TransferBlocStatus.addressValidated)
              .having((s) => s.validatedAddress, 'validatedAddress',
                  validAddress)
              .having((s) => s.isAddressValid, 'isAddressValid', true)
              .having((s) => s.userInfo, 'userInfo', _testUserInfo)
              // wallet data preserved
              .having((s) => s.tokens, 'tokens', _testTokens)
              .having((s) => s.balances, 'balances', _testBalances),
        ],
      );

      blocTest<TransferBloc, TransferState>(
        'emits addressValidated with isAddressValid=false on invalid address',
        setUp: () {
          when(() => mockRepository.isValidAddress(invalidAddress))
              .thenReturn(false);
        },
        build: () => TransferBloc(mockRepository, mockWalletBridge),
        seed: () => _walletLoadedState(),
        act: (bloc) => bloc.add(const ValidateAddress(invalidAddress)),
        expect: () => [
          isA<TransferState>()
              .having((s) => s.status, 'status',
                  TransferBlocStatus.addressValidated)
              .having(
                  (s) => s.validatedAddress, 'validatedAddress', invalidAddress)
              .having((s) => s.isAddressValid, 'isAddressValid', false)
              .having((s) => s.userInfo, 'userInfo', isNull),
        ],
        verify: (_) {
          // getUserInfoByAddress should NOT be called for invalid addresses
          verifyNever(
              () => mockWalletBridge.getUserInfoByAddress(any()));
        },
      );

      blocTest<TransferBloc, TransferState>(
        'emits addressValidated with null userInfo when lookup returns null',
        setUp: () {
          when(() => mockRepository.isValidAddress(validAddress))
              .thenReturn(true);
          when(() => mockWalletBridge.getUserInfoByAddress(validAddress))
              .thenAnswer((_) async => null);
        },
        build: () => TransferBloc(mockRepository, mockWalletBridge),
        act: (bloc) => bloc.add(const ValidateAddress(validAddress)),
        expect: () => [
          isA<TransferState>()
              .having((s) => s.isAddressValid, 'isAddressValid', true)
              .having((s) => s.userInfo, 'userInfo', isNull),
        ],
      );
    });

    // -----------------------------------------------------------------------
    // 6. InitiateTransfer
    // -----------------------------------------------------------------------
    group('InitiateTransfer', () {
      const event = InitiateTransfer(
        roomId: '!room:server',
        receiverAddress: '0x1111111111111111111111111111111111111111',
        amount: '0.5',
        token: 'ETH',
        memo: 'test transfer',
      );

      blocTest<TransferBloc, TransferState>(
        'emits [processing, success] with lastTransfer on successful transfer',
        setUp: () {
          when(() => mockRepository.initiateTransfer(
                roomId: any(named: 'roomId'),
                receiverAddress: any(named: 'receiverAddress'),
                amount: any(named: 'amount'),
                token: any(named: 'token'),
                memo: any(named: 'memo'),
              )).thenAnswer((_) async => _testTransferSuccess);
        },
        build: () => TransferBloc(mockRepository, mockWalletBridge),
        seed: () => _walletLoadedState(),
        act: (bloc) => bloc.add(event),
        expect: () => [
          // First: processing state
          isA<TransferState>()
              .having(
                  (s) => s.status, 'status', TransferBlocStatus.processing)
              .having((s) => s.processingMessage, 'processingMessage',
                  BlocMessageKeys.transferProcessing)
              .having((s) => s.isProcessing, 'isProcessing', true),
          // Second: success state
          isA<TransferState>()
              .having(
                  (s) => s.status, 'status', TransferBlocStatus.success)
              .having((s) => s.lastTransfer, 'lastTransfer',
                  _testTransferSuccess)
              .having((s) => s.isProcessing, 'isProcessing', false),
        ],
        verify: (_) {
          verify(() => mockRepository.initiateTransfer(
                roomId: '!room:server',
                receiverAddress:
                    '0x1111111111111111111111111111111111111111',
                amount: '0.5',
                token: 'ETH',
                memo: 'test transfer',
              )).called(1);
        },
      );

      blocTest<TransferBloc, TransferState>(
        'emits [processing, failure] with errorMessage on failed transfer',
        setUp: () {
          when(() => mockRepository.initiateTransfer(
                roomId: any(named: 'roomId'),
                receiverAddress: any(named: 'receiverAddress'),
                amount: any(named: 'amount'),
                token: any(named: 'token'),
                memo: any(named: 'memo'),
              )).thenAnswer((_) async => _testTransferFailed);
        },
        build: () => TransferBloc(mockRepository, mockWalletBridge),
        seed: () => _walletLoadedState(),
        act: (bloc) => bloc.add(event),
        expect: () => [
          isA<TransferState>()
              .having(
                  (s) => s.status, 'status', TransferBlocStatus.processing),
          isA<TransferState>()
              .having(
                  (s) => s.status, 'status', TransferBlocStatus.failure)
              .having((s) => s.errorMessage, 'errorMessage',
                  'Insufficient funds'),
        ],
      );

      blocTest<TransferBloc, TransferState>(
        'emits [processing, failure] with "Transfer cancelled" on cancelled transfer',
        setUp: () {
          when(() => mockRepository.initiateTransfer(
                roomId: any(named: 'roomId'),
                receiverAddress: any(named: 'receiverAddress'),
                amount: any(named: 'amount'),
                token: any(named: 'token'),
                memo: any(named: 'memo'),
              )).thenAnswer((_) async => _testTransferCancelled);
        },
        build: () => TransferBloc(mockRepository, mockWalletBridge),
        seed: () => _walletLoadedState(),
        act: (bloc) => bloc.add(event),
        expect: () => [
          isA<TransferState>()
              .having(
                  (s) => s.status, 'status', TransferBlocStatus.processing),
          isA<TransferState>()
              .having(
                  (s) => s.status, 'status', TransferBlocStatus.failure)
              .having((s) => s.errorMessage, 'errorMessage',
                  BlocMessageKeys.transferCancelled),
        ],
      );

      blocTest<TransferBloc, TransferState>(
        'emits [processing, failure] when repository throws an exception',
        setUp: () {
          when(() => mockRepository.initiateTransfer(
                roomId: any(named: 'roomId'),
                receiverAddress: any(named: 'receiverAddress'),
                amount: any(named: 'amount'),
                token: any(named: 'token'),
                memo: any(named: 'memo'),
              )).thenThrow(Exception('Blockchain RPC timeout'));
        },
        build: () => TransferBloc(mockRepository, mockWalletBridge),
        seed: () => _walletLoadedState(),
        act: (bloc) => bloc.add(event),
        expect: () => [
          isA<TransferState>()
              .having(
                  (s) => s.status, 'status', TransferBlocStatus.processing),
          isA<TransferState>()
              .having(
                  (s) => s.status, 'status', TransferBlocStatus.failure)
              .having((s) => s.errorMessage, 'errorMessage',
                  contains('Blockchain RPC timeout')),
        ],
      );

      blocTest<TransferBloc, TransferState>(
        'emits [processing, failure] with generic message when failureReason is null',
        setUp: () {
          final transferNoReason = TransferEntity(
            id: 'tx-no-reason',
            senderAddress: _testWalletAddress,
            receiverAddress: '0x1111111111111111111111111111111111111111',
            amount: '0.5',
            token: 'ETH',
            status: TransferStatus.failed,
            failureReason: null,
            createdAt: DateTime(2026, 1, 1),
          );
          when(() => mockRepository.initiateTransfer(
                roomId: any(named: 'roomId'),
                receiverAddress: any(named: 'receiverAddress'),
                amount: any(named: 'amount'),
                token: any(named: 'token'),
                memo: any(named: 'memo'),
              )).thenAnswer((_) async => transferNoReason);
        },
        build: () => TransferBloc(mockRepository, mockWalletBridge),
        seed: () => _walletLoadedState(),
        act: (bloc) => bloc.add(event),
        expect: () => [
          isA<TransferState>()
              .having(
                  (s) => s.status, 'status', TransferBlocStatus.processing),
          isA<TransferState>()
              .having(
                  (s) => s.status, 'status', TransferBlocStatus.failure)
              .having((s) => s.errorMessage, 'errorMessage',
                  BlocMessageKeys.transferFailed),
        ],
      );
    });

    // -----------------------------------------------------------------------
    // 7. CreatePaymentRequest
    // -----------------------------------------------------------------------
    group('CreatePaymentRequest', () {
      const event = CreatePaymentRequest(
        roomId: '!room:server',
        amount: '10.0',
        token: 'USDT',
        memo: 'Dinner split',
      );

      blocTest<TransferBloc, TransferState>(
        'emits [processing, paymentCreated] with paymentRequest on success',
        setUp: () {
          when(() => mockRepository.createPaymentRequest(
                amount: any(named: 'amount'),
                token: any(named: 'token'),
                memo: any(named: 'memo'),
              )).thenAnswer((_) async => _testPaymentRequest);
          when(() => mockRepository.sendPaymentRequestMessage(
                roomId: any(named: 'roomId'),
                request: any(named: 'request'),
              )).thenAnswer((_) async => 'msg-id-123');
        },
        build: () => TransferBloc(mockRepository, mockWalletBridge),
        seed: () => _walletLoadedState(),
        act: (bloc) => bloc.add(event),
        expect: () => [
          isA<TransferState>()
              .having(
                  (s) => s.status, 'status', TransferBlocStatus.processing)
              .having((s) => s.processingMessage, 'processingMessage',
                  BlocMessageKeys.paymentProcessing),
          isA<TransferState>()
              .having((s) => s.status, 'status',
                  TransferBlocStatus.paymentCreated)
              .having((s) => s.paymentRequest, 'paymentRequest',
                  _testPaymentRequest),
        ],
        verify: (_) {
          verify(() => mockRepository.createPaymentRequest(
                amount: '10.0',
                token: 'USDT',
                memo: 'Dinner split',
              )).called(1);
          verify(() => mockRepository.sendPaymentRequestMessage(
                roomId: '!room:server',
                request: any(named: 'request'),
              )).called(1);
        },
      );

      blocTest<TransferBloc, TransferState>(
        'emits [processing, failure] when createPaymentRequest throws',
        setUp: () {
          when(() => mockRepository.createPaymentRequest(
                amount: any(named: 'amount'),
                token: any(named: 'token'),
                memo: any(named: 'memo'),
              )).thenThrow(Exception('server error'));
        },
        build: () => TransferBloc(mockRepository, mockWalletBridge),
        seed: () => _walletLoadedState(),
        act: (bloc) => bloc.add(event),
        expect: () => [
          isA<TransferState>()
              .having(
                  (s) => s.status, 'status', TransferBlocStatus.processing),
          isA<TransferState>()
              .having(
                  (s) => s.status, 'status', TransferBlocStatus.failure)
              .having((s) => s.errorMessage, 'errorMessage',
                  contains('server error')),
        ],
      );

      blocTest<TransferBloc, TransferState>(
        'emits [processing, failure] when sendPaymentRequestMessage throws',
        setUp: () {
          when(() => mockRepository.createPaymentRequest(
                amount: any(named: 'amount'),
                token: any(named: 'token'),
                memo: any(named: 'memo'),
              )).thenAnswer((_) async => _testPaymentRequest);
          when(() => mockRepository.sendPaymentRequestMessage(
                roomId: any(named: 'roomId'),
                request: any(named: 'request'),
              )).thenThrow(Exception('message send failed'));
        },
        build: () => TransferBloc(mockRepository, mockWalletBridge),
        seed: () => _walletLoadedState(),
        act: (bloc) => bloc.add(event),
        expect: () => [
          isA<TransferState>()
              .having(
                  (s) => s.status, 'status', TransferBlocStatus.processing),
          isA<TransferState>()
              .having(
                  (s) => s.status, 'status', TransferBlocStatus.failure)
              .having((s) => s.errorMessage, 'errorMessage',
                  contains('message send failed')),
        ],
      );
    });

    // -----------------------------------------------------------------------
    // 8. FulfillPaymentRequest
    // -----------------------------------------------------------------------
    group('FulfillPaymentRequest', () {
      const event = FulfillPaymentRequest(
        roomId: '!room:server',
        requestId: 'pay-001',
        receiverAddress: '0x1111111111111111111111111111111111111111',
        amount: '10.0',
        token: 'USDT',
      );

      blocTest<TransferBloc, TransferState>(
        'emits [processing, success] on successful fulfillment',
        setUp: () {
          when(() => mockRepository.fulfillPaymentRequest(
                roomId: any(named: 'roomId'),
                requestId: any(named: 'requestId'),
                receiverAddress: any(named: 'receiverAddress'),
                amount: any(named: 'amount'),
                token: any(named: 'token'),
              )).thenAnswer((_) async => _testTransferSuccess);
        },
        build: () => TransferBloc(mockRepository, mockWalletBridge),
        seed: () => _walletLoadedState(),
        act: (bloc) => bloc.add(event),
        expect: () => [
          isA<TransferState>()
              .having(
                  (s) => s.status, 'status', TransferBlocStatus.processing)
              .having((s) => s.processingMessage, 'processingMessage',
                  BlocMessageKeys.paymentProcessing),
          isA<TransferState>()
              .having(
                  (s) => s.status, 'status', TransferBlocStatus.success)
              .having((s) => s.lastTransfer, 'lastTransfer',
                  _testTransferSuccess),
        ],
      );

      blocTest<TransferBloc, TransferState>(
        'emits [processing, failure] on failed fulfillment',
        setUp: () {
          when(() => mockRepository.fulfillPaymentRequest(
                roomId: any(named: 'roomId'),
                requestId: any(named: 'requestId'),
                receiverAddress: any(named: 'receiverAddress'),
                amount: any(named: 'amount'),
                token: any(named: 'token'),
              )).thenAnswer((_) async => _testTransferFailed);
        },
        build: () => TransferBloc(mockRepository, mockWalletBridge),
        seed: () => _walletLoadedState(),
        act: (bloc) => bloc.add(event),
        expect: () => [
          isA<TransferState>()
              .having(
                  (s) => s.status, 'status', TransferBlocStatus.processing),
          isA<TransferState>()
              .having(
                  (s) => s.status, 'status', TransferBlocStatus.failure)
              .having((s) => s.errorMessage, 'errorMessage',
                  'Insufficient funds'),
        ],
      );

      blocTest<TransferBloc, TransferState>(
        'emits [processing, failure] with generic message when failureReason is null',
        setUp: () {
          final failedNoReason = TransferEntity(
            id: 'tx-no-reason',
            senderAddress: _testWalletAddress,
            receiverAddress: '0x1111111111111111111111111111111111111111',
            amount: '10.0',
            token: 'USDT',
            status: TransferStatus.failed,
            failureReason: null,
            createdAt: DateTime(2026, 1, 1),
          );
          when(() => mockRepository.fulfillPaymentRequest(
                roomId: any(named: 'roomId'),
                requestId: any(named: 'requestId'),
                receiverAddress: any(named: 'receiverAddress'),
                amount: any(named: 'amount'),
                token: any(named: 'token'),
              )).thenAnswer((_) async => failedNoReason);
        },
        build: () => TransferBloc(mockRepository, mockWalletBridge),
        seed: () => _walletLoadedState(),
        act: (bloc) => bloc.add(event),
        expect: () => [
          isA<TransferState>()
              .having(
                  (s) => s.status, 'status', TransferBlocStatus.processing),
          isA<TransferState>()
              .having(
                  (s) => s.status, 'status', TransferBlocStatus.failure)
              .having(
                  (s) => s.errorMessage, 'errorMessage', BlocMessageKeys.paymentFailed),
        ],
      );

      blocTest<TransferBloc, TransferState>(
        'emits [processing, failure] when repository throws',
        setUp: () {
          when(() => mockRepository.fulfillPaymentRequest(
                roomId: any(named: 'roomId'),
                requestId: any(named: 'requestId'),
                receiverAddress: any(named: 'receiverAddress'),
                amount: any(named: 'amount'),
                token: any(named: 'token'),
              )).thenThrow(Exception('Unexpected error'));
        },
        build: () => TransferBloc(mockRepository, mockWalletBridge),
        seed: () => _walletLoadedState(),
        act: (bloc) => bloc.add(event),
        expect: () => [
          isA<TransferState>()
              .having(
                  (s) => s.status, 'status', TransferBlocStatus.processing),
          isA<TransferState>()
              .having(
                  (s) => s.status, 'status', TransferBlocStatus.failure)
              .having((s) => s.errorMessage, 'errorMessage',
                  contains('Unexpected error')),
        ],
      );
    });

    // -----------------------------------------------------------------------
    // 9. ClearTransferState
    // -----------------------------------------------------------------------
    group('ClearTransferState', () {
      blocTest<TransferBloc, TransferState>(
        'delegates to LoadWalletInfo (re-loads wallet)',
        setUp: () {
          when(() => mockWalletBridge.isWalletConnected).thenReturn(true);
          when(() => mockWalletBridge.walletAddress)
              .thenReturn(_testWalletAddress);
          when(() => mockWalletBridge.getSupportedTokens())
              .thenAnswer((_) async => _testTokens);
          when(() => mockWalletBridge.getBalance('ETH'))
              .thenAnswer((_) async => '2.5');
          when(() => mockWalletBridge.getBalance('USDT'))
              .thenAnswer((_) async => '1000.00');
        },
        build: () => TransferBloc(mockRepository, mockWalletBridge),
        seed: () => _walletLoadedState().copyWith(
          status: TransferBlocStatus.failure,
          errorMessage: 'some old error',
        ),
        act: (bloc) => bloc.add(const ClearTransferState()),
        expect: () => [
          // LoadWalletInfo is triggered, emitting walletLoaded
          isA<TransferState>()
              .having((s) => s.status, 'status',
                  TransferBlocStatus.walletLoaded)
              .having((s) => s.isWalletConnected, 'isWalletConnected', true),
        ],
      );
    });

    // -----------------------------------------------------------------------
    // 10. State preservation: wallet info survives errors
    // -----------------------------------------------------------------------
    group('state preservation', () {
      blocTest<TransferBloc, TransferState>(
        'tokens and balances are preserved after a transfer failure',
        setUp: () {
          when(() => mockRepository.initiateTransfer(
                roomId: any(named: 'roomId'),
                receiverAddress: any(named: 'receiverAddress'),
                amount: any(named: 'amount'),
                token: any(named: 'token'),
                memo: any(named: 'memo'),
              )).thenThrow(Exception('Transfer boom'));
        },
        build: () => TransferBloc(mockRepository, mockWalletBridge),
        seed: () => _walletLoadedState(),
        act: (bloc) => bloc.add(const InitiateTransfer(
          roomId: '!room:server',
          receiverAddress: '0x1111111111111111111111111111111111111111',
          amount: '1.0',
          token: 'ETH',
        )),
        expect: () => [
          // processing: tokens/balances preserved
          isA<TransferState>()
              .having(
                  (s) => s.status, 'status', TransferBlocStatus.processing)
              .having((s) => s.tokens, 'tokens', _testTokens)
              .having((s) => s.balances, 'balances', _testBalances)
              .having(
                  (s) => s.isWalletConnected, 'isWalletConnected', true),
          // failure: tokens/balances still preserved
          isA<TransferState>()
              .having(
                  (s) => s.status, 'status', TransferBlocStatus.failure)
              .having((s) => s.tokens, 'tokens', _testTokens)
              .having((s) => s.balances, 'balances', _testBalances)
              .having(
                  (s) => s.isWalletConnected, 'isWalletConnected', true)
              .having(
                  (s) => s.walletAddress, 'walletAddress', _testWalletAddress),
        ],
      );

      blocTest<TransferBloc, TransferState>(
        'tokens and balances are preserved after a payment request failure',
        setUp: () {
          when(() => mockRepository.createPaymentRequest(
                amount: any(named: 'amount'),
                token: any(named: 'token'),
                memo: any(named: 'memo'),
              )).thenThrow(Exception('Payment boom'));
        },
        build: () => TransferBloc(mockRepository, mockWalletBridge),
        seed: () => _walletLoadedState(),
        act: (bloc) => bloc.add(const CreatePaymentRequest(
          roomId: '!room:server',
          amount: '5.0',
          token: 'USDT',
        )),
        expect: () => [
          isA<TransferState>()
              .having(
                  (s) => s.status, 'status', TransferBlocStatus.processing)
              .having((s) => s.tokens, 'tokens', _testTokens)
              .having((s) => s.balances, 'balances', _testBalances),
          isA<TransferState>()
              .having(
                  (s) => s.status, 'status', TransferBlocStatus.failure)
              .having((s) => s.tokens, 'tokens', _testTokens)
              .having((s) => s.balances, 'balances', _testBalances),
        ],
      );

      blocTest<TransferBloc, TransferState>(
        'wallet address and connection status survive address validation',
        setUp: () {
          when(() => mockRepository.isValidAddress(any())).thenReturn(true);
          when(() => mockWalletBridge.getUserInfoByAddress(any()))
              .thenAnswer((_) async => _testUserInfo);
        },
        build: () => TransferBloc(mockRepository, mockWalletBridge),
        seed: () => _walletLoadedState(),
        act: (bloc) => bloc.add(const ValidateAddress(
            '0x1111111111111111111111111111111111111111')),
        expect: () => [
          isA<TransferState>()
              .having((s) => s.status, 'status',
                  TransferBlocStatus.addressValidated)
              .having(
                  (s) => s.isWalletConnected, 'isWalletConnected', true)
              .having(
                  (s) => s.walletAddress, 'walletAddress', _testWalletAddress)
              .having((s) => s.tokens, 'tokens', _testTokens)
              .having((s) => s.balances, 'balances', _testBalances),
        ],
      );
    });

    // -----------------------------------------------------------------------
    // 11. TransferState unit tests (copyWith, equality, computed getters)
    // -----------------------------------------------------------------------
    group('TransferState', () {
      test('initial() has correct defaults', () {
        const state = TransferState.initial();
        expect(state.status, TransferBlocStatus.initial);
        expect(state.isWalletConnected, false);
        expect(state.walletAddress, isNull);
        expect(state.tokens, isEmpty);
        expect(state.balances, isEmpty);
        expect(state.lastTransfer, isNull);
        expect(state.errorMessage, isNull);
        expect(state.validatedAddress, isNull);
        expect(state.isAddressValid, isNull);
        expect(state.userInfo, isNull);
        expect(state.paymentRequest, isNull);
        expect(state.processingMessage, isNull);
      });

      test('isProcessing returns true only when status is processing', () {
        const initial = TransferState.initial();
        expect(initial.isProcessing, false);

        final processing = initial.copyWith(
          status: TransferBlocStatus.processing,
        );
        expect(processing.isProcessing, true);

        final success = initial.copyWith(
          status: TransferBlocStatus.success,
        );
        expect(success.isProcessing, false);
      });

      test('isWalletLoaded returns true for walletLoaded or isWalletConnected', () {
        const initial = TransferState.initial();
        expect(initial.isWalletLoaded, false);

        final loaded = initial.copyWith(
          status: TransferBlocStatus.walletLoaded,
        );
        expect(loaded.isWalletLoaded, true);

        // isWalletConnected=true with a different status should also be true
        final connected = initial.copyWith(
          status: TransferBlocStatus.success,
          isWalletConnected: true,
        );
        expect(connected.isWalletLoaded, true);
      });

      test('copyWith preserves tokens and balances when not provided', () {
        final state = _walletLoadedState();
        final updated = state.copyWith(
          status: TransferBlocStatus.failure,
          errorMessage: 'Error',
        );

        expect(updated.tokens, _testTokens);
        expect(updated.balances, _testBalances);
        expect(updated.isWalletConnected, true);
        expect(updated.walletAddress, _testWalletAddress);
      });

      test('copyWith clears nullable fields when not explicitly passed', () {
        final state = _walletLoadedState().copyWith(
          lastTransfer: _testTransferSuccess,
          errorMessage: 'some error',
          processingMessage: 'working...',
        );
        expect(state.lastTransfer, _testTransferSuccess);
        expect(state.errorMessage, 'some error');

        // copyWith without passing those fields => they become null
        final cleared = state.copyWith(
          status: TransferBlocStatus.walletLoaded,
        );
        expect(cleared.lastTransfer, isNull);
        expect(cleared.errorMessage, isNull);
        expect(cleared.processingMessage, isNull);
      });

      test('equality: two states with same values are equal', () {
        const a = TransferState(
          status: TransferBlocStatus.walletLoaded,
          isWalletConnected: true,
          walletAddress: '0x123',
          tokens: _testTokens,
          balances: _testBalances,
        );
        const b = TransferState(
          status: TransferBlocStatus.walletLoaded,
          isWalletConnected: true,
          walletAddress: '0x123',
          tokens: _testTokens,
          balances: _testBalances,
        );
        expect(a, equals(b));
      });

      test('equality: different status means different states', () {
        const a = TransferState(status: TransferBlocStatus.initial);
        const b = TransferState(status: TransferBlocStatus.walletLoaded);
        expect(a, isNot(equals(b)));
      });

      test('toString includes status and connected flag', () {
        const state = TransferState(
          status: TransferBlocStatus.walletLoaded,
          isWalletConnected: true,
        );
        expect(state.toString(),
            contains('TransferBlocStatus.walletLoaded'));
        expect(state.toString(), contains('connected: true'));
      });
    });

    // -----------------------------------------------------------------------
    // 12. Event equality and props
    // -----------------------------------------------------------------------
    group('TransferEvent props', () {
      test('LoadWalletInfo events are equal', () {
        expect(const LoadWalletInfo(), equals(const LoadWalletInfo()));
      });

      test('LoadTokens events are equal', () {
        expect(const LoadTokens(), equals(const LoadTokens()));
      });

      test('LoadTokenBalance events with same token are equal', () {
        expect(
          const LoadTokenBalance('ETH'),
          equals(const LoadTokenBalance('ETH')),
        );
      });

      test('LoadTokenBalance events with different tokens are not equal', () {
        expect(
          const LoadTokenBalance('ETH'),
          isNot(equals(const LoadTokenBalance('USDT'))),
        );
      });

      test('InitiateTransfer props include all fields', () {
        const event = InitiateTransfer(
          roomId: 'room',
          receiverAddress: '0x1',
          amount: '1.0',
          token: 'ETH',
          memo: 'test',
        );
        expect(event.props, ['room', '0x1', '1.0', 'ETH', 'test']);
      });

      test('CreatePaymentRequest props include all fields', () {
        const event = CreatePaymentRequest(
          roomId: 'room',
          amount: '5.0',
          token: 'USDT',
          memo: 'dinner',
        );
        expect(event.props, ['room', '5.0', 'USDT', 'dinner']);
      });

      test('ValidateAddress props include address', () {
        const event = ValidateAddress('0xabc');
        expect(event.props, ['0xabc']);
      });

      test('ClearTransferState events are equal', () {
        expect(
            const ClearTransferState(), equals(const ClearTransferState()));
      });

      test('FulfillPaymentRequest props include all fields', () {
        const event = FulfillPaymentRequest(
          roomId: 'room',
          requestId: 'req-1',
          receiverAddress: '0x1',
          amount: '10.0',
          token: 'USDT',
        );
        expect(event.props, ['room', 'req-1', '0x1', '10.0', 'USDT']);
      });
    });
  });
}
