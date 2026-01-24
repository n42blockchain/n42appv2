import 'dart:async';

import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/src/component/enums/coin_type.dart';
import 'package:n42appv2/src/models/message_model.dart';
import 'package:n42appv2/src/sqlite/app_database.dart';
import 'package:n42appv2/core/utils/event_bus.dart';
import 'package:n42appv2/core/utils/toast_utils.dart';
import 'package:n42appv2/src/wallet/api/chain_api/algo_api.dart';
import 'package:n42appv2/src/wallet/api/chain_api/btc_api.dart';
import 'package:n42appv2/src/wallet/api/chain_api/fil_api.dart';
import 'package:n42appv2/src/wallet/api/chain_api/xrp_api.dart';
import 'package:n42appv2/src/wallet/api/chain_api/xtz_api.dart';
import 'package:n42appv2/src/wallet/api/chain_api/zil_api.dart';
import 'package:n42appv2/src/wallet/api/token_view_api.dart';
import 'package:n42appv2/src/wallet/models/btc_transaction_recode_model.dart';
import 'package:n42appv2/src/wallet/models/transation_record_model.dart';
import 'package:n42appv2/src/wallet/provider/wallet_action_provider.dart';
import 'package:flutter/material.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:provider/provider.dart';

class TransactionRecordItemProvider with ChangeNotifier{
  AppDatabase? _db;
  AppDatabase get db{
    _db ??= AppDatabase();
    return _db!;
  }
  //未完成的列表
  List<TransationRecordModel> _unDoneTrModelList=[];
  List<TransationRecordModel> get unDoneTrModelList=>_unDoneTrModelList;

  //比特币类 未完成列表
  List<BtcTransactionRecodeModel> _trUndoneList=[];
  List<BtcTransactionRecodeModel> get trUndoneList=>_trUndoneList;
  int timerCount=0;

