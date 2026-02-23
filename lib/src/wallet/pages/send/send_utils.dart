// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/component/pages/scan_page.dart';
import 'package:n42appv2/src/wallet/models/coin_model.dart';
import 'package:n42appv2/src/wallet/pages/address_book/address_book_list.dart';
import 'package:n42appv2/src/wallet/pages/face_matching/face_match.dart';
import 'package:n42appv2/src/wallet/services/recent_address_service.dart';
import 'package:n42appv2/src/widgets/sheet_bottom.dart';

// ─── 共享小部件 ─────────────────────────────────────────────────────────────

/// 地址输入框右侧的小图标按钮（扫码 / 粘贴 / 地址簿）。
Widget buildSendIconBtn(BuildContext context, IconData icon) {
  return Container(
    width: ScreenUtil().setWidth(50.0),
    height: ScreenUtil().setWidth(50.0),
    padding: EdgeInsets.all(ScreenUtil().setWidth(6.0)),
    child: Icon(
      icon,
      size: ScreenUtil().setWidth(38.0),
      color: AppThemeUtils.getColorByKey(
          context, AppThemeKeys.mainBlueColor.name),
    ),
  );
}

/// 金额输入框下方的 USD 等值显示。
///
/// [amountText] 为当前输入的金额字符串，[coinPrice] 为币价（USD）。
/// 当价格或金额无效时返回空占位。
Widget buildUsdEquivalent(
    BuildContext context, String amountText, double coinPrice) {
  final amount = double.tryParse(amountText) ?? 0.0;
  if (coinPrice <= 0 || amount <= 0) return const SizedBox.shrink();
  final usd = amount * coinPrice;
  final usdStr = usd < 0.01 ? '< \$0.01' : '\$${usd.toStringAsFixed(2)}';
  return Padding(
    padding: EdgeInsets.only(
      left: ScreenUtil().setWidth(30),
      bottom: ScreenUtil().setWidth(12),
    ),
    child: Text(
      '≈ $usdStr',
      style: TextStyle(
        fontSize: ScreenUtil().setSp(24),
        color: AppThemeUtils.getColorByKey(
            context, AppThemeKeys.itemSubtitleTextColor.name),
      ),
    ),
  );
}

/// 扫码并填入地址。
///
/// [controller] 为目标地址输入框控制器。
/// [onAddress] 在扫码成功后回调（通常用于触发地址校验）。
Future<void> performScanQR(
  BuildContext context, {
  required TextEditingController controller,
  required ValueChanged<String> onAddress,
}) async {
  final String? scanValue = await Navigator.push<String>(
      context, MaterialPageRoute(builder: (_) => ScanPage()));
  if (!context.mounted) return;
  if (scanValue != null) {
    controller.text = scanValue;
    onAddress(scanValue);
  }
}

/// 粘贴剪贴板内容并填入地址。
///
/// [controller] 为目标地址输入框控制器。
/// [onAddress] 在粘贴成功后回调（通常用于触发地址校验）。
Future<void> performPasteAddress(
  BuildContext context, {
  required TextEditingController controller,
  required ValueChanged<String> onAddress,
}) async {
  final cd = await Clipboard.getData(Clipboard.kTextPlain);
  if (!context.mounted) return;
  if (cd?.text != null && cd!.text != 'null') {
    controller.text = cd.text!;
    onAddress(cd.text!);
  }
}

// ─── 地址选择弹窗 ──────────────────────────────────────────────────────────

