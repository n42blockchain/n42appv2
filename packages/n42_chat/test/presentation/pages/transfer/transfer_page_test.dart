import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/l10n/app_localizations.dart';
import 'package:n42_chat/src/integration/wallet_bridge.dart';
import 'package:n42_chat/src/presentation/blocs/transfer/transfer_bloc.dart';
import 'package:n42_chat/src/presentation/blocs/transfer/transfer_event.dart';
import 'package:n42_chat/src/presentation/blocs/transfer/transfer_state.dart';
import 'package:n42_chat/src/presentation/pages/transfer/transfer_page.dart';
import 'package:n42_chat/src/presentation/widgets/common/n42_button.dart';

class MockTransferBloc extends MockBloc<TransferEvent, TransferState>
    implements TransferBloc {}

class FakeTransferEvent extends Fake implements TransferEvent {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeTransferEvent());
  });

  testWidgets(
    'payment request mode keeps wallet tokens visible after address validation and dispatches fulfill event',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final bloc = MockTransferBloc();
      final request = PaymentRequest(
        requestId: 'req-42',
        amount: '12.5',
        token: 'USDT',
        receiverAddress: '0xreceiver',
        memo: 'Dinner',
        qrCodeData: 'wallet:0xreceiver?amount=12.5',
        createdAt: DateTime(2026, 3, 21, 10),
      );

      const state = TransferState(
        status: TransferBlocStatus.addressValidated,
        isWalletConnected: true,
        walletAddress: '0xsender',
        tokens: [
          TokenInfo(symbol: 'ETH', name: 'Ethereum', decimals: 18),
          TokenInfo(symbol: 'USDT', name: 'Tether USD', decimals: 6),
        ],
        balances: {'ETH': '1.0', 'USDT': '99.5'},
        validatedAddress: '0xreceiver',
        isAddressValid: true,
      );

      when(() => bloc.state).thenReturn(state);
      whenListen(bloc, Stream<TransferState>.value(state), initialState: state);
      when(() => bloc.add(any())).thenReturn(null);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: S.localizationsDelegates,
          supportedLocales: S.supportedLocales,
          locale: const Locale('en'),
          home: BlocProvider<TransferBloc>.value(
            value: bloc,
            child: TransferPage(
              roomId: '!room:server.test',
              recipientName: 'Alice',
              paymentRequest: request,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('USDT'), findsWidgets);
      expect(find.text('12.5'), findsOneWidget);
      expect(find.text('Dinner'), findsOneWidget);

      await tester.tap(find.byType(N42Button));
      await tester.pump();

      verify(
        () => bloc.add(
          const FulfillPaymentRequest(
            roomId: '!room:server.test',
            requestId: 'req-42',
            receiverAddress: '0xreceiver',
            amount: '12.5',
            token: 'USDT',
          ),
        ),
      ).called(1);
    },
  );

  testWidgets('expired payment request does not dispatch fulfill event', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final bloc = MockTransferBloc();
    final request = PaymentRequest(
      requestId: 'req-expired',
      amount: '12.5',
      token: 'USDT',
      receiverAddress: '0xreceiver',
      memo: 'Dinner',
      qrCodeData: 'wallet:0xreceiver?amount=12.5',
      createdAt: DateTime(2026, 3, 21, 10),
      expiresAt: DateTime(2000, 1, 1),
    );

    const state = TransferState(
      status: TransferBlocStatus.addressValidated,
      isWalletConnected: true,
      walletAddress: '0xsender',
      tokens: [TokenInfo(symbol: 'USDT', name: 'Tether USD', decimals: 6)],
      balances: {'USDT': '99.5'},
      validatedAddress: '0xreceiver',
      isAddressValid: true,
    );

    when(() => bloc.state).thenReturn(state);
    whenListen(bloc, Stream<TransferState>.value(state), initialState: state);
    when(() => bloc.add(any())).thenReturn(null);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: S.localizationsDelegates,
        supportedLocales: S.supportedLocales,
        locale: const Locale('en'),
        home: BlocProvider<TransferBloc>.value(
          value: bloc,
          child: TransferPage(
            roomId: '!room:server.test',
            recipientName: 'Alice',
            paymentRequest: request,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(N42Button));
    await tester.pump();

    verifyNever(
      () => bloc.add(
        const FulfillPaymentRequest(
          roomId: '!room:server.test',
          requestId: 'req-expired',
          receiverAddress: '0xreceiver',
          amount: '12.5',
          token: 'USDT',
        ),
      ),
    );
    expect(find.text('Expired'), findsOneWidget);
  });
}
