import 'package:n42_wallet/features/wallet/api/sender/chain_sender.dart';
import 'package:n42_wallet/features/wallet/api/sender/evm_sender.dart';

import 'mpc_evm_transaction_signer.dart';

import 'package:n42_wallet/shared/domain/entities/message_model.dart';
import 'package:n42_wallet/features/wallet/api/sender/transfer_handler.dart';
import 'package:n42_wallet/features/wallet/api/sender/base_transfer_handler.dart';

import 'mpc_provider.dart';

/// MPC 转账参数
class MpcTransferParams extends TransferParams {
  /// MPC Provider 实例
  final MpcProvider mpcProvider;

  /// Exact reviewed EVM request, including durable broadcast persistence.
  final SendParams? transaction;
  final bool Function()? isCurrent;

  factory MpcTransferParams.prepared({
    required SendParams transaction,
    required MpcProvider provider,
    required bool Function() isCurrent,
  }) => MpcTransferParams(
    chainSymbol: transaction.coinType,
    fromAddress: transaction.fromAddress,
    toAddress: transaction.toAddress,
    value: transaction.amount,
    contractAddress: transaction.contractAddress,
    isTest: transaction.isTest,
    maxValue: transaction.sendMax,
    message: transaction.memo,
    privateKey: transaction.privateKey,
    chainMap: transaction.chainConfig,
    mpcProvider: provider,
    transaction: transaction,
    isCurrent: isCurrent,
  );

  const MpcTransferParams({
    required super.chainSymbol,
    required super.fromAddress,
    required super.toAddress,
    required super.value,
    required this.mpcProvider,
    this.transaction,
    this.isCurrent,
    super.contractAddress = '',
    super.isTest = false,
    super.maxValue = true,
    super.message,
    super.privateKey,
    super.pathIndex = 0,
    super.chainMap,
    super.token,
  });
}

/// MPC Transfer Handler
///
/// 将 EVM 交易签名委托给 MpcProvider，而非本地私钥。
/// Prepared EVM transfers use the shared sender and return a broadcast hash.
class MpcTransferHandler extends BaseTransferHandler {
  final String _chainSymbol;

  final ChainSender Function(MpcEvmTransactionSigner)? _senderFactory;

  MpcTransferHandler(
    this._chainSymbol, {
    ChainSender Function(MpcEvmTransactionSigner)? senderFactory,
  }) : _senderFactory = senderFactory;

  @override
  String get chainSymbol => _chainSymbol;

  @override
  bool supports(String chainSymbol) {
    // MPC supports all EVM chains
    const evmChains = {
      'ETH',
      'BNB',
      'MATIC',
      'AVAX',
      'FTM',
      'OP',
      'ARB',
      'BASE',
      'LINEA',
      'SCROLL',
      'ZKSYNC',
      'BLAST',
      'N',
    };
    return evmChains.contains(normalizeSymbol(chainSymbol));
  }

  @override
  Future<MessageModel> transfer(TransferParams params) async {
    try {
      if (params is! MpcTransferParams) {
        return createError('Invalid parameters: MpcTransferParams required');
      }

      final transaction = params.transaction;
      final isCurrent = params.isCurrent;
      if (transaction == null ||
          isCurrent == null ||
          transaction.beforeBroadcast == null) {
        return createError(
          'A reviewed EVM transaction and durable persistence are required',
        );
      }
      if (!supports(transaction.coinType) ||
          normalizeSymbol(transaction.coinType) !=
              normalizeSymbol(_chainSymbol) ||
          normalizeSymbol(transaction.coinType) !=
              normalizeSymbol(params.chainSymbol) ||
          transaction.fromAddress != params.fromAddress ||
          transaction.toAddress != params.toAddress ||
          transaction.amount != params.value ||
          transaction.contractAddress != params.contractAddress ||
          transaction.isTest != params.isTest ||
          transaction.sendMax != params.maxValue ||
          transaction.memo != params.message ||
          transaction.privateKey != null ||
          params.privateKey != null) {
        return createError(
          'MPC transfer does not match the reviewed EVM request',
        );
      }
      final provider = params.mpcProvider;
      if (!provider.isLoggedIn || !isCurrent()) {
        return createError(
          'MPC wallet is not logged in or its session changed',
        );
      }
      final signer = MpcEvmTransactionSigner(provider, isCurrent: isCurrent);
      final sender =
          _senderFactory?.call(signer) ?? EvmSender(mpcSigner: signer);
      final result = await sender.send(transaction);
      if (!result.success && result.txHash != null) {
        return createError(
          result.error ?? 'Broadcast outcome is uncertain',
          data: {
            'txHash': result.txHash,
            'error': result.error,
            'definitelyNotSubmitted': result.definitelyNotSubmitted,
            'uncertain': !result.definitelyNotSubmitted,
          },
        );
      }
      return result.toMessageModel();
    } catch (_) {
      return createError('MPC transfer failed');
    }
  }

  @override
  Future<GasEstimation> estimateGas(TransferParams params) async {
    // MPC wallets use the same gas estimation as regular EVM wallets
    // This is a simplified estimation — in production, call eth_estimateGas
    return GasEstimation(
      gasLimit: BigInt.zero,
      gasPrice: BigInt.zero,
      totalFee: BigInt.zero,
      errorMessage: 'MPC gas estimation requires RPC call',
    );
  }
}
