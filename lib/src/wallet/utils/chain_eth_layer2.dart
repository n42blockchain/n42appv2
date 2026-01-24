//判断是否是以太坊二级网络
import 'package:n42appv2/src/component/enums/coin_type.dart';

getEthLayer2(String symbol){
  if(symbol==CoinType.BOBA.name
      || symbol==CoinType.OP.name
  || symbol==CoinType.BASE.name
  || symbol==CoinType.ARB.name
  ){
    return true;
  }
  return false;
}