/// 显示地址选择底部弹窗（地址簿 / 扫码 / 粘贴 / EVM 人脸识别）。
///
/// [isEvm] 为 true 时追加人脸识别选项（仅 EVM 链支持）。
/// [onAddressSelected] 在用户选定地址后回调，由调用方处理地址赋值和验证。
/// [onScanQR] 扫码按钮回调（由调用方提供，因为各页面扫码后的处理逻辑相同）。
///   若传 null，则使用内置实现：推送 ScanPage 然后 pop 弹窗。
Future<void> showAddressPickerSheet(
  BuildContext context, {
  required CoinModel coinModel,
  required ValueChanged<String> onAddressSelected,
  VoidCallback? onScanQR,
  bool isEvm = false,
}) async {
  // 扫码默认实现
  void defaultScanQR() async {
    String? scanValue = await Navigator.push(
        context, MaterialPageRoute(builder: (_) => ScanPage()));
    if (!context.mounted) return;
    if (scanValue != null) {
      onAddressSelected(scanValue);
    }
    if (context.mounted) Navigator.pop(context);
  }

  final scanAction = onScanQR ?? defaultScanQR;

  final List<Widget> childs = [
    // ── 地址簿 ──────────────────────────────────────
    InkWell(
      onTap: () async {
        final value = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                AddressBookList(coinName: coinModel.coin['coinType']),
          ),
        );
        if (!context.mounted) return;
        if (value != null) {
          onAddressSelected(value as String);
        }
        if (context.mounted) Navigator.pop(context);
      },
      child: SizedBox(
        height: ScreenUtil().setWidth(88),
        width: double.infinity,
        child: Row(
          children: [
            Container(
              height: ScreenUtil().setWidth(48),
              width: ScreenUtil().setWidth(48),
              margin: EdgeInsets.only(right: ScreenUtil().setWidth(20)),
              child: Image.asset(
                'assets/wallet/addressBook.png',
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainBlueColor.name),
                height: ScreenUtil().setWidth(48),
                width: ScreenUtil().setWidth(48),
              ),
            ),
            Expanded(
              child: Text(
                S.of(context).g_key_108,
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainBlueColor.name),
                  fontSize: ScreenUtil().setSp(30),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    Divider(height: ScreenUtil().setWidth(1), indent: 0, endIndent: 0),

    // ── 扫码 ────────────────────────────────────────
    InkWell(
      onTap: scanAction,
      child: SizedBox(
        height: ScreenUtil().setWidth(88),
        width: double.infinity,
        child: Row(
          children: [
            Container(
              height: ScreenUtil().setWidth(48),
              width: ScreenUtil().setWidth(48),
              margin: EdgeInsets.only(right: ScreenUtil().setWidth(20)),
              child: Image.asset(
                'assets/wallet/scan.png',
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainBlueColor.name),
                height: ScreenUtil().setWidth(48),
                width: ScreenUtil().setWidth(48),
              ),
            ),
            Expanded(
              child: Text(
                S.of(context).g_key_4,
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainBlueColor.name),
                  fontSize: ScreenUtil().setSp(30),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    Divider(height: ScreenUtil().setWidth(1), indent: 0, endIndent: 0),

    // ── 粘贴 ────────────────────────────────────────
    InkWell(
      onTap: () async {
        final cd = await Clipboard.getData(Clipboard.kTextPlain);
        if (!context.mounted) return;
        if (cd?.text != null && cd!.text != 'null') {
          onAddressSelected(cd.text!);
        }
        if (context.mounted) Navigator.pop(context);
      },
      child: SizedBox(
        height: ScreenUtil().setWidth(88),
        width: double.infinity,
        child: Row(
          children: [
            Container(
              height: ScreenUtil().setWidth(48),
              width: ScreenUtil().setWidth(48),
              margin: EdgeInsets.only(right: ScreenUtil().setWidth(20)),
              child: Icon(
                Icons.paste_outlined,
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainBlueColor.name),
                size: ScreenUtil().setWidth(48),
              ),
            ),
            Expanded(
              child: Text(
                S.of(context).g_key_166,
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainBlueColor.name),
                  fontSize: ScreenUtil().setSp(30),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    Divider(height: ScreenUtil().setWidth(1), indent: 0, endIndent: 0),
  ];

  // ── EVM 专属：人脸识别（拍照 / 相册） ──────────────
  if (isEvm) {
    childs.addAll([
      InkWell(
        onTap: () async {
          final address = await Navigator.push<String>(
              context, MaterialPageRoute(builder: (_) => FaceMatch(1)));
          if (!context.mounted) return;
          if (address != null) {
            onAddressSelected(address);
          }
          if (context.mounted) Navigator.pop(context);
        },
        child: SizedBox(
          height: ScreenUtil().setWidth(88),
          width: double.infinity,
          child: Row(
            children: [
              Container(
                height: ScreenUtil().setWidth(48),
                width: ScreenUtil().setWidth(48),
                margin: EdgeInsets.only(right: ScreenUtil().setWidth(20)),
                child: Icon(
                  Icons.photo_album_outlined,
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainBlueColor.name),
                  size: ScreenUtil().setWidth(48),
                ),
              ),
              Expanded(
                child: Text(
                  '${S.of(context).g_face_match_key1}(${S.of(context).photograph})',
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.mainBlueColor.name),
                    fontSize: ScreenUtil().setSp(30),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      Divider(height: ScreenUtil().setWidth(1), indent: 0, endIndent: 0),
      InkWell(
        onTap: () async {
          final address = await Navigator.push<String>(
              context, MaterialPageRoute(builder: (_) => FaceMatch(2)));
          if (!context.mounted) return;
          if (address != null) {
            onAddressSelected(address);
          }
          if (context.mounted) Navigator.pop(context);
        },
        child: SizedBox(
          height: ScreenUtil().setWidth(88),
          width: double.infinity,
          child: Row(
            children: [
              Container(
                height: ScreenUtil().setWidth(48),
                width: ScreenUtil().setWidth(48),
                margin: EdgeInsets.only(right: ScreenUtil().setWidth(20)),
                child: Icon(
                  Icons.face_outlined,
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainBlueColor.name),
                  size: ScreenUtil().setWidth(48),
                ),
              ),
              Expanded(
                child: Text(
                  '${S.of(context).g_face_match_key1}(${S.of(context).g_key_nft_16})',
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.mainBlueColor.name),
                    fontSize: ScreenUtil().setSp(30),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ]);
  }

  sheetBottom(context, S.of(context).g_face_match_key1,
      Column(children: childs));
}

/// 地址输入框上方的最近转账地址快选条。
///
/// - 无历史时隐藏（不占空间）。
/// - 有历史时显示横向滚动的 [ActionChip]。
/// - 点击 chip → 调用 [onSelected] 填入地址。
class RecentAddressBar extends StatefulWidget {
  final String coinType;
  final ValueChanged<String> onSelected;

  const RecentAddressBar({
    required this.coinType,
    required this.onSelected,
    super.key,
  });

  @override
  State<RecentAddressBar> createState() => _RecentAddressBarState();
}

class _RecentAddressBarState extends State<RecentAddressBar> {
  List<RecentAddressEntry> _entries = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list =
        await RecentAddressService.load(widget.coinType, maxCount: 5);
    if (mounted) {
      setState(() => _entries = list);
    }
  }

  String _formatAddress(String addr) {
    if (addr.length <= 10) return addr;
    return '${addr.substring(0, 6)}…${addr.substring(addr.length - 4)}';
  }

  @override
  Widget build(BuildContext context) {
    if (_entries.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(
        bottom: ScreenUtil().setWidth(8),
        left: ScreenUtil().setWidth(30),
        right: ScreenUtil().setWidth(30),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _entries.map((entry) {
            final label =
                entry.name?.isNotEmpty == true
                    ? entry.name!
                    : _formatAddress(entry.address);
            return Padding(
              padding: EdgeInsets.only(right: ScreenUtil().setWidth(8)),
              child: ActionChip(
                label: Text(
                  label,
                  style: TextStyle(fontSize: ScreenUtil().setSp(24)),
                ),
                onPressed: () => widget.onSelected(entry.address),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
