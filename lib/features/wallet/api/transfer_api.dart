import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/core/network/activity_api.dart';
import 'package:n42_wallet/features/models/message_model.dart';
import 'package:n42_wallet/features/utils/data_utils.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/algo_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/apt_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/atom_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/btc_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/dot_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/fil_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/sol_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/ton_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/trx_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/xrp_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/xtz_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/zil_api.dart';
import 'package:n42_wallet/features/wallet/api/token_view_api.dart';
import 'package:n42_wallet/features/wallet/models/btc_transaction_recode_model.dart';
import 'package:n42_wallet/features/wallet/models/transation_record_model.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/provider/trustdart.dart';
import 'package:n42_wallet/features/wallet/provider/wallet_action_provider.dart';
import 'package:n42_wallet/features/wallet/utils/chain/chain_eip1559.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/features/wallet/utils/transaction/coin_gas.dart';
import 'package:n42_wallet/features/wallet/utils/validation/signature_validator.dart';
import 'package:decimal/decimal.dart';
import 'package:web3dart/web3dart.dart';
import 'package:n42_wallet/core/providers/legacy_wallet_adapter.dart';
import 'package:n42_wallet/generated/l10n.dart';

part 'transfer/transfer_base.dart';
part 'transfer/transfer_evm.dart';
part 'transfer/transfer_btc.dart';
part 'transfer/transfer_sol.dart';
part 'transfer/transfer_trx.dart';
part 'transfer/transfer_cosmos_family.dart';
part 'transfer/transfer_others.dart';

