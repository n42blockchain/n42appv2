//返回币的基础gas费
import 'package:n42appv2/src/component/enums/coin_type.dart';

GetCoinGas(String coinType,{bool contract=false}){
  int index=CoinType.values.indexWhere((element) => element.name==coinType?true:false);
  int _gas=0;
  if(index==-1)return 50000;
  CoinType ct=CoinType.values[index];
  switch(ct){
    case CoinType.N :
    case CoinType.ETH :
    case CoinType.MATIC :
    case CoinType.HT :
    case CoinType.XDAI :
    case CoinType.CELO :
    case CoinType.FTM :
    case CoinType.MOVE:
    case CoinType.VIC:
    case CoinType.TT:
    case CoinType.GO:
    case CoinType.WAN:
    case CoinType.CRO:
    case CoinType.KAVA:
    case CoinType.KCS:
    case CoinType.EVMOS:
    case CoinType.MOVR:
    case CoinType.GLMR:
    case CoinType.KLAY:
    case CoinType.MTR:
    case CoinType.OKT:
    case CoinType.AURORA:
    case CoinType.AVAX :
    case CoinType.ETC:
    case CoinType.CLO:
    case CoinType.POA:
    case CoinType.BNB:
    case CoinType.METIS:
    case CoinType.ZETA:
    case CoinType.MOVE:
    case CoinType.BOBA:
    case CoinType.OP:
    case CoinType.BASE:
    case CoinType.ARB:
    case CoinType.S:
      if(contract==false){
        _gas=50000;
      }else{
        _gas=500000;
      }
      break;


      /*
      case CoinType.ARB:
      case CoinType.OP:
      if(contract==false){
        _gas=500000;
      }else{
        _gas=500000;
      }
      break;
    case CoinType.BOBA:
    case CoinType.BASE:
      if(contract==false){
        _gas=100000;
      }else{
        _gas=1000000;
      }
      break;*/
    case CoinType.SOL:
      _gas=1;
      break;
    case CoinType.TRX:
      if(contract==false){
        _gas=21000;
      }else{
        _gas=70000;
      }
      break;
    case CoinType.BTC:
      _gas=5;
      break;
    case CoinType.LTC:
      _gas=3;
      break;
    case CoinType.BCH:
      _gas=3;
      break;
    case CoinType.DOGE:
      _gas=1000;
      break;
    case CoinType.DASH:
      _gas=10;
      break;
    case CoinType.VIA:
    case CoinType.DGB:
    case CoinType.MONA:
    case CoinType.BTG:
    case CoinType.RVN:
      _gas=10;
      break;
    case CoinType.XTZ:
    case CoinType.XRP:
    case CoinType.ALGO:
    case CoinType.ATOM:
    case CoinType.SUI:
    case CoinType.TON:
      _gas=1;
      break;
    case CoinType.FIL:
      _gas=10000000;
      break;
    case CoinType.DOT:
    case CoinType.ACA:
    case CoinType.KSM:
      _gas=1;
      break;
    case CoinType.APT:
      _gas=100;
      break;
    case CoinType.ZIL:
      if(contract==false){
        _gas=1;
      }else{
        _gas=8000;
      }
      break;
    default:
    _gas=0;
      break;
  }
  return _gas;
}
