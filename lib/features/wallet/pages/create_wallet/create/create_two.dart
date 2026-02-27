import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/pages/create_wallet/create/create_three.dart';
import 'package:n42_wallet/features/wallet/pages/create_wallet/create_finish.dart';
import 'package:n42_wallet/features/wallet/provider/trustdart.dart';
import 'package:n42_wallet/features/widgets/button_widget.dart';
import 'package:n42_wallet/features/widgets/dialog_widget/tips_dialog_3.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';

part 'create_two_widgets.dart';

class CreateTwo extends StatefulWidget {
  final WalletInfo wInfo;
  const CreateTwo(this.wInfo, {super.key});

  @override
  State<CreateTwo> createState() => _CreateTwoState();
}

class _CreateTwoState extends State<CreateTwo> with _CreateTwoWidgetsMixin {
  Trustdart? trustdart;
  Trustdart get _trustdart {
    trustdart ??= Trustdart();
    return trustdart!;
  }

  @override
  bool showMnemonic = false;

  /// 助记词
  @override
  late String mnemonicWords;

  @override
  var mnemonicWordsList = [];

  int mnemonicWordsCount = 12;

  Future<void> resetMnemonicWordsCount({int value = 12}) async {
    mnemonicWordsCount = value;
    mnemonicWords = await _trustdart.generateMnemonic(
        length: (value * 10 + value / 3 * 2).toInt());
    if (mounted) {
      setState(() {
        mnemonicWordsList = mnemonicWords.split(" ");
      });
    }
  }

  @override
  void initState() {
    super.initState();
    resetMnemonicWordsCount();
  }

  // ─── Build ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildProgressDot(active: true),
              SizedBox(width: ScreenUtil().setWidth(20.0)),
              _buildProgressDot(active: true),
              SizedBox(width: ScreenUtil().setWidth(20.0)),
              _buildProgressDot(active: false),
              SizedBox(width: ScreenUtil().setWidth(20.0)),
              _buildProgressDot(active: false),
            ],
          ),
        ),
        actions: [
          SizedBox(width: ScreenUtil().setWidth(130.0)),
        ],
        leadingWidth: ScreenUtil().setWidth(130.0),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                    horizontal: ScreenUtil().setWidth(30.0)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitle(),
                    _buildSubtitle(),
                    _buildWordCountSelector(),
                    SizedBox(height: ScreenUtil().setWidth(50.0)),
                    buildGridView(),
                    _buildWarningRow(S.of(context).g_key_wallet_c41,
                        topMargin: ScreenUtil().setWidth(40)),
                    _buildWarningRow(S.of(context).g_key_wallet_c42),
                    SizedBox(height: ScreenUtil().setWidth(248.0)),
                  ],
                ),
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  // ─── Small Build Helpers ──────────────────────────────────────────────

  Widget _buildProgressDot({required bool active}) {
    return Container(
      height: ScreenUtil().setWidth(10.0),
      width: ScreenUtil().setWidth(88.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(10.0)),
        color: AppThemeUtils.getColorByKey(
          context,
          active
              ? AppThemeKeys.mainBlueColor.name
              : AppThemeKeys.dividerColor.name,
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Container(
      margin: EdgeInsets.only(
        top: ScreenUtil().setWidth(30),
        bottom: ScreenUtil().setWidth(30),
      ),
      child: Text(
        S.of(context).g_key_wallet_c39,
        style: TextStyle(
          fontSize: ScreenUtil().setSp(50),
          color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.mainTextColor.name),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSubtitle() {
    return Container(
      margin: EdgeInsets.only(
        bottom: ScreenUtil().setWidth(60),
      ),
      child: Text(
        S.of(context).g_key_wallet_c40,
        style: TextStyle(
          fontSize: ScreenUtil().setSp(28),
          color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.mainTextColor.name),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildWordCountSelector() {
    return Container(
      alignment: Alignment.center,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildWordCountButton(12),
          SizedBox(width: ScreenUtil().setWidth(40.0)),
          _buildWordCountButton(24),
        ],
      ),
    );
  }

  Widget _buildWordCountButton(int count) {
    final isSelected = mnemonicWordsCount == count;
    return SizedBox(
      width: ScreenUtil().setWidth(164.0),
      height: ScreenUtil().setWidth(60.0),
      child: buttonStyle5(
        context,
        () {
          resetMnemonicWordsCount(value: count);
        },
        "$count",
        AppThemeUtils.getColorByKey(
          context,
          isSelected
              ? AppThemeKeys.mainButtonBgColor.name
              : AppThemeKeys.itemBgColor8.name,
        ),
        AppThemeUtils.getColorByKey(
          context,
          isSelected
              ? AppThemeKeys.mainButtonTextColor.name
              : AppThemeKeys.mainTextColor4.name,
        ),
        circular: ScreenUtil().setWidth(24.0),
      ),
    );
  }

  Widget _buildWarningRow(String text, {double topMargin = 0}) {
    return Container(
      margin: EdgeInsets.only(top: topMargin),
      padding: EdgeInsets.symmetric(
        vertical: ScreenUtil().setWidth(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber,
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.mainTextColor.name),
            size: ScreenUtil().setWidth(40),
          ),
          SizedBox(width: ScreenUtil().setWidth(10)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(28),
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainTextColor.name),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Column(
        children: [
          const Divider(height: 1, indent: 0, endIndent: 0),
          Container(
            height: ScreenUtil().setWidth(148.0),
            padding: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
            width: double.infinity,
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.backGroundColor.name),
            child: buttonStyle6(
              context,
              () {
                if (showMnemonic) {
                  widget.wInfo.mnemonic = mnemonicWords;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CreateThree(widget.wInfo)),
                  );
                }
              },
              S.of(context).g_key_wallet_c43,
              AppThemeUtils.getColorByKey(
                context,
                showMnemonic
                    ? AppThemeKeys.mainButtonBgColor.name
                    : AppThemeKeys.mainButtonBgColor3.name,
              ),
              AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.mainButtonTextColor.name),
              false,
            ),
          ),
          Container(
            height: ScreenUtil().setWidth(100.0),
            padding: EdgeInsets.only(bottom: ScreenUtil().setWidth(30.0)),
            width: double.infinity,
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.backGroundColor.name),
            child: TextButton(
              onPressed: () {
                showSkipWidget();
              },
              child: Text(
                S.of(context).g_key_wallet_c18,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(28.0),
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainBlueColor.name),
                  decoration: TextDecoration.underline,
                  decorationColor: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainBlueColor.name),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
