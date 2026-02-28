import 'dart:convert';

import 'package:n42_wallet/core/config/app_config.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/core/network/base_api.dart';
import 'package:n42_wallet/features/mining_v1/api/mining_config.dart';
import 'package:n42_wallet/features/mining_v1/api/mining_token.dart';
import 'package:n42_wallet/features/mining_v1/provider/mining_v1_providers.dart';
import 'package:n42_wallet/features/mining_v1/utils/mining_cache_utils.dart';
import 'package:n42_wallet/features/mining_v1/utils/mining_utils.dart';
import 'package:n42_wallet/features/wallet/provider/trustdart.dart';
import 'package:n42_wallet/core/providers/legacy_wallet_adapter.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:http/http.dart';
import 'package:wallet/wallet.dart' show EthereumAddress;
import 'package:web3dart/web3dart.dart';
class MiningApi {
  static MiningToken? _token;
  static Web3Client? _client;

  static int mainBeijingBlock = 770000;
  static int testBeijingBlock = 40000;
  static const int _rewardInterval = 10800;
  static const double _dayBlockCount = 24 * 60 * 60 / 8;

  static Future<void> cleanToken() async {
    _token = null;
    _client = null;
  }

  static Future<void> createToken() async {
    if (_token != null && _client != null) return;
    final astServiceUrl = await MiningCacheUtils.getCurrentMiningNodeIp();
    final isMainChainMining = await MiningUtils.isMainChainMining();
    final contractAddress = isMainChainMining
        ? miningNodeMap["miningContract"] as String
        : miningNodeMap["miningContract_test"] as String;

    _client = Web3Client(astServiceUrl, Client());
    _token = MiningToken.init(
        address: EthereumAddress.fromHex(contractAddress), client: _client!);
  }

  static void setMiningNode(String nodeAddress) {
    _client = Web3Client(nodeAddress, Client());
    final contract = miningNodeMap["miningContract"] as String;
    _token = MiningToken.init(
        address: EthereumAddress.fromHex(contract), client: _client!);
  }

  static Future<String?> getPrivateKey() async {
    final wap = globalWapAdapter;
    final mp = globalMiningV1;
    final walletInfo = wap.walletInfoLsit[mp.walletIndex];
    final astMap = walletInfo.coinInfo?[CoinType.N.name];
    if (astMap == null) return null;

    final pathIndex = astMap['pathIndex'] ?? 0;
    final path = getPathWithIndex(astMap["baseInfo"]["path"]["legacy"], pathIndex);
    final privateKey = walletInfo.privateKey ??
        await Trustdart().getPrivateKey(walletInfo.mnemonic ?? "", CoinType.N.name, path);
    final pk = base64Decode(privateKey);
    return bytesToHex(pk);
  }

  static Future<EthPrivateKey> _getCredentials() async {
    await createToken();
    final privateKey = await getPrivateKey();
    assert(privateKey != null);
    return EthPrivateKey.fromHex(privateKey!);
  }

  static Future deposit(String pubKey, String msg, BigInt value) async {
    final credentials = await _getCredentials();
    return await _token?.deposit(pubKey, msg, value, credentials: credentials);
  }

  static Future depositAllowed(BigInt value) async {
    final credentials = await _getCredentials();
    return await _token?.depositAllowed(value, credentials: credentials);
  }

  static Future depositsOf(String address) async {
    final credentials = await _getCredentials();
    return await _token?.depositsOf(address, credentials: credentials);
  }

  static Future lockTime(String address) async {
    final credentials = await _getCredentials();
    return await _token?.lockTime(address, credentials: credentials);
  }

  static Future getTransactionReceipt(String hashTx) async {
    await createToken();
    return await _client?.getTransactionReceipt(hashTx);
  }

  static Future getBlockNumber() async {
    await createToken();
    return await _client?.getBlockNumber();
  }

  static Future unlock() async {
    final credentials = await _getCredentials();
    return await _token?.unlock(credentials: credentials);
  }

  static Map<String, dynamic> _rpcParams(String method, List<dynamic> params) =>
      {"jsonrpc": "2.0", "method": method, "params": params, "id": 1};

  static Future _postRpc(String chainUrl, String method, List<dynamic> params) async {
    final p = _rpcParams(method, params);
    return await BaseApi.requestEmptyH.post(chainUrl, data: p, params: p);
  }

  static Future<int> _getStartBlockHeight() async {
    final isMain = await MiningUtils.isMainChainMining();
    return isMain ? mainBeijingBlock : testBeijingBlock;
  }

  static Future revenue24(String address) async {
    final chainUrl = await MiningCacheUtils.getCurrentMiningNodeIp();
    final int currentBlockNum = await MiningApi.getBlockNumber();
    final dayBlockNum = (currentBlockNum - _dayBlockCount).clamp(0, currentBlockNum).toInt();
    final from = dayBlockNum.toRadixString(16);
    return _postRpc(chainUrl, "apos_getRewards", [address, '0x$from', 'latest']);
  }

