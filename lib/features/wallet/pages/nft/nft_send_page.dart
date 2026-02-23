// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/wallet/api/transfer_api.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/nft_model.dart';
import 'package:n42_wallet/features/wallet/provider/trustdart.dart';
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

    setState(() => _sending = true);

    try {
      final mm = await TransferApi().transferEth721(
        toAddress: toAddress,
        contractAddress: nft.contractAddress,
        value: 0,
        nftNum: quantity,
        tokenId: nft.tokenId,
        erc721Or1155: nft.nftType,
        coinType: coinType,
        isTest: coinModel.isTest,
      );

      if (!mounted) return;

      if (mm.error == true) {
        ToastUtils.showWarning(mm.data?.toString() ?? 'Send failed');
      } else {
        ToastUtils.showSuccess(S.of(context).g_key_nft_41); // Transaction submitted
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ToastUtils.showWarning(e.toString());
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final blueColor = AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name);
    final textColor = AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name);
    final subtitleColor = AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name);

    return Scaffold(
      appBar: AppBarWidget(text: S.of(context).g_key_nft_send),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: ScreenUtil().setWidth(30)),

                // NFT 简要信息
                _buildNftInfo(context, textColor, subtitleColor),

                SizedBox(height: ScreenUtil().setWidth(30)),

                // 收款地址
                Text(
                  S.of(context).g_key_38, // To
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(28),
                    color: subtitleColor,
                  ),
                ),
                SizedBox(height: ScreenUtil().setWidth(10)),
                TextFormField(
                  controller: _addressCtrl,
                  decoration: InputDecoration(
                    hintText: S.of(context).g_key_41,
                    hintStyle: TextStyle(color: subtitleColor, fontSize: ScreenUtil().setSp(26)),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.paste, color: blueColor),
                      onPressed: () async {
                        final data = await Clipboard.getData('text/plain');
                        if (data?.text != null) {
                          _addressCtrl.text = data!.text!;
                        }
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
                    ),
                  ),
                  style: TextStyle(fontSize: ScreenUtil().setSp(26), color: textColor),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return S.of(context).g_key_41;
                    }
                    return null;
                  },
                ),

                // ERC1155 数量字段
                if (nft.isErc1155) ...[
                  SizedBox(height: ScreenUtil().setWidth(24)),
                  Text(
                    S.of(context).g_key_nft_quantity,
                    style: TextStyle(fontSize: ScreenUtil().setSp(28), color: subtitleColor),
                  ),
                  SizedBox(height: ScreenUtil().setWidth(10)),
                  TextFormField(
                    controller: _quantityCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      hintText: '1 ~ ${nft.balance}',
                      hintStyle: TextStyle(color: subtitleColor, fontSize: ScreenUtil().setSp(26)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
                      ),
                    ),
                    style: TextStyle(fontSize: ScreenUtil().setSp(26), color: textColor),
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
                        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
                      ),
                    ),
                    child: _sending
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            S.of(context).g_key_48, // Send
                            style: TextStyle(
                              fontSize: ScreenUtil().setSp(30),
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: ScreenUtil().setWidth(30)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNftInfo(BuildContext context, Color textColor, Color subtitleColor) {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name).withAlpha(15),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
      ),
      child: Row(
        children: [
          // 缩略图
          ClipRRect(
            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
            child: nft.imageUrl != null && nft.imageUrl!.isNotEmpty
                ? Image.network(
                    nft.imageUrl!,
                    width: ScreenUtil().setWidth(80),
                    height: ScreenUtil().setWidth(80),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) => _imgPlaceholder(),
                  )
                : _imgPlaceholder(),
          ),
          SizedBox(width: ScreenUtil().setWidth(16)),
          // 名称 + Token ID
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nft.name,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(28),
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: ScreenUtil().setWidth(4)),
                Text(
                  '${S.of(context).g_key_nft_token_id}: #${nft.tokenId}',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(24),
                    color: subtitleColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imgPlaceholder() {
    return Builder(
      builder: (context) => Container(
        width: ScreenUtil().setWidth(80),
        height: ScreenUtil().setWidth(80),
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name).withAlpha(30),
        child: Icon(
          Icons.image_outlined,
          size: ScreenUtil().setWidth(40),
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
        ),
      ),
    );
  }
}
