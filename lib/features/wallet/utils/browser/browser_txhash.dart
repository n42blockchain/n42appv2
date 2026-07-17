//获取浏览器地址，根据交易hash
import 'package:n42_wallet/core/providers/legacy_wallet_adapter.dart';
import 'package:n42_wallet/core/network/request_url.dart';

String getSafeBrowserTxHashUrl(
  Object? coinType,
  Object? txHash, {
  bool? isTest,
}) {
  final normalizedCoinType = coinType?.toString().trim();
  final normalizedTxHash = _encodeTxHashForBrowser(txHash);
  if (normalizedCoinType == null ||
      normalizedCoinType.isEmpty ||
      normalizedTxHash == null) {
    return '';
  }
  return getBrowserTxHash(normalizedCoinType, normalizedTxHash, isTest: isTest);
}

String getBrowserTxHash(String coinType, String txHash, {bool? isTest}) {
  coinType = coinType.trim().toUpperCase();
  txHash = txHash.trim();
  if (coinType.isEmpty || txHash.isEmpty) return "";
  if (isTest == null) {
    final coinMap = globalWapAdapter.walletMap[coinType];
    if (coinMap is Map && coinMap['isTest'] is bool) {
      isTest = coinMap['isTest'] as bool;
    } else {
      isTest = false;
    }
  }
  final bool resolvedIsTest = isTest;
  String path = RequestUrl().getUrl2(
    coinType,
    "browser",
    isTest: resolvedIsTest,
  );
  if (path == "") return path;
  switch (coinType) {
    case "ETH":
    case "S":
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
      path += 'tx/$txHash';
      break;
    case "ATOM":
    case "XRP":
    case "TT":
      path += 'transactions/$txHash';
      break;
    case "TRX":
      path += 'transaction/$txHash';
      break;
    case "BCH":
    case "BTC":
      path += 'explorer/transactions/$coinType/$txHash';
      break;
    case "BTG":
      path += 'insight/tx/$txHash';
      break;
    case "HT":
      path += 'en-us/tx/$txHash';
      break;
    case "EVMOS":
    case "KAVA":
      path += 'txs/$txHash';
      break;
    case "SOL":
      path += 'tx/$txHash${resolvedIsTest ? "?cluster=testnet" : ""}';
      break;
    case "OKT":
      path += 'okc/tx/$txHash';
      break;
    case "XTZ":
      path += txHash;
      break;
    case "DASH":
      path += 'tx.dws?$txHash.htm';
      break;
    case "METIS":
      path += 'en/tx/$txHash';
      break;
    case "RVN":
      path += 'rvn/transaction/$txHash';
      break;
    case "FIL":
      path += 'message/$txHash';
      break;
    case "DOT":
    case "ACA":
    case "KSM":
      path += 'extrinsic/$txHash';
      break;
    case "APT":
      path += 'txn/$txHash?network=${resolvedIsTest ? "testnet" : "mainnet"}';
      break;
    case "ZIL":
      path += 'tx/$txHash?network=${resolvedIsTest ? "testnet" : "mainnet"}';
      break;
    default:
      path = "";
      break;
  }
  if (!_isSafeBrowserUrl(path)) return "";
  return path;
}

String? _encodeTxHashForBrowser(Object? rawTxHash) {
  final txHash = rawTxHash?.toString().trim() ?? '';
  if (txHash.isEmpty) return null;
  return Uri.encodeComponent(txHash);
}

bool _isSafeBrowserUrl(String rawUrl) {
  if (rawUrl.isEmpty) return false;
  final uri = Uri.tryParse(rawUrl);
  if (uri == null || uri.host.isEmpty) return false;
  return uri.isScheme('https') || uri.isScheme('http');
}
