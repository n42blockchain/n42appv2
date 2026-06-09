// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/features/wallet/provider/batch_transfer_provider.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/features/wallet/pages/batch_transfer/csv_import_page.dart';
import 'package:n42_wallet/features/wallet/pages/batch_transfer/batch_transfer_bottom_bar.dart';
import 'package:n42_wallet/features/wallet/pages/batch_transfer/batch_transfer_dialogs.dart';
import 'package:n42_wallet/features/wallet/pages/batch_transfer/batch_transfer_list_widgets.dart';
import 'package:n42_wallet/features/wallet/pages/batch_transfer/batch_transfer_widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:n42_wallet/features/wallet/utils/feature_address_utils.dart';

/// 批量转账页面
class BatchTransferPage extends ConsumerStatefulWidget {
  final String chainSymbol;
  final String rpcUrl;
  final int chainId;
  final String fromAddress;
  final String? tokenAddress;
  final String tokenSymbol;
  final int decimals;
  final BigInt balance;
  final BatchTransferProvider batchTransferProvider;

  const BatchTransferPage({
    super.key,
    required this.chainSymbol,
    required this.rpcUrl,
    required this.chainId,
    required this.fromAddress,
    this.tokenAddress,
    required this.tokenSymbol,
    required this.decimals,
    required this.balance,
    required this.batchTransferProvider,
  });

  @override
  ConsumerState<BatchTransferPage> createState() => _BatchTransferPageState();
}

