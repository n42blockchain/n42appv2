import 'dart:convert';

import 'package:n42_wallet/core/config/app_config.dart';
import 'package:n42_wallet/src/component/enums/coin_type.dart';
import 'package:n42_wallet/src/http/base_api.dart';
import 'package:n42_wallet/src/mining_v1/api/mining_config.dart';
import 'package:n42_wallet/src/mining_v1/api/mining_token.dart';
import 'package:n42_wallet/src/mining_v1/provider/mining_provider.dart';
import 'package:n42_wallet/src/mining_v1/provider/mining_v1_providers.dart';
import 'package:n42_wallet/src/mining_v1/utils/mining_cache_utils.dart';
import 'package:n42_wallet/src/mining_v1/utils/mining_utils.dart';
import 'package:n42_wallet/src/wallet/models/wallet_info.dart';
import 'package:n42_wallet/src/wallet/provider/trustdart.dart';
import 'package:n42_wallet/src/wallet/provider/wallet_action_provider.dart';
import 'package:n42_wallet/core/providers/legacy_wallet_adapter.dart';
import 'package:n42_wallet/src/wallet/utils/chain_util.dart';
import 'package:http/http.dart';
import 'package:wallet/wallet.dart' show EthereumAddress;
import 'package:web3dart/web3dart.dart';
class MiningApi {
  static MiningToken? _token;
  static Web3Client? _client;
  static cleanToken()async{
    if (_token != null && _client != null){
      _token=null;
      _client=null;
    }
  }
  static createToken() async {
    if (_token != null && _client != null) return;
    String astServiceUrl = await MiningCacheUtils.getCurrentMiningNodeIp();
    final String astMimingContract = miningNodeMap["miningContract"] as String;
    final String astMimingContractTest =
    miningNodeMap["miningContract_test"] as String;

    final isMainChainMining = await MiningUtils.isMainChainMining();
    final contractAddress =
    isMainChainMining ? astMimingContract : astMimingContractTest;


    _client = Web3Client(astServiceUrl, Client());
    _token = MiningToken.init(
        address: EthereumAddress.fromHex(contractAddress), client: _client!);
  }

  static setMiningNode(String nodeAddress) {
    _client = Web3Client(nodeAddress, Client());
    final String astMimingContract = miningNodeMap["miningContract"] as String;
    _token = MiningToken.init(
        address: EthereumAddress.fromHex(astMimingContract), client: _client!);
  }

  static Future<String?> getPrivateKey() async {
    WalletActionProvider wap=globalWapAdapter;
    MiningProvider mp=globalMiningV1;
    //获取ast的 private key
    WalletInfo walletInfo=wap.walletInfoLsit[mp.walletIndex];
    final Map<String, dynamic>? map = walletInfo.coinInfo;
    final astMap = map?[CoinType.N.name];
    if (astMap != null) {
      int pathIndex = astMap['pathIndex'] ?? 0;
      final path =
      getPathWithIndex(astMap["baseInfo"]["path"]["legacy"], pathIndex);
      // debugPrint("path: $path");
      String? privateKey=walletInfo.privateKey;
      if(walletInfo.privateKey ==null){
        privateKey=await Trustdart().getPrivateKey(walletInfo.mnemonic??"", CoinType.N.name, path);
      }
      // debugPrint("privateKey: $privateKey");
      final pk = base64Decode(privateKey!);
      return bytesToHex(pk);
        //HexUtils().uint8ToHex(pk);
    }
    return null;
  }

  static Future deposit(String pubKey, String msg, BigInt value) async {
    await createToken();
    final privateKey = await getPrivateKey();
    assert(privateKey != null);
    EthPrivateKey credentials = EthPrivateKey.fromHex(privateKey!);
    return await _token?.deposit(pubKey, msg, value, credentials: credentials);
  }

  static Future depositAllowed(BigInt value) async {
    await createToken();
    final privateKey = await getPrivateKey();
    assert(privateKey != null);
    EthPrivateKey credentials = EthPrivateKey.fromHex(privateKey!);
    return await _token?.depositAllowed(value, credentials: credentials);
  }
/*
  static Future getDepositRemain() async {
    await createToken();
    final privateKey = await getPrivateKey();
    assert(privateKey != null);
    EthPrivateKey credentials = EthPrivateKey.fromHex(privateKey!);
    return await _token?.getDepositRemain(credentials: credentials);
  }*/

  static Future depositsOf(String address) async {
    await createToken();
    final privateKey = await getPrivateKey();
    assert(privateKey != null);
    EthPrivateKey credentials = EthPrivateKey.fromHex(privateKey!);
    return await _token?.depositsOf(address, credentials: credentials);
  }
/*
  static Future depositCount() async {
    await createToken();
    final privateKey = await getPrivateKey();
    assert(privateKey != null);
    EthPrivateKey credentials = EthPrivateKey.fromHex(privateKey!);
    return await _token?.depositCount(credentials: credentials);
  }*/

