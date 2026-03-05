// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

part of 'stake_page.dart';

/// Logic mixin: data loading, event handlers, utility methods.
///
/// Requires [_StakePageState] to provide the state fields and [widget].
mixin _StakeLogicMixin on State<StakePage> {
  StakingProvider get _provider;
  TextEditingController get _amountController;
  TextEditingController get _unstakeAmountController;

  bool get _isLoading;
  set _isLoading(bool value);

  BigInt get _balance;
  set _balance(BigInt value);

  String get _errorMessage;
  set _errorMessage(String value);

  List<StakingPosition> get _activePositions;
  set _activePositions(List<StakingPosition> value);

  StakingPosition? get _selectedPosition;
  set _selectedPosition(StakingPosition? value);

  bool get _loadingPositions;
  set _loadingPositions(bool value);

  // ── Query helpers ───────────────────────────────────────────────────────

  bool _needsValidator() {
    return widget.protocol.chainType != StakingChainType.ethereum;
  }

  static const _chainTypeDecimals = <StakingChainType, int>{
    StakingChainType.ethereum: 18,
    StakingChainType.solana: 9,
    StakingChainType.cosmos: 6,
    StakingChainType.polkadot: 10,
  };

  int _getDecimals() => _chainTypeDecimals[widget.protocol.chainType] ?? 18;

  // ── Data loading ────────────────────────────────────────────────────────

  /// 加载用户当前活跃质押仓位（用于解质押页面显示）
  Future<void> _loadActivePositions() async {
    if (widget.userAddress == null || widget.userAddress!.isEmpty) return;
    if (!mounted) return;
    setState(() => _loadingPositions = true);

    await _provider.loadUserPositions(widget.userAddress!, widget.protocol.chainType);

    if (!mounted) return;
    setState(() {
      _activePositions = _provider.positions
          .where((p) => p.status == StakingPositionStatus.active)
          .toList();
      _loadingPositions = false;
    });
  }

  Future<void> _loadBalance() async {
    BigInt balance = BigInt.zero;
    try {
      final symbol = widget.protocol.chainSymbol;
      final cm = globalWapAdapter.coinModels
          .where((c) => c.coin['coinType'] == symbol)
          .firstOrNull;
      if (cm != null) {
        final key = cm.isTest ? 'balance_test' : 'balance';
        balance = BigInt.tryParse(cm.coin[key] ?? '0') ?? BigInt.zero;
      }
    } catch (_) {}
    setState(() => _balance = balance);
  }

  // ── Navigation ──────────────────────────────────────────────────────────

  Future<void> _navigateToValidatorList(BuildContext context, StakingProvider provider) async {
    final selectedValidator = await Navigator.push<Validator>(
      context,
      MaterialPageRoute(
        builder: (context) => ValidatorListPage(
          protocol: widget.protocol,
          validators: provider.validators,
          selectedValidator: provider.selectedValidator,
        ),
      ),
    );

    if (selectedValidator != null) {
      provider.selectValidator(selectedValidator);
    }
  }

  // ── Stake / Unstake actions ─────────────────────────────────────────────

  Future<void> _performStake(BuildContext context, StakingProvider provider) async {
    if (widget.userAddress == null || widget.userAddress!.isEmpty) {
      setState(() {
        _errorMessage = S.of(context).g_key_stake_no_wallet;
      });
      return;
    }

    final amountText = _amountController.text;
    final amountBigInt = _parseAmountToBigInt(amountText, _getDecimals());
    // 提前捕获跨异步使用的对象
    final messenger = ScaffoldMessenger.of(context);
    final txPreparedMsg = S.of(context).g_key_stake_tx_prepared;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final result = await provider.buildStakeTransaction(
        fromAddress: widget.userAddress!,
        amount: amountBigInt,
      );

      if (result != null && result.success) {
        if (!mounted) return;
        messenger.showSnackBar(
          SnackBar(content: Text(txPreparedMsg), backgroundColor: Colors.green),
        );
      } else {
        setState(() {
          _errorMessage = result?.error ?? '';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _performUnstake(BuildContext context, StakingProvider provider) async {
    if (widget.userAddress == null || widget.userAddress!.isEmpty) {
      setState(() => _errorMessage = S.of(context).g_key_stake_no_wallet);
      return;
    }

    if (_selectedPosition == null) {
      setState(() => _errorMessage = S.of(context).g_key_stake_select_position);
      return;
    }

    // 解质押金额：SOL 全量，ATOM 可自定义
    BigInt unstakeAmount;
    if (widget.protocol.chainType == StakingChainType.cosmos) {
      final amtText = _unstakeAmountController.text;
      unstakeAmount = _parseAmountToBigInt(amtText, _getDecimals());
      if (unstakeAmount == BigInt.zero) {
        setState(() => _errorMessage = S.of(context).g_key_stake_amount_unstake);
        return;
      }
    } else {
      // SOL：全量解绑整个 stake account
      unstakeAmount = _selectedPosition!.stakedAmount;
    }

    // 提前捕获跨异步使用的对象
    final messenger = ScaffoldMessenger.of(context);
    final txPreparedMsg = S.of(context).g_key_stake_tx_prepared;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final positionToUnstake = _selectedPosition!;
    try {
      final result = await provider.buildUnstakeTransaction(
        position: positionToUnstake,
        fromAddress: widget.userAddress!,
        amount: unstakeAmount,
      );

      if (!mounted) return;

      if (result != null && result.success) {
        messenger.showSnackBar(
          SnackBar(content: Text(txPreparedMsg), backgroundColor: Colors.green),
        );
        // 解质押成功后刷新仓位列表
        setState(() => _selectedPosition = null);
        await _loadActivePositions();
      } else {
        setState(() {
          _errorMessage = result?.error ?? '';
        });
      }
    } catch (e) {
      if (mounted) setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Format helpers ──────────────────────────────────────────────────────

  /// 将用户输入的金额字符串精确转换为 BigInt（最小单位）
  ///
  /// 避免使用 double 中间转换导致的精度丢失。
  /// 例如：输入 "1.5"，decimals=18 -> 1500000000000000000
  BigInt _parseAmountToBigInt(String amountText, int decimals) {
    if (amountText.isEmpty) return BigInt.zero;

    final parts = amountText.split('.');
    final integerPart = parts[0].isEmpty ? '0' : parts[0];
    String fractionalPart = parts.length > 1 ? parts[1] : '';

    // 截断超出精度的小数位
    if (fractionalPart.length > decimals) {
      fractionalPart = fractionalPart.substring(0, decimals);
    }

    // 右侧补零到 decimals 位
    fractionalPart = fractionalPart.padRight(decimals, '0');

    final combined = '$integerPart$fractionalPart';
    return BigInt.tryParse(combined) ?? BigInt.zero;
  }

  /// BigInt 转人类可读字符串（最多 6 位小数）
  String _formatBigInt(BigInt amount) {
    final decimals = _getDecimals();
    final divisor = BigInt.from(10).pow(decimals);
    final intPart = amount ~/ divisor;
    final fracStr = amount.remainder(divisor).abs().toString().padLeft(decimals, '0');
    final dispFrac = fracStr.length > 6 ? fracStr.substring(0, 6) : fracStr;
    // 去掉尾部多余 0
    final trimmed = dispFrac.replaceAll(RegExp(r'0+$'), '');
    return trimmed.isEmpty ? '$intPart' : '$intPart.$trimmed';
  }
}