class _BatchTransferPageState extends ConsumerState<BatchTransferPage> {
  final _addressController = TextEditingController();
  final _amountController = TextEditingController();
  final _memoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.batchTransferProvider.initialize(
        chainSymbol: widget.chainSymbol,
        rpcUrl: widget.rpcUrl,
        chainId: widget.chainId,
        fromAddress: widget.fromAddress,
        tokenAddress: widget.tokenAddress,
        tokenSymbol: widget.tokenSymbol,
        decimals: widget.decimals,
      );
    });
  }

  @override
  void dispose() {
    _addressController.dispose();
    _amountController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).g_key_batch_title),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: _importCsv,
            tooltip: S.of(context).g_key_batch_import_csv,
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelp,
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: widget.batchTransferProvider,
        builder: (context, _) {
          final provider = widget.batchTransferProvider;
          return Column(
            children: [
              BatchInfoCard(
                tokenSymbol: widget.tokenSymbol,
                chainSymbol: widget.chainSymbol,
                supportsMulticall: provider.supportsMulticall,
              ),
              BatchAddItemForm(
                addressController: _addressController,
                amountController: _amountController,
                memoController: _memoController,
                tokenSymbol: widget.tokenSymbol,
                onPasteAddress: _pasteAddress,
                onAdd: _addItem,
              ),
              Expanded(
                child: BatchTransferList(
                  provider: provider,
                  tokenSymbol: widget.tokenSymbol,
                  onImportCsv: _importCsv,
                ),
              ),
              BatchBottomBar(
                provider: provider,
                tokenSymbol: widget.tokenSymbol,
                chainSymbol: widget.chainSymbol,
                formatGasFee: _formatGasFee,
                onProceed: _proceedToConfirm,
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _pasteAddress() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (!mounted) return;
    if (data?.text != null) {
      _addressController.text = data!.text!;
    }
  }

  void _addItem() {
    final address = _addressController.text.trim();
    final amountStr = _amountController.text.trim();
    final memo = _memoController.text.trim();

    if (address.isEmpty) return _showSnackBar('Please enter an address');
    if (!FeatureAddressUtils.isValidEvmAddress(address)) {
      return _showSnackBar('Invalid address format');
    }
    if (amountStr.isEmpty) return _showSnackBar('Please enter an amount');

    final amount = _parseAmount(amountStr);
    if (amount <= BigInt.zero) return _showSnackBar('Invalid amount');

    if (widget.batchTransferProvider.totalAmount + amount > widget.balance) {
      return _showSnackBar(
        S.of(context).g_key_batch_insufficient_balance(widget.tokenSymbol),
        bg: AppColorTokens.of(context).warning,
      );
    }

    widget.batchTransferProvider.addItem(
      address,
      amount,
      memo: memo.isEmpty ? null : memo,
    );

    _addressController.clear();
    _amountController.clear();
    _memoController.clear();
  }

  void _showSnackBar(String message, {Color? bg}) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: bg));
  }

  BigInt _parseAmount(String amountStr) {
    try {
      final cleaned = amountStr.replaceAll(',', '');
      if (!cleaned.contains('.')) {
        return BigInt.parse(cleaned) * BigInt.from(10).pow(widget.decimals);
      }
      final parts = cleaned.split('.');
      final decPart = parts[1].length > widget.decimals
          ? parts[1].substring(0, widget.decimals)
          : parts[1].padRight(widget.decimals, '0');
      return BigInt.parse('${parts[0]}$decPart');
    } catch (_) {
      return BigInt.zero;
    }
  }

  Future<void> _importCsv() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => CsvImportPage(
          tokenSymbol: widget.tokenSymbol,
          decimals: widget.decimals,
        ),
      ),
    );

    if (!mounted) return;
    if (result != null && result.isNotEmpty) {
      widget.batchTransferProvider.parseCsv(result);
    }
  }

  Future<void> _proceedToConfirm() async {
    final provider = widget.batchTransferProvider;

    await provider.estimateGas();

    if (!mounted) return;
    if (provider.gasEstimate == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => BatchConfirmDialog(
        provider: provider,
        tokenSymbol: widget.tokenSymbol,
        formatGasFee: _formatGasFee,
      ),
    );

    if (confirmed == true) {
      _executeTransfer();
    }
  }

  Future<void> _executeTransfer() async {
    final provider = widget.batchTransferProvider;
    final walletProvider = ref.read(wapBridgeProvider);

    final l10n = S.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final walletInfo = walletProvider.walletInfo;
    final mnemonic = walletInfo.mnemonic ?? '';
    final privateKey = walletInfo.privateKey ?? '';

    if (mnemonic.isEmpty && privateKey.isEmpty) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.g_key_210)));
      return;
    }

    final txData = await provider.buildTransaction();
    if (txData == null) return;

    provider.setSigningState();

    try {
      final coinInfo = walletProvider.walletMap[widget.chainSymbol];
      if (coinInfo == null) {
        provider.setError('Chain not supported');
        return;
      }

      final pathMap = coinInfo['baseInfo']['path'] as Map<String, dynamic>;
      final pathIndex = coinInfo['pathIndex'] ?? 0;
      final path = getPathWithIndex(
        pathMap['legacy'] ?? "m/44'/60'/0'/0/0",
        pathIndex,
      );

      final trustdart = Trustdart();
      final signedTx = await trustdart.signTransaction(
        widget.chainSymbol,
        path,
        txData,
        mnemonic: mnemonic,
        pk: privateKey,
      );

      if (signedTx.isEmpty) {
        provider.setError(l10n.g_key_175);
        return;
      }

      final success = await provider.broadcastTransaction(signedTx);

      if (success && mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.g_key_140),
            backgroundColor: AppColorTokens.of(context).success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        await _showTransferResult(provider);
        if (mounted) Navigator.pop(context, true);
      }
    } catch (e) {
      provider.setError(e.toString());
    }
  }

  Future<void> _showTransferResult(BatchTransferProvider provider) async {
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColorTokens.of(context).bgSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ScreenUtil().setWidth(24)),
        ),
      ),
      builder: (sheetCtx) => BatchResultSheet(
        provider: provider,
        tokenSymbol: widget.tokenSymbol,
        onExport: (ctx) => _exportReport(provider, ctx),
      ),
    );
  }

  Future<void> _exportReport(
    BatchTransferProvider provider,
    BuildContext sheetCtx,
  ) async {
    final subject = S.of(sheetCtx).g_key_batch_export_csv;
    try {
      final csvContent = provider.generateReportCsv();
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .substring(0, 19);
      final fileName = 'batch_report_$timestamp.csv';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsString(csvContent);

      if (!mounted) return;
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'text/csv', name: fileName)],
          subject: subject,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: $e'),
          backgroundColor: AppColorTokens.of(context).danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showHelp() {
    showDialog(context: context, builder: (ctx) => const BatchHelpDialog());
  }

  String _formatGasFee(BigInt fee) {
    final divisor = BigInt.from(10).pow(18);
    final ethValue = fee ~/ divisor;
    final remainder = fee % divisor;
    final decimalStr = remainder.toString().padLeft(18, '0').substring(0, 6);
    return '$ethValue.$decimalStr ${widget.chainSymbol}';
  }
}