  static Future lockTime(String address) async {
    await createToken();
    final privateKey = await getPrivateKey();
    assert(privateKey != null);
    EthPrivateKey credentials = EthPrivateKey.fromHex(privateKey!);
    return await _token?.lockTime(address, credentials: credentials);
  }

  /// Returns an receipt of a transaction based on its hash.
  static Future getTransactionReceipt(String hashTx) async {
    await createToken();
    return await _client?.getTransactionReceipt(hashTx);
  }

  static Future getBlockNumber() async {
    await createToken();
    return await _client?.getBlockNumber();
  }

  static Future unlock() async {
    await createToken();
    final privateKey = await getPrivateKey();
    assert(privateKey != null);
    EthPrivateKey credentials = EthPrivateKey.fromHex(privateKey!);
    return await _token?.unlock(credentials: credentials);
  }

  static Future revenue24(String address) async {
    String chainUrl = await MiningCacheUtils.getCurrentMiningNodeIp();
    final int currentBlockNum = await MiningApi.getBlockNumber();
    const dayBlockNumCount = 24 * 60 * 60 / 8;
    final dayBlockNum = currentBlockNum - dayBlockNumCount > 0
        ? (currentBlockNum - dayBlockNumCount).toInt()
        : 0;
    final from = dayBlockNum.toRadixString(16);
    Map<String, dynamic> params = {
      "jsonrpc": "2.0",
      "method": "apos_getRewards",
      "params": [address, '0x$from', 'latest'],
      "id": 1
    };
    return await BaseApi.requestEmptyH.post(chainUrl,
        data: params, params: params);
  }

  static Future getNearMonthData(
      String address,
      ) async {
    String chainUrl = await MiningCacheUtils.getCurrentMiningNodeIp();
    final int currentBlockNum = await MiningApi.getBlockNumber();
    const dayBlockNumCount = 24 * 60 * 60 / 8;
    const monthBlockNum = 30 * dayBlockNumCount;
    final monthBeforeBlockNum = currentBlockNum - monthBlockNum > 0
        ? (currentBlockNum - monthBlockNum).toInt()
        : 0;
    final from = monthBeforeBlockNum.toRadixString(16);
    Map<String, dynamic> params = {
      "jsonrpc": "2.0",
      "method": "apos_getRewards",
      "params": [address, '0x$from', 'latest'],
      "id": 1
    };
    return await BaseApi.requestEmptyH.post(chainUrl,
        data: params, params: params);
  }

  static Future getTotalMiningValue(String address) async {
    String chainUrl = await MiningCacheUtils.getCurrentMiningNodeIp();
    Map<String, dynamic> params = {
      "jsonrpc": "2.0",
      "method": "apos_getRewards",
      "params": [address, '0x0', 'latest'],
      "id": 1
    };
    return await BaseApi.requestEmptyH.post(chainUrl,
        data: params, params: params);
  }

  static Future getMiningFromBlockNum(
      String address, int fromBlockNum, int toBlockNum) async {
    String chainUrl = await MiningCacheUtils.getCurrentMiningNodeIp();
    final from = fromBlockNum.toRadixString(16);
    final to = toBlockNum.toRadixString(16);
    Map<String, dynamic> params = {
      "jsonrpc": "2.0",
      "method": "apos_getRewards",
      "params": [address, '0x$from', '0x$to'],
      "id": 1
    };
    return await BaseApi.requestEmptyH.post(chainUrl,
        data: params, params: params);
  }

  static Future getMiningTaskList(String address, String? fromBlockNum,
      {int pageSize = 20}) async {
    String chainUrl = await MiningCacheUtils.getCurrentMiningNodeIp();
    Map<String, dynamic> params = {
      "jsonrpc": "2.0",
      "method": "apos_getMinedBlock",
      //address types.Address, from jsonrpc.BlockNumberOrHash, count int
      "params": [address, fromBlockNum ?? "latest", pageSize],
      "id": 1
    };
    return await BaseApi.requestEmptyH.post(chainUrl,
        data: params, params: params);
  }

  ///获取最后一次出块之后 挖矿活动进行的时间
  static Future getCurrentMiningTime(
      String address,
      ) async {
    String chainUrl = await MiningCacheUtils.getCurrentMiningNodeIp();
    final int currentBlockHeight = await MiningApi.getBlockNumber();
    final isMain = await MiningUtils.isMainChainMining();
    final startBlockHeight = isMain ? mainBeijingBlock : testBeijingBlock;
    const rewardInterval = 10800;

    int flagNum = (currentBlockHeight - startBlockHeight) ~/ rewardInterval;
    int lastRewardBlockHeight = startBlockHeight + flagNum * rewardInterval;
    final from = currentBlockHeight.toRadixString(16);
    final to = lastRewardBlockHeight.toRadixString(16);

    Map<String, dynamic> params = {
      "jsonrpc": "2.0",
      "method": "apos_verifiedBlock",
      "params": [address, '0x$from', 10800, '0x$to'],
      "id": 1
    };
    return await BaseApi.requestEmptyH.post(chainUrl,
        data: params, params: params);
  }