class TransferApi
    with
        _TransferBaseMixin,
        _TransferEvmMixin,
        _TransferBtcMixin,
        _TransferSolMixin,
        _TransferTrxMixin,
        _TransferCosmosFamilyMixin,
        _TransferOthersMixin {

  ///转账方法
  /// chainSymbol 链缩写 例如：Bitcoin:btc或BTC都可以
  /// fromAddress 转出地址
  /// toAddress 转入地址
  /// value 转账金额 double类型
  /// maxValue 是否是最大转账金额，默认 是最大转账金额
  /// contractAddeess 合约地址 ，如果是合约币转账，传入合约地址
  Future<MessageModel> transfer(
      String chainSymbol ,String toAddress, double value,
      {String contractAddress = "", String fromAddress = "",bool isTest=false,bool maxValue=true,String? message}) async {
    WalletActionProvider wap = globalWapAdapter;
    chainSymbol=symbolDealWith(chainSymbol);
    Map<String, dynamic>? txChainMap =
    wap.walletMap[chainSymbol.toString().toUpperCase()];
    if (txChainMap == null) {
      MessageModel mm = MessageModel.error();
      mm.data = S.current.g_key_wallet_m1(chainSymbol);
      return mm;
    }
    Map<String, dynamic>? token;
    if (contractAddress != "") {
      if(isTest){
        if (txChainMap['testnets']['testnetContract'].length != 0) {
          token = txChainMap['testnets']['testnetContract'][contractAddress.toString().toUpperCase()];
        }
      }else{
        if (txChainMap['mainnets'].length != 0) {
          token = txChainMap['mainnets'][contractAddress.toString().toUpperCase()];
        }
      }

      if (token == null) {
        MessageModel mm = MessageModel.error();
        mm.data = S.current.g_key_wallet_m2;
        return mm;
      }
    }

    if (fromAddress == "") {
      String? fAddress = wap.getAddress(txChainMap['baseInfo']['coinType'],
          addrType: txChainMap['addrType']);
      if (fAddress == null) {
        MessageModel mm = MessageModel.error();
        mm.data = S.current.g_key_wallet_m3(txChainMap['baseInfo']['coinType']);
        return mm;
      } else {
        fromAddress = fAddress;
      }
    }
    String blockchain = txChainMap['baseInfo']['blockchainType'];
    String path=txChainMap['baseInfo']['path'][txChainMap['addrType']];
    int pathIndex=txChainMap["pathIndex"]??0;
    path=getPathWithIndex(path, pathIndex);
    String coinType=txChainMap['baseInfo']['coinType'];
    MessageModel txmm=MessageModel();
    switch (blockchain) {
      case "Bitcoin":
        txmm= await transferBtc(
            txChainMap['baseInfo']['coinType'],
            fromAddress,
            toAddress,
            value,
            path,
            maxValue: maxValue,
            isTest:isTest?"test":"main",

        );
        break;
      case "Ethereum":
        txmm= await transferEth(
          isTest?txChainMap['baseInfo']['chainId_test']:txChainMap['baseInfo']['chainId'],
          txChainMap['baseInfo']['coinType'],
          fromAddress,
          toAddress,
          value,
          txChainMap['baseInfo']['decimals'],
          path,

          contractAddress: contractAddress,
          tokenDecimals: token==null?0:token['decimals'],
          isTest:isTest,
          maxValue: maxValue,
          message: message,
        );
        break;
      case "Solana":
        txmm= await transferSol(
            txChainMap,
            fromAddress,
            toAddress,
            value,
            txChainMap['baseInfo']['decimals'],
            path,

            contractAddress: contractAddress,tokenDecimals: token==null?0:token['decimals'],
            maxValue: maxValue
        );
        break;
      case "Tron":
        txmm= await transferTrx(
            fromAddress,
            toAddress,
            value,
            txChainMap['baseInfo']['decimals'],
            path,

            contractAddress: contractAddress,tokenDecimals: token==null?0:token['decimals'],
            maxValue: maxValue
        );
        break;
      case "Algorand":
        return await transferAlgo(
          fromAddress,
          toAddress,
          value,
          txChainMap['baseInfo']['decimals'],
          path,

          maxValue: maxValue,
        );
      case "Tezos":
        return await transferXtz(
            fromAddress,
            toAddress,
            value,
            txChainMap['baseInfo']['decimals'],
            path,

            maxValue: maxValue
        );
      case "Ripple":
        return await transferXrp(
            fromAddress,
            toAddress,
            value,
            txChainMap['baseInfo']['decimals'],
            path,

            maxValue: maxValue
        );
      case "Cosmos":
        return await transferAtom(
          fromAddress,
          toAddress,
          value,
          txChainMap['baseInfo']['decimals'],
          path,
          maxValue: maxValue,
        );
    }
    if (txmm.error == false) {
      Map<String, dynamic> pushMap = {
        "uuid": AppGlobals.userInfo?.uuid??"",
        "coin": coinType,
        "tx": txmm.data['txHash'],
        "network":isTest?"test":"main",
      };
      ActivityApi activityApi=ActivityApi();
      activityApi.collectDelayPush(json.encode(pushMap), event: "transaction");
    }
    return txmm;
  }

  //钱包转账使用，此方法无需检测币是否存在，也无需检测转账是否无误
  Future<MessageModel> transferWallet({TransationRecordModel? trModel,BtcTransactionRecodeModel? trModelBtc,String? privateKey,int pathIndex=0})async{
    String blockchain = "";
    if(trModel==null){
      blockchain=trModelBtc!.coin['blockchainType'];
    }else{
      blockchain=trModel.coin['blockchainType'];
    }
    MessageModel txmm=MessageModel();
    String coinType="";
    String network="main";
    switch (blockchain) {
      case "Bitcoin":
        List<Map<String,dynamic>> utxo=[];
        for(InputModel im in trModelBtc!.inputModelsList){
          utxo.add(im.toMap());
        }
        coinType=trModelBtc.coin['coinType'];
        network=trModelBtc.isTest==0?"main":"test";
        txmm= await transferBtcSend(
          trModelBtc.coin['coinType'],
          trModelBtc.address,
          trModelBtc.to1,
          trModelBtc.price,
          getPathWithIndex(trModelBtc.coin['path'][trModelBtc.addrType], pathIndex),
          trModelBtc.gas,
          trModelBtc.gasPrice,
          trModelBtc.inputModelsMap(),
          max: trModelBtc.max,
          privateKey: privateKey,
          isTest: trModelBtc.isTest==0?"main":"test",
        );
        break;
      case "Ethereum":
        coinType=trModel!.coin['coinType'];
        network=trModel.isTest==0?"main":"test";
        double gasPrice2Double=toEther(trModel.gasPriceValue.toString(), trModel.coin['decimals']).toDouble();
        gasPrice2Double=gasPrice2Double/2;
        Decimal rValue=Decimal.parse(gasPrice2Double.toString());
        BigInt gasPrice2=ethToWeiString(rValue.toString(), trModel.coin['decimals']);
        String? rpc;
        if(trModel.isTest==0){
          rpc=trModel.coin['service'];
        }else{
          rpc=trModel.coin['service_test'];
        }
        txmm= await transferEthSend(
          trModel.from1,
          trModel.to1,
          trModel.price,
          getPathWithIndex(trModel.coin['path'][trModel.addrType], pathIndex),
          trModel.gasPriceValue,
          gasPrice2,
          trModel.gas,//gas
          trModel.coin['coinType'],
          trModel.isTest==0?trModel.coin['chainId']:trModel.coin['chainId_test'],
          contractAddress: trModel.contract,
          isTest: trModel.isTest==0?"main":"test",
          privateKey: privateKey,
          nonce: trModel.nonce,
          message: trModel.message,
          erc721Or1155:trModel.erc721Or1155,
          returnSignHash:trModel.returnSignHash,
          rpc: rpc,
        );
        break;
      case "Solana":
        coinType=CoinType.SOL.name;
        network=trModel!.isTest==0?"main":"test";
        txmm= await transferSolSend(
          trModel.from1,
          trModel.to1,
          trModel.price,
          getPathWithIndex(trModel.coin['path'][trModel.addrType], pathIndex),
          trModel.gasPrice,
          contractAddress: trModel.contract,
          tokenDecimals: trModel.coin['decimals'],
          isTest:trModel.isTest==0?"main":"test",
          privateKey: privateKey,
        );
        break;
      case "Tron":
        coinType=CoinType.TRX.name;
        network=trModel!.isTest==0?"main":"test";
        txmm= await transferTrxSend(
          trModel.from1,
          trModel.to1,
          trModel.price,
          getPathWithIndex(trModel.coin['path'][trModel.addrType], pathIndex),
          trModel.gasPrice,
          contractAddress: trModel.contract,
          isTest:trModel.isTest==0?"main":"test",
          privateKey: privateKey,
        );
        break;
      case "Algorand":
        coinType=CoinType.ALGO.name;
        network=trModel!.isTest==0?"main":"test";
        String type="ALGO";
        if(trModel.contract !=""){
          type="Asset";
        }
        if(trModel.other !=null){
          type=trModel.other.type;
        }
        txmm= await transferAlgoSend(trModel.from1,
          trModel.to1,
          trModel.price.toString(),
          getPathWithIndex(trModel.coin['path'][trModel.addrType], pathIndex),
          isTest: trModel.isTest==0?"main":"test",
          privateKey: privateKey,
          contractAddress: trModel.contract,
          type: type,
        );
        break;
      case "Tezos":
        coinType=CoinType.XTZ.name;
        network=trModel!.isTest==0?"main":"test";
        txmm= await transferXtzSend(
          trModel.from1,
          trModel.to1,
          trModel.price.toInt(),
          getPathWithIndex(trModel.coin['path'][trModel.addrType], pathIndex),
          isTest: trModel.isTest==0?false:true,
          privateKey: privateKey,
        );
        break;
      case "Ripple":
        coinType=CoinType.XRP.name;
        network=trModel!.isTest==0?"main":"test";
        txmm= await transferXrpSend(trModel.from1,
          trModel.to1,
          trModel.price,
          trModel.gasPrice,
          getPathWithIndex(trModel.coin['path'][trModel.addrType], pathIndex),
          trModel.other.sequence,
          isTest: trModel.isTest==0?false:true,
          privateKey: privateKey,
          destinationTag: trModel.other.destinationTag,
        );
        break;
      case "Filecoin":
        coinType=CoinType.FIL.name;
        network=trModel!.isTest==0?"main":"test";
        txmm=await transferFilSend(
            trModel.from1,
            trModel.to1,
            trModel.price,
            trModel.gasPrice,
            getPathWithIndex(trModel.coin['path'][trModel.addrType], pathIndex),
            trModel.nonce??"0",
            trModel.gas.toString(),
            trModel.other.gasFeeCap,
            trModel.other.gasPremium,isTest:trModel.isTest==0?false:true);
        break;
      case "Cosmos":
        coinType=CoinType.ATOM.name;
        network=trModel!.isTest==0?"main":"test";
        txmm= await transferAtomSend(
          trModel.from1,
          trModel.to1,
          trModel.price,
          getPathWithIndex(trModel.coin['path'][trModel.addrType], pathIndex),
          trModel.gasPrice,
          contractAddress: trModel.contract,
          isTest:trModel.isTest==0?"main":"test",
          privateKey: privateKey,
        );
        break;
      case "Polkadot":
        coinType=trModel!.coin['coinType'];
        network=trModel.isTest==0?"main":"test";
        txmm= await transferDotSend(
          trModel.from1,
          trModel.to1,
          trModel.price,
          getPathWithIndex(trModel.coin['path'][trModel.addrType], pathIndex),
          trModel.gasPrice,
          coinType,
          contractAddress: trModel.contract,
          isTest:trModel.isTest==0?"main":"test",
          privateKey: privateKey,
          returnSignHash:trModel.returnSignHash,
        );
        break;
      case "Aptos":
        coinType=trModel!.coin['coinType'];
        network=trModel.isTest==0?"main":"test";
        txmm=await transferAptSend(
            trModel.from1,
            trModel.to1,
            trModel.price,
            getPathWithIndex(trModel.coin['path'][trModel.addrType], pathIndex),
            trModel.gas,
            trModel.gasPrice,
            coinType, trModel.coinId);
        break;
      case "TheOpenNetwork":
        coinType=trModel!.coin['coinType'];
        network=trModel.isTest==0?"main":"test";
        txmm=await transferTonSend(
            trModel.from1,
            trModel.to1,
            trModel.price,
            getPathWithIndex(trModel.coin['path'][trModel.addrType], pathIndex),
            trModel.gas,
            trModel.gasPrice,
            coinType,
          isTest: trModel.isTest==0?"main":"test",
        );
        break;
      case "Zilliqa":
        coinType=trModel!.coin['coinType'];
        network=trModel.isTest==0?"main":"test";
        txmm=await transferZilSend(
            trModel.from1,
            trModel.to1,
            trModel.price,
            getPathWithIndex(trModel.coin['path'][trModel.addrType], pathIndex),
            trModel.gas,
            trModel.gasPrice,
            coinType,
          isTest: trModel.isTest==0?"main":"test",
          privateKey: privateKey,
        );
        break;
    }
    if (txmm.error == false) {
      Map<String, dynamic> pushMap = {
        "uuid": AppGlobals.userInfo?.uuid??"",
        "coin": coinType,
        "tx": txmm.data,
        "network":network,
      };
      ActivityApi activityApi=ActivityApi();
      activityApi.collectDelayPush(json.encode(pushMap), event: "transaction");
    }
    return txmm;
  }
}
