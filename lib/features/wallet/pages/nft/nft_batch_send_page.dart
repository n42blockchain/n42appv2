// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';
import 'package:n42_wallet/features/wallet/api/sender/chain_sender.dart';
import 'package:n42_wallet/features/wallet/api/sender/nft_sender.dart';
import 'package:n42_wallet/features/wallet/models/coin_config_view.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/nft_model.dart';
import 'package:n42_wallet/features/wallet/pages/nft/nft_batch_transfer_utils.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart'
    show getPathWithIndex;
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/generated/l10n.dart';

class NftBatchSendPage extends StatefulWidget {
  final List<NftModel> nfts;
  final CoinModel coinModel;

  const NftBatchSendPage(this.nfts, this.coinModel, {super.key});

  @override
  State<NftBatchSendPage> createState() => _NftBatchSendPageState();
}

enum _NftBatchStatus { pending, sending, success, failed }

class _NftBatchItem {
  final NftModel nft;
  _NftBatchStatus status;
  String? error;
  String? txHash;

  _NftBatchItem(this.nft) : status = _NftBatchStatus.pending;
}

class _NftBatchSendPageState extends State<NftBatchSendPage> {
  final _formKey = GlobalKey<FormState>();
  final _addressCtrl = TextEditingController();
  late final List<_NftBatchItem> _items;
  bool _sending = false;

  CoinModel get coinModel => widget.coinModel;

  @override
  void initState() {
    super.initState();
    _items = widget.nfts
        .where(NftBatchTransferUtils.isBatchTransferable)
        .map(_NftBatchItem.new)
        .toList();
  }

  @override
  void dispose() {
    _addressCtrl.dispose();
    super.dispose();
  }

  int get _successCount =>
      _items.where((i) => i.status == _NftBatchStatus.success).length;

  int get _failedCount =>
      _items.where((i) => i.status == _NftBatchStatus.failed).length;

  bool get _allSucceeded => _items.isNotEmpty && _successCount == _items.length;

  List<_NftBatchItem> get _retryScope => _items
      .where((i) => i.status == _NftBatchStatus.failed)
      .toList(growable: false);

  Future<void> _send({bool retryFailedOnly = false}) async {
    if (_sending) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_items.isEmpty) return;

    final toAddress = _addressCtrl.text.trim();
    final configCoinType = coinModel.config.coinType;
    final coinType = configCoinType.isNotEmpty ? configCoinType : 'ETH';

    final valid = await Trustdart().validateAddress(coinType, toAddress);
    if (!mounted) return;
    if (!valid) {
      ToastUtils.showWarning(S.of(context).g_key_nft_address_invalid);
      return;
    }

    final scope = retryFailedOnly ? _retryScope : _items;
    if (scope.isEmpty) return;

    setState(() {
      _sending = true;
      for (final item in scope) {
        item.status = _NftBatchStatus.pending;
        item.error = null;
        item.txHash = null;
      }
    });

    final sender = NftSender();
    for (final item in scope) {
      if (!mounted) return;
      setState(() => item.status = _NftBatchStatus.sending);
      try {
        final result = await sender.send(
          SendParams(
            coinType: coinType,
            fromAddress: coinModel.address.toString(),
            toAddress: toAddress,
            amount: 0.0,
            decimals: (coinModel.coin['decimals'] as num?)?.toInt() ?? 18,
            path: _derivePath(),
            isTest: coinModel.isTest,
            contractAddress: item.nft.contractAddress,
            nftTokenId: item.nft.tokenId,
            nftStandard: item.nft.nftType,
            nftQuantity: NftBatchTransferUtils.quantityForBatch(item.nft),
            privateKey: coinModel.privateKey,
            chainConfig: coinModel.coin,
          ),
        );
        if (!mounted) return;
        setState(() {
          if (result.success) {
            item.status = _NftBatchStatus.success;
            item.txHash = result.txHash;
          } else {
            item.status = _NftBatchStatus.failed;
            item.error = result.error ?? 'Send failed';
          }
        });
      } catch (e) {
        if (!mounted) return;
        setState(() {
          item.status = _NftBatchStatus.failed;
          item.error = e.toString();
        });
      }
    }

