import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/algo_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/btc_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/fil_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/xrp_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/xtz_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/zil_api.dart';
import 'package:n42_wallet/features/wallet/api/sender/evm_sender.dart';
import 'package:n42_wallet/features/wallet/api/token_view_api.dart';
import 'package:n42_wallet/features/wallet/models/btc_transaction_recode_model.dart';
import 'package:n42_wallet/features/wallet/models/transation_record_model.dart';

typedef TransactionReceiptReader =
    Future<MessageModel> Function(
      String coinType,
      String txHash, {
      bool isTest,
      String? rpc,
    });

/// 交易状态解析器 — 纯网络查询，无副作用。
///
/// 返回值约定：
///   1 = 成功上链
///   2 = 失败（reverted）
///  -1 = 无法确定（RPC 错误、数据尚未就绪）
///   0 = 尚未确认（仍在 pending 中）
class TransactionStateResolver {
  final TokenViewApi _tokenViewApi;
  final TransactionReceiptReader? _receiptReader;

  TransactionStateResolver({
    TokenViewApi? tokenViewApi,
    TransactionReceiptReader? receiptReader,
  }) : _tokenViewApi = tokenViewApi ?? TokenViewApi(),
       _receiptReader = receiptReader;

  Future<MessageModel> _readEvmReceipt(
    String coinType,
    String txHash, {
    required bool isTest,
    required String? rpc,
  }) {
    final reader = _receiptReader;
    if (reader != null) {
      return reader(coinType, txHash, isTest: isTest, rpc: rpc);
    }
    return _tokenViewApi.getTransactionReceiptEth(
      coinType,
      txHash,
      isTest: isTest,
      rpc: rpc,
    );
  }

  /// 根据区块链类型查询 [trm] 的上链状态。
  Future<int> resolveState(TransationRecordModel trm) async {
    final BlockchainType bt = BlockchainType.values.firstWhere(
      (e) => e.name == trm.coin['blockchainType'],
    );
    switch (bt) {
      case BlockchainType.Ethereum:
        return _resolveEth(trm);
      case BlockchainType.Solana:
        return _resolveSolana(trm);
      case BlockchainType.Tron:
        return _resolveTron(trm);
      case BlockchainType.Algorand:
        return _resolveAlgorand(trm);
      case BlockchainType.Tezos:
        return _resolveTezos(trm);
      case BlockchainType.Ripple:
        return _resolveRipple(trm);
      case BlockchainType.Filecoin:
        return _resolveFilecoin(trm);
      case BlockchainType.Harmony:
      case BlockchainType.IoTeX:
      case BlockchainType.Theta:
        // EVM compatible - uses Ethereum RPC
        return _resolveEvmCompatible(trm);
      case BlockchainType.Zilliqa:
        return _resolveZilliqa(trm);
      default:
        // Unsupported chain type — return 0 (unknown confirmation count)
        return 0;
    }
  }

  /// 查询 BTC 类交易的确认数，更新 [trm] 并返回最新确认数（-1 表示查询失败）。
  Future<int> resolveBtcConfirmations(BtcTransactionRecodeModel trm) async {
    if (trm.isTest == 1) {
      final MessageModel mm = await BtcApi(test: true).getTxState(trm.txHash);
      if (mm.error) return -1;
      return mm.data['confirmed'] == true ? 6 : 0;
    } else {
      final MessageModel mm = await _tokenViewApi.getTxConfirmation(
        trm.coin['coinType'],
        trm.txHash,
      );
      if (mm.error) return -1;
      return mm.data as int? ?? 0;
    }
  }

  // ---------- per-chain resolvers ----------

  Future<int> _resolveEth(TransationRecordModel trm) async {
    final bool isTest = trm.isTest != 0;
    final String? customRpc = _receiptRpc(trm);
    final MessageModel mm = await _readEvmReceipt(
      trm.coin['coinType'],
      trm.txHash,
      isTest: isTest,
      rpc: customRpc,
    );
    if (mm.error) return 0;

    if (customRpc != null) {
      // eth_getTransactionReceipt 对 pending 交易返回 null，不是错误。
      if (mm.data == null) return 0;
      return _statusFromHex(mm.data['status']);
    }
    if (mm.data['error']['code'] != 0) return -1;
    return _statusFromHex(mm.data['result']['status']);
  }

