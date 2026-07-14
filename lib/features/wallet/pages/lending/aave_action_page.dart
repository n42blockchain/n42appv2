// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider, Consumer;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:web3dart/web3dart.dart' show bytesToHex;

import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/features/wallet/api/sender/chain_sender.dart';
import 'package:n42_wallet/features/wallet/api/sender/sender_factory.dart';
import 'package:n42_wallet/features/wallet/models/coin_config_view.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/pages/lending/aave_service.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart'
    show getPathWithIndex, ethToWeiString;

/// Aave V3 单笔存入/借出执行页。
///
/// 复用 dex_swap_home.dart 已验证的模式：通过 chainId 反查钱包在该链上的
/// 原生 CoinModel 取得 coinType/派生路径，再经 SenderFactory 把
/// aave_service.dart 已有的 calldata builder 送上链——不新增签名/广播通道。
/// 存入（Supply）在授权额度不足时先发一笔 approve，再发 supply；
/// 借出（Borrow）无需授权，直接调用 Pool。
class AaveActionPage extends ConsumerStatefulWidget {
  final AaveReserve reserve;
  final int chainId;
  final String walletAddress;
  final bool isSupply;

  const AaveActionPage({
    required this.reserve,
    required this.chainId,
    required this.walletAddress,
    required this.isSupply,
    super.key,
  });

  @override
  ConsumerState<AaveActionPage> createState() => _AaveActionPageState();
}

class _AaveActionPageState extends ConsumerState<AaveActionPage> {
  final _amountCtrl = TextEditingController();
  bool _needsApproval = false;
  bool _checkingApproval = false;
  bool _submitting = false;
  String? _error;
  int _approvalRequest = 0;

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  CoinModel? _resolveNativeCoin() {
    final wa = ref.read(wapBridgeProvider);
    for (final cm in wa.coinModels) {
      if (cm.config.chainId == widget.chainId && !cm.config.isContract) {
        return cm;
      }
    }
    return null;
  }

  BigInt _amountWei() {
    final text = _amountCtrl.text.trim();
    if (text.isEmpty) return BigInt.zero;
    try {
      final wei = ethToWeiString(text, widget.reserve.decimals);
      return wei > BigInt.zero ? wei : BigInt.zero;
    } catch (_) {
      return BigInt.zero;
    }
  }

  Future<void> _refreshApprovalState() async {
    if (!widget.isSupply) return;
    final request = ++_approvalRequest;
    final amountWei = _amountWei();
    if (amountWei == BigInt.zero) {
      if (mounted) setState(() => _needsApproval = false);
      return;
    }
    final cm = _resolveNativeCoin();
    final poolAddr = AaveService.getPoolAddress(widget.chainId);
    if (cm == null || poolAddr == null) return;

    setState(() => _checkingApproval = true);
    final allowance = await AaveService.checkAllowance(
      coinType: cm.config.coinType,
      tokenAddr: widget.reserve.underlyingAsset,
      owner: widget.walletAddress,
      spender: poolAddr,
    );
    if (!mounted || request != _approvalRequest) return;
    setState(() {
      _needsApproval = allowance < amountWei;
      _checkingApproval = false;
    });
  }

  Future<void> _submit() async {
    if (_submitting) return;
    final amountWei = _amountWei();
    if (amountWei == BigInt.zero) {
      setState(() => _error = 'Enter an amount');
      return;
    }

    final cm = _resolveNativeCoin();
    final poolAddr = AaveService.getPoolAddress(widget.chainId);
    if (cm == null || poolAddr == null) {
      setState(() => _error = 'No wallet account found for this chain');
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    final basePath =
        cm.config.pathForAddrType(cm.addrType) ?? "m/44'/60'/0'/0/0";
    final path = getPathWithIndex(basePath, cm.pathIndex);
    final sender = SenderFactory.instance.getSender(cm.config.coinType);

    // Step 1: submit-time allowance check. The field-level check is only a UI
    // hint and may still be in flight when the user confirms.
    var needsApproval = false;
    if (widget.isSupply) {
      final allowance = await AaveService.checkAllowance(
        coinType: cm.config.coinType,
        tokenAddr: widget.reserve.underlyingAsset,
        owner: widget.walletAddress,
        spender: poolAddr,
      );
      if (!mounted) return;
      needsApproval = allowance < amountWei;
      setState(() => _needsApproval = needsApproval);
    }
    if (needsApproval) {
      final approveResult = await sender.send(
        SendParams(
          coinType: cm.config.coinType,
          fromAddress: widget.walletAddress,
          toAddress: widget.reserve.underlyingAsset,
          amount: 0.0,
          decimals: 18,
          path: path,
          isTest: cm.isTest,
          privateKey: cm.privateKey,
          chainConfig: cm.coin,
          calldata:
              '0x${bytesToHex(AaveService.buildApproveCalldata(spender: poolAddr, amount: amountWei))}',
        ),
      );
      if (!mounted) return;
      if (!approveResult.success) {
        setState(() {
          _submitting = false;
          _error = approveResult.error ?? 'Approve failed';
        });
        return;
      }
      setState(() => _needsApproval = false);
    }

    // Step 2: supply / borrow
    final calldata = widget.isSupply
        ? AaveService.buildSupplyCalldata(
            asset: widget.reserve.underlyingAsset,
            amount: amountWei,
            onBehalfOf: widget.walletAddress,
          )
        : AaveService.buildBorrowCalldata(
            asset: widget.reserve.underlyingAsset,
            amount: amountWei,
            onBehalfOf: widget.walletAddress,
          );

    final result = await sender.send(
      SendParams(
        coinType: cm.config.coinType,
        fromAddress: widget.walletAddress,
        toAddress: poolAddr,
        amount: 0.0,
        decimals: 18,
        path: path,
        isTest: cm.isTest,
        privateKey: cm.privateKey,
        chainConfig: cm.coin,
        calldata: '0x${bytesToHex(calldata)}',
      ),
    );
    if (!mounted) return;

    setState(() => _submitting = false);

    if (!result.success) {
      setState(() => _error = result.error ?? 'Transaction failed');
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop(true);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          widget.isSupply ? 'Supply submitted' : 'Borrow submitted',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColorTokens.of(context);
    final apy = widget.isSupply
        ? widget.reserve.supplyApy
        : widget.reserve.borrowApy;
    final actionLabel = widget.isSupply ? 'Supply' : 'Borrow';
    final buttonLabel = _submitting
        ? 'Submitting...'
        : (widget.isSupply && _needsApproval)
        ? 'Approve $actionLabel'
        : 'Confirm $actionLabel';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '$actionLabel ${widget.reserve.symbol}',
          style: AppTypography.title.copyWith(
            fontWeight: FontWeight.w600,
            color: c.textPrimary,
          ),
        ),
        backgroundColor: c.bgBase,
        elevation: 0,
      ),
      backgroundColor: c.bgBase,
      body: Padding(
        padding: EdgeInsets.all(AppSpacing.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(AppSpacing.space4),
              decoration: BoxDecoration(
                color: c.bgSurface,
                borderRadius: AppRadius.brMd,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.reserve.symbol,
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w600,
                      color: c.textPrimary,
                    ),
                  ),
                  Text(
                    '${apy.toStringAsFixed(2)}% ${widget.isSupply ? 'Supply APY' : 'Borrow APR'}',
                    style: AppTypography.caption.copyWith(
                      color: widget.isSupply ? c.success : c.warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.space6),
            AppTextField(
              controller: _amountCtrl,
              label: 'Amount',
              hint: '0.0',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: (_) => _refreshApprovalState(),
              enabled: !_submitting,
            ),
            if (_checkingApproval) ...[
              SizedBox(height: AppSpacing.space2),
              Text(
                'Checking approval…',
                style: AppTypography.caption.copyWith(color: c.textSubtitle),
              ),
            ],
            if (_error != null) ...[
              SizedBox(height: AppSpacing.space4),
              Text(
                _error!,
                style: AppTypography.caption.copyWith(color: c.danger),
              ),
            ],
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: ScreenUtil().setWidth(88),
              child: AppButton(
                label: buttonLabel,
                onPressed: _submitting ? null : _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