    if (!mounted) return;
    setState(() => _sending = false);
    if (_failedCount == 0) {
      ToastUtils.showSuccess(S.of(context).g_key_nft_41);
    }
  }

  String _derivePath() {
    final addrType = coinModel.addrType;
    final basePath =
        coinModel.config.pathForAddrType(addrType) ?? "m/44'/60'/0'/0/0";
    return getPathWithIndex(basePath, coinModel.pathIndex);
  }

  void _finish() => Navigator.pop(context, true);

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    return Scaffold(
      appBar: AppBarWidget(text: 'Batch NFT Transfer'),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.space6),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: AppSpacing.space6),
                _buildAddressField(tokens),
                SizedBox(height: AppSpacing.space4),
                _buildProgress(tokens),
                SizedBox(height: AppSpacing.space4),
                Expanded(child: _buildList(tokens)),
                SizedBox(height: AppSpacing.space4),
                _buildPrimaryButton(tokens),
                SizedBox(height: AppSpacing.space6),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddressField(AppColorTokens tokens) {
    return TextFormField(
      controller: _addressCtrl,
      enabled: !_sending && !_allSucceeded,
      decoration: InputDecoration(
        labelText: S.of(context).g_key_38,
        hintText: S.of(context).g_key_41,
        suffixIcon: IconButton(
          icon: Icon(Icons.paste, color: tokens.brand),
          onPressed: _sending || _allSucceeded
              ? null
              : () async {
                  final data = await Clipboard.getData(Clipboard.kTextPlain);
                  if (!mounted) return;
                  final text = data?.text?.trim();
                  if (text != null && text.isNotEmpty) {
                    _addressCtrl.text = text;
                  }
                },
        ),
        border: OutlineInputBorder(borderRadius: AppRadius.brSm),
      ),
      style: AppTypography.bodySm.copyWith(color: tokens.textPrimary),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return S.of(context).g_key_41;
        }
        return null;
      },
    );
  }

  Widget _buildProgress(AppColorTokens tokens) {
    final total = _items.length;
    final text = total == 0
        ? '0 selected'
        : '$_successCount/$total submitted'
              '${_failedCount > 0 ? ' • $_failedCount failed' : ''}';
    return Row(
      children: [
        Expanded(
          child: LinearProgressIndicator(
            value: total == 0 ? 0 : _successCount / total,
            minHeight: ScreenUtil().setWidth(6),
            color: tokens.brand,
            backgroundColor: tokens.textSubtitle.withAlpha(35),
          ),
        ),
        SizedBox(width: AppSpacing.space4),
        Text(
          text,
          style: AppTypography.caption.copyWith(color: tokens.textSubtitle),
        ),
      ],
    );
  }

  Widget _buildList(AppColorTokens tokens) {
    if (_items.isEmpty) {
      return Center(
        child: Text(
          S.of(context).g_key_nft_no_items,
          style: AppTypography.body.copyWith(color: tokens.textSubtitle),
        ),
      );
    }
    return ListView.separated(
      itemCount: _items.length,
      separatorBuilder: (context, index) =>
          Divider(color: tokens.textSubtitle.withAlpha(30)),
      itemBuilder: (context, index) => _buildItem(_items[index], tokens),
    );
  }

  Widget _buildItem(_NftBatchItem item, AppColorTokens tokens) {
    final statusColor = switch (item.status) {
      _NftBatchStatus.pending => tokens.textSubtitle,
      _NftBatchStatus.sending => tokens.brand,
      _NftBatchStatus.success => tokens.success,
      _NftBatchStatus.failed => tokens.danger,
    };
    final statusIcon = switch (item.status) {
      _NftBatchStatus.pending => Icons.radio_button_unchecked,
      _NftBatchStatus.sending => Icons.sync,
      _NftBatchStatus.success => Icons.check_circle,
      _NftBatchStatus.failed => Icons.error,
    };
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: ClipRRect(
        borderRadius: AppRadius.brSm,
        child: SizedBox(
          width: ScreenUtil().setWidth(48),
          height: ScreenUtil().setWidth(48),
          child: item.nft.imageUrl?.isNotEmpty == true
              ? Image.network(
                  item.nft.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildThumbFallback(tokens),
                )
              : _buildThumbFallback(tokens),
        ),
      ),
      title: Text(
        item.nft.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTypography.bodySm.copyWith(color: tokens.textPrimary),
      ),
      subtitle: Text(
        item.error ?? '#${item.nft.tokenId}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTypography.captionSm.copyWith(
          color: item.error == null ? tokens.textSubtitle : tokens.danger,
        ),
      ),
      trailing: Icon(statusIcon, color: statusColor),
    );
  }

  Widget _buildThumbFallback(AppColorTokens tokens) {
    return Container(
      color: tokens.brand.withAlpha(20),
      child: Icon(Icons.image_outlined, color: tokens.brand),
    );
  }

  Widget _buildPrimaryButton(AppColorTokens tokens) {
    final canSend = !_sending && _items.isNotEmpty;
    final label = _allSucceeded
        ? S.of(context).g_key_batch_done
        : _failedCount > 0
        ? S.of(context).g_key_aa_retry
        : '${S.of(context).g_key_48} (${_items.length})';

    return SizedBox(
      width: double.infinity,
      height: ScreenUtil().setWidth(88),
      child: ElevatedButton(
        onPressed: !canSend
            ? null
            : _allSucceeded
            ? _finish
            : () => _send(retryFailedOnly: _failedCount > 0),
        style: ElevatedButton.styleFrom(
          backgroundColor: tokens.brand,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.brMd),
        ),
        child: _sending
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                label,
                style: AppTypography.body.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
