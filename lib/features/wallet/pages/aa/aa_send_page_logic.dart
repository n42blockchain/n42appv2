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

  Uint8List _buildCallData() {
    final toAddress = toController.text.trim();
    final amountWei = BigInt.from(
      ((double.tryParse(amountController.text.trim()) ?? 0.0) * 1e18).toInt(),
    );
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
    if (result != null) {
      setState(() => selectedPaymaster = result);
      estimateGas();
    }
  }

  void showTransactionPreview() {
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
    setState(() => isSending = true);

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => isSending = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).g_key_140),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    }
  }

  String formatGasCost() {
    if (estimatedGas == null || maxFeePerGas == null) return '-';
    final cost = estimatedGas! * maxFeePerGas!;
    final ethValue = cost / BigInt.from(10).pow(18);
    return '${ethValue.toStringAsFixed(6)} ETH';
  }
}
