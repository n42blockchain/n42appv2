//判断是否支持1559
import 'package:n42appv2/src/component/enums/coin_type.dart';

bool get1559WithChainSymbol(String symbol){
  if(symbol==CoinType.GO.name
      || symbol==CoinType.OKT.name
      || symbol==CoinType.KCS.name
      || symbol==CoinType.VIC.name
      || symbol==CoinType.KLAY.name
      || symbol==CoinType.METIS.name
      || symbol==CoinType.ETC.name
  ){
    return false;
  }
  return true;
}
