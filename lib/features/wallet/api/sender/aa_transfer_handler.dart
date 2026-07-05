// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:typed_data';

import 'package:n42_wallet/core/utils/app_logger.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';
import 'package:n42_wallet/features/wallet/aa/core/aa_config.dart';
import 'package:n42_wallet/features/wallet/aa/core/aa_constants.dart';
import 'package:n42_wallet/features/wallet/aa/core/aa_errors.dart';
import 'package:n42_wallet/features/wallet/aa/models/user_operation.dart';
import 'package:n42_wallet/features/wallet/aa/models/smart_account.dart';
import 'package:n42_wallet/features/wallet/aa/models/paymaster_data.dart';
import 'package:n42_wallet/features/wallet/aa/builder/user_op_builder.dart';
import 'package:n42_wallet/features/wallet/aa/builder/calldata_builder.dart';
import 'package:n42_wallet/features/wallet/aa/builder/signature_builder.dart';
import 'package:n42_wallet/features/wallet/aa/account/smart_account_factory.dart';
import 'package:n42_wallet/features/wallet/aa/bundler/bundler_client.dart';
import 'package:n42_wallet/features/wallet/aa/utils/user_op_hash.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/eth_api.dart';
import 'package:n42_wallet/features/wallet/models/coin_config_view.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/features/wallet/utils/decimal_amount.dart';
import 'package:n42_wallet/features/wallet/utils/transfer_serializer.dart';
import 'package:web3dart/web3dart.dart';

import 'transfer_handler.dart';
import 'base_transfer_handler.dart';

/// Transfer parameters specific to AA transactions
class AATransferParams extends TransferParams {
  /// Smart account to use for the transfer
  final SmartAccount smartAccount;

  /// Paymaster data (optional, for sponsored transactions)
  final PaymasterData? paymasterData;

  /// Whether to batch with other operations
  final List<ExecuteCall>? batchCalls;

  /// Bundler API key
  final String? bundlerApiKey;

  const AATransferParams({
    required super.chainSymbol,
    required super.fromAddress,
    required super.toAddress,
    required super.value,
    required this.smartAccount,
    super.contractAddress = '',
    super.isTest = false,
    super.maxValue = true,
    super.message,
    super.privateKey,
    super.pathIndex = 0,
    super.chainMap,
    super.token,
    this.paymasterData,
    this.batchCalls,
    this.bundlerApiKey,
  });
}

/// Transfer handler for Account Abstraction (ERC-4337) transactions
///
/// Handles transfers through smart accounts using the ERC-4337 standard.
/// Supports:
/// - ETH and ERC20 transfers
/// - Batch transactions
/// - Paymaster-sponsored transactions
/// - First-time account deployment
class AATransferHandler extends BaseTransferHandler {
  final String _chainSymbol;
  BundlerClient? _bundlerClient;
  String? _bundlerApiKey;

  AATransferHandler(this._chainSymbol, {String? bundlerApiKey})
    : _bundlerApiKey = bundlerApiKey;

  @override
  String get chainSymbol => _chainSymbol;

  @override
  bool supports(String chainSymbol) {
    return AAConfig.isChainSupported(normalizeSymbol(chainSymbol));
  }

  /// Get or create bundler client
  BundlerClient _getBundlerClient() {
    _bundlerClient ??= BundlerClient.forChain(
      _chainSymbol,
      apiKey: _bundlerApiKey,
    );
    return _bundlerClient!;
  }

  /// Set bundler API key
  void setBundlerApiKey(String? apiKey) {
    _bundlerApiKey = apiKey;
    _bundlerClient = null; // Reset client to use new key
  }

  @override
  Future<MessageModel> transfer(TransferParams params) async {
    if (params is! AATransferParams) {
      return createError('Invalid parameters: AATransferParams required');
    }
    // 同一智能账户的转账串行化：nonce 从查询到广播之间没有链上互斥，
    // 并发构建（快速双击/自动重试）会拿到同一 nonce 并各自广播（双花）。
    return TransferSerializer.run(
      '${params.chainSymbol}:${params.smartAccount.address}',
      () => _transferSerialized(params),
    );
  }

  Future<MessageModel> _transferSerialized(AATransferParams params) async {
    try {
      if (!AAConfig.isChainSupported(normalizeSymbol(params.chainSymbol))) {
        return createError(S.current.g_key_wallet_m1(params.chainSymbol));
      }

      final chainConfig = AAConfig.getChainConfig(params.chainSymbol);
      if (chainConfig == null) {
        return createError('Chain configuration not found');
      }

      final userOp = await _buildUserOperation(params, chainConfig);

      final bundler = _getBundlerClient();
      final gasEstimate = await bundler.estimateUserOperationGas(userOp);
      final userOpWithGas = gasEstimate
          .withBuffer(AAConstants.gasBufferMultiplier)
          .applyTo(userOp);

      final signedUserOp = await _signUserOperation(
        userOpWithGas,
        params,
        chainConfig,
      );
      final userOpHash = await bundler.sendUserOperation(signedUserOp);

      AppLogger.d('AATransferHandler', 'UserOp sent, hash: $userOpHash');

      // Wait for receipt (with timeout)
      final receipt = await bundler.waitForReceipt(
        userOpHash,
        timeout: const Duration(seconds: 60),
      );

      if (receipt.success) {
        return createSuccess(
          data: {
            'userOpHash': userOpHash,
            'txHash': receipt.receipt.transactionHash,
            'value': params.value,
            'success': true,
          },
        );
      } else {
        return createError(
          'Transaction failed',
          data: {
            'userOpHash': userOpHash,
            'txHash': receipt.receipt.transactionHash,
          },
        );
      }
    } on ReceiptTimeoutError catch (e) {
      // UserOp 已成功提交给 bundler，超时只是没等到回执——交易很可能
      // 仍会上链。绝不能报告为「失败」：用户重试会用同一 nonce 构建
      // 第二笔，造成双花或 nonce 冲突。
      AppLogger.w(
        'AATransferHandler',
        'receipt timeout, userOp may still land: ${e.userOpHash}',
      );
      return createError(
        'Transaction submitted and awaiting confirmation. '
        'Do NOT resend — check the transaction status first.',
        data: {'userOpHash': e.userOpHash, 'isPending': true},
      );
    } on AAError catch (e, s) {
      AppLogger.e('AATransferHandler', 'AA error', error: e, stackTrace: s);
      return createError(e.message, data: e.details);
    } catch (e, s) {
      AppLogger.e(
        'AATransferHandler',
        'unexpected error',
        error: e,
        stackTrace: s,
      );
      return createError(e.toString());
    }
  }

  /// Build UserOperation for the transfer
  Future<UserOperation> _buildUserOperation(
    AATransferParams params,
    AAChainConfig chainConfig,
  ) async {
    final smartAccount = params.smartAccount;

    // Get nonce from EntryPoint
    final nonce = await _getNonce(smartAccount.address, chainConfig);

    // Get gas prices
    final gasPrices = await _getGasPrices(params.chainSymbol);

    // Build call data
    Uint8List callData;
    if (params.batchCalls != null && params.batchCalls!.isNotEmpty) {
      // Batch transaction
      callData = CalldataBuilder.buildExecuteBatch(params.batchCalls!);
    } else if (params.contractAddress.isNotEmpty) {
      // ERC20 transfer
      final transferData = CalldataBuilder.buildErc20Transfer(
        to: params.toAddress,
        amount: _parseValue(params.value, _tokenDecimals(params)),
      );
      callData = CalldataBuilder.buildExecute(
        target: params.contractAddress,
        value: BigInt.zero,
        data: transferData,
      );
    } else {
      // ETH transfer
      callData = CalldataBuilder.buildExecute(
        target: params.toAddress,
        value: _parseValue(params.value, 18),
        data: Uint8List(0),
      );
    }

    // Build UserOp
    final builder = UserOpBuilder()
        .setSenderFromAccount(smartAccount)
        .setNonce(nonce)
        .setCallData(callData)
        .setGasFees(
          maxFeePerGas: gasPrices.maxFeePerGas,
          maxPriorityFeePerGas: gasPrices.maxPriorityFeePerGas,
        )
        .setDummySignature();

    // Add init code if account not deployed
    if (smartAccount.needsDeployment) {
      final factory = SmartAccountFactory(
        ownerAddress: smartAccount.ownerAddress,
        chainId: smartAccount.chainId,
      );
      builder.setInitCode(factory.getInitCode(salt: smartAccount.salt));

      // Increase verification gas for deployment
      builder.setGasLimits(
        verificationGasLimit: BigInt.from(AAConstants.accountDeploymentGas),
      );
    }

    // Add paymaster data if provided
    if (params.paymasterData != null) {
      builder.setPaymaster(params.paymasterData!);
    }

    return builder.build();
  }

  /// Sign the UserOperation
  Future<UserOperation> _signUserOperation(
    UserOperation userOp,
    AATransferParams params,
    AAChainConfig chainConfig,
  ) async {
    // Get the hash to sign
    final userOpHash = UserOpHasher.hash(
      userOp: userOp,
      entryPoint: chainConfig.entryPoint,
      chainId: BigInt.from(chainConfig.chainId),
    );

    final hashHex = '0x${bytesToHex(userOpHash)}';

    // Get chain map for signing
    final chainMap = params.chainMap ?? getChainMap(params.chainSymbol);
    if (chainMap == null) {
      throw UserOperationBuildError('Chain map not found');
    }

    // 签名 path 必须与 owner 地址派生用同一 pathIndex/addrType。owner 来自
    // walletProvider.getAddress(chainSymbol)(活跃钱包真实 pathIndex);此前 path
    // 取 chainMap['path'](该键在 walletMap 是 Map 非 String,`as String?` 恒命中
    // null)→ 硬编码 index-0,多账户(pathIndex>0)AA 会 signer≠owner 被 bundler
    // 拒、资金锁死在该智能账户(第三轮 P1)。
    String path = chainMap['path'] as String? ?? '';
    if (path.isEmpty) {
      final ownerCm =
          walletProvider.getCoinModelWithCoinType(params.chainSymbol);
      if (ownerCm != null) {
        final base = ownerCm.config.pathForAddrType(ownerCm.addrType) ??
            "m/44'/60'/0'/0/0";
        path = getPathWithIndex(base, ownerCm.pathIndex);
      } else {
        path = "m/44'/60'/0'/0/0";
      }
    }

    // Sign using trustdart (prefer private key, fallback to mnemonic)
    final signatureHex = params.privateKey != null
        ? await trustdart.signMessage(
            params.chainSymbol,
            path,
            hashHex,
            pk: params.privateKey!,
          )
        : await trustdart.signMessage(
            params.chainSymbol,
            path,
            hashHex,
            mnemonic: walletProvider.walletInfo.mnemonic ?? '',
          );

    if (signatureHex.isEmpty) {
      throw SignatureError('Failed to sign UserOperation');
    }

    // Format signature
    final signature = SignatureBuilder.formatSignature(signatureHex);

    return userOp.copyWith(signature: signature);
  }

  /// Get nonce for smart account
  Future<BigInt> _getNonce(String sender, AAChainConfig chainConfig) async {
    try {
      // Query nonce from EntryPoint contract via eth_call
      final ethApi = EthAPI.init(_chainSymbol, _getRpcUrl(), '');

      // getNonce(address sender, uint192 key)
      // Function selector: 0x35567e1a
      final senderPadded = sender
          .replaceFirst('0x', '')
          .toLowerCase()
          .padLeft(64, '0');
      const keyPadded =
          '0000000000000000000000000000000000000000000000000000000000000000';
      final data = '0x35567e1a$senderPadded$keyPadded';

      final result = await ethApi.ethCallRaw(chainConfig.entryPoint, data);

      // 查询失败必须中止构建：静默退回 0 会构造一个 nonce 错误的
      // UserOp——轻则被 bundler 以 nonce-too-low 拒绝，重则在新账户
      // 边界场景下与历史 nonce=0 的操作冲突。
      if (result.error || result.data == null) {
        throw UserOperationBuildError(
          'Failed to fetch account nonce from EntryPoint',
          details: result.data?.toString(),
        );
      }
      final hex = result.data.toString().replaceFirst('0x', '');
      return (hex.isNotEmpty && hex != '0')
          ? BigInt.parse(hex, radix: 16)
          : BigInt.zero;
    } on AAError {
      rethrow;
    } catch (e) {
      AppLogger.e('AATransferHandler', 'error getting nonce: $e');
      throw UserOperationBuildError(
        'Failed to fetch account nonce',
        details: e.toString(),
      );
    }
  }

  /// Get RPC URL for the chain
  String _getRpcUrl() {
    return getChainMap(_chainSymbol)?['service'] as String? ??
        chainUrlMap[_chainSymbol]?['baseInfo']?['service'] as String? ??
        '';
  }

  /// Get gas prices
  Future<({BigInt maxFeePerGas, BigInt maxPriorityFeePerGas})> _getGasPrices(
    String chainSymbol,
  ) async {
    final mm = await tokenViewApi.getGasPrice(
      BlockchainType.Ethereum.name,
      chainSymbol,
      isTest: false,
    );

    if (mm == null || mm.error) {
      throw GasEstimationError('Failed to get gas price');
    }

    final gasPrice = mm.data as BigInt;

    // For EIP-1559 chains, estimate priority fee
    final priorityFee = gasPrice ~/ BigInt.from(10); // ~10% of gas price
    final maxFee = gasPrice * BigInt.from(2); // 2x for buffer

    return (maxFeePerGas: maxFee, maxPriorityFeePerGas: priorityFee);
  }

  /// 解析 ERC20 token 的 decimals：动态 map 中可能是 int 或 String，
  /// 字段缺失/不可解析时必须报错而不是默认 18 —— 对 USDC（decimals=6）
  /// 这类代币，错用 18 意味着金额偏差 12 个数量级。
  int _tokenDecimals(AATransferParams params) {
    final raw = params.token?['decimals'];
    final decimals = switch (raw) {
      int v => v,
      String v => int.tryParse(v),
      _ => null,
    };
    if (decimals == null || decimals < 0 || decimals > 36) {
      throw UserOperationBuildError(
        'Invalid or missing token decimals for ERC20 transfer',
        details: 'token=${params.token}',
      );
    }
    return decimals;
  }

  /// Parse value to BigInt（精确十进制移位，见 decimal_amount.dart）
  BigInt _parseValue(double value, int decimals) =>
      doubleAmountToBigInt(value, decimals);

  static GasEstimation _gasError(String message) => GasEstimation(
    gasLimit: BigInt.zero,
    gasPrice: BigInt.zero,
    totalFee: BigInt.zero,
    errorMessage: message,
  );

  @override
  Future<GasEstimation> estimateGas(TransferParams params) async {
    try {
      if (params is! AATransferParams) return _gasError('Invalid parameters');

      final chainConfig = AAConfig.getChainConfig(params.chainSymbol);
      if (chainConfig == null) return _gasError('Chain not supported');

      final userOp = await _buildUserOperation(params, chainConfig);
      final bundler = _getBundlerClient();
      final estimate = await bundler.estimateUserOperationGas(userOp);
      final gasPrices = await _getGasPrices(params.chainSymbol);
      final totalGas = estimate.totalGas;

      return GasEstimation(
        gasLimit: totalGas,
        gasPrice: gasPrices.maxFeePerGas,
        totalFee: totalGas * gasPrices.maxFeePerGas,
      );
    } catch (e) {
      return _gasError(e.toString());
    }
  }

  /// Check if smart account is deployed
  Future<bool> isAccountDeployed(String address) async {
    try {
      final ethApi = EthAPI.init(_chainSymbol, _getRpcUrl(), '');
      final result = await ethApi.getCode(address);

      if (!result.error && result.data != null) {
        return SmartAccountFactory.isDeployed(result.data.toString());
      }
      return false;
    } catch (e) {
      AppLogger.w('AATransferHandler', 'error checking account deployment: $e');
      return false;
    }
  }

  /// Clean up resources
  void dispose() {
    _bundlerClient?.dispose();
    _bundlerClient = null;
  }
}
