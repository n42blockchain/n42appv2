// 返回币的基础 gas 费
import 'package:n42_wallet/features/component/enums/coin_type.dart';

int getCoinGas(String coinType, {bool contract = false}) {
  final index = CoinType.values.indexWhere((e) => e.name == coinType);
  if (index == -1) return 50000;

  switch (CoinType.values[index]) {
    case CoinType.N:
    case CoinType.ETH:
    case CoinType.MATIC:
    case CoinType.HT:
    case CoinType.GNOSIS:
    case CoinType.CELO:
    case CoinType.FTM:
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
    case CoinType.AVAX:
    case CoinType.ETC:
    case CoinType.CLO:
    case CoinType.POA:
    case CoinType.BNB:
    case CoinType.METIS:
    case CoinType.ZETA:
    case CoinType.BOBA:
    case CoinType.OP:
    case CoinType.BASE:
    case CoinType.ARB:
    case CoinType.S:
      return contract ? 500000 : 50000;
    case CoinType.SOL:
      return 1;
    case CoinType.TRX:
      return contract ? 70000 : 21000;
    case CoinType.BTC:
      return 5;
    case CoinType.LTC:
    case CoinType.BCH:
      return 3;
    case CoinType.DOGE:
      return 1000;
    case CoinType.DASH:
    case CoinType.VIA:
    case CoinType.DGB:
    case CoinType.MONA:
    case CoinType.BTG:
    case CoinType.RVN:
      return 10;
    case CoinType.XTZ:
    case CoinType.XRP:
    case CoinType.ALGO:
    case CoinType.ATOM:
    case CoinType.SUI:
    case CoinType.TON:
      return 1;
    case CoinType.FIL:
      return 10000000;
    case CoinType.DOT:
    case CoinType.ACA:
    case CoinType.KSM:
      return 1;
    case CoinType.APT:
      return 100;
    case CoinType.ZIL:
      return contract ? 8000 : 1;
    default:
      return 0;
  }
}
