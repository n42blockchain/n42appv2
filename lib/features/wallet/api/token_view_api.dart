import 'dart:convert';

import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/core/config/app_config.dart';
import 'package:n42_wallet/core/network/base_api.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/algo_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/akt_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/apt_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/atom_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/btc_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/dot_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/dydx_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/eth_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/fil_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/inj_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/near_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/ntrn_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/osmo_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/sol_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/sui_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/tia_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/ton_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/trx_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/xrp_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/xtz_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/zil_api.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';
import 'package:n42_wallet/features/wallet/utils/chain/chain_eip1559.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:web3dart/web3dart.dart';

part 'token_view_api_btc.dart';
part 'token_view_api_eth.dart';
part 'token_view_api_ns.dart';
part 'token_view_api_sol.dart';
part 'token_view_api_trx.dart';

class TokenViewApi {
  late String url;
  late Map<String, String> header;

  TokenViewApi() {
    url = AppConfig.getApiUrlOnline('tokenViewUri');
    header = {'content-type': 'application/json'};
  }

  Future<int?> getErc20Decimals(String contractAddress, String rpcUrl) {
    return EthAPI.getErc20Decimals(contractAddress, rpcUrl);
  }

  // ── 公共列表查询 ───────────────────────────────────────────────────────────

  /// 统一的 GET 请求模板：发起请求、校验状态码、提取数据
  Future<MessageModel> _request(
    String path, {
    int successCode = 200,
    dynamic Function(Map<String, dynamic> response)? extractData,
  }) async {
    try {
      final a = await BaseApi.requestEmptyH.get(
        '$url$path',
        params: {},
        header: header,
      );
      final mm = MessageModel.error();
      if (a['code'] == successCode) {
        mm.error = false;
        mm.data = extractData != null ? extractData(a) : a['data'];
      } else {
        mm.data = errorMessage(a['code']);
      }
      return mm;
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// 获取币列表（主链 + 代币）
  ///
  /// [chains] — 按主链全名过滤，如 "Solana,Bitcoin"
  /// [coins]  — 按代币 symbol 过滤，如 "eth,bnb"
  Future<MessageModel> getChainListAll({
    String chains = '',
    String coins = '',
  }) {
    final parts = <String>[];
    if (chains.isNotEmpty) parts.add('chains=$chains');
    if (coins.isNotEmpty) parts.add('coins=$coins');
    final query = parts.isEmpty ? '' : '?${parts.join('&')}';
    return _request('v2/chains/coins/v2$query');
  }

  /// 获取某主链的所有代币列表
  Future<MessageModel> getTokenListFullname(String fullname) {
    return _request(
      'v1/chains/coins?chains=$fullname',
      extractData: (a) {
        final List<dynamic> rData = a['data'];
        return rData.isEmpty ? [] : rData[0]['coins'];
      },
    );
  }

  /// 获取某笔交易的确认数
  Future<MessageModel> getTxConfirmation(String coinType, String txHash) {
    return _request(
      'v1/vipapi/tx/confirmation?coin=${coinType.toLowerCase()}&tx_hash=$txHash',
      successCode: 1,
      extractData: (a) => a['data']['confirmation'],
    );
  }

  // ── 多链 dispatch ──────────────────────────────────────────────────────────

  /// 获取余额（按链分派）
  Future<MessageModel?> getBalance(
    String blockchain,
    String coinType,
    String address, {
    String contract = '',
    bool returnDouble = false,
    bool isTest = false,
    String? rpc,
  }) async {
    switch (blockchain) {
      case 'Bitcoin':
        if (isTest) return await BtcApi(test: isTest).getBalance(address);
        return await getBalanceBtc(
          coinType,
          address,
          returnDouble: returnDouble,
        );
      case 'Ethereum':
        return await getBalanceEth(
          coinType,
          address,
          contract,
          returnDouble: returnDouble,
          isTest: isTest,
          rpc: rpc,
        );
      case 'Solana':
        return await getBalanceSolana(
          coinType,
          address,
          contract,
          returnDouble: returnDouble,
          isTest: isTest,
        );
      case 'Tron':
        return await TrxApi().getBalanceTrx(address, contract, isTest: isTest);
      case 'Algorand':
        return await AlgoApi().getBalance(
          address,
          assetId: contract,
          isTest: isTest,
        );
      case 'Tezos':
        return await XtzApi().getBalanceXtz(
          address,
          contract,
          'balance',
          isTest,
        );
      case 'Ripple':
        return await XrpApi().getAccountInfoXrp(address, isTest);
      case 'Cosmos':
        switch (coinType) {
          case 'INJ':
            return await InjApi(isTest: isTest).getBalance(address);
          case 'OSMO':
            return await OsmoApi(isTest: isTest).getBalance(address);
          case 'TIA':
            return await TiaApi(isTest: isTest).getBalance(address);
          case 'DYDX':
            return await DydxApi(isTest: isTest).getBalance(address);
          case 'NTRN':
            return await NtrnApi(isTest: isTest).getBalance(address);
          case 'AKT':
            return await AktApi(isTest: isTest).getBalance(address);
          default:
            return await AtomApi().getBalance(address, contract);
        }
      case 'Filecoin':
        return await FilApi().getBalance(address, isTest: isTest);
      case 'Polkadot':
        return await DotApi().getTokens(address, coinType, isTest: isTest);
      case 'Aptos':
        return await AptApi(
          isTest: isTest,
        ).getBalance(address, contract: contract);
      case 'Sui':
        return await SuiApi(isTest: isTest).getBalanceSui(address);
      case 'TheOpenNetwork':
        return await TonApi(isTest: isTest).getBalanceTon(address);
      case 'Zilliqa':
        return await ZilApi(isTest: isTest).getBalance(address);
      case 'Near':
        return await NearApi(isTest: isTest).getBalance(address);
    }
    return null;
  }

  /// 发送交易（按链分派）
  Future<MessageModel?> sendTx(
    String blockchain,
    String coinType,
    dynamic signHash, {
    String netMode = 'main',
    String? rpc,
  }) async {
    switch (blockchain) {
      case 'Bitcoin':
        return await sendTxBtc(coinType, signHash, isTest: netMode != 'main');
      case 'Ethereum':
        return await sendTxEth(coinType, signHash, netMode, rpc: rpc);
      case 'Solana':
        return await sendTxSolana(signHash, netMode);
      case 'Tron':
        return await sendTxTrx(signHash, netMode);
      case 'Cosmos':
        return await AtomApi().sendTxs(signHash);
      case 'Algorand':
        return await AlgoApi().sendTx(signHash, isTest: netMode != 'main');
      case 'Zilliqa':
        return await ZilApi(
          isTest: netMode != 'main',
        ).createTransaction(signHash);
    }
    return null;
  }

  /// 获取 gasPrice（按链分派）
  Future<MessageModel?> getGasPrice(
    String blockchain,
    String coinType, {
    bool isTest = false,
    String? rpc,
    String signMessage = '',
  }) async {
    switch (blockchain) {
      case 'Ethereum':
        return await getGasPriceEth(coinType, isTest: isTest, rpc: rpc);
      case 'Solana':
        return await SolApi().getFeeForMessage(signMessage);
      case 'Tron':
        return await getGasPriceTrx(isTest: isTest);
      case 'Algorand':
        return await AlgoApi().getTransactionsParams(isTest: isTest);
      case 'Tezos':
        return MessageModel()..data = BigInt.from(500);
      case 'Ripple':
        return await XrpApi().getGasPriceXrp(isTest);
      case 'Cosmos':
        return MessageModel()..data = BigInt.from(20000);
      case 'Filecoin':
        return await FilApi().getGasPrice(isTest: isTest);
      case 'Aptos':
        return await AptApi(isTest: isTest).getGasPrice();
      case 'Sui':
        return await SuiApi(isTest: isTest).getGasPriceSui();
      case 'Zilliqa':
        return await ZilApi(isTest: isTest).getMinimumGasPrice();
    }
    return null;
  }

  // ── 工具方法 ──────────────────────────────────────────────────────────────

  /// 将 API 错误码转换为本地化提示文本
  String errorMessage(int errorcode) {
    switch (errorcode) {
      case 404:
        return S.current.g_key_error_14;
      case 429:
        return S.current.g_key_error_24;
      case 500:
        return S.current.g_key_error_5;
      case 40001:
        return S.current.g_key_error_23; // 系统繁忙
      case 10001:
        return S.current.g_key_error_25;
      case 10002:
        return S.current.g_key_error_26;
      default:
        return S.current.g_key_error_3; // 未知错误
    }
  }
}
