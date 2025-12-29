import 'dart:async';

import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/src/component/enums/coin_type.dart';
import 'package:n42appv2/src/models/message_model.dart';
import 'package:n42appv2/core/storage/app_database.dart';
import 'package:n42appv2/core/utils/event_bus.dart';
import 'package:n42appv2/core/utils/toast_utils.dart';
import 'package:n42appv2/src/wallet/api/chain_api/algo_api.dart';
import 'package:n42appv2/src/wallet/api/chain_api/btc_api.dart';
import 'package:n42appv2/src/wallet/api/chain_api/fil_api.dart';
import 'package:n42appv2/src/wallet/api/chain_api/xrp_api.dart';
import 'package:n42appv2/src/wallet/api/chain_api/xtz_api.dart';
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
    if(_db==null){
      _db=AppDatabase();
    }
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
  Timer? _timer_btc;
  TokenViewApi? _tokenViewApi;
  TokenViewApi get tokenViewApi{
    if(_tokenViewApi==null){
      _tokenViewApi=TokenViewApi();
    }
    return _tokenViewApi!;
  }
  //查询未完成的交易
  selectUndoneTr()async{
    _unDoneTrModelList=await db.selectTransationRecord_unDone(AppGlobals.userInfo?.uuid??"");
    _trUndoneList=await db.selectBtcTransationRecord_byUUID(AppGlobals.userInfo?.uuid??"", 2);
    if(_unDoneTrModelList.length!=0){
      //开启timer，循环请求数据
      timerStart();
    }
    if(_trUndoneList.length!=0){
      timerStart_btc();
    }
  }
  //添加未完成的交易，type：0比特币类，1其它类型
  addUndoneTr(dynamic trm,int type){
    if(type==1){
      _unDoneTrModelList.add(trm);
      timerStart();
    }else{
      _trUndoneList.add(trm);
      timerStart_btc();
    }
  }
  timerStart(){
    if(_timer!=null)return;
    _timer=Timer.periodic(Duration(seconds: 10), (timer) {
      if(_unDoneTrModelList.length !=0){
        for(int i=0;i<_unDoneTrModelList.length;i++){
          checkUndoneTr(_unDoneTrModelList[i]);
        }
      }
      if(_unDoneTrModelList.length==0 && _timer !=null ){
        _timer!.cancel();
        _timer=null;
      }
    });
  }
  timerStart_btc(){
    if(_timer_btc!=null)return;
    _timer_btc=Timer.periodic(Duration(seconds: 180), (timer) {
      if(_trUndoneList.length !=0){
        for(int i=0;i<_trUndoneList.length;i++){
          checkUndoneTr_btc(_trUndoneList[i]);
        }
      }
      if(_trUndoneList.length==0 && _timer_btc !=null){
        _timer_btc!.cancel();
        _timer_btc=null;
      }
    });
  }
  //检查未完成的交易
  checkUndoneTr(TransationRecordModel trm)async{
    BlockchainType bt=BlockchainType.values.firstWhere((element) => element.name==trm.coin['blockchainType']?true:false);
    switch(bt){
      case BlockchainType.Ethereum:
        MessageModel mm= await tokenViewApi.getTransactionReceipt_eth(trm.coin['coinType'],trm.txHash,isTest:trm.isTest==0?false:true,rpc: trm.coin['custom']==true?trm.isTest==0?trm.coin['service']:trm.coin['service_test']:null);
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
        MessageModel mm= await tokenViewApi.getTransaction_solana(trm.txHash,trm.isTest==0?"main":"test");
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
        MessageModel mm= await tokenViewApi.getTransactionReceipt_trx(trm.txHash,isTest:trm.isTest==0?false:true);
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
        MessageModel mm=await xtzApi.getTxInfo_xtz(trm.txHash,trm.isTest==0?false:true);
        if(mm.error==false){
          List<dynamic> rData=mm.data;
          if(rData.length!=0){
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
        MessageModel mm=await xrpApi.getTxInfo_xrp(trm.txHash,trm.isTest==0?false:true);
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
    }
    if(trm.state==1){
      await db.updateTransationRecord(trm);
      ToastUtils.show(S.current.g_key_140);
      //发出交易成功通知
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
  checkUndoneTr_return(TransationRecordModel trm)async{
    BlockchainType bt=BlockchainType.values.firstWhere((element) => element.name==trm.coin['blockchainType']?true:false);
    switch(bt){
      case BlockchainType.Ethereum:
        MessageModel mm= await tokenViewApi.getTransactionReceipt_eth(trm.coin['coinType'],trm.txHash,isTest:trm.isTest==0?false:true,rpc: trm.coin['custom']==true?trm.isTest==0?trm.coin['service']:trm.coin['service_test']:null);
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
            }else if(mm.data['result']['status']=="0x0"){
              trm.state=2;
            }
          }
        }
        break;
      case BlockchainType.Solana:
        MessageModel mm= await tokenViewApi.getTransaction_solana(trm.txHash,trm.isTest==0?"main":"test");
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
        MessageModel mm= await tokenViewApi.getTransactionReceipt_trx(trm.txHash,isTest:trm.isTest==0?false:true);
        if(mm.error==false){
          if(mm.data['error']['code']!=0){
            return;
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
        MessageModel mm=await xtzApi.getTxInfo_xtz(trm.txHash,trm.isTest==0?false:true);
        if(mm.error==false){
          List<dynamic> rData=mm.data;
          if(rData.length!=0){
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
        MessageModel mm=await xrpApi.getTxInfo_xrp(trm.txHash,trm.isTest==0?false:true);
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
    }
    await db.updateTransationRecord_txhash(trm);
    return trm;
  }
  //检查未完成的交易
  checkUndoneTr_btc(BtcTransactionRecodeModel trm)async{
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
        trm.confirmations=confirmations==null?0:confirmations;
        if(trm.confirmations>=6){
          trm.state=1;
        }
        await db.updateBtcTransactionRecord(trm);
        if(trm.state==1){
          //ProviderUtil.btcCoinInfoProvider().getBalance();
          //发出交易成功通知
          await Provider.of<WalletActionProvider>(AppGlobals.appContext,listen: false).refreshCoinBalance(trm.coin['coinType'],contract:"");
          eventBus.fire(EventPublic(EventPublicType.transferOk));
          _trUndoneList.remove(trm);
          checkUndoneList();
        }
      }
    }
  }
  checkUndoneTr_btc_return(BtcTransactionRecodeModel trm)async{
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
        trm.confirmations=confirmations==null?0:confirmations;
        if(trm.confirmations>=6){
          trm.state=1;
        }
        await db.updateBtcTransactionRecord(trm);
      }
      return trm;
    }

  }
  checkUndoneList(){
    if(_trUndoneList.length==0 && _timer_btc !=null){
      _timer_btc!.cancel();
      _timer_btc=null;
    }
    if(_unDoneTrModelList.length==0 && _timer !=null){
      _timer!.cancel();
      _timer=null;
    }
  }
}