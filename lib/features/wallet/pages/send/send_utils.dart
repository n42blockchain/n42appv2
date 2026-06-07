// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/features/component/pages/scan_page.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/pages/address_book/address_book_list.dart';
import 'package:n42_wallet/features/wallet/services/recent_address_service.dart';
import 'package:n42_wallet/features/widgets/sheet_bottom.dart';

/// Computes the largest transferable on-chain amount after fees and reserve.
///
/// Returns zero instead of a negative value when the available balance cannot
/// cover fees or reserve requirements.
BigInt maxTransferableAmount({
  required BigInt balance,
  required BigInt fee,
  BigInt? reserve,
}) {
  final spendable = balance - fee - (reserve ?? BigInt.zero);
  return spendable > BigInt.zero ? spendable : BigInt.zero;
}

/// Small icon button for the address input field (scan / paste / address book).
Widget buildSendIconBtn(BuildContext context, IconData icon) {
  return Container(
    width: ScreenUtil().setWidth(50.0),
    height: ScreenUtil().setWidth(50.0),
    padding: EdgeInsets.all(ScreenUtil().setWidth(6.0)),
    child: Icon(
      icon,
      size: ScreenUtil().setWidth(38.0),
      color: AppColorTokens.of(context).brand,
    ),
  );
}

/// USD equivalent display below the amount input field.
///
/// Returns empty placeholder when price or amount is invalid.
Widget buildUsdEquivalent(
  BuildContext context,
  String amountText,
  double coinPrice,
) {
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
      style: AppTypography.caption.copyWith(color: AppColorTokens.of(context).textSubtitle),
    ),
  );
}

/// Scan QR code and fill in address.
Future<void> performScanQR(
  BuildContext context, {
  required TextEditingController controller,
  required ValueChanged<String> onAddress,
}) async {
  final String? scanValue = await Navigator.push<String>(
    context,
    MaterialPageRoute(builder: (_) => ScanPage()),
  );
  if (!context.mounted) return;
  if (scanValue != null) {
    controller.text = scanValue;
    onAddress(scanValue);
  }
}

/// Paste clipboard content into address field.
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

/// Show address picker bottom sheet (address book / scan / paste).
Future<void> showAddressPickerSheet(
  BuildContext context, {
  required CoinModel coinModel,
  required ValueChanged<String> onAddressSelected,
  VoidCallback? onScanQR,
}) async {
  void defaultScanQR() async {
    final scanValue = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ScanPage()),
    );
    if (!context.mounted) return;
    if (scanValue != null) onAddressSelected(scanValue as String);
    if (context.mounted) Navigator.pop(context);
  }

  final scanAction = onScanQR ?? defaultScanQR;
  final blueColor = AppColorTokens.of(context).brand;
  final divider = Divider(
    height: ScreenUtil().setWidth(1),
    indent: 0,
    endIndent: 0,
  );
  final iconSize = ScreenUtil().setWidth(48);

  Widget buildSheetRow(
    BuildContext ctx, {
    required Widget iconWidget,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: ScreenUtil().setWidth(88),
        width: double.infinity,
        child: Row(
          children: [
            Container(
              height: iconSize,
              width: iconSize,
              margin: EdgeInsets.only(right: ScreenUtil().setWidth(20)),
              child: iconWidget,
            ),
            Expanded(
              child: Text(
                label,
                style: AppTypography.body.copyWith(color: blueColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  final List<Widget> childs = [
    buildSheetRow(
      context,
      iconWidget: Image.asset(
        'assets/wallet/addressBook.png',
        color: blueColor,
        height: iconSize,
        width: iconSize,
      ),
      label: S.of(context).g_key_108,
      onTap: () async {
        final value = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                AddressBookList(coinName: coinModel.coin['coinType']),
          ),
        );
        if (!context.mounted) return;
        if (value != null) onAddressSelected(value as String);
        if (context.mounted) Navigator.pop(context);
      },
    ),
    divider,
    buildSheetRow(
      context,
      iconWidget: Image.asset(
        'assets/wallet/scan.png',
        color: blueColor,
        height: iconSize,
        width: iconSize,
      ),
      label: S.of(context).g_key_4,
      onTap: scanAction,
    ),
    divider,
    buildSheetRow(
      context,
      iconWidget: Icon(Icons.paste_outlined, color: blueColor, size: iconSize),
      label: S.of(context).g_key_166,
      onTap: () async {
        final cd = await Clipboard.getData(Clipboard.kTextPlain);
        if (!context.mounted) return;
        if (cd?.text != null && cd!.text != 'null') {
          onAddressSelected(cd.text!);
        }
        if (context.mounted) Navigator.pop(context);
      },
    ),
    divider,
  ];

  sheetBottom(context, S.of(context).g_key_108, Column(children: childs));
}

/// Recent address quick-select bar above the address input field.
///
/// Hidden when no history exists. Shows horizontal scrolling [ActionChip]s.
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
    final list = await RecentAddressService.load(widget.coinType, maxCount: 5);
    if (mounted) setState(() => _entries = list);
  }

  String _formatAddress(String addr) {
    if (addr.length <= 10) return addr;
    return '${addr.substring(0, 6)}...${addr.substring(addr.length - 4)}';
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
            final label = (entry.name?.isNotEmpty == true)
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