  Future<int> _resolveSolana(TransationRecordModel trm) async {
    final MessageModel mm = await _tokenViewApi.getTransactionSolana(
      trm.txHash,
      trm.isTest == 0 ? 'main' : 'test',
    );
    if (mm.error) return 0;
    if (mm.data.length == 0) return 0;

    final errObj = mm.data['Err'];
    if (errObj != null && errObj['InstructionError'] != null) return 2;
    final ok = mm.data['Ok'];
    return ok == null ? 1 : 0;
  }

  Future<int> _resolveTron(TransationRecordModel trm) async {
    final MessageModel mm = await _tokenViewApi.getTransactionReceiptTrx(
      trm.txHash,
      isTest: trm.isTest != 0,
    );
    if (mm.error) return 0;
    if (mm.data['error']['code'] != 0) return -1;
    return _statusFromHex(mm.data['result']['status']);
  }

  Future<int> _resolveAlgorand(TransationRecordModel trm) async {
    final MessageModel mm = await AlgoApi().getTransactionsInfo(
      trm.txHash,
      isTest: trm.isTest != 0,
    );
    if (mm.error) return 0;
    return 1;
  }

  Future<int> _resolveTezos(TransationRecordModel trm) async {
    final MessageModel mm = await XtzApi().getTxInfoXtz(
      trm.txHash,
      trm.isTest != 0,
    );
    if (mm.error) return 0;
    final List<dynamic> rData = mm.data;
    if (rData.isNotEmpty && rData[0]['is_success'] == true) return 1;
    return 0;
  }

  Future<int> _resolveRipple(TransationRecordModel trm) async {
    final MessageModel mm = await XrpApi().getTxInfoXrp(
      trm.txHash,
      trm.isTest != 0,
    );
    if (mm.error) return 0;
    return mm.data == 'tesSUCCESS' ? 1 : 0;
  }

  Future<int> _resolveFilecoin(TransationRecordModel trm) async {
    final MessageModel mm = await FilApi().getMessageInfo(trm.txHash);
    if (mm.error) return 0;
    return 1;
  }

  Future<int> _resolveEvmCompatible(TransationRecordModel trm) async {
    final bool isTest = trm.isTest != 0;
    final String? customRpc = _receiptRpc(trm);
    final MessageModel mm = await _readEvmReceipt(
      trm.coin['coinType'],
      trm.txHash,
      isTest: isTest,
      rpc: customRpc,
    );
    if (mm.error) return 0;
    if (customRpc != null) {
      if (mm.data == null) return 0;
      return _statusFromHex(mm.data['status']);
    }
    if (mm.data['error']['code'] != 0) return -1;
    return _statusFromHex(mm.data['result']['status']);
  }

  Future<int> _resolveZilliqa(TransationRecordModel trm) async {
    final ZilApi zilApi = ZilApi(isTest: trm.isTest != 0);
    final MessageModel mm = await zilApi.getTransaction(trm.txHash);
    if (mm.error) return 0;
    // Transaction found and confirmed
    final receipt = mm.data['receipt'];
    if (receipt == null) return 0;
    return receipt['success'] == true ? 1 : 2;
  }

  // ---------- helpers ----------

  /// 从 EVM status hex 字符串（"0x1" / "0x0"）转换为状态码
  int _statusFromHex(dynamic status) {
    if (status == '0x1') return 1;
    if (status == '0x0') return 2;
    return 0;
  }

  /// 返回 EVM 交易记录的链 RPC。与发送侧（EvmSender.resolveRpcOverride）保持
  /// 同一套解析：凡配置了链 RPC 的都直连查收据，否则经交易在链上广播成功、
  /// 收据却走不路由该链的 TokenView 后端，会永远停在 pending。
  String? _receiptRpc(TransationRecordModel trm) =>
      EvmSender.resolveRpcOverride(trm.coin, isTest: trm.isTest != 0);
}
