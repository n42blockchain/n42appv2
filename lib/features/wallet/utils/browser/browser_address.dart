//获取浏览器地址，根据币类型和地址
import 'package:n42_wallet/core/providers/legacy_wallet_adapter.dart';
import 'package:n42_wallet/core/network/request_url.dart';

String getBrowserAddress(String coinType,String address,{bool? isTest}){
  coinType=coinType.toUpperCase();
  if(isTest==null){
    Map<String,dynamic> coinMap=globalWapAdapter.walletMap[coinType];
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
    case "TT":
    case "WAN":
    case "CRO":
    case "KCS":
    case "BOBA":
    case "MTR":
    case "OP":
    case "ARB":
    case "AURORA":
    case "TRX":
    case "ALGO":
    case "BTC":
    case "LTC":
    case "DOGE":
    case "VIA":
    case "DGB":
    case "MONA":
    case "FIRO":
    case "BCH":
    case "BTG":
    case "RVN":
    case "QTUM":
    case "XEC":
    case "ZETA":
    case "BASE":
    case "FIL":
    case "N":
    case "S":
      path+='address/$address';
      break;
    case "CELO":
    case "CLO":
      path+='address/$address/transactions';
      break;
    case "HT":
      path+='en-us/address/$address?tab=Transactions';
      break;
    case "GO":
      path+='addr/$address';
      break;
    case "KAVA":
    case "EVMOS":
    case "MOVR":
    case "GLMR":
    case "KLAY":
      path+='account/$address';
      break;
    case "SOL":
      path+='account/$address${isTest! ?"?cluster=testnet":""}';
      break;
    case "OKT":
      path+='oktc/address/$address';
      break;
    case "XTZ":
      path+=address;
      break;
    case "ATOM":
    case "XRP":
      path+='accounts/$address';
      break;
    case "DASH":
      path+='address.dws?$address.htm';
      break;
    case "METIS":
      path+='en/address/$address';
      break;
    case "DOT":
    case "ACA":
    case "KSM":
      path+='account/$address';
      break;
    case "APT":
      path+='account/$address?network=${isTest!?"testnet":"mainnet"}';
      break;
    case "TON":
      path+='address/$address';
      break;
    case "ZIL":
      path+='address/$address?network=${isTest!?"testnet":"mainnet"}';
      break;
    default:
      path="";
      break;
  }
  return path;
}
