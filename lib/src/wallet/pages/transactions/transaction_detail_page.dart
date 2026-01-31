import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/core/utils/toast_utils.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:n42appv2/src/wallet/widgets/ens_address_display.dart';
import 'package:flutter/material.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TransactionDetailPage extends StatefulWidget {
  final String? time;
  final String? from;
  final String? to;
  final String? txHash;
  final String? gas;
  final String? gasPrice;
  final String? gasUsed;
  final String? blockNumber;
  final String? coinType;

  //交易的金额
  final String? value;
  const TransactionDetailPage({this.time,
    this.from,
    this.to,
    this.txHash,
    this.gas,
    this.gasPrice,
    this.blockNumber,
    this.coinType,
    this.gasUsed,
    this.value,
    super.key});

  @override
  State<TransactionDetailPage> createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_key_tran_4,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildItem(S.of(context).g_key_wallet_k25, widget.time),
            _buildItem(S.of(context).g_key_wallet_k54, widget.blockNumber),
            _buildAddressItem(
              S.of(context).g_key_75,
              widget.from,
            ),
            _buildAddressItem(
              S.of(context).g_key_38,
              widget.to,
            ),
            _buildItem(S.of(context).g_key_wallet_k55, widget.value),
            _buildItem(S.of(context).g_key_t_7, widget.gas),
            _buildItem(S.of(context).g_key_t_15, widget.gasPrice),
            _buildItem(S.of(context).g_key_t_6, widget.gasUsed),
            _buildItem(
              S.of(context).g_key_wallet_k37,
              widget.txHash,
              copy: true,
            ),
            /*_buildItem(
              "blockHash",
              widget.blockHash,
              copy: true,
            ),
            _buildItem("status", widget.status),*/
          ],
        ),
      ),
    );
  }
  /// 构建地址显示项（支持 ENS）
  Widget _buildAddressItem(String? title, String? address) {
    if (address == null || address.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: ScreenUtil().setWidth(16),
        horizontal: ScreenUtil().setWidth(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title ?? "",
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemSubtitleTextColor.name),
              fontSize: ScreenUtil().setSp(30),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(12)),
          EnsAddressDisplay(
            address: address,
            coinType: widget.coinType ?? 'ETH',
            style: EnsDisplayStyle.full,
            showAvatar: true,
            showCopy: true,
            fontSize: ScreenUtil().setSp(28),
          ),
          SizedBox(height: ScreenUtil().setWidth(24)),
          Divider(
            height: ScreenUtil().setWidth(1),
            endIndent: 0,
            indent: 0,
          ),
        ],
      ),
    );
  }

  Widget _buildItem(String? title, String? content, {bool copy = false}) {
    if (content == null || content.isEmpty) {
      return const SizedBox(
        width: 0,
        height: 0,
      );
    }
    return Padding(
      padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(16), horizontal: ScreenUtil().setWidth(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title ?? "",
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemSubtitleTextColor.name),
              fontSize: ScreenUtil().setSp(30),
            ),
          ),
          SizedBox(
            height: ScreenUtil().setWidth(12),
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainTextColor.name),
                      fontSize: ScreenUtil().setSp(28)),
                ),
              ),
              if (copy)
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: content));
                    ToastUtils.show(S.of(context).copy);
                  },
                  child: Container(
                    margin: EdgeInsets.only(left: ScreenUtil().setWidth(20)),
                    width: ScreenUtil().setWidth(50),
                    height: ScreenUtil().setWidth(50),
                    child: Icon(
                      Icons.copy,
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainBlueColor.name),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(
            height: ScreenUtil().setWidth(24),
          ),
          Divider(
            height: ScreenUtil().setWidth(1),
            endIndent: 0,
            indent: 0,
          ),
        ],
      ),
    );
  }
}
