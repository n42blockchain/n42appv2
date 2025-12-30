import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/src/component/enums/coin_type.dart';
import 'package:n42appv2/src/sqlite/app_database.dart';
import 'package:n42appv2/src/wallet/models/btc_transaction_recode_model.dart';
import 'package:n42appv2/src/wallet/models/coin_model.dart';
import 'package:n42appv2/src/wallet/models/transation_record_model.dart';
import 'package:n42appv2/src/wallet/widgets/wallet_chain_info_transactions_item.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:n42appv2/src/widgets/base_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/generated/l10n.dart';

class TransactionHistoryList extends StatefulWidget {
  CoinModel coinModel;
  TransactionHistoryList(this.coinModel,{super.key});

  @override
  State<TransactionHistoryList> createState() => _TransactionHistoryListState();
}

class _TransactionHistoryListState extends State<TransactionHistoryList> {
  AppDatabase? _db;
  AppDatabase get db{
    if(_db==null){
      _db=AppDatabase();
    }
    return _db!;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_coin_key_1,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
          child: BaseList(
            buildItem: (BuildContext context, List<dynamic> results, int index) {
              if (widget.coinModel.coin['blockchainType'] ==
                  BlockchainType.Bitcoin.name) {

                BtcTransactionRecodeModel trm = results[index];
                return WalletChainInfoTransactionsItem(
                  coinModel: widget.coinModel,
                    type: 0, transactionModel: trm);
              } else {
                TransationRecordModel trm = results[index];
                return WalletChainInfoTransactionsItem(
                  type: 1, transactionModel: trm,coinModel: widget.coinModel,onBack: (){
                },);
              }
            },
            getData: (int page, int pageSize) async {
              var txList;
              String addr = widget.coinModel?.address.toString() ?? "";
              String coinKey = widget.coinModel.coin['coinType'];
              String contract = widget.coinModel.coin['contract'];
              if (widget.coinModel.coin['blockchainType'] ==
                  BlockchainType.Bitcoin.name) {
                txList = await db
                    .selectBtcTransationRecord(
                    AppGlobals.userInfo?.uuid ?? "", addr, coinKey, 0,
                    pageSize: pageSize, pageNum: page);
              } else {
                txList = await db
                    .selectTransationRecord_miniName(addr, coinKey, 0,
                    contract: contract,
                    pageSize: pageSize,
                    pageNum: page,
                    isTest: widget.coinModel.isTest ? 1 : 0);
              }
              return txList;
            },
            firstRefresh: true,
            pageIndex: 1,
            pageSize: 5,
            mainAxisSpacing: ScreenUtil().setWidth(30.0),
          ),
        ),
      ),
    );
  }
}
