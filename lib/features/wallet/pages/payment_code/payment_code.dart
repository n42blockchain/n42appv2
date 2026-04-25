import 'package:n42_wallet/core/config/app_config.dart';
import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/wallet/pages/payment_code/payment_history.dart';
import 'package:n42_wallet/features/wallet/pages/payment_code/set_amount.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_flutter/qr_flutter.dart';

class PaymentCode extends StatefulWidget {
  final Map<String, String>? amount;
  const PaymentCode({this.amount, super.key});

  @override
  State<PaymentCode> createState() => _PaymentCodeState();
}

class _PaymentCodeState extends State<PaymentCode> {
  Map<String, String>? amount;

  @override
  void initState() {
    super.initState();
    amount = widget.amount;
  }

  String _buildQrData() {
    final base = AppConfig.apiUrl['n42Browser'] ?? '';
    final amt = amount?['amount'] ?? '';
    final coinType = amount?['coinType'] ?? '';
    final address = amount?['address'] ?? '';
    final uuid = AppGlobals.userInfo?.uuid ?? '';
    return '$base?type=payment&amount=$amt&coinType=$coinType&address=$address&user=$uuid';
  }

  Color _color(String key) => AppThemeUtils.getColorByKey(context, key);

  @override
  Widget build(BuildContext context) {
    final su = ScreenUtil();
    final bgColor = _color(AppThemeKeys.rightTextColor.name);
    final whiteColor = _color(AppThemeKeys.mainWhiteColor.name);
    final blockColor = _color(AppThemeKeys.mainBlockColor.name);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBarWidget(
        backgroundColor: bgColor,
        text: S.of(context).g_key_payment_code_title,
        style: TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: su.setSp(32.0),
          color: whiteColor,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => PaymentHistory()),
            ),
            child: Text(
              S.of(context).g_key_payment_history_btn,
              style: TextStyle(color: whiteColor, fontSize: su.setSp(30.0)),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(su.setWidth(30)),
            child: _buildQrCard(su, whiteColor, blockColor),
          ),
        ),
      ),
    );
  }

  Widget _buildQrCard(ScreenUtil su, Color whiteColor, Color blockColor) {
    final userName = AppGlobals.userInfo?.name ?? '';
    return Container(
      padding: EdgeInsets.all(su.setWidth(30)),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(su.setWidth(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (userName.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(bottom: su.setWidth(30)),
              child: Text(
                userName,
                style: TextStyle(fontSize: su.setSp(30), color: blockColor),
                textAlign: TextAlign.center,
              ),
            ),
          if (amount != null)
            Padding(
              padding: EdgeInsets.only(bottom: su.setWidth(30)),
              child: Text(
                "\$ ${amount?["amount"] ?? ""}",
                style: TextStyle(fontSize: su.setSp(50), color: blockColor),
                textAlign: TextAlign.center,
              ),
            ),
          Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(su.setWidth(40.0)),
              color: whiteColor,
            ),
            clipBehavior: Clip.hardEdge,
            child: QrImageView(
              padding: const EdgeInsets.all(20.0),
              backgroundColor: const Color(0xffffffff),
              data: _buildQrData(),
              version: QrVersions.min + 7,
              embeddedImage: Image.network(
                "${AppConfig.apiUrl['n42Browser']}/static/ast.png",
              ).image,
              embeddedImageStyle: QrEmbeddedImageStyle(
                size: Size(su.setWidth(80.0), su.setWidth(80.0)),
              ),
            ),
          ),
          Divider(
            height: su.setWidth(60),
            color: _color(AppThemeKeys.dividerColor.name),
          ),
          TextButton(
            onPressed: () async {
              final rAmount = await Navigator.push<Map<String, String>>(
                context,
                MaterialPageRoute(
                  builder: (_) => SetAmount(type: 1, amount: amount),
                ),
              );
              if (!mounted || rAmount == null) return;
              setState(() => amount = rAmount);
            },
            child: Text(
              S.of(context).g_key_payment_set_amount_title,
              style: TextStyle(
                fontSize: su.setSp(32),
                color: _color(AppThemeKeys.mainBlueColor.name),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
