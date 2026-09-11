import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/btc_transaction_recode_model.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/transation_record_model.dart';
import 'package:n42_wallet/features/wallet/pages/transactions/transaction_detail_eth.dart';
import 'package:n42_wallet/features/wallet/pages/transactions/transaction_detail_page.dart';
import 'package:n42_wallet/features/wallet/widgets/wallet_chain_info_transactions_item.dart';
import '../../../helpers/widget_test_helpers.dart';

void main() {
  testWidgets('aggregate history opens details without a signing route', (
    tester,
  ) async {
    final tx = TransationRecordModel()
      ..from1 = 'sender'
      ..to1 = 'recipient'
      ..address = 'sender'
      ..state = 0
      ..price = BigInt.parse('900719925474099312345')
      ..txHash = 'pending-hash'
      ..coin = {
        'coinType': 'ETH',
        'blockchainType': 'Ethereum',
        'unit': 'ETH',
        'decimals': 18,
      };
    final coin = CoinModel()
      ..coin = tx.coin
      ..address = tx.address;
    await tester.pumpWidget(
      wrapForTest(
        WalletChainInfoTransactionsItem(
          type: 1,
          transactionModel: tx,
          coinModel: coin,
          readOnly: true,
          onBack: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(WalletChainInfoTransactionsItem));
    await tester.pumpAndSettle();
    expect(find.byType(TransactionDetailPage), findsOneWidget);
    expect(find.byType(TransactionDetailEth), findsNothing);
    final detail = tester.widget<TransactionDetailPage>(
      find.byType(TransactionDetailPage),
    );
    expect(detail.from, 'sender');
    expect(detail.txHash, 'pending-hash');
    expect(detail.value, '900.719925474099312345 ETH');
    expect(detail.isTest, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders legacy BTC history using the current model getters', (
    tester,
  ) async {
    final tx = BtcTransactionRecodeModel()
      ..address = 'bc1qsender'
      ..to1 = 'bc1qrecipient'
      ..price = 12345
      ..coin = {'coinType': 'BTC', 'unit': 'BTC', 'decimals': 8}
      ..inputModels = [
        InputModel()..address = ['bc1qsender'],
      ]
      ..outputModels = [
        OutputModel()..address = ['bc1qrecipient'],
      ];
    final coin = CoinModel()
      ..coin = tx.coin
      ..address = tx.address;
    await tester.pumpWidget(
      wrapForTest(
        WalletChainInfoTransactionsItem(
          type: 0,
          transactionModel: tx,
          coinModel: coin,
          onBack: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.textContaining('BTC'), findsOneWidget);
  });
}