  static Future getNearMonthData(String address) async {
    final chainUrl = await MiningCacheUtils.getCurrentMiningNodeIp();
    final int currentBlockNum = await MiningApi.getBlockNumber();
    final monthBlockNum = 30 * _dayBlockCount;
    final monthBeforeBlockNum = (currentBlockNum - monthBlockNum).clamp(0, currentBlockNum).toInt();
    final from = monthBeforeBlockNum.toRadixString(16);
    return _postRpc(chainUrl, "apos_getRewards", [address, '0x$from', 'latest']);
  }

  static Future getTotalMiningValue(String address) async {
    final chainUrl = await MiningCacheUtils.getCurrentMiningNodeIp();
    return _postRpc(chainUrl, "apos_getRewards", [address, '0x0', 'latest']);
  }

  static Future getMiningFromBlockNum(
      String address, int fromBlockNum, int toBlockNum) async {
    final chainUrl = await MiningCacheUtils.getCurrentMiningNodeIp();
    final from = fromBlockNum.toRadixString(16);
    final to = toBlockNum.toRadixString(16);
    return _postRpc(chainUrl, "apos_getRewards", [address, '0x$from', '0x$to']);
  }

  static Future getMiningTaskList(String address, String? fromBlockNum,
      {int pageSize = 20}) async {
    final chainUrl = await MiningCacheUtils.getCurrentMiningNodeIp();
    return _postRpc(chainUrl, "apos_getMinedBlock",
        [address, fromBlockNum ?? "latest", pageSize]);
  }

  static Future getCurrentMiningTime(String address) async {
    final chainUrl = await MiningCacheUtils.getCurrentMiningNodeIp();
    final int currentBlockHeight = await MiningApi.getBlockNumber();
    final startBlockHeight = await _getStartBlockHeight();

    final flagNum = (currentBlockHeight - startBlockHeight) ~/ _rewardInterval;
    final lastRewardBlockHeight = startBlockHeight + flagNum * _rewardInterval;
    final from = currentBlockHeight.toRadixString(16);
    final to = lastRewardBlockHeight.toRadixString(16);

    return _postRpc(chainUrl, "apos_verifiedBlock",
        [address, '0x$from', _rewardInterval, '0x$to']);
  }

  static Future getLastCycleMiningTime(String address) async {
    final chainUrl = await MiningCacheUtils.getCurrentMiningNodeIp();
    final int currentBlockHeight = await MiningApi.getBlockNumber();
    final startBlockHeight = await _getStartBlockHeight();

    final flagNum = (currentBlockHeight - startBlockHeight) ~/ _rewardInterval;
    final lastRewardBlockHeight = startBlockHeight + flagNum * _rewardInterval;
    final prevRewardBlockHeight = lastRewardBlockHeight - _rewardInterval;

    final from = lastRewardBlockHeight.toRadixString(16);
    final to = prevRewardBlockHeight.toRadixString(16);

    return _postRpc(chainUrl, "apos_verifiedBlock",
        [address, '0x$from', _rewardInterval, '0x$to']);
  }

  static Future getTaskDetail(String blockNumber) async {
    final chainUrl = await MiningCacheUtils.getCurrentMiningNodeIp();
    return _postRpc(chainUrl, "eth_getBlockByNumber", [blockNumber, true]);
  }

  static Future getAllRewardsList(String address) async {
    final chainUrl = await MiningCacheUtils.getCurrentMiningNodeIp();
    final startBlockHeight = await _getStartBlockHeight();
    final from = startBlockHeight.toRadixString(16);
    return _postRpc(chainUrl, "apos_getRewards", [address, '0x$from', 'latest']);
  }

  static Future<List<int>> generateRewardsArray() async {
    final flagNum = await getLastEpochNum();
    return List.generate(7, (i) => flagNum - 6 + i);
  }

  static Future<int> getLastEpochNum() async {
    final int currentBlockHeight = await MiningApi.getBlockNumber();
    final startBlockHeight = await _getStartBlockHeight();
    return (currentBlockHeight - startBlockHeight) ~/ _rewardInterval;
  }

  static Future getMiningBarChartData(String address,
      {int? currEpochNum}) async {
    final isMain = await MiningUtils.isMainChainMining();
    final hostKey = isMain ? 'main' : 'test';
    final baseUrl = "${AppConfig.apiUrl['blockBrowserHost'][hostKey]}/api/v2/addresses/";
    final epochQuery = currEpochNum != null ? "?epoch=$currEpochNum" : "";
    final requestUrl = "$baseUrl$address/verify_daily$epochQuery";
    return await BaseApi.requestEmptyH.get(requestUrl, params: {});
  }

  static Future getAccountRewardUnpaid(String address) async {
    final chainUrl = await MiningCacheUtils.getCurrentMiningNodeIp();
    return _postRpc(chainUrl, "apos_getAccountRewardUnpaid", [address]);
  }
}