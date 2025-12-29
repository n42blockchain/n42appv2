//获取浏览器地址，根据交易hash
import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/src/https/request_url.dart';
import 'package:n42appv2/src/wallet/provider/wallet_action_provider.dart';
import 'package:provider/provider.dart';

getBrowser_txHash(String coinType,String txHash,{bool? isTest}){
  coinType=coinType.toUpperCase();
  if(isTest==null){
    Map<String,dynamic> coinMap=Provider.of<WalletActionProvider>(AppGlobals.appContext,listen: false).walletMap[coinType];
    isTest=coinMap['isTest'];
  }
  String path=RequestUrl().getUrl2(coinType, "browser",isTest: isTest);
  if(path=="")return path;
  switch(coinType){
    case "ETH":
    case "BNB":
    case "MATIC":
    case "ETC":
    case "AVAX":
    case "XDAI":
    case "FTM":
    case "POA":
    case "MOVE":
    case "VIC":
    case "WAN":
    case "CRO":
    case "KCS":
    case "BOBA":
    case "MTR":
    case "OP":
    case "ARB":
    case "AURORA":
    case "ALGO":
    case "LTC":
    case "DOGE":
    case "VIA":
    case "DGB":
    case "MONA":
    case "FIRO":
    case "QTUM":
    case "XEC":
    case "N":
    case "CELO":
    case "CLO":
    case "GO":
    case "MOVR":
    case "GLMR":
    case "KLAY":
    case "ZETA":
    case "BASE":
      path+='tx/${txHash}';
      break;
    case "ATOM":
    case "XRP":
    case "TT":
      path+='transactions/${txHash}';
      break;
    case "TRX":
      path+='transaction/${txHash}';
      break;
    case "BCH":
    case "BTC":
      path+='explorer/transactions/${coinType}/${txHash}';
      break;
    case "BTG":
      path+='insight/tx/${txHash}';
      break;
    case "HT":
      path+='en-us/tx/${txHash}';
      break;
    case "EVMOS":
    case "KAVA":
      path+='txs/${txHash}';
      break;
    case "SOL":
      path+='tx/${txHash}${isTest! ?"?cluster=testnet":""}';
      break;
    case "OKT":
      path+='okc/tx/${txHash}';
      break;
    case "XTZ":
      path+=txHash;
      break;
    case "DASH":
      path+='tx.dws?${txHash}.htm';
      break;
    case "METIS":
      path+='en/tx/${txHash}';
      break;
    case "RVN":
      path+='rvn/transaction/${txHash}';
      break;
    case "FIL":
      path+='message/${txHash}';
      break;
    case "DOT":
    case "ACA":
    case "KSM":
      path+='extrinsic/${txHash}';
      break;
    case "APT":
      path+='txn/${txHash}?network=${isTest!?"testnet":"mainnet"}';
      break;
    default:
      path="";
      break;
  }
  return path;
}