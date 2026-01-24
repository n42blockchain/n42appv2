import 'dart:async';
import 'dart:convert';

import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/src/browser/pages/browser_page.dart';
import 'package:n42appv2/src/component/enums/coin_type.dart';
import 'package:n42appv2/src/component/enums/load.dart';
import 'package:n42appv2/src/models/message_model.dart';
import 'package:n42appv2/src/pay/moonpay/moonpay.dart';
import 'package:n42appv2/src/sqlite/app_database.dart';
import 'package:n42appv2/core/utils/event_bus.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/core/utils/toast_utils.dart';
import 'package:n42appv2/src/wallet/api/chain_api/xrp_api.dart';
import 'package:n42appv2/src/wallet/api/transaction_api.dart';
import 'package:n42appv2/src/wallet/models/btc_transaction_recode_model.dart';
import 'package:n42appv2/src/wallet/models/coin_model.dart';
import 'package:n42appv2/src/wallet/models/transaction/btc_tran_detail.dart';
import 'package:n42appv2/src/wallet/models/transaction/common_response_item_model.dart';
import 'package:n42appv2/src/wallet/models/transation_record_model.dart';
import 'package:n42appv2/src/wallet/pages/add_token/wallet_coin_token_add2.dart';
import 'package:n42appv2/src/wallet/pages/market/market_coin_info.dart';
import 'package:n42appv2/src/wallet/pages/send/wallet_chain_send.dart';
import 'package:n42appv2/src/wallet/pages/send/wallet_chain_send_algo.dart';
import 'package:n42appv2/src/wallet/pages/send/wallet_chain_send_btc.dart';
import 'package:n42appv2/src/wallet/pages/send/wallet_chain_send_fil.dart';
import 'package:n42appv2/src/wallet/pages/send/wallet_chain_send_sol.dart';
import 'package:n42appv2/src/wallet/pages/send/wallet_chain_send_trx.dart';
import 'package:n42appv2/src/wallet/pages/send/wallet_chain_send_xrp.dart';
import 'package:n42appv2/src/wallet/pages/transactions/transaction_history_list.dart';
import 'package:n42appv2/src/wallet/pages/wallet_backup/backup_one.dart';
import 'package:n42appv2/src/wallet/pages/wallet_receive_qr.dart';
import 'package:n42appv2/src/wallet/provider/transaction_record_iterms_provider.dart';
import 'package:n42appv2/src/wallet/provider/wallet_action_provider.dart';
import 'package:n42appv2/src/wallet/utils/browser_address.dart';
import 'package:n42appv2/src/wallet/utils/browser_token_address.dart';
import 'package:n42appv2/src/wallet/utils/chain_util.dart';
import 'package:n42appv2/src/wallet/widgets/wallet_chain_info_board.dart';
import 'package:n42appv2/src/wallet/widgets/wallet_chain_info_transactions_item.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:n42appv2/src/widgets/dialog_widget/tips_dialog_7.dart';
import 'package:n42appv2/src/widgets/empty.dart';
import 'package:n42appv2/src/widgets/sheet_bottom.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:web3dart/crypto.dart';
import 'package:intl/intl.dart';

class WalletChainInfoXRP extends StatefulWidget {
  final CoinModel coinModel;
  const WalletChainInfoXRP(this.coinModel,{super.key});

  @override
  State<WalletChainInfoXRP> createState() => _WalletChainInfoXRPState();
}

class _WalletChainInfoXRPState extends State<WalletChainInfoXRP> {
  final NumberFormat _oCcy = NumberFormat("#,##0.####", "en_US");
  AppDatabase? _db;
  AppDatabase get db{
    _db ??= AppDatabase();
    return _db!;
  }
  String chainName = "";
  String chainSymbol = "";
  String? tokenName;
  String? tokenSymbol;
  CoinModel? chainCoinModel;
  Map<String, dynamic>? marketInfo;
  String browserUrl = "";
  ScrollController scrollController = ScrollController();
  Load load = Load.finish;
  int pageSize = 10;
  int page = 1;
  bool lastPage = false;
  List<dynamic> transactionList = [];
  StreamSubscription? eventBusFn;

