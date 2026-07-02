part of 'aa_send_page.dart';

/// State fields and business logic mixin for [_AASendPageState].
mixin _AASendLogicMixin on State<AASendPage> {
  final TextEditingController toController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final FocusNode toFocusNode = FocusNode();
  final FocusNode amountFocusNode = FocusNode();

  final String selectedToken = 'ETH';
  PaymasterOption selectedPaymaster = PaymasterOption.none;
  bool isEstimating = false;
  bool isSending = false;

  BigInt? estimatedGas;
  BigInt? maxFeePerGas;

  void disposeLogic() {
    toController.dispose();
    amountController.dispose();
    toFocusNode.dispose();
    amountFocusNode.dispose();
  }

  String _chainSymbol() => AAConfig.chainIds.entries
      .firstWhere(
        (e) => e.value == widget.account.chainId,
        orElse: () => const MapEntry('ETH', 1),
      )
      .key;

  static final _addrRegex = RegExp(r'^0x[0-9a-fA-F]{40}$');

  Uint8List _buildCallData() {
    final toAddress = toController.text.trim();
    final parsed = double.tryParse(amountController.text.trim()) ?? 0.0;
    final wholePart = BigInt.from(parsed.truncate());
    final fracPart = BigInt.from(((parsed - parsed.truncate()) * 1e18).round());
    final amountWei = wholePart * BigInt.from(10).pow(18) + fracPart;
    return CalldataBuilder.buildExecute(
      target: toAddress.isEmpty
          ? '0x0000000000000000000000000000000000000000'
          : toAddress,
      value: amountWei,
      data: Uint8List(0),
    );
  }

  Future<void> estimateGas() async {
    if (toController.text.isEmpty || amountController.text.isEmpty) return;

    setState(() => isEstimating = true);

    const defaultMaxFeePerGas = 22 * 1000000000;
    try {
      final chainSymbol = _chainSymbol();
      final bundler = BundlerClient.forChain(chainSymbol);

      final estimationOp = UserOpBuilder()
          .setSender(widget.account.address)
          .setNonce(BigInt.zero)
          .setCallData(_buildCallData())
          .buildForEstimation();

      final estimator = AAGasEstimator(bundler);
      final result = await estimator.estimate(estimationOp);

      if (!mounted) return;
      setState(() {
        estimatedGas = result.totalGas;
        maxFeePerGas = BigInt.from(defaultMaxFeePerGas);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        estimatedGas = BigInt.from(150000);
        maxFeePerGas = BigInt.from(defaultMaxFeePerGas);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).g_key_aa_gas_estimate_failed)),
      );
    } finally {
      if (mounted) setState(() => isEstimating = false);
    }
  }

  Future<void> selectPaymaster() async {
    final result = await Navigator.push<PaymasterOption>(
      context,
      MaterialPageRoute(
        builder: (_) => PaymasterSelectPage(
          currentOption: selectedPaymaster,
          chainId: widget.account.chainId,
        ),
      ),
    );
    if (!mounted || result == null) return;
    setState(() => selectedPaymaster = result);
    estimateGas();
  }

  void showTransactionPreview() {
    final toAddress = toController.text.trim();
    if (!_addrRegex.hasMatch(toAddress)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(S.of(context).g_key_t_50)));
      return;
    }
    final amount = double.tryParse(amountController.text.trim()) ?? 0.0;
    if (amount <= 0) {
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AATransactionPreview(
        data: AATransactionPreviewData(
          fromAddress: widget.account.address,
          toAddress: toController.text,
          amount: amountController.text,
          tokenSymbol: selectedToken,
          estimatedGas: estimatedGas,
          maxFeePerGas: maxFeePerGas,
          isGasSponsored: selectedPaymaster.type == PaymasterType.sponsored,
        ),
        onConfirm: () {
          Navigator.pop(context);
          _sendTransaction();
        },
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  Future<void> _sendTransaction() async {
    // Paymaster 代付当前没有真实的 pm_getPaymasterData 集成（见
    // paymaster_select_page 的探测逻辑）——选了代付却静默按自付 gas 发送
    // 会让用户被扣费。在此如实拦截，而不是假装代付生效。
    if (selectedPaymaster.type != PaymasterType.none) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).g_key_aa_paymaster_unavailable)),
      );
      setState(() => selectedPaymaster = PaymasterOption.none);
      return;
    }

    setState(() => isSending = true);

    // 与批量交易页同一真实通道：AATransferHandler 构建 UserOperation →
    // bundler 估 gas → 签名 → eth_sendUserOperation → 等待回执。
    final handler = AATransferHandler(_chainSymbol());
    final result = await handler.transfer(
      AATransferParams(
        chainSymbol: _chainSymbol(),
        fromAddress: widget.walletAddress,
        toAddress: toController.text.trim(),
        value: double.tryParse(amountController.text.trim()) ?? 0.0,
        smartAccount: widget.account,
      ),
    );

    if (!mounted) return;
    setState(() => isSending = false);

    if (!result.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).g_key_140),
          backgroundColor: AppColorTokens.of(context).success,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.data?.toString() ?? S.of(context).g_key_aa_send_failed,
          ),
          backgroundColor: AppColorTokens.of(context).danger,
        ),
      );
    }
  }

  String formatGasCost() {
    if (estimatedGas == null || maxFeePerGas == null) return '-';
    final cost = estimatedGas! * maxFeePerGas!;
    final ethValue = cost / BigInt.from(10).pow(18);
    return '${ethValue.toStringAsFixed(6)} ETH';
  }
}
