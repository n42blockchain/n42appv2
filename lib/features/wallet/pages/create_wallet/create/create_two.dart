import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/pages/create_wallet/create/create_three.dart';
import 'package:n42_wallet/features/wallet/pages/create_wallet/create_finish.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/shared/widgets/tips_dialog_3.dart';
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
  late final Trustdart _trustdart = Trustdart();

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
      length: (value * 10 + value / 3 * 2).toInt(),
    );
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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildProgressDot(active: true),
            SizedBox(width: AppSpacing.space4),
            _buildProgressDot(active: true),
            SizedBox(width: AppSpacing.space4),
            _buildProgressDot(active: false),
            SizedBox(width: AppSpacing.space4),
            _buildProgressDot(active: false),
          ],
        ),
        actions: [SizedBox(width: ScreenUtil().setWidth(130.0))],
        leadingWidth: ScreenUtil().setWidth(130.0),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.space8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitle(),
                    _buildSubtitle(),
                    _buildWordCountSelector(),
                    SizedBox(height: ScreenUtil().setWidth(50.0)),
                    buildGridView(),
                    _buildWarningRow(
                      S.of(context).g_key_wallet_c41,
                      topMargin: ScreenUtil().setWidth(40),
                    ),
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
        borderRadius: AppRadius.brSm,
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
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.space8),
      child: Text(
        S.of(context).g_key_wallet_c39,
        style: AppTypography.displayLg.copyWith(
          color: AppColorTokens.of(context).textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSubtitle() {
    return Padding(
      padding: EdgeInsets.only(bottom: ScreenUtil().setWidth(60)),
      child: Text(
        S.of(context).g_key_wallet_c40,
        style: AppTypography.body.copyWith(
          color: AppColorTokens.of(context).textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildWordCountSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildWordCountButton(12),
        SizedBox(width: AppSpacing.space12),
        _buildWordCountButton(24),
      ],
    );
  }

  Widget _buildWordCountButton(int count) {
    final isSelected = mnemonicWordsCount == count;
    return SizedBox(
      width: ScreenUtil().setWidth(164.0),
      height: ScreenUtil().setWidth(60.0),
      child: AppButton(
        label: "$count",
        variant: isSelected
            ? AppButtonVariant.primary
            : AppButtonVariant.secondary,
        expand: false,
        onPressed: () => resetMnemonicWordsCount(value: count),
      ),
    );
  }

  Widget _buildWarningRow(String text, {double topMargin = 0}) {
    return Container(
      margin: EdgeInsets.only(top: topMargin),
      padding: EdgeInsets.symmetric(vertical: AppSpacing.space4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber,
            color: AppColorTokens.of(context).textPrimary,
            size: ScreenUtil().setWidth(40),
          ),
          SizedBox(width: AppSpacing.space2),
          Expanded(
            child: Text(
              text,
              style: AppTypography.body.copyWith(
                color: AppColorTokens.of(context).textPrimary,
                fontWeight: FontWeight.w600,
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
            padding: EdgeInsets.all(AppSpacing.space8),
            width: double.infinity,
            color: AppColorTokens.of(context).bgBase,
            child: AppButton(
              label: S.of(context).g_key_wallet_c43,
              onPressed: showMnemonic
                  ? () {
                      widget.wInfo.mnemonic = mnemonicWords;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateThree(widget.wInfo),
                        ),
                      );
                    }
                  : null,
            ),
          ),
          Container(
            height: ScreenUtil().setWidth(100.0),
            padding: EdgeInsets.only(bottom: ScreenUtil().setWidth(30.0)),
            width: double.infinity,
            color: AppColorTokens.of(context).bgBase,
            child: TextButton(
              onPressed: () {
                showSkipWidget();
              },
              child: Text(
                S.of(context).g_key_wallet_c18,
                style: AppTypography.body.copyWith(
                  color: AppColorTokens.of(context).brand,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColorTokens.of(context).brand,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