  //主网开始挖矿节点高度
  static int mainBeijingBlock = 770000;

  //测试网开始挖矿节点高度
  static int testBeijingBlock = 40000;

  ///获取最后一次发放奖励时做过多少时间的任务
  ///返回任务数 * 8s 就是时间
  static Future getLastCycleMiningTime(
      String address,
      ) async {
    String chainUrl = await MiningCacheUtils.getCurrentMiningNodeIp();
    final int currentBlockHeight = await MiningApi.getBlockNumber();

    final isMain = await MiningUtils.isMainChainMining();
    final startBlockHeight = isMain ? mainBeijingBlock : testBeijingBlock;
    const rewardInterval = 10800;

    int flagNum = (currentBlockHeight - startBlockHeight) ~/ rewardInterval;
    int lastRewardBlockHeight = startBlockHeight + flagNum * rewardInterval;
    int sLastRewardBlockHeight =
        (startBlockHeight + flagNum * rewardInterval) - rewardInterval;

    final from = lastRewardBlockHeight.toRadixString(16);
    final to = sLastRewardBlockHeight.toRadixString(16);

    // debugPrint("getLastCycleMiningTime from: $lastRewardBlockHeight");
    // debugPrint("getLastCycleMiningTime to: $sLastRewardBlockHeight");

    Map<String, dynamic> params = {
      "jsonrpc": "2.0",
      "method": "apos_verifiedBlock",
      "params": [address, '0x$from', 10800, '0x$to'],
      "id": 1
    };
    return await BaseApi.requestEmptyH.post(chainUrl,
        data: params, params: params);
  }

  static Future getTaskDetail(String blockNumber) async {
    String chainUrl = await MiningCacheUtils.getCurrentMiningNodeIp();
    Map<String, dynamic> params = {
      "jsonrpc": "2.0",
      "method": "eth_getBlockByNumber",
      "params": [blockNumber, true],
      "id": 1
    };
    return await BaseApi.requestEmptyH.post(chainUrl,
        data: params, params: params);
  }

  ///获取当前地址所有的收益发放列表
  static Future getAllRewardsList(
      String address,
      ) async {
    String chainUrl = await MiningCacheUtils.getCurrentMiningNodeIp();
    final isMain = await MiningUtils.isMainChainMining();
    final startBlockHeight = isMain ? mainBeijingBlock : testBeijingBlock;
    final from = startBlockHeight.toRadixString(16);
    Map<String, dynamic> params = {
      "jsonrpc": "2.0",
      "method": "apos_getRewards",
      "params": [address, '0x$from', 'latest'],
      "id": 1
    };
    return await BaseApi.requestEmptyH.post(chainUrl,
        data: params, params: params);
  }

  //生成最近7天的发放奖励次数数组
  static Future<List<int>> generateRewardsArray() async {
    int flagNum = await getLastEpochNum();
    List<int> result = [];
    int start = flagNum - 6; // 数组起始值为 num - 6
    for (int i = start; i <= flagNum; i++) {
      result.add(i);
    }
    return result;
  }

  static Future<int> getLastEpochNum() async {
    final int currentBlockHeight = await MiningApi.getBlockNumber();
    final isMain = await MiningUtils.isMainChainMining();
    final startBlockHeight = isMain ? mainBeijingBlock : testBeijingBlock;
    const rewardInterval = 10800;

    int flagNum = (currentBlockHeight - startBlockHeight) ~/ rewardInterval;
    return flagNum;
  }

  //获取挖矿柱状图数据
  static Future getMiningBarChartData(String address,
      {int? currEpochNum}) async {
    final isMain = await MiningUtils.isMainChainMining();
    final mainNetUrl = "${AppConfig.apiUrl['blockBrowserHost']['main']}/api/v2/addresses/";
    final testnetUrl = "${AppConfig.apiUrl['blockBrowserHost']['test']}/api/v2/addresses/";
    final requestUrl = isMain
        ? "$mainNetUrl$address/verify_daily${currEpochNum != null ? "?epoch=$currEpochNum" : ""}"
        : "$testnetUrl$address/verify_daily${currEpochNum != null ? "?epoch=$currEpochNum" : ""}";
    Map<String, dynamic> params = {};
    return await BaseApi.requestEmptyH.get(requestUrl, params: params);
  }

  //获取当前地址未发放的奖励金额（不含当天挖矿）
  static Future getAccountRewardUnpaid(String address) async {
    String chainUrl = await MiningCacheUtils.getCurrentMiningNodeIp();
    Map<String, dynamic> params = {
      "jsonrpc": "2.0",
      "method": "apos_getAccountRewardUnpaid",
      "params": [address],
      "id": 1
    };
    return await BaseApi.requestEmptyH.post(chainUrl,
        data: params, params: params);
  }
}