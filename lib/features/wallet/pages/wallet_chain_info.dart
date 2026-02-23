import 'dart:async';
import 'dart:convert';

import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/features/browser/pages/browser_page.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/component/enums/load.dart';
import 'package:n42_wallet/features/models/message_model.dart';
import 'package:n42_wallet/features/pay/moonpay/moonpay.dart';
import 'package:n42_wallet/features/sqlite/app_database.dart';
import 'package:n42_wallet/core/utils/event_bus.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/wallet/api/transaction_api.dart';
import 'package:n42_wallet/features/wallet/models/btc_transaction_recode_model.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/transaction/btc_tran_detail.dart';
import 'package:n42_wallet/features/wallet/models/transaction/common_response_item_model.dart';
import 'package:n42_wallet/features/wallet/models/transaction/sol_transaction_item.dart';
import 'package:n42_wallet/features/wallet/models/transation_record_model.dart';
import 'package:n42_wallet/features/wallet/api/simplehash_nft_api.dart';
import 'package:n42_wallet/features/wallet/pages/add_token/wallet_coin_token_add2.dart';
import 'package:n42_wallet/features/wallet/pages/market/market_coin_info.dart';
import 'package:n42_wallet/features/wallet/pages/nft/nft_list_page.dart';
import 'package:n42_wallet/features/wallet/pages/send/unified_send_page.dart';
import 'package:n42_wallet/features/wallet/pages/batch_transfer/batch_transfer_page.dart';
import 'package:n42_wallet/features/wallet/provider/batch_transfer_provider.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/features/wallet/pages/transactions/transaction_detail_eth.dart';
import 'package:n42_wallet/features/wallet/pages/transactions/transaction_history_list.dart';
import 'package:n42_wallet/features/wallet/pages/transactions/transaction_retry.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_backup/backup_one.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_receive_qr.dart';
import 'package:n42_wallet/features/wallet/provider/wallet_action_provider.dart';
import 'package:n42_wallet/features/wallet/utils/browser/browser_address.dart';
import 'package:n42_wallet/features/wallet/utils/browser/browser_token_address.dart';
import 'package:n42_wallet/features/wallet/widgets/wallet_chain_info_board.dart';
import 'package:n42_wallet/features/wallet/widgets/wallet_chain_info_transactions_item.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/features/widgets/dialog_widget/tips_dialog_7.dart';
import 'package:n42_wallet/features/widgets/empty.dart';
import 'package:n42_wallet/features/widgets/sheet_bottom.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/transaction_providers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:web3dart/web3dart.dart';

class WalletChainInfo extends ConsumerStatefulWidget {
  final CoinModel coinModel;
  const WalletChainInfo(this.coinModel,{super.key});

  @override
  ConsumerState<WalletChainInfo> createState() => _WalletChainInfoState();
}

class _WalletChainInfoState extends ConsumerState<WalletChainInfo> {
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

  WalletActionProvider get _walletProvider =>
      ref.read(wapBridgeProvider);

  Future<bool> _ensureWalletBackedUp() async {
    final walletInfo = _walletProvider.walletInfo;
    // 安全检查 password，如果为 null 或空则需要备份
    if (walletInfo.password != null && walletInfo.password!.isNotEmpty) {
      return true;
    }
    final flag = await tipsDialog7(context);
    if (!mounted) return false;
    if (flag == true) {
      await Navigator.push(
          context,
          MaterialPageRoute(
              settings: const RouteSettings(name: 'BackupOne'),
              builder: (context) =>
                  BackupOne(walletInfo, _walletProvider.walletIndex)));
    }
    return false;
  }

  Future<void> _handleSend({bool closeSheet = false}) async {
    if (!await _ensureWalletBackedUp()) {
      if (!mounted) return;
      if (closeSheet) Navigator.pop(context);
      return;
    }
    if (!mounted) return;
    await _openSendPage();
    await getTransactionData(Load.refresh);
    if (!mounted) return;
    if (closeSheet) Navigator.pop(context);
  }

  Future<void> _handleReceive({bool closeSheet = false}) async {
    if (!await _ensureWalletBackedUp()) {
      if (!mounted) return;
      if (closeSheet) Navigator.pop(context);
      return;
    }
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WalletReceiveQr(
          chainCoinModel ?? widget.coinModel,
          tokenCoinModel: chainCoinModel == null ? null : widget.coinModel,
        ),
      ),
    );
    if (!mounted) return;
    if (closeSheet) Navigator.pop(context);
  }

  Future<void> _handleBatchTransfer() async {
    if (!await _ensureWalletBackedUp()) {
      return;
    }

    // 获取 RPC URL 和 chain ID
    final coinType = widget.coinModel.coin['coinType'];
    final isTest = widget.coinModel.isTest;
    final chainConfig = chainUrlMap[coinType];

    String rpcUrl = '';
    int chainId = 1;

    if (chainConfig != null) {
      rpcUrl = isTest
          ? (chainConfig['baseInfo']?['service_test'] ?? '')
          : (chainConfig['baseInfo']?['service'] ?? '');
      chainId = isTest
          ? (chainConfig['testnetChainID'] ?? chainConfig['baseInfo']?['chainId_test'] ?? 1)
          : (chainConfig['mainnetChainID'] ?? chainConfig['baseInfo']?['chainId'] ?? 1);
    }

    // 如果是自定义链
    if (widget.coinModel.coin['custom'] == true) {
      rpcUrl = isTest
          ? (widget.coinModel.coin['service_test'] ?? '')
          : (widget.coinModel.coin['service'] ?? '');
      chainId = isTest
          ? (widget.coinModel.coin['chainId_test'] ?? 1)
          : (widget.coinModel.coin['chainId'] ?? 1);
    }

    if (rpcUrl.isEmpty) {
      ToastUtils.showWarning('RPC URL not configured');
      return;
    }

    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BatchTransferPage(
            chainSymbol: widget.coinModel.coin['miniName'] ?? coinType,
            rpcUrl: rpcUrl,
            chainId: chainId,
            fromAddress: widget.coinModel.address ?? '',
            tokenAddress: widget.coinModel.coin['isContract'] == true
                ? widget.coinModel.coin['contract']
                : null,
            tokenSymbol: widget.coinModel.coin['miniName'] ?? '',
            decimals: widget.coinModel.coin['decimals'] ?? 18,
            balance: widget.coinModel.balance,
            batchTransferProvider: BatchTransferProvider(),
          ),
      ),
    );
  }

  Future<void> _openSendPage() async {
    final targetPage = _buildSendPage();
    if (targetPage == null) return;
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) => targetPage));
  }

  Widget? _buildSendPage() => UnifiedSendPage(widget.coinModel);

  @override
  void initState() {
    super.initState();
    initData();
    scrollController.addListener(() {
      var maxScroll = scrollController.position.maxScrollExtent;
      var pixel = scrollController.position.pixels;
      if (pixel > maxScroll - 200) {
        getTransactionData(Load.nextPage);
        getTransactionDataNetwork(Load.nextPage);
      }
    });
    eventBusFn = eventBus.on().listen((event) async {
      if (event is EventPublic && event.type == EventPublicType.transferOk) {
        getTransactionData(Load.refresh);
        getTransactionDataNetwork(Load.refresh);
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

  void initData() {
    if (widget.coinModel.coin['isContract']) {
      int cIndex = ref.read(wapBridgeProvider)
          .coinModels
          .indexWhere((element) {
        if (element.coin['coinType'] == widget.coinModel.coin['coinType']) {
          return true;
        }
        return false;
      });
      chainCoinModel =
      ref.read(wapBridgeProvider).coinModels[cIndex];
      chainName = chainCoinModel?.coin['name'];
      chainSymbol = chainCoinModel?.coin['miniName'];
      tokenName = widget.coinModel.coin['name'];
      tokenSymbol = widget.coinModel.coin['miniName'];
      browserUrl = getBrowserTokenAddress(
        widget.coinModel.coin['coinType'],
        widget.coinModel.address,
        widget.coinModel.coin['contract'],
        isTest: widget.coinModel.isTest,
      );
    } else {
      chainName = widget.coinModel.coin['name'];
      chainSymbol = widget.coinModel.coin['miniName'];
      browserUrl = getBrowserAddress(
          widget.coinModel.coin['coinType'], widget.coinModel.address,
          isTest: widget.coinModel.isTest);
    }
    marketInfo = ref.read(wapBridgeProvider)
        .getCoinPriceWithUnitAll(widget.coinModel.coin['unit']);
    getTransactionData(Load.refresh);
    getTransactionDataNetwork(Load.refresh);
  }

  Future<void> getTransactionData(Load loadType) async {
    if (load != Load.finish) return;
    if (loadType == Load.nextPage && lastPage) return;

    if (loadType == Load.refresh) {
      page = 1;
      lastPage = false;
    } else {
      page += 1;
    }

    load = loadType;
    try {
      final addr = widget.coinModel.address?.toString() ?? "";
      final coinKey = widget.coinModel.coin['coinType'];
      final contract = widget.coinModel.coin['contract'];
      List<dynamic>? txList;
      if (widget.coinModel.coin['blockchainType'] ==
          BlockchainType.Bitcoin.name) {
        txList = await db.selectBtcTransationRecord(
            AppGlobals.userInfo?.uuid ?? "", addr, coinKey, 0,
            pageSize: pageSize, pageNum: page);
      } else {
        txList = await db.selectTransationRecordMiniName(
            addr, coinKey, 0,
            contract: contract,
            pageSize: pageSize,
            pageNum: page,
            isTest: widget.coinModel.isTest ? 1 : 0);
      }
      if (loadType == Load.refresh) {
        transactionList = txList;
      } else {
        transactionList.addAll(txList);
      }
      if (txList.length < pageSize) {
        lastPage = true;
      }
    } finally {
      setState(() {
        load = Load.finish;
      });
    }
  }

  Future<void> getTransactionDataNetwork(Load loadType)async{
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
        getTransactionDataNetworkEth(mm.data);
      }
      else if(widget.coinModel.coin['blockchainType'] ==BlockchainType.Bitcoin.name){
        getTransactionDataNetworkBtc(mm.data);
      }else if(widget.coinModel.coin['blockchainType'] ==BlockchainType.Tron.name){
        getTransactionDataNetworkTrx(mm.data);
      }else if(widget.coinModel.coin['blockchainType'] ==BlockchainType.Solana.name){
        getTransactionDataNetworkSol(mm.data);
      }else if(widget.coinModel.coin['blockchainType'] ==BlockchainType.Polkadot.name||
               widget.coinModel.coin['blockchainType'] ==BlockchainType.Aptos.name||
               widget.coinModel.coin['blockchainType'] ==BlockchainType.TheOpenNetwork.name){
        getTransactionDataNetworkGeneric(mm.data);
      }
    }
  }
  Future<void> getTransactionDataNetworkEth(List<CommonResponseItemModel>? cril)async{
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
          transationRecordModel.walletIndex=ref.read(wapBridgeProvider).walletIndex;
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
          //await getTxInfoNetwork(transationRecordModel);
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
  Future<void> getTransactionDataNetworkTrx(List<CommonResponseItemModel>? cril)async{
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
          transationRecordModel.walletIndex=ref.read(wapBridgeProvider).walletIndex;
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
          //await getTxInfoNetwork(transationRecordModel);
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
  Future<void> getTransactionDataNetworkBtc(List<BtcTranDetail>? cril)async{
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
          transationRecordModel.walletIndex=ref.read(wapBridgeProvider).walletIndex;
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
          //getTxInfoNetwork(transationRecordModel);
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
  /// Solana 交易记录同步 — 将 SOLTransactionItem 映射到本地 DB
  Future<void> getTransactionDataNetworkSol(List<SOLTransactionItem>? cril) async {
    if (cril == null) return;
    bool isEdit = false;
    for (int i = cril.length - 1; i >= 0; i--) {
      final cri = cril[i];
      final hash = cri.txHash ?? '';
      if (hash.isEmpty) continue;
      final rtrm = await db.selectTransationRecordTxHash(hash, widget.coinModel.address);
      if (!mounted) return;
      if (rtrm.isEmpty) {
        final trm = TransationRecordModel();
        trm.coinId = (widget.coinModel.isTest
                ? widget.coinModel.coin['chainId_test']
                : widget.coinModel.coin['chainId']) ??
            0;
        trm.coin = widget.coinModel.coin;
        trm.address = widget.coinModel.address ?? '';
        trm.from1 = (cri.src ?? '').toLowerCase();
        trm.to1 = (cri.dst ?? '').toLowerCase();
        trm.price = BigInt.from(cri.lamport ?? 0);   // lamport (10^-9 SOL)
        trm.contract = (widget.coinModel.coin['contract'] ?? '').toLowerCase();
        trm.walletIndex = ref.read(wapBridgeProvider).walletIndex;
        trm.txHash = hash;
        trm.gasPrice = BigInt.from(cri.fee ?? 0);    // fee in lamport
        trm.gas = 0;
        trm.txTime = (cri.blockTime ?? 0).toString(); // Unix seconds
        trm.state = (cri.status == 'Success') ? 1 : 0;
        trm.coinMiniName = widget.coinModel.coin['coinType'];
        trm.isTest = widget.coinModel.isTest ? 1 : 0;
        await db.insertTransationRecord(trm);
        isEdit = true;
      } else {
        final trm = rtrm[0];
        final newTime = (cri.blockTime ?? 0).toString();
        if (trm.txTime != newTime) {
          trm.txTime = newTime;
          await db.updateTransationRecord(trm);
          isEdit = true;
        }
      }
    }
    if (isEdit) getTransactionData(Load.refresh);
  }

  /// 通用交易记录同步（DOT / APT / TON）— 复用 CommonResponseItemModel 格式
  Future<void> getTransactionDataNetworkGeneric(List<CommonResponseItemModel>? cril) async {
    if (cril == null) return;
    bool isEdit = false;
    for (int i = cril.length - 1; i >= 0; i--) {
      final cri = cril[i];
      final hash = cri.hash ?? '';
      if (hash.isEmpty) continue;
      final rtrm = await db.selectTransationRecordTxHash(hash, widget.coinModel.address);
      if (!mounted) return;
      if (rtrm.isEmpty) {
        final trm = TransationRecordModel();
        trm.coinId = (widget.coinModel.isTest
                ? widget.coinModel.coin['chainId_test']
                : widget.coinModel.coin['chainId']) ??
            0;
        trm.coin = widget.coinModel.coin;
        trm.address = widget.coinModel.address ?? '';
        trm.from1 = (cri.from ?? '').toLowerCase();
        trm.to1 = (cri.to ?? '').toLowerCase();
        trm.price = BigInt.tryParse(cri.value ?? '0') ?? BigInt.zero;
        trm.contract = (widget.coinModel.coin['contract'] ?? '').toLowerCase();
        trm.walletIndex = ref.read(wapBridgeProvider).walletIndex;
        trm.txHash = hash;
        trm.gasPrice = BigInt.tryParse(cri.gasPrice ?? '0') ?? BigInt.zero;
        trm.gas = int.tryParse(cri.gas ?? '0') ?? 0;
        trm.txTime = cri.timeStamp ?? '0';
        trm.state = int.tryParse(cri.txreceiptStatus ?? '0') ?? 0;
        trm.coinMiniName = widget.coinModel.coin['coinType'];
        trm.isTest = widget.coinModel.isTest ? 1 : 0;
        await db.insertTransationRecord(trm);
        isEdit = true;
      } else {
        final trm = rtrm[0];
        if (trm.txTime != (cri.timeStamp ?? '0')) {
          trm.txTime = cri.timeStamp ?? '0';
          await db.updateTransationRecord(trm);
          isEdit = true;
        }
      }
    }
    if (isEdit) getTransactionData(Load.refresh);
  }
  Future<void> getTxInfoNetwork(TransationRecordModel transationRecordModel)async{
    TransationRecordModel rtrm=await ref.read(tripBridgeProvider).checkUndoneTrReturn(transationRecordModel) ?? transationRecordModel;
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
  Future<void> getTxInfoNetworkBtc(BtcTransactionRecodeModel transationRecordModel)async{
    BtcTransactionRecodeModel rtrm=await ref.read(tripBridgeProvider).checkUndoneTrBtcReturn(transationRecordModel) ?? transationRecordModel;
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
          /*if(widget.coinModel.coin['coinType'] == CoinType.N.name || widget.coinModel.coin['coinType'] == CoinType.ETH.name || widget.coinModel.coin['coinType'] == CoinType.BTC.name)
            InkWell(
              onTap: () async {
                showtestAndMainnetWidget();
              },
              child: Container(
                width: ScreenUtil().setWidth(40.0),
                height: ScreenUtil().setWidth(40.0),
                //padding: EdgeInsets.all(ScreenUtil().setWidth(5.0)),
                child: Image.asset(
                  "assets/wallet/${widget.coinModel.isTest ? "testnet" : "mainnet"}.png",
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainBlueColor.name),
                ),
              ),
            ),
          InkWell(
            onTap: (){
              if (marketInfo != null) {
                if(marketInfo!["coin_gecko_id"]=="")return;
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            MarketCoinInfo(marketInfo ?? {})));
              }
            },
            child: Container(
              width: ScreenUtil().setWidth(40.0),
              height: ScreenUtil().setWidth(40.0),
              margin: EdgeInsets.only(right:ScreenUtil().setWidth(30.0),left: ScreenUtil().setWidth(20.0),),
              child: Image.asset(
                'assets/wallet/marketInfo.png',
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainBlueColor.name),
              ),
            ),
          ),*/
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
            /*WalletChainInfoTitle(
              title: Text(
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
              subtitle: tokenSymbol == null
                  ? null
                  : Text(
                "$tokenSymbol($tokenName)",
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainTextColor.name),
                  fontSize: ScreenUtil().setSp(24.0),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              rightImgUrl: 'assets/wallet/marketInfo.png',
              rightTao: () {
                if (marketInfo != null) {
                  if(marketInfo!["coin_gecko_id"]=="")return;
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              MarketCoinInfo(marketInfo ?? {})));
                }
              },
              rightTaoChangeNetworkWidget:
              (widget.coinModel.coin['coinType'] == CoinType.N.name &&
                  widget.coinModel.privateKey == null)
                  ? InkWell(
                onTap: () async {
                  showtestAndMainnetWidget();
                },
                child: Container(
                  width: ScreenUtil().setWidth(50.0),
                  height: ScreenUtil().setWidth(50.0),
                  padding: EdgeInsets.all(ScreenUtil().setWidth(5.0)),
                  child: Image.asset(
                    "assets/wallet/${widget.coinModel.isTest ? "testnet" : "mainnet"}.png",
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.mainBlueColor.name),
                  ),
                ),
              )
                  : null,
            ),*/
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await getTransactionData(Load.refresh);
                  await getTransactionDataNetwork(Load.refresh);
                  await widget.coinModel.getBalance();
                  setState(() {});
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
                      coinType: widget.coinModel.coin['coinType'],
                      balanceStr:
                      '${widget.coinModel.balanceStringAll()}${widget.coinModel.coin['unit'].toString().toUpperCase()}',
                      balanceDollarStr: '\$${widget.coinModel.valueString()}',
                      marketValueStr:
                      '\$${widget.coinModel.coinPriceString()}',
                      lockAmountStr: null,
                      xmlLockInfoTap: null,
                      tokenAddTap: null,
                      swapAddTap: null,
                      sellAddTap: null,
                      sendTap: _handleSend,
                      receiveTap: _handleReceive,
                      browserTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => BrowserPage(
                                  browserUrl,
                                  //S.of(context).g_key_m_15
                                )));
                      },
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
                          if(widget.coinModel.coin['blockchainType']==BlockchainType.Ethereum.name)
                            InkWell(
                              onTap: ()async{
                                if(widget.coinModel.coin['coinType']==CoinType.N.name){
                                  bool? r=await Navigator.push(context, MaterialPageRoute(builder: (context)=>TransactionRetry(widget.coinModel,"",)));
                                  if(r==true){
                                    getTransactionData(Load.refresh);
                                  }
                                }else{
                                  bool? r=await Navigator.push(context, MaterialPageRoute(builder: (context)=>TransactionDetailEth(widget.coinModel,"",)));
                                  if(r==true){
                                    getTransactionData(Load.refresh);
                                  }
                                }
                              },
                              child: Container(
                                height: ScreenUtil().setWidth(50),
                                width: ScreenUtil().setWidth(50),
                                padding: EdgeInsets.all(ScreenUtil().setWidth(5)),
                                child: Icon(Icons.search,color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),),
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

  Widget transactionsWidget() {
    if (transactionList.isEmpty) {
      //IntrinsicHeight: Dynamically calculated height
      return IntrinsicHeight(
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
  /*
  //显示切换主网和测试网的弹层
  showtestAndMainnetWidget() {
    List<Widget> childs = [];
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
    childs.add(InkWell(
      onTap: () {
        if (isTest == false) {
          Navigator.pop(context);
          return;
        }
        changeNet(
          false,
          Load.refresh,
        );
        Navigator.pop(context);
      },
      child: Container(
          padding: EdgeInsets.all(20.0),
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              Container(
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
    ));
    childs.add(InkWell(
      onTap: () {
        if (isTest) {
          Navigator.pop(context);
          return;
        }
        changeNet(true, Load.refresh);
        Navigator.pop(context);
      },
      child: Container(
          padding: EdgeInsets.all(20.0),
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              Container(
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
    ));
    sheetBottom(
        context,
        "",
        Column(
          children: childs,
        ));
  }
  */
  //切换网络，测试网络还是主网
  Future<void> changeNet(bool isTest, Load loadType) async {
    try {
      WalletActionProvider wap=ref.read(wapBridgeProvider);
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
  void showActionButtonListWidget(){
    List<Widget> childs = [];
    //send
    childs.add(InkWell(
      onTap: () async {
        await _handleSend(closeSheet: true);
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
        await _handleReceive(closeSheet: true);
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
    //batch transfer - only for EVM chains
    if(widget.coinModel.coin['blockchainType'] == BlockchainType.Ethereum.name) {
      childs.add(Divider(
        height: ScreenUtil().setWidth(1),
        indent: 0,
        endIndent: 0,
      ));
      childs.add(InkWell(
        onTap: () async {
          await _handleBatchTransfer();
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
                  child: Icon(
                    Icons.groups,
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                    size: ScreenUtil().setWidth(40.0),
                  ),
                ),
                SizedBox(
                  width: ScreenUtil().setWidth(20.0),
                ),
                Text(
                  'Batch Transfer',
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                    fontSize: ScreenUtil().setSp(30.0),
                  ),
                ),
                SizedBox(width: ScreenUtil().setWidth(10.0)),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ScreenUtil().setWidth(8),
                    vertical: ScreenUtil().setWidth(2),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(ScreenUtil().setWidth(6)),
                  ),
                  child: Text(
                    'NEW',
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(18),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            )),
      ));
    }
    // NFT Gallery — 非合约代币 且 链在 SimpleHash 支持列表中
    if (widget.coinModel.coin['isContract'] != true &&
        SimpleHashNftApi.chainMap.containsKey(
            (widget.coinModel.coin['coinType'] as String? ?? '').toUpperCase())) {
      childs.add(Divider(
        height: ScreenUtil().setWidth(1),
        indent: 0,
        endIndent: 0,
      ));
      childs.add(InkWell(
        onTap: () async {
          Navigator.pop(context);
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NftListPage(widget.coinModel),
            ),
          );
        },
        child: Container(
            padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                SizedBox(
                  width: ScreenUtil().setWidth(40.0),
                  height: ScreenUtil().setWidth(40.0),
                  child: Icon(
                    Icons.collections_outlined,
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                    size: ScreenUtil().setWidth(40.0),
                  ),
                ),
                SizedBox(width: ScreenUtil().setWidth(20.0)),
                Text(
                  S.of(context).g_key_nft_gallery,
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                    fontSize: ScreenUtil().setSp(30.0),
                  ),
                ),
              ],
            )),
      ));
    }
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
            ref.read(wapBridgeProvider).initWallet(shouldInitCoinInfo: true);
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
    if(widget.coinModel.coin['coinType'] == CoinType.N.name
        || widget.coinModel.coin['coinType'] == CoinType.ETH.name
        || widget.coinModel.coin['coinType'] == CoinType.BTC.name
        || widget.coinModel.coin['coinType'] == CoinType.DOT.name
        || widget.coinModel.coin['coinType'] == CoinType.ZIL.name
    ){
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
    }
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
    sheetBottom(
        context,
        "",
        Column(
          children: childs,
        ));
  }
}
