import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_backup/backup_flow_utils.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_backup/backup_two.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';

class BackupOne extends StatefulWidget {
  final WalletInfo walletInfo;
  final int walletIndex;
  const BackupOne(this.walletInfo, this.walletIndex, {super.key});

  @override
  State<BackupOne> createState() => _BackupOneState();
}

class _BackupOneState extends State<BackupOne> {
  bool showMnemonic = false;
  late final List<String> mnemonicWordsList;

  @override
  void initState() {
    super.initState();
    mnemonicWordsList = parseBackupMnemonicWords(widget.walletInfo.mnemonic);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(text: S.of(context).g_key_wallet_c38),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        top: ScreenUtil().setWidth(30),
                        bottom: ScreenUtil().setWidth(30),
                      ),
                      child: Text(
                        S.of(context).g_key_wallet_c39,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(50),
                          color: AppColorTokens.of(context).textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: ScreenUtil().setWidth(60),
                      ),
                      child: Text(
                        S.of(context).g_key_wallet_c40,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(28),
                          color: AppColorTokens.of(context).textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _buildGridView(),
                    _buildWarningRow(
                      context,
                      S.of(context).g_key_wallet_c41,
                      topMargin: ScreenUtil().setWidth(40),
                    ),
                    _buildWarningRow(context, S.of(context).g_key_wallet_c42),
                    SizedBox(height: ScreenUtil().setWidth(148.0)),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  const Divider(height: 1),
                  Container(
                    padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
                    color: AppColorTokens.of(context).bgBase,
                    height: ScreenUtil().setWidth(148),
                    child: AppButton(
                      label: S.of(context).g_key_wallet_c43,
                      onPressed: (showMnemonic && mnemonicWordsList.isNotEmpty)
                          ? () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BackupTwo(
                                    widget.walletInfo,
                                    widget.walletIndex,
                                  ),
                                ),
                              );
                            }
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningRow(
    BuildContext context,
    String text, {
    double topMargin = 0,
  }) {
    final verticalPad = ScreenUtil().setWidth(20);
    return Padding(
      padding: EdgeInsets.only(
        top: topMargin + verticalPad,
        bottom: verticalPad,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber,
            color: AppColorTokens.of(context).textPrimary,
            size: ScreenUtil().setWidth(40),
          ),
          SizedBox(width: ScreenUtil().setWidth(10)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(28),
                color: AppColorTokens.of(context).textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView() {
    if (showMnemonic) {
      return GridView.builder(
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0)),
        itemCount: mnemonicWordsList.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: ScreenUtil().setWidth(20.0),
          crossAxisSpacing: ScreenUtil().setWidth(20.0),
          childAspectRatio: 2.4,
        ),
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: AppColorTokens.of(context).bgSurface,
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8.0)),
            ),
            child: Center(
              child: Text(
                mnemonicWordsList[index],
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColorTokens.of(context).textItem,
                  fontSize: ScreenUtil().setSp(28.0),
                ),
              ),
            ),
          );
        },
      );
    }

    final itemTextColor = AppColorTokens.of(context).textItem;
    return InkWell(
      onTap: mnemonicWordsList.isEmpty
          ? null
          : () => setState(() => showMnemonic = true),
      child: Container(
        width: double.infinity,
        height: ScreenUtil().setWidth(400),
        padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
        decoration: BoxDecoration(
          color: AppColorTokens.of(context).bgSurface,
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16.0)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: ScreenUtil().setWidth(30.0)),
              child: Icon(
                mnemonicWordsList.isEmpty
                    ? Icons.key_off_outlined
                    : Icons.visibility_off_outlined,
                color: itemTextColor,
                size: ScreenUtil().setWidth(80.0),
              ),
            ),
            Text(
              mnemonicWordsList.isEmpty
                  ? walletBackupPhraseUnavailableMessage
                  : S.of(context).g_key_wallet_c44,
              style: TextStyle(
                color: itemTextColor,
                fontSize: ScreenUtil().setSp(30),
              ),
              textAlign: TextAlign.center,
            ),
            if (mnemonicWordsList.isNotEmpty)
              Text(
                S.of(context).g_key_wallet_c45,
                style: TextStyle(
                  color: itemTextColor,
                  fontSize: ScreenUtil().setSp(30),
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}