  @override
  void initState() {
    super.initState();
    initData();
    scrollController.addListener(() {
      var maxScroll = scrollController.position.maxScrollExtent;
      var pixel = scrollController.position.pixels;
      if (pixel > maxScroll - 200) {
        getTransactionData(Load.nextPage);
        getTransactionData_network(Load.nextPage);
      }
    });
    eventBusFn = eventBus.on().listen((event) async {
      if (event is EventPublic && event.type == EventPublicType.transferOk) {
        getTransactionData(Load.refresh);
        getTransactionData_network(Load.refresh);
        await widget.coinModel.getBalance();
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    eventBusFn?.cancel();
    scrollController.dispose();
    super.dispose();
  }

  initData() {
    if (widget.coinModel.coin['isContract']) {
      int cIndex = Provider.of<WalletActionProvider>(context,listen: false)
          .coinModels
          .indexWhere((element) {
        if (element.coin['coinType'] == widget.coinModel.coin['coinType']) {
          return true;
        }
        return false;
      });
      chainCoinModel =
      Provider.of<WalletActionProvider>(context,listen: false).coinModels[cIndex];
      chainName = chainCoinModel?.coin['name'];
      chainSymbol = chainCoinModel?.coin['miniName'];
      tokenName = widget.coinModel.coin['name'];
      tokenSymbol = widget.coinModel.coin['miniName'];
      browserUrl = getBrowser_token_address(
        widget.coinModel.coin['coinType'],
        widget.coinModel.address,
        widget.coinModel.coin['contract'],
        isTest: widget.coinModel.isTest,
      );
    } else {
      chainName = widget.coinModel.coin['name'];
      chainSymbol = widget.coinModel.coin['miniName'];
      browserUrl = getBrowser_address(
          widget.coinModel.coin['coinType'], widget.coinModel.address,
          isTest: widget.coinModel.isTest);
      getServiceState();
    }
    marketInfo = Provider.of<WalletActionProvider>(context,listen: false)
        .getCoinPriceWithUnit_all(widget.coinModel.coin['unit']);
    getTransactionData(Load.refresh);
    getTransactionData_network(Load.refresh);
  }
  //获取xrp服务器信息，主要获取 基础说定额度和每个对象的锁定额度
  getServiceState()async{
    MessageModel mm=await XrpApi().getServerStateXrp(isTest: widget.coinModel.isTest);
    if (!mounted) return;
    if(mm.error==false){
      widget.coinModel.other?.setServiceState(mm.data);
    }else{

    }
    setState(() {});
  }

  getTransactionData(Load loadType) async {
    if (load == Load.finish) {
      if (loadType == Load.nextPage) {
        if (lastPage) return;
      }
      if (loadType == Load.refresh) {
        page = 1;
      } else {
        page += 1;
      }
      load = loadType;
      String addr = widget.coinModel.address.toString();
      String coinKey = widget.coinModel.coin['coinType'];
      String contract = widget.coinModel.coin['contract'];
      List<dynamic>? txList;
      if (widget.coinModel.coin['blockchainType'] ==
          BlockchainType.Bitcoin.name) {
        txList = await db
            .selectBtcTransationRecord(
            AppGlobals.userInfo?.uuid ?? "", addr, coinKey, 0,
            pageSize: pageSize, pageNum: page);
      } else {
        txList = await db
            .selectTransationRecordMiniName(addr, coinKey, 0,
            contract: contract,
            pageSize: pageSize,
            pageNum: page,
            isTest: widget.coinModel.isTest ? 1 : 0);
      }
      if (loadType == Load.refresh) {
        transactionList = txList;
      } else {
        transactionList.add(txList);
      }
      if (txList.length < pageSize) {
        lastPage = true;
      }
      setState(() {
        load = Load.finish;
      });
    }
  }

  getTransactionData_network(Load LoadType)async{
    String addr = widget.coinModel.address.toString();
    String coinKey = widget.coinModel.coin['coinType'];
    String contract = widget.coinModel.coin['contract'];
    //List<CommonResponseItemModel>? cril;
    MessageModel mm;
    if(contract==""){
      mm=await TransactionApi().getTransactionList(coinKey, addr,isTest: widget.coinModel.isTest);
    }else{
      mm=await TransactionApi().getContractTransactionList(coinKey, addr, contract,isTest: widget.coinModel.isTest);
    }
    if(mm.error==false){
      //cril=mm.data;
      if(widget.coinModel.coin['blockchainType'] ==BlockchainType.Ethereum.name){
        getTransactionData_network_eth(mm.data);
      }
      else if(widget.coinModel.coin['blockchainType'] ==BlockchainType.Bitcoin.name){
        getTransactionData_network_btc(mm.data);
      }else if(widget.coinModel.coin['blockchainType'] ==BlockchainType.Tron.name){
        getTransactionData_network_trx(mm.data);
      }else if(widget.coinModel.coin['blockchainType'] ==BlockchainType.Solana.name){
        //getTransactionData_network_sol(mm.data);
      }
    }
  }
  getTransactionData_network_eth(List<CommonResponseItemModel>? cril)async{
    if(cril !=null){
      bool isEdit=false;
      for(int i=cril.length-1;i>=0;i--){
        CommonResponseItemModel cri=cril[i];
        List<TransationRecordModel> rtrm=await db.selectTransationRecordTxHash(cri.hash??"0x",widget.coinModel.address);
        if (!mounted) return;
        if(rtrm.isEmpty){
          TransationRecordModel transationRecordModel=TransationRecordModel();
          transationRecordModel.coinId=widget.coinModel.isTest?widget.coinModel.coin['chainId_test']:widget.coinModel.coin['chainId'];
          transationRecordModel.coin=widget.coinModel.coin;
          transationRecordModel.address=widget.coinModel.address??"";
          transationRecordModel.from1=(cri.from??"").toLowerCase();
          transationRecordModel.to1=(cri.to??"").toLowerCase();
          transationRecordModel.price=BigInt.parse(cri.value??"0");
          transationRecordModel.contract=(widget.coinModel.coin['contract']??"").toLowerCase();
          transationRecordModel.walletIndex=Provider.of<WalletActionProvider>(context,listen: false).walletIndex;
          transationRecordModel.nonce=cri.nonce;
          transationRecordModel.txHash=cri.hash??"";
          transationRecordModel.gasPrice=BigInt.parse(cri.gasPrice??"0");
          transationRecordModel.gas=int.parse(cri.gas??"0");
          transationRecordModel.txTime=cri.timeStamp??"0";
          transationRecordModel.state=int.parse(cri.txreceiptStatus??"0");
          transationRecordModel.coinMiniName=widget.coinModel.coin['coinType'];
          transationRecordModel.isTest=widget.coinModel.isTest?1:0;
          if(transationRecordModel.contract ==""){
            String input=cri.input??"0x";
            if(input=="0x"){
              input="";
            }
            else{
              try{
                input=utf8.decode(hexToBytes(input));
              }catch(e){
                input="";
              }

            }
            transationRecordModel.message=input;
          }
          await db.insertTransationRecord(transationRecordModel);
          isEdit=true;
          getTxInfo_network(transationRecordModel);
        }
        else{
          TransationRecordModel transationRecordModel=rtrm[0];
          if(transationRecordModel.txTime != cri.timeStamp){
            transationRecordModel.txTime=cri.timeStamp??"0";
            /*if(transationRecordModel.state!=1){
            transationRecordModel.state=int.parse(cri.txreceiptStatus??"0");
          }*/
            await db.updateTransationRecord(transationRecordModel);
            isEdit=true;
          }
          if(transationRecordModel.contract !=""){
            transationRecordModel.state=transationRecordModel.state;
          }
        }
      }
      if(isEdit){
        getTransactionData(Load.refresh);
      }
    }
  }
  getTransactionData_network_trx(List<CommonResponseItemModel>? cril)async{
    if(cril !=null){
      bool isEdit=false;
      for(int i=cril.length-1;i>=0;i--){
        CommonResponseItemModel cri=cril[i];
        if(widget.coinModel.coin['contract'].toString().toUpperCase() != (cri.contractAddress??"").toUpperCase()){
          continue;
        }
        List<TransationRecordModel> rtrm=await db.selectTransationRecordTxHash(cri.hash??"0x",widget.coinModel.address);
        if (!mounted) return;
        if(rtrm.isEmpty){
          TransationRecordModel transationRecordModel=TransationRecordModel();
          transationRecordModel.coinId=widget.coinModel.isTest?widget.coinModel.coin['chainId_test']:widget.coinModel.coin['chainId'];
          transationRecordModel.coin=widget.coinModel.coin;
          transationRecordModel.address=widget.coinModel.address??"";
          transationRecordModel.from1=(cri.from??"").toLowerCase();
          transationRecordModel.to1=(cri.to??"").toLowerCase();
          transationRecordModel.price=BigInt.parse(cri.value??"0");
          transationRecordModel.contract=(widget.coinModel.coin['contract']??"").toLowerCase();
          transationRecordModel.walletIndex=Provider.of<WalletActionProvider>(context,listen: false).walletIndex;
          transationRecordModel.nonce=cri.nonce;
          transationRecordModel.txHash=cri.hash??"";
          transationRecordModel.gasPrice=BigInt.parse(cri.gasPrice??"0");
          transationRecordModel.gas=int.parse(cri.gas??"0");
          transationRecordModel.txTime=cri.timeStamp??"0";
          transationRecordModel.state=int.parse(cri.txreceiptStatus??"0");
          transationRecordModel.coinMiniName=widget.coinModel.coin['coinType'];
          transationRecordModel.isTest=widget.coinModel.isTest?1:0;
          await db.insertTransationRecord(transationRecordModel);
          isEdit=true;
          getTxInfo_network(transationRecordModel);
        }
        else{
          TransationRecordModel transationRecordModel=rtrm[0];
          if(transationRecordModel.txTime != cri.timeStamp){
            transationRecordModel.txTime=cri.timeStamp??"0";
            /*if(transationRecordModel.state!=1){
            transationRecordModel.state=int.parse(cri.txreceiptStatus??"0");
          }*/
            await db.updateTransationRecord(transationRecordModel);
            isEdit=true;
          }
          if(transationRecordModel.contract !=""){
            transationRecordModel.state=transationRecordModel.state;
          }
        }
      }
      if(isEdit){
        getTransactionData(Load.refresh);
      }
    }
  }
  getTransactionData_network_btc(List<BtcTranDetail>? cril)async{
    if(cril !=null){
      bool isEdit=false;
      for(int i=cril.length-1;i>=0;i--){
        BtcTranDetail cri=cril[i];
        List<BtcTransactionRecodeModel> rtrm=await db.selectBtcTransationRecordTxHash(cri.hash);
        if (!mounted) return;
        if(rtrm.isEmpty){
          BtcTransactionRecodeModel transationRecordModel=BtcTransactionRecodeModel();
          transationRecordModel.addrType=widget.coinModel.addrType;
          transationRecordModel.coin=widget.coinModel.coin;
          transationRecordModel.address=widget.coinModel.address??"";
          transationRecordModel.price=cri.total;
          transationRecordModel.gasPrice=cri.fees;
          transationRecordModel.to1="";
          transationRecordModel.walletIndex=Provider.of<WalletActionProvider>(context,listen: false).walletIndex;
          //transationRecordModel.nonce="0";
          transationRecordModel.txHash=cri.hash;
          //transationRecordModel.gasPrice=BigInt.parse(cri.gasPrice??"0");
          //transationRecordModel.gas=int.parse(cri.gas??"0");
          transationRecordModel.txTime=(DateTime.parse(cri.confirmed??"").millisecondsSinceEpoch~/1000).toString();
          transationRecordModel.state=cri.confirmations>=6?1:0;//int.parse(cri.txreceiptStatus??"0");
          transationRecordModel.coinMiniName=widget.coinModel.coin['coinType'];
          transationRecordModel.isTest=widget.coinModel.isTest?1:0;
          bool isIn=false;//是否是转入
          if(cri.inputs!=null){
            transationRecordModel.inputModels=[];
            for(Input input in cri.inputs!){
              InputModel im=InputModel();
              im.vout=input.outputValue;
              im.txid=input.prevHash;
              im.script=input.script??"";
              im.address=input.addresses;
              int aIndex=im.address.indexWhere((e){
                if(e.toUpperCase()==transationRecordModel.address.toUpperCase()){
                  return true;
                }
                return false;
              });
              if(aIndex==-1){
                isIn=true;
              }
              transationRecordModel.inputModels!.add(im);
            }
          }
          if(cri.outputs!=null){
            transationRecordModel.outputModels=[];
            int outputPrice=0;
            for(Output output in cri.outputs!){
              OutputModel om=OutputModel();
              om.price=output.value;
              om.script=output.script??"";
              om.address=output.addresses??[];
              int aIndex=om.address.indexWhere((e){
                if(e.toUpperCase()==transationRecordModel.address.toUpperCase()){
                  return true;
                }
                return false;
              });
              if(isIn){
                if(aIndex !=-1){
                  outputPrice+=output.value;
                }
              }else{
                if(aIndex ==-1){
                  outputPrice+=output.value;
                }
              }
              transationRecordModel.outputModels!.add(om);
            }
            transationRecordModel.price=outputPrice;
          }
          //transationRecordModel.input

          await db.insertBtcTransactionRecord(transationRecordModel);
          isEdit=true;
          //getTxInfo_network(transationRecordModel);
        }
        else{
          BtcTransactionRecodeModel transationRecordModel=rtrm[0];
          String cDate=(DateTime.parse(cri.confirmed??"").millisecondsSinceEpoch~/1000).toString();
          if(transationRecordModel.inputsAddressList.isEmpty){
            if(cri.inputs!=null){
              transationRecordModel.inputModels=[];
              for(Input input in cri.inputs!){
                InputModel im=InputModel();
                im.vout=input.outputValue;
                im.txid=input.prevHash;
                im.script=input.script??"";
                im.address=input.addresses;
                transationRecordModel.inputModels!.add(im);
              }
            }
            if(cri.outputs!=null){
              transationRecordModel.outputModels=[];
              for(Output output in cri.outputs!){
                OutputModel om=OutputModel();
                om.price=output.value;
                om.script=output.script??"";
                om.address=output.addresses??[];
                transationRecordModel.outputModels!.add(om);
              }
            }
            transationRecordModel.txTime=cDate;
            await db.updateBtcTransactionRecord(transationRecordModel);
            isEdit=true;
          }
          if(transationRecordModel.txTime != cDate){
            transationRecordModel.txTime=cDate;
            /*if(transationRecordModel.state!=1){
            transationRecordModel.state=int.parse(cri.txreceiptStatus??"0");
          }*/
            await db.updateBtcTransactionRecord(transationRecordModel);
            isEdit=true;
          }
        }
      }
      if(isEdit){
        getTransactionData(Load.refresh);
      }
    }
  }
  /*
  getTransactionData_network_sol(List<SOLTransactionItem>? cril)async{
    if(cril !=null){
      bool isEdit=false;
      for(int i=cril.length-1;i>=0;i--){
        SOLTransactionItem cri=cril[i];
        List<TransationRecordModel> rtrm=await db.selectTransationRecordTxHash(cri.txHash??"0x");
        if(rtrm.length==0){
          TransationRecordModel transationRecordModel=TransationRecordModel();
          transationRecordModel.coinId=widget.coinModel.isTest?widget.coinModel.coin['chainId_test']:widget.coinModel.coin['chainId'];
          transationRecordModel.coin=widget.coinModel.coin;
          transationRecordModel.address=widget.coinModel.address??"";
          transationRecordModel.from1=(cri.from??"").toLowerCase();
          transationRecordModel.to1=(cri.to??"").toLowerCase();
          transationRecordModel.price=BigInt.parse(cri.value??"0");
          transationRecordModel.contract=(widget.coinModel.coin['contract']??"").toLowerCase();
          transationRecordModel.walletIndex=Provider.of<WalletActionProvider>(context,listen: false).walletIndex;
          transationRecordModel.nonce=cri.nonce;
          transationRecordModel.txHash=cri.hash;
          transationRecordModel.gasPrice=BigInt.parse(cri.gasPrice??"0");
          transationRecordModel.gas=int.parse(cri.gas??"0");
          transationRecordModel.txTime=cri.timeStamp??"0";
          transationRecordModel.state=int.parse(cri.txreceiptStatus??"0");
          transationRecordModel.coinMiniName=widget.coinModel.coin['coinType'];
          transationRecordModel.isTest=widget.coinModel.isTest?1:0;
          if(transationRecordModel.contract ==""){
            String input=cri.input??"0x";
            if(input=="0x"){
              input="";
            }
            else{
              try{
                input=utf8.decode(hexToBytes(input));
              }catch(e){
                input="";
              }

            }
            transationRecordModel.message=input;
          }
          await db.insertTransationRecord(transationRecordModel);
          isEdit=true;
          getTxInfo_network(transationRecordModel);
        }
        else{
          TransationRecordModel transationRecordModel=rtrm[0];
          if(transationRecordModel.txTime != cri.timeStamp){
            transationRecordModel.txTime=cri.timeStamp??"0";
            /*if(transationRecordModel.state!=1){
            transationRecordModel.state=int.parse(cri.txreceiptStatus??"0");
          }*/
            await db.updateTransationRecord(transationRecordModel);
            isEdit=true;
          }
          if(transationRecordModel.contract !=""){
            transationRecordModel.state=transationRecordModel.state;
          }
        }
      }
      if(isEdit){
        getTransactionData(Load.refresh);
      }
    }
  }
  */
  getTxInfo_network(TransationRecordModel transationRecordModel)async{
    TransationRecordModel rtrm=await Provider.of<TransactionRecordItemProvider>(context,listen: false).checkUndoneTr_return(transationRecordModel);
    transactionList.firstWhere((element){
      TransationRecordModel trm=element as TransationRecordModel;
      if(trm.txHash==rtrm.txHash){
        trm.state=rtrm.state;
        return true;
      }
      return false;
    });
    setState(() {});
  }
  getTxInfo_network_btc(BtcTransactionRecodeModel transationRecordModel)async{
    BtcTransactionRecodeModel rtrm=await Provider.of<TransactionRecordItemProvider>(context,listen: false).checkUndoneTr_btc_return(transationRecordModel);
    transactionList.firstWhere((element){
      TransationRecordModel trm=element as TransationRecordModel;
      if(trm.txHash==rtrm.txHash){
        trm.state=rtrm.state;
        return true;
      }
      return false;
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        titleWidget: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "$chainSymbol ($chainName)",
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainTextColor.name),
                fontSize: ScreenUtil().setSp(32.0),
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if(tokenSymbol!=null)
              Text(
                "$tokenSymbol($tokenName)",
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainTextColor.name),
                  fontSize: ScreenUtil().setSp(24.0),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        actions: [
          InkWell(
            onTap: (){
              showActionButtonListWidget();
            },
            child: Container(
              width: ScreenUtil().setWidth(40.0),
              height: ScreenUtil().setWidth(40.0),
              margin: EdgeInsets.only(right:ScreenUtil().setWidth(40.0),left: ScreenUtil().setWidth(20.0),),
              child: Image.asset('assets/wallet/w_actions.png',color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),),

            ),
          ),
        ],

      ),
      body: SafeArea(
        child:Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  getTransactionData(Load.refresh);
                  getTransactionData_network(Load.refresh);
                  await widget.coinModel.getBalance();
                },
                backgroundColor: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainButtonBgColor.name),
                color:
                AppThemeUtils.getColorByKey(context, AppThemeKeys.mainWhiteColor.name),
                displacement: ScreenUtil().setWidth(72.0),
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    WalletChainInfoBoard(
                      address: widget.coinModel.address,
                      balanceStr:
                      '${widget.coinModel.balanceStringAll()} ${widget.coinModel.coin['unit'].toString().toUpperCase()}',
                      balanceDollarStr: '\$${widget.coinModel.valueString()}',
                      marketValueStr:
                      '\$${widget.coinModel.coinPriceString()}',
                      lockAmountStr: //widget.coinModel.coin['isContract']==false?
                      '${toEther((widget.coinModel.other?.getLockAmount??0).toString(), widget.coinModel.coin['decimals'])} ${CoinType.XRP.name}',
                      xmlLockInfoTap: (){
                        showXMLLockAmountWidget();
                      },
                      sendTap: () async {
                        WalletActionProvider wap=Provider.of<WalletActionProvider>(context,listen: false);
                        if(wap.walletInfo.password==""){
                          final flag= await TipsDialog7(context);
                          if (!context.mounted) return;
                          if (flag == null || !flag) return;
                          Navigator.push(context, MaterialPageRoute(
                              settings: RouteSettings(
                                name: 'BackupOne',
                              ),
                              builder: (context)=>BackupOne(wap.walletInfo,wap.walletIndex)));
                          return;
                        }
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  WalletChainSendXrp(widget.coinModel),
                            ));
                        if (!mounted) return;
                        getTransactionData(Load.refresh);
                      },
                      receiveTap: () async{
                        WalletActionProvider wap=Provider.of<WalletActionProvider>(context,listen: false);
                        if(wap.walletInfo.password==""){
                          final flag= await TipsDialog7(context);
                          if (!context.mounted) return;
                          if (flag == null || !flag) return;
                          Navigator.push(context, MaterialPageRoute(
                              settings: RouteSettings(
                                name: 'BackupOne',
                              ),
                              builder: (context)=>BackupOne(wap.walletInfo,wap.walletIndex)));
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WalletReceiveQr(
                              chainCoinModel == null
                                  ? widget.coinModel
                                  : chainCoinModel!,
                              tokenCoinModel: chainCoinModel == null
                                  ? null
                                  : widget.coinModel,
                            ),
                          ),
                        );
                      },
                      browserTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => BrowserPage(
                                  browserUrl,
                                  //S.of(context).g_key_m_15
                                )));
                      },
                      tokenAddTap: null,
                      swapAddTap: null,
                      sellAddTap: null,
                    ),
                    Divider(
                      height: ScreenUtil().setWidth(1),
                      endIndent: 0,
                      indent: 0,
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.symmetric(
                        vertical: ScreenUtil().setWidth(20.0),),
                      margin: EdgeInsets.symmetric(
                        horizontal: ScreenUtil().setWidth(30.0),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Text(
                              S.of(context).g_coin_key_1,
                              style: TextStyle(
                                color: AppThemeUtils.getColorByKey(
                                    context, AppThemeKeys.mainTextColor.name),
                                fontSize: ScreenUtil().setSp(30.0),
                              ),
                            ),
                          ),
                        ],
                      ),

                    ),
                    transactionsWidget(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

    );
  }

  transactionsWidget() {
    if (transactionList.isEmpty) {
      //IntrinsicHeight: Dynamically calculated height
      return const IntrinsicHeight(
        child: Center(
          child: EmptyView(),
        ),
      );
    }
    int itemCount=transactionList.length;
    if(widget.coinModel.coin['coinType']==CoinType.N.name){
      if(itemCount==10){
        itemCount++;
      }
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0)),
      itemCount: transactionList.length+1,
      itemBuilder: (context, int index) {

        if(transactionList.length==index){
          return InkWell(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>TransactionHistoryList(widget.coinModel)));
            },
            child: Container(
              height: ScreenUtil().setWidth(80.0),
              width: double.infinity,
              alignment: Alignment.center,
              child: Text(
                S.of(context).g_mining_key_49,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(30.0),
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                ),
              ),
            ),
          );
        }
        if (widget.coinModel.coin['blockchainType'] ==
            BlockchainType.Bitcoin.name) {
          BtcTransactionRecodeModel trm = transactionList[index];
          return WalletChainInfoTransactionsItem(
              coinModel: widget.coinModel, type: 0, transactionModel: trm, onBack: (){
                getTransactionData(Load.refresh);
              });
        } else {
          TransationRecordModel trm = transactionList[index];
          return WalletChainInfoTransactionsItem(
            type: 1, transactionModel: trm,coinModel: widget.coinModel,onBack: (){
            getTransactionData(Load.refresh);
          },);
        }

      },
    );
  }
  //切换网络，测试网络还是主网
  changeNet(bool isTest, Load loadType) async {
    try {
      WalletActionProvider wap=Provider.of<WalletActionProvider>(context,listen: false);
      wap.walletMap[widget.coinModel.coin['coinType']]['isTest'] = isTest;
      widget.coinModel.isTest = isTest;
      await wap.saveWalletInfo(wap.walletInfo, wap.walletIndex);
      await widget.coinModel.getBalance();
      widget.coinModel.address=null;
      await widget.coinModel.buildWallet();
      await widget.coinModel.getBalance();
      setState(() {});
      initData();
    } catch (e) {
      ToastUtils.show(e.toString());
    }
  }

  //显示操作按钮列表
  showActionButtonListWidget(){
    List<Widget> childs = [];
    //send
    childs.add(InkWell(
      onTap: () async {
        WalletActionProvider wap=Provider.of<WalletActionProvider>(context,listen: false);
        if(wap.walletInfo.password==""){
          final flag= await TipsDialog7(context);
          if (!mounted) return;
          if (flag != null && flag) {
            await Navigator.push(context, MaterialPageRoute(
                settings: RouteSettings(
                  name: 'BackupOne',
                ),
                builder: (context)=>BackupOne(wap.walletInfo,wap.walletIndex)));
          }
          if (!mounted) return;
          Navigator.pop(context);
        }
        if (widget.coinModel.coin['blockchainType'] ==
            BlockchainType.Bitcoin.name) {
          await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    WalletChainSendBtc(widget.coinModel),
              ));
        } else if(widget.coinModel.coin['blockchainType']==BlockchainType.Solana.name){
          await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    WalletChainSendSol(widget.coinModel),
              ));
        }else if(widget.coinModel.coin['blockchainType']==BlockchainType.Tron.name){
          await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    WalletChainSendTrx(widget.coinModel),
              ));
        }else if(widget.coinModel.coin['blockchainType']==BlockchainType.Algorand.name){
          await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    WalletChainSendAlgo(widget.coinModel),
              ));
        }else if(widget.coinModel.coin['blockchainType']==BlockchainType.Ripple.name){
          await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    WalletChainSendXrp(widget.coinModel),
              ));
        }else if(widget.coinModel.coin['blockchainType']==BlockchainType.Filecoin.name){
          await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    WalletChainSendFil(widget.coinModel),
              ));
        }else {
          await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    WalletChainSend(widget.coinModel),
              ));
        }
        if (!mounted) return;
        getTransactionData(Load.refresh);
        Navigator.pop(context);
      },
      child: Container(
          padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              SizedBox(
                width: ScreenUtil().setWidth(40.0),
                height: ScreenUtil().setWidth(40.0),
                child: Image.asset(
                    'assets/wallet/w_send.png',
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name)
                ),
              ),
              SizedBox(
                width: ScreenUtil().setWidth(20.0),
              ),
              Text(
                S.of(context).g_key_48,
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                  fontSize: ScreenUtil().setSp(30.0),
                ),
              ),
            ],
          )),
    ));
    childs.add(Divider(
      height: ScreenUtil().setWidth(1),
      indent: 0,
      endIndent: 0,
    ));
    //Receive
    childs.add(InkWell(
      onTap: () async{
        WalletActionProvider wap=Provider.of<WalletActionProvider>(context,listen: false);
        if(wap.walletInfo.password==""){
          final flag= await TipsDialog7(context);
          if (!mounted) return;
          if (flag != null && flag) {
            await Navigator.push(context, MaterialPageRoute(
                settings: RouteSettings(
                  name: 'BackupOne',
                ),
                builder: (context)=>BackupOne(wap.walletInfo,wap.walletIndex)));
          }
        }else{
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WalletReceiveQr(
                chainCoinModel == null
                    ? widget.coinModel
                    : chainCoinModel!,
                tokenCoinModel: chainCoinModel == null
                    ? null
                    : widget.coinModel,
              ),
            ),
          );
        }
        if (!mounted) return;
        Navigator.pop(context);
      },
      child: Container(
          padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              SizedBox(
                width: ScreenUtil().setWidth(40.0),
                height: ScreenUtil().setWidth(40.0),
                child: Image.asset(
                  'assets/wallet/w_receive.png',
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                ),
              ),
              SizedBox(
                width: ScreenUtil().setWidth(20.0),
              ),
              Text(
                S.of(context).g_key_33,
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                  fontSize: ScreenUtil().setSp(30.0),
                ),
              ),
            ],
          )),
    ));
    childs.add(Divider(
      height: ScreenUtil().setWidth(1),
      indent: 0,
      endIndent: 0,
    ));
    //Explorer
    childs.add(InkWell(
      onTap: () async{
        await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => BrowserPage(
                  browserUrl,
                  //S.of(context).g_key_m_15
                )));
        if (!mounted) return;
        Navigator.pop(context);
      },
      child: Container(
          padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              SizedBox(
                width: ScreenUtil().setWidth(40.0),
                height: ScreenUtil().setWidth(40.0),
                child: Image.asset(
                  'assets/wallet/w_explorer.png',
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                ),
              ),
              SizedBox(
                width: ScreenUtil().setWidth(20.0),
              ),
              Text(
                S.of(context).g_key_196,
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                  fontSize: ScreenUtil().setSp(30.0),
                ),
              ),
            ],
          )),
    ));
    childs.add(Divider(
      height: ScreenUtil().setWidth(1),
      indent: 0,
      endIndent: 0,
    ));
    //buy
    childs.add(InkWell(
      onTap: () async{
        await Navigator.push(context, MaterialPageRoute(builder: (context)=>Moonpay(coinModel:widget.coinModel)));
        if (!mounted) return;
        Navigator.pop(context);
      },
      child: Container(
          padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              SizedBox(
                width: ScreenUtil().setWidth(40.0),
                height: ScreenUtil().setWidth(40.0),
                child: Image.asset(
                  'assets/wallet/w_buy.png',
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                ),
              ),
              SizedBox(
                width: ScreenUtil().setWidth(20.0),
              ),
              Text(
                S.of(context).g_key_211,
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                  fontSize: ScreenUtil().setSp(30.0),
                ),
              ),
            ],
          )),
    ));
    childs.add(Divider(
      height: ScreenUtil().setWidth(1),
      indent: 0,
      endIndent: 0,
    ));
    //sell
    childs.add(InkWell(
      onTap: () async{
        await Navigator.push(context, MaterialPageRoute(builder: (context)=>Moonpay(coinModel:widget.coinModel,type: 1,)));
        if (!mounted) return;
        Navigator.pop(context);
      },
      child: Container(
          padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              SizedBox(
                width: ScreenUtil().setWidth(40.0),
                height: ScreenUtil().setWidth(40.0),
                child: Image.asset(
                  'assets/wallet/w_sell.png',
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                ),
              ),
              SizedBox(
                width: ScreenUtil().setWidth(20.0),
              ),
              Text(
                S.of(context).g_key_212,
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                  fontSize: ScreenUtil().setSp(30.0),
                ),
              ),
            ],
          )),
    ));
    //tokens
    if(widget.coinModel.privateKey == null ||
        widget.coinModel.coin['blockchainType'] == BlockchainType.Bitcoin.name ||
        widget.coinModel.coin['isContract'] == true) {

    }else{
      childs.add(Divider(
        height: ScreenUtil().setWidth(1),
        indent: 0,
        endIndent: 0,
      ));
      childs.add(InkWell(
        onTap: () async {
          bool r = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => WalletCoinTokenAdd2(
                    widget.coinModel,)));
          if (!mounted) return;
          if (r) {
            Provider.of<WalletActionProvider>(context).init_wallet(initCoinInfo: true);
          }
          Navigator.pop(context);
        },
        child: Container(
            padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                SizedBox(
                  width: ScreenUtil().setWidth(40.0),
                  height: ScreenUtil().setWidth(40.0),
                  child: Image.asset(
                    'assets/wallet/addToken.png',
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                  ),
                ),
                SizedBox(
                  width: ScreenUtil().setWidth(20.0),
                ),
                Text(
                  S.of(context).g_token_m_key_11,
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                    fontSize: ScreenUtil().setSp(30.0),
                  ),
                ),
              ],
            )),
      ));
    }
    //change net
    bool isTest = widget.coinModel.isTest;
    Color mainColor =
    AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor.name);
    Color testColor = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.itemSubtitleTextColor.name);
    if (isTest) {
      testColor =
          AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name);
      mainColor = AppThemeUtils.getColorByKey(
          context, AppThemeKeys.itemSubtitleTextColor.name);
    }
    childs.add(Divider(
      height: ScreenUtil().setWidth(1),
      indent: 0,
      endIndent: 0,
    ));
    childs.add(
      Row(
        children: [
          Expanded(
            flex: 1,
            child: InkWell(
              onTap: () {
                if (isTest) {
                  changeNet(
                    false,
                    Load.refresh,
                  );
                }
                Navigator.pop(context);
              },
              child: Container(
                  padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      SizedBox(
                        width: ScreenUtil().setWidth(40.0),
                        height: ScreenUtil().setWidth(40.0),
                        child: Image.asset(
                          'assets/wallet/mainnet.png',
                          color: mainColor,
                        ),
                      ),
                      SizedBox(
                        width: ScreenUtil().setWidth(20.0),
                      ),
                      Text(
                        S.of(context).g_key_148,
                        style: TextStyle(
                          color: mainColor,
                          fontSize: ScreenUtil().setSp(30.0),
                        ),
                      ),
                    ],
                  )),
            ),
          ),
          Expanded(
            flex: 1,
            child: InkWell(
              onTap: () {
                if (isTest==false) {
                  changeNet(true, Load.refresh);
                }
                Navigator.pop(context);
              },
              child: Container(
                  padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      SizedBox(
                        width: ScreenUtil().setWidth(40.0),
                        height: ScreenUtil().setWidth(40.0),
                        child: Image.asset(
                          'assets/wallet/testnet.png',
                          color: testColor,
                        ),
                      ),
                      SizedBox(
                        width: ScreenUtil().setWidth(20.0),
                      ),
                      Text(
                        S.of(context).g_key_147,
                        style: TextStyle(
                          color: testColor,
                          fontSize: ScreenUtil().setSp(30.0),
                        ),
                      ),
                    ],
                  )),
            ),
          ),
        ],
      ),
    );
    //coin info
    if (marketInfo != null) {
      if(marketInfo!["coin_gecko_id"] !="") {
        childs.add(Divider(
          height: ScreenUtil().setWidth(1),
          indent: 0,
          endIndent: 0,
        ));
        childs.add(InkWell(
          onTap: () async{
            await Navigator.push(context, MaterialPageRoute(builder: (context) => MarketCoinInfo(marketInfo ?? {})));
            if (!mounted) return;
            Navigator.pop(context);
          },
          child: Container(
              padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  SizedBox(
                    width: ScreenUtil().setWidth(40.0),
                    height: ScreenUtil().setWidth(40.0),
                    child: Image.asset(
                      'assets/wallet/marketInfo.png',
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                    ),
                  ),
                  SizedBox(
                    width: ScreenUtil().setWidth(20.0),
                  ),
                  Text(
                    S.of(context).g_key_213,
                    style: TextStyle(
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                      fontSize: ScreenUtil().setSp(30.0),
                    ),
                  ),
                ],
              )),
        ));
      }
    }
    SheetBottom(
        context,
        "",
        Column(
          children: childs,
        ));
  }
  //显示XML锁定金额信息
  showXMLLockAmountWidget(){
    List<Widget> childs=[];
    //reserve base
    childs.add(
        xmlInfoWidget(
            S.of(context).g_key_xml_1,
            "${toEther(widget.coinModel.other.reserveBase.toString(), widget.coinModel.coin['decimals'])} ${CoinType.XRP.name} (${_oCcy.format(widget.coinModel.other.reserveBase)} drops)",
            S.of(context).g_key_xml_11(toEther(widget.coinModel.other.reserveBase.toString(), widget.coinModel.coin['decimals']),_oCcy.format(widget.coinModel.other.reserveBase)))
    );
    //reserve inc
    childs.add(
        xmlInfoWidget(
            S.of(context).g_key_xml_2,
            "${toEther(widget.coinModel.other.reserveInc.toString(), widget.coinModel.coin['decimals'])} ${CoinType.XRP.name} (${_oCcy.format(widget.coinModel.other.reserveInc)} drops)",
            S.of(context).g_key_xml_22(toEther(widget.coinModel.other.reserveInc.toString(), widget.coinModel.coin['decimals']),_oCcy.format(widget.coinModel.other.reserveInc)))
    );
    //owner Count
    childs.add(
        xmlInfoWidget(
            S.of(context).g_key_xml_3,
            widget.coinModel.other.ownerCount.toString(),
            S.of(context).g_key_xml_33(widget.coinModel.other.ownerCount,toEther(widget.coinModel.other.reserveInc.toString(), widget.coinModel.coin['decimals']).toDouble()*widget.coinModel.other.ownerCount))
    );
    //公式
    childs.add(
        xmlInfoWidget(
            S.of(context).g_key_xml_4,
            "",
            S.of(context).g_key_xml_44)
    );
    SheetBottom(
        context,
        "",
        Column(
          children: childs,
        ));
  }
  Widget xmlInfoWidget(String title,String value,String description){
    return Container(
      margin: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(20)),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                "$title:",
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                  fontSize: ScreenUtil().setSp(28),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemTextColor.name),
                  fontSize: ScreenUtil().setSp(28),
                ),
              ),
            ],
          ),
          SizedBox(height: ScreenUtil().setWidth(10),),
          Text(
            description,
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
              fontSize: ScreenUtil().setSp(28),
            ),
          ),
        ],
      ),
    );
  }
}
