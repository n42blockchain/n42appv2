// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/features/wallet/api/sender/chain_sender.dart';
import 'package:n42_wallet/features/wallet/api/sender/nft_sender.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart'
    show getPathWithIndex;
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/nft_model.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';

/// NFT 发送页
///
/// 字段：收款地址 + 数量（仅 ERC1155 显示）。
/// 地址校验通过后直接调用 [TransferApi.transferEth721]。
/// Solana NFT 暂不支持，显示 toast。
class NftSendPage extends StatefulWidget {
  final NftModel nft;
  final CoinModel coinModel;

  const NftSendPage(this.nft, this.coinModel, {super.key});

  @override
  State<NftSendPage> createState() => _NftSendPageState();
}

class _NftSendPageState extends State<NftSendPage> {
  final _formKey = GlobalKey<FormState>();
  final _addressCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController(text: '1');
  bool _sending = false;

  NftModel get nft => widget.nft;
  CoinModel get coinModel => widget.coinModel;

  @override
  void dispose() {
    _addressCtrl.dispose();
    _quantityCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final toAddress = _addressCtrl.text.trim();
    final coinType = coinModel.coin['coinType'] as String? ?? 'ETH';

    // 地址校验
    final valid = await Trustdart().validateAddress(coinType, toAddress);
    if (!mounted) return;
    if (!valid) {
      ToastUtils.showWarning(S.of(context).g_key_nft_address_invalid);
      return;
    }

    // 数量校验（ERC1155）
    int quantity = 1;
    if (nft.isErc1155) {
      quantity = int.tryParse(_quantityCtrl.text.trim()) ?? 1;
      if (quantity <= 0 || quantity > nft.balance) {
        ToastUtils.showWarning(S.of(context).g_key_t_43);
        return;
      }
    }

    bool completedWithExit = false;
    setState(() => _sending = true);

    try {
      final addrType = coinModel.addrType;
      final baseInfo = coinModel.coin['baseInfo'] as Map<String, dynamic>?;
      final pathMap = baseInfo?['path'] as Map<String, dynamic>?;
      final basePath = pathMap?[addrType]?.toString() ?? "m/44'/60'/0'/0/0";
      final path = getPathWithIndex(basePath, coinModel.pathIndex);

      final result = await NftSender().send(
        SendParams(
          coinType: coinType,
          fromAddress: coinModel.address.toString(),
          toAddress: toAddress,
          amount: 0.0,
          decimals: (coinModel.coin['decimals'] as num?)?.toInt() ?? 18,
          path: path,
          isTest: coinModel.isTest,
          contractAddress: nft.contractAddress,
          nftTokenId: nft.tokenId,
          nftStandard: nft.nftType,
          nftQuantity: quantity,
          chainConfig: coinModel.coin,
        ),
      );

      if (!mounted) return;

      if (!result.success) {
        ToastUtils.showWarning(result.error ?? 'Send failed');
      } else {
        ToastUtils.showSuccess(S.of(context).g_key_nft_41);
        completedWithExit = true;
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ToastUtils.showWarning(e.toString());
    } finally {
      if (mounted && !completedWithExit) {
        setState(() => _sending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final blueColor = AppColorTokens.of(context).brand;
    final textColor = AppColorTokens.of(context).textPrimary;
    final subtitleColor = AppColorTokens.of(context).textSubtitle;

    return Scaffold(
      appBar: AppBarWidget(text: S.of(context).g_key_nft_send),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.space8),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: AppSpacing.space8),

                // NFT 简要信息
                _buildNftInfo(context, textColor, subtitleColor),

                SizedBox(height: AppSpacing.space8),

                // 收款地址
                Text(
                  S.of(context).g_key_38, // To
                  style: AppTypography.body.copyWith(color: subtitleColor),
                ),
                SizedBox(height: AppSpacing.space2),
                TextFormField(
                  controller: _addressCtrl,
                  decoration: InputDecoration(
                    hintText: S.of(context).g_key_41,
                    hintStyle: AppTypography.bodySm.copyWith(
                      color: subtitleColor,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.paste, color: blueColor),
                      onPressed: () async {
                        final data = await Clipboard.getData('text/plain');
                        if (!mounted) return;
                        if (data?.text != null) {
                          _addressCtrl.text = data!.text!;
                        }
                      },
                    ),
                    border: OutlineInputBorder(borderRadius: AppRadius.brSm),
                  ),
                  style: AppTypography.bodySm.copyWith(color: textColor),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return S.of(context).g_key_41;
                    }
                    return null;
                  },
                ),

                // ERC1155 数量字段
                if (nft.isErc1155) ...[
                  SizedBox(height: AppSpacing.space6),
                  Text(
                    S.of(context).g_key_nft_quantity,
                    style: AppTypography.body.copyWith(color: subtitleColor),
                  ),
                  SizedBox(height: AppSpacing.space2),
                  TextFormField(
                    controller: _quantityCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      hintText: '1 ~ ${nft.balance}',
                      hintStyle: AppTypography.bodySm.copyWith(
                        color: subtitleColor,
                      ),
                      border: OutlineInputBorder(borderRadius: AppRadius.brSm),
                    ),
                    style: AppTypography.bodySm.copyWith(color: textColor),
                    validator: (v) {
                      final n = int.tryParse(v ?? '');
                      if (n == null || n <= 0) return S.of(context).g_key_t_43;
                      if (n > nft.balance) return S.of(context).g_key_47;
                      return null;
                    },
                  ),
                ],

                const Spacer(),

                // 发送按钮
                SizedBox(
                  width: double.infinity,
                  height: ScreenUtil().setWidth(90),
                  child: ElevatedButton(
                    onPressed: _sending ? null : _send,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: blueColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.brMd,
                      ),
                    ),
                    child: _sending
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            S.of(context).g_key_48, // Send
                            style: AppTypography.body.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: AppSpacing.space8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNftInfo(
    BuildContext context,
    Color textColor,
    Color subtitleColor,
  ) {
    final blueColor = AppColorTokens.of(context).brand;
    return Container(
      padding: EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        color: blueColor.withAlpha(15),
        borderRadius: AppRadius.brMd,
      ),
      child: Row(
        children: [
          // 缩略图
          ClipRRect(
            borderRadius: AppRadius.brSm,
            child: nft.imageUrl != null && nft.imageUrl!.isNotEmpty
                ? Image.network(
                    nft.imageUrl!,
                    width: ScreenUtil().setWidth(80),
                    height: ScreenUtil().setWidth(80),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) =>
                        _imgPlaceholder(blueColor),
                  )
                : _imgPlaceholder(blueColor),
          ),
          SizedBox(width: AppSpacing.space4),
          // 名称 + Token ID
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nft.name,
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: AppSpacing.space2),
                Text(
                  '${S.of(context).g_key_nft_token_id}: #${nft.tokenId}',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: AppTypography.caption.copyWith(color: subtitleColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imgPlaceholder(Color blueColor) {
    return Container(
      width: ScreenUtil().setWidth(80),
      height: ScreenUtil().setWidth(80),
      color: blueColor.withAlpha(30),
      child: Icon(
        Icons.image_outlined,
        size: ScreenUtil().setWidth(40),
        color: blueColor,
      ),
    );
  }
}