  Timer? _timer;
  Timer? _timerBtc;
  TokenViewApi? _tokenViewApi;
  TokenViewApi get tokenViewApi{
    _tokenViewApi ??= TokenViewApi();
    return _tokenViewApi!;
  }
  //查询未完成的交易
  Future<void> selectUndoneTr()async{
    _unDoneTrModelList=await db.selectTransationRecordUnDone(AppGlobals.userInfo?.uuid??"");
    _trUndoneList=await db.selectBtcTransationRecordByUUID(AppGlobals.userInfo?.uuid??"", 2);
    if(_unDoneTrModelList.isNotEmpty){
      //开启timer，循环请求数据
      timerStart();
    }
    if(_trUndoneList.isNotEmpty){
      timerStartBtc();
    }
  }
  //添加未完成的交易，type：0比特币类，1其它类型
  void addUndoneTr(dynamic trm,int type){
    if(type==1){
      _unDoneTrModelList.add(trm);
      timerStart();
    }else{
      _trUndoneList.add(trm);
      timerStartBtc();
    }
  }
  void timerStart(){
    if(_timer!=null)return;
    _timer=Timer.periodic(Duration(seconds: 10), (timer) {
      if(_unDoneTrModelList.isNotEmpty){
        for(int i=0;i<_unDoneTrModelList.length;i++){
          checkUndoneTr(_unDoneTrModelList[i]);
        }
      }
      if(_unDoneTrModelList.isEmpty && _timer !=null ){
        _timer!.cancel();
        _timer=null;
      }
    });
  }
  void timerStartBtc(){
    if(_timerBtc!=null)return;
    _timerBtc=Timer.periodic(Duration(seconds: 180), (timer) {
      if(_trUndoneList.isNotEmpty){
        for(int i=0;i<_trUndoneList.length;i++){
          checkUndoneTrBtc(_trUndoneList[i]);
        }
      }
      if(_trUndoneList.isEmpty && _timerBtc !=null){
        _timerBtc!.cancel();
        _timerBtc=null;
      }
    });
  }
  //检查未完成的交易
  Future<void> checkUndoneTr(TransationRecordModel trm)async{
    BlockchainType bt=BlockchainType.values.firstWhere((element) => element.name==trm.coin['blockchainType']?true:false);
    switch(bt){
      case BlockchainType.Ethereum:
        MessageModel mm= await tokenViewApi.getTransactionReceiptEth(trm.coin['coinType'],trm.txHash,isTest:trm.isTest==0?false:true,rpc: trm.coin['custom']==true?trm.isTest==0?trm.coin['service']:trm.coin['service_test']:null);
        if(mm.error==false){
          if(trm.coin['coinType']==CoinType.S.name){
            if(mm.data['status']=="0x1"){
              trm.state=1;
            }
            else if(mm.data['status']=="0x0"){
              trm.state=2;
            }
          }else{
            if(mm.data['error']['code']!=0){
              return;
            }
            if(mm.data['result']['status']=="0x1"){
              trm.state=1;
              //await WalletDatabaseProvider.dbProvider.updateTransationRecord(trm);
              //ToastUtils.show(S.current.g_key_140);
            }
            else if(mm.data['result']['status']=="0x0"){
              trm.state=2;
            }
          }
        }
        break;
      case BlockchainType.Solana:
        MessageModel mm= await tokenViewApi.getTransactionSolana(trm.txHash,trm.isTest==0?"main":"test");
        if(mm.error==false){
          int mapLength=mm.data.length;
          if(mapLength!=0){
            final err=mm.data['Err']['InstructionError'];
            if(err==null){
              final ok=mm.data['Ok'];
              if(ok==null){
                trm.state=1;
              }
            }else{
              trm.state=2;
            }
          }
        }
        break;
      case BlockchainType.Tron:
        MessageModel mm= await tokenViewApi.getTransactionReceiptTrx(trm.txHash,isTest:trm.isTest==0?false:true);
        if(mm.error==false){
          if(mm.data['error']['code']!=0){
            return;
          }
          if(mm.data['result']['status']=="0x1"){
            trm.state=1;
            //await WalletDatabaseProvider.dbProvider.updateTransationRecord(trm);
            //ToastUtils.show(S.current.g_key_140);
          }
          else if(mm.data['result']['status']=="0x0"){
            trm.state=2;
          }
        }
        break;
      case BlockchainType.Algorand:
        AlgoApi algoApi=AlgoApi();
        MessageModel mm=await algoApi.getTransactionsInfo(trm.txHash,isTest: trm.isTest==0?false:true);
        if(mm.error==false){
          /*if(mm.data['confirmed-round']==0){
            return;
          }
          if(mm.data['confirmed-round']>6){
            trm.state=1;
            await WalletDatabaseProvider.dbProvider.updateTransationRecord(trm);
            ToastUtils.show(S.current.g_key_140);
          }*/
          trm.state=1;
          //await WalletDatabaseProvider.dbProvider.updateTransationRecord(trm);
          //ToastUtils.show(S.current.g_key_140);
        }
        break;
      case BlockchainType.Tezos:
        XtzApi xtzApi=XtzApi();
        MessageModel mm=await xtzApi.getTxInfoXtz(trm.txHash,trm.isTest==0?false:true);
        if(mm.error==false){
          List<dynamic> rData=mm.data;
          if(rData.isNotEmpty){
            if(rData[0]['is_success']==true){
              trm.state=1;
              //await WalletDatabaseProvider.dbProvider.updateTransationRecord(trm);
              //ToastUtils.show(S.current.g_key_140);
            }
          }
        }
        break;
      case BlockchainType.Ripple:
        XrpApi xrpApi=XrpApi();
        MessageModel mm=await xrpApi.getTxInfoXrp(trm.txHash,trm.isTest==0?false:true);
        if(mm.error==false){
          if(mm.data=="tesSUCCESS"){
            trm.state=1;
            //await WalletDatabaseProvider.dbProvider.updateTransationRecord(trm);
            //ToastUtils.show(S.current.g_key_140);
          }
        }
        break;
      case BlockchainType.Bitcoin:
        // TODO: Handle this case.
        break;
      case BlockchainType.Cosmos:
        // TODO: Handle this case.
        break;
      case BlockchainType.Filecoin:
        FilApi filApi=FilApi();
        MessageModel mm=await filApi.getMessageInfo(trm.txHash);
        if(mm.error==false){
          trm.state=1;
        }
        break;
      case BlockchainType.Polkadot:
        // TODO: Handle this case.
        break;
      case BlockchainType.Aptos:
        // TODO: Handle this case.
        break;
      case BlockchainType.Sui:
        // TODO: Handle this case.
        break;
      case BlockchainType.TheOpenNetwork:
        // TODO: Handle this case.
        break;
      case BlockchainType.Stellar:
        // TODO: Handle this case.
        break;
      case BlockchainType.VeChain:
        // TODO: Handle this case.
        break;
      case BlockchainType.Harmony:
        // EVM compatible - uses Ethereum RPC
        MessageModel mmHarmony = await tokenViewApi.getTransactionReceiptEth(trm.coin['coinType'],trm.txHash,isTest:trm.isTest==0?false:true,rpc: trm.coin['custom']==true?trm.isTest==0?trm.coin['service']:trm.coin['service_test']:null);
        if(mmHarmony.error==false){
          if(mmHarmony.data['error']['code']!=0){
            return;
          }
          if(mmHarmony.data['result']['status']=="0x1"){
            trm.state=1;
          }else if(mmHarmony.data['result']['status']=="0x0"){
            trm.state=2;
          }
        }
        break;
      case BlockchainType.IoTeX:
        // EVM compatible - uses Ethereum RPC
        MessageModel mmIotex = await tokenViewApi.getTransactionReceiptEth(trm.coin['coinType'],trm.txHash,isTest:trm.isTest==0?false:true,rpc: trm.coin['custom']==true?trm.isTest==0?trm.coin['service']:trm.coin['service_test']:null);
        if(mmIotex.error==false){
          if(mmIotex.data['error']['code']!=0){
            return;
          }
          if(mmIotex.data['result']['status']=="0x1"){
            trm.state=1;
          }else if(mmIotex.data['result']['status']=="0x0"){
            trm.state=2;
          }
        }
        break;
      case BlockchainType.Near:
        // TODO: Handle this case.
        break;
      case BlockchainType.Zilliqa:
        ZilApi zilApi = ZilApi(isTest: trm.isTest==0?false:true);
        MessageModel mm = await zilApi.getTransaction(trm.txHash);
        if(mm.error==false){
          // Transaction found and confirmed
          if(mm.data['receipt'] != null){
            if(mm.data['receipt']['success'] == true){
              trm.state=1;
            }else{
              trm.state=2;
            }
          }
        }
        break;
      case BlockchainType.Theta:
        // EVM compatible - uses Ethereum RPC
        MessageModel mmTheta = await tokenViewApi.getTransactionReceiptEth(trm.coin['coinType'],trm.txHash,isTest:trm.isTest==0?false:true,rpc: trm.coin['custom']==true?trm.isTest==0?trm.coin['service']:trm.coin['service_test']:null);
        if(mmTheta.error==false){
          if(mmTheta.data['error']['code']!=0){
            return;
          }
          if(mmTheta.data['result']['status']=="0x1"){
            trm.state=1;
          }else if(mmTheta.data['result']['status']=="0x0"){
            trm.state=2;
          }
        }
        break;
      case BlockchainType.Cardano:
        // TODO: Handle this case.
        break;
      case BlockchainType.MultiversX:
        // TODO: Handle this case.
        break;
      case BlockchainType.Starknet:
        // TODO: Handle this case.
        break;
      case BlockchainType.EOSIO:
        // TODO: Handle this case.
        break;
      case BlockchainType.Waves:
        // TODO: Handle this case.
        break;
      case BlockchainType.Neo:
        // TODO: Handle this case.
        break;
      case BlockchainType.Ontology:
        // TODO: Handle this case.
        break;
      case BlockchainType.NEM:
        // TODO: Handle this case.
        break;
      case BlockchainType.Nano:
        // TODO: Handle this case.
        break;
      case BlockchainType.Decred:
        // TODO: Handle this case.
        break;
      case BlockchainType.ICON:
        // TODO: Handle this case.
        break;
      case BlockchainType.IOST:
        // TODO: Handle this case.
        break;
      case BlockchainType.Ark:
        // TODO: Handle this case.
        break;
      case BlockchainType.Qtum:
        // TODO: Handle this case.
        break;
      case BlockchainType.Hive:
        // TODO: Handle this case.
        break;
    }
    if(trm.state==1){
      await db.updateTransationRecord(trm);
      ToastUtils.show(S.current.g_key_140);
      //发出交易成功通知
      if (!AppGlobals.appContext.mounted) return;
      Provider.of<WalletActionProvider>(AppGlobals.appContext,listen: false).refreshCoinBalance(trm.coin['coinType'],contract:trm.contract);
      eventBus.fire(EventPublic(EventPublicType.transferOk));
      /**if(trm.contract!=""){
          ProviderUtil.coinInfoProvider().getBalance_main();
          ProviderUtil.coinInfoProvider().changeSelectType_token();
          }else{
          ProviderUtil.coinInfoProvider().getBalance_main();
          }*/
      int trmIndex=_unDoneTrModelList.indexWhere((value){
        if(trm.txHash==value.txHash){
          return true;
        }
        return false;
      });
      if(trmIndex>=0){
        _unDoneTrModelList.removeAt(trmIndex);
      }
    }else if(trm.state==2){
      await db.updateTransationRecord(trm);
      ToastUtils.show(S.current.g_key_175);
      int trmIndex=_unDoneTrModelList.indexWhere((value){
        if(trm.txHash==value.txHash){
          return true;
        }
        return false;
      });
      if(trmIndex>=0){
        _unDoneTrModelList.removeAt(trmIndex);
      }
    }
    checkUndoneList();
  }
  Future<TransationRecordModel?> checkUndoneTrReturn(TransationRecordModel trm)async{
    BlockchainType bt=BlockchainType.values.firstWhere((element) => element.name==trm.coin['blockchainType']?true:false);
    switch(bt){
      case BlockchainType.Ethereum:
        MessageModel mm= await tokenViewApi.getTransactionReceiptEth(trm.coin['coinType'],trm.txHash,isTest:trm.isTest==0?false:true,rpc: trm.coin['custom']==true?trm.isTest==0?trm.coin['service']:trm.coin['service_test']:null);
        if(mm.error==false){
          if(trm.coin['coinType']==CoinType.S.name){
            if(mm.data['status']=="0x1"){
              trm.state=1;
            }
            else if(mm.data['status']=="0x0"){
              trm.state=2;
            }
          }else{
            if(mm.data['error']['code']!=0){
              return null;
            }
            if(mm.data['result']['status']=="0x1"){
              trm.state=1;
              //await WalletDatabaseProvider.dbProvider.updateTransationRecord(trm);
              //ToastUtils.show(S.current.g_key_140);
            }else if(mm.data['result']['status']=="0x0"){
              trm.state=2;
            }
          }
        }
        break;
      case BlockchainType.Solana:
        MessageModel mm= await tokenViewApi.getTransactionSolana(trm.txHash,trm.isTest==0?"main":"test");
        if(mm.error==false){
          int mapLength=mm.data.length;
          if(mapLength!=0){
            final err=mm.data['Err']['InstructionError'];
            if(err==null){
              final ok=mm.data['Ok'];
              if(ok==null){
                trm.state=1;
              }
            }else{
              trm.state=2;
            }
          }
        }
        break;
      case BlockchainType.Tron:
        MessageModel mm= await tokenViewApi.getTransactionReceiptTrx(trm.txHash,isTest:trm.isTest==0?false:true);
        if(mm.error==false){
          if(mm.data['error']['code']!=0){
            return null;
          }
          if(mm.data['result']['status']=="0x1"){
            trm.state=1;
            //await WalletDatabaseProvider.dbProvider.updateTransationRecord(trm);
            //ToastUtils.show(S.current.g_key_140);
          }else if(mm.data['result']['status']=="0x0"){
            trm.state=2;
          }
        }
        break;
      case BlockchainType.Algorand:
        AlgoApi algoApi=AlgoApi();
        MessageModel mm=await algoApi.getTransactionsInfo(trm.txHash,isTest: trm.isTest==0?false:true);
        if(mm.error==false){
          /*if(mm.data['confirmed-round']==0){
            return;
          }
          if(mm.data['confirmed-round']>6){
            trm.state=1;
            await WalletDatabaseProvider.dbProvider.updateTransationRecord(trm);
            ToastUtils.show(S.current.g_key_140);
          }*/
          trm.state=1;
          //await WalletDatabaseProvider.dbProvider.updateTransationRecord(trm);
          //ToastUtils.show(S.current.g_key_140);
        }
        break;
      case BlockchainType.Tezos:
        XtzApi xtzApi=XtzApi();
        MessageModel mm=await xtzApi.getTxInfoXtz(trm.txHash,trm.isTest==0?false:true);
        if(mm.error==false){
          List<dynamic> rData=mm.data;
          if(rData.isNotEmpty){
            if(rData[0]['is_success']==true){
              trm.state=1;
              //await WalletDatabaseProvider.dbProvider.updateTransationRecord(trm);
              //ToastUtils.show(S.current.g_key_140);
            }
          }
        }
        break;
      case BlockchainType.Ripple:
        XrpApi xrpApi=XrpApi();
        MessageModel mm=await xrpApi.getTxInfoXrp(trm.txHash,trm.isTest==0?false:true);
        if(mm.error==false){
          if(mm.data=="tesSUCCESS"){
            trm.state=1;
            //await WalletDatabaseProvider.dbProvider.updateTransationRecord(trm);
            //ToastUtils.show(S.current.g_key_140);
          }
        }
        break;
      case BlockchainType.Bitcoin:
        // TODO: Handle this case.
        break;
      case BlockchainType.Cosmos:
        // TODO: Handle this case.
        break;
      case BlockchainType.Filecoin:
        FilApi filApi=FilApi();
        MessageModel mm=await filApi.getMessageInfo(trm.txHash);
        if(mm.error==false){
          trm.state=1;
        }
        break;
      case BlockchainType.Polkadot:
        // TODO: Handle this case.
        break;
      case BlockchainType.Aptos:
        // TODO: Handle this case.
        break;
      case BlockchainType.Sui:
        // TODO: Handle this case.
        break;
      case BlockchainType.TheOpenNetwork:
        // TODO: Handle this case.
        break;
      case BlockchainType.Stellar:
        // TODO: Handle this case.
        break;
      case BlockchainType.VeChain:
        // TODO: Handle this case.
        break;
      case BlockchainType.Harmony:
        // EVM compatible - uses Ethereum RPC
        MessageModel mmHarmony = await tokenViewApi.getTransactionReceiptEth(trm.coin['coinType'],trm.txHash,isTest:trm.isTest==0?false:true,rpc: trm.coin['custom']==true?trm.isTest==0?trm.coin['service']:trm.coin['service_test']:null);
        if(mmHarmony.error==false){
          if(mmHarmony.data['error']['code']!=0){
            return null;
          }
          if(mmHarmony.data['result']['status']=="0x1"){
            trm.state=1;
          }else if(mmHarmony.data['result']['status']=="0x0"){
            trm.state=2;
          }
        }
        break;
      case BlockchainType.IoTeX:
        // EVM compatible - uses Ethereum RPC
        MessageModel mmIotex = await tokenViewApi.getTransactionReceiptEth(trm.coin['coinType'],trm.txHash,isTest:trm.isTest==0?false:true,rpc: trm.coin['custom']==true?trm.isTest==0?trm.coin['service']:trm.coin['service_test']:null);
        if(mmIotex.error==false){
          if(mmIotex.data['error']['code']!=0){
            return null;
          }
          if(mmIotex.data['result']['status']=="0x1"){
            trm.state=1;
          }else if(mmIotex.data['result']['status']=="0x0"){
            trm.state=2;
          }
        }
        break;
      case BlockchainType.Near:
        // TODO: Handle this case.
        break;
      case BlockchainType.Zilliqa:
        ZilApi zilApi = ZilApi(isTest: trm.isTest==0?false:true);
        MessageModel mm = await zilApi.getTransaction(trm.txHash);
        if(mm.error==false){
          // Transaction found and confirmed
          if(mm.data['receipt'] != null){
            if(mm.data['receipt']['success'] == true){
              trm.state=1;
            }else{
              trm.state=2;
            }
          }
        }
        break;
      case BlockchainType.Theta:
        // EVM compatible - uses Ethereum RPC
        MessageModel mmTheta = await tokenViewApi.getTransactionReceiptEth(trm.coin['coinType'],trm.txHash,isTest:trm.isTest==0?false:true,rpc: trm.coin['custom']==true?trm.isTest==0?trm.coin['service']:trm.coin['service_test']:null);
        if(mmTheta.error==false){
          if(mmTheta.data['error']['code']!=0){
            return null;
          }
          if(mmTheta.data['result']['status']=="0x1"){
            trm.state=1;
          }else if(mmTheta.data['result']['status']=="0x0"){
            trm.state=2;
          }
        }
        break;
      case BlockchainType.Cardano:
        // TODO: Handle this case.
        break;
      case BlockchainType.MultiversX:
        // TODO: Handle this case.
        break;
      case BlockchainType.Starknet:
        // TODO: Handle this case.
        break;
      case BlockchainType.EOSIO:
        // TODO: Handle this case.
        break;
      case BlockchainType.Waves:
        // TODO: Handle this case.
        break;
      case BlockchainType.Neo:
        // TODO: Handle this case.
        break;
      case BlockchainType.Ontology:
        // TODO: Handle this case.
        break;
      case BlockchainType.NEM:
        // TODO: Handle this case.
        break;
      case BlockchainType.Nano:
        // TODO: Handle this case.
        break;
      case BlockchainType.Decred:
        // TODO: Handle this case.
        break;
      case BlockchainType.ICON:
        // TODO: Handle this case.
        break;
      case BlockchainType.IOST:
        // TODO: Handle this case.
        break;
      case BlockchainType.Ark:
        // TODO: Handle this case.
        break;
      case BlockchainType.Qtum:
        // TODO: Handle this case.
        break;
      case BlockchainType.Hive:
        // TODO: Handle this case.
        break;
    }
    await db.updateTransationRecordTxhash(trm);
    return trm;
  }
  //检查未完成的交易
  Future<void> checkUndoneTrBtc(BtcTransactionRecodeModel trm)async{
    if(trm.isTest==1){
      MessageModel mm=await BtcApi(test: trm.isTest==1?true:false).getTxState(trm.txHash);
      if(mm.error){

      }else{
        if(mm.data['confirmed']==true){
          trm.state=1;
          await db.updateBtcTransactionRecord(trm);
        }
      }
    }else{
      MessageModel mm=await tokenViewApi.getTxConfirmation(trm.coin['coinType'], trm.txHash);
      //BTCProvider? btc=ProviderUtil.walletsProviderDefault().coinByName_btc(trm.coin['coinType']);
      //if(btc==null)return;
      //MessageModel mm=await btc.getTransactionInfo(trm.txHash, trm.trId.toString());
      if(mm.error){
      }else{
        int? confirmations=mm.data;
        trm.confirmations=confirmations??0;
        if(trm.confirmations>=6){
          trm.state=1;
        }
        await db.updateBtcTransactionRecord(trm);
        if(trm.state==1){
          //ProviderUtil.btcCoinInfoProvider().getBalance();
          //发出交易成功通知
          if (!AppGlobals.appContext.mounted) return;
          await Provider.of<WalletActionProvider>(AppGlobals.appContext,listen: false).refreshCoinBalance(trm.coin['coinType'],contract:"");
          eventBus.fire(EventPublic(EventPublicType.transferOk));
          _trUndoneList.remove(trm);
          checkUndoneList();
        }
      }
    }
  }
  Future<BtcTransactionRecodeModel?> checkUndoneTrBtcReturn(BtcTransactionRecodeModel trm)async{
    if(trm.isTest==1){
      MessageModel mm=await BtcApi(test: trm.isTest==1?true:false).getTxState(trm.txHash);
      if(mm.error){

      }else{
        if(mm.data['confirmed']==true){
          trm.state=1;
          await db.updateBtcTransactionRecord(trm);
        }
      }
    }else{
      MessageModel mm=await tokenViewApi.getTxConfirmation(trm.coin['coinType'], trm.txHash);
      //BTCProvider? btc=ProviderUtil.walletsProviderDefault().coinByName_btc(trm.coin['coinType']);
      //if(btc==null)return;
      //MessageModel mm=await btc.getTransactionInfo(trm.txHash, trm.trId.toString());
      if(mm.error){
      }else{
        int? confirmations=mm.data;
        trm.confirmations=confirmations??0;
        if(trm.confirmations>=6){
          trm.state=1;
        }
        await db.updateBtcTransactionRecord(trm);
      }
      return trm;
    }
    return null;
  }
  void checkUndoneList(){
    if(_trUndoneList.isEmpty && _timerBtc !=null){
      _timerBtc!.cancel();
      _timerBtc=null;
    }
    if(_unDoneTrModelList.isEmpty && _timer !=null){
      _timer!.cancel();
      _timer=null;
    }
  }
}
