import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/browser/pages/browser_page.dart';
import 'package:n42_wallet/features/wallet/utils/browser/browser_txhash.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/features/wallet/widgets/ens_address_display.dart';
import 'package:flutter/material.dart';
import 'package:n42_wallet/generated/l10n.dart';
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
  final String? value;
  final bool? isTest;

  const TransactionDetailPage({
    this.time,
    this.from,
    this.to,
    this.txHash,
    this.gas,
    this.gasPrice,
    this.blockNumber,
    this.coinType,
    this.gasUsed,
    this.value,
    this.isTest,
    super.key,
  });

  @override
  State<TransactionDetailPage> createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  TextStyle _labelStyle() => AppTypography.body.copyWith(color: AppColorTokens.of(context).textSubtitle);

  EdgeInsets get _itemPadding => EdgeInsets.symmetric(
    vertical: AppSpacing.space4,
    horizontal: AppSpacing.space6,
  );

  Widget _divider() =>
      Divider(height: ScreenUtil().setWidth(1), endIndent: 0, indent: 0);

  @override
  Widget build(BuildContext context) {
    final explorerUrl = (widget.coinType != null && widget.txHash != null)
        ? getBrowserTxHash(
            widget.coinType!,
            widget.txHash!,
            isTest: widget.isTest,
          )
        : '';
    final s = S.of(context);
    return Scaffold(
      appBar: AppBarWidget(
        text: s.g_key_tran_4,
        actions: explorerUrl.isNotEmpty
            ? [
                IconButton(
                  icon: const Icon(Icons.open_in_browser_outlined),
                  tooltip: s.g_key_196,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => BrowserPage(explorerUrl)),
                  ),
                ),
              ]
            : null,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.space8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildItem(s.g_key_wallet_k25, widget.time),
            _buildItem(s.g_key_wallet_k54, widget.blockNumber),
            _buildAddressItem(s.g_key_75, widget.from),
            _buildAddressItem(s.g_key_38, widget.to),
            _buildItem(s.g_key_wallet_k55, widget.value),
            _buildItem(s.g_key_t_7, widget.gas),
            _buildItem(s.g_key_t_15, widget.gasPrice),
            _buildItem(s.g_key_t_6, widget.gasUsed),
            _buildItem(s.g_key_wallet_k37, widget.txHash, copy: true),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressItem(String? title, String? address) {
    if (address == null || address.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: _itemPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title ?? "", style: _labelStyle()),
          SizedBox(height: AppSpacing.space4),
          EnsAddressDisplay(
            address: address,
            coinType: widget.coinType ?? 'ETH',
            style: EnsDisplayStyle.full,
            showAvatar: true,
            showCopy: true,
            fontSize: ScreenUtil().setSp(28),
          ),
          SizedBox(height: AppSpacing.space6),
          _divider(),
        ],
      ),
    );
  }

  Widget _buildItem(String? title, String? content, {bool copy = false}) {
    if (content == null || content.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: _itemPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title ?? "", style: _labelStyle()),
          SizedBox(height: AppSpacing.space4),
          Row(
            children: [
              Expanded(
                child: Text(
                  content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.body.copyWith(color: AppColorTokens.of(context).textPrimary),
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
                      color: AppColorTokens.of(context).brand,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: AppSpacing.space6),
          _divider(),
        ],
      ),
    );
  }
}
