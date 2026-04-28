import 'package:flutter/services.dart';
import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/features/home/setting/setting_share.dart';
import 'package:n42_wallet/features/wallet/services/ens_service.dart';

import 'package:n42_wallet/data/models/user_info.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/features/widgets/image_network.dart';
import 'package:flutter/material.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

part 'personal_setting_fields.dart';

class PersonalSetting extends StatefulWidget {
  const PersonalSetting({super.key});

  @override
  State<PersonalSetting> createState() => _PersonalSettingState();
}

class _PersonalSettingState extends State<PersonalSetting> {
  UserInfo? userInfo;
  String? _ensName;
  bool _ensLoading = false;

  @override
  void initState() {
    super.initState();
    userInfo = AppGlobals.userInfo;
    _resolveEnsName();
  }

  Future<void> _resolveEnsName() async {
    final addr = userInfo?.walletAddr ?? '';
    if (addr.isEmpty) return;
    setState(() => _ensLoading = true);
    try {
      final name = await EnsServiceProvider.instance.resolveAddress(addr);
      if (mounted && name != null && name.isNotEmpty) {
        setState(() => _ensName = name);
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _ensLoading = false);
    }
  }

  // ── 样式辅助 ────────────────────────────────────────────────────

  BoxDecoration get _bottomBorder => BoxDecoration(
    border: Border(
      bottom: BorderSide(
        width: ScreenUtil().setWidth(1.0),
        color: AppThemeUtils.getColorByKey(
          context,
          AppThemeKeys.itemLineColor.name,
        ),
      ),
    ),
  );

  Widget _buildFieldLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(top: ScreenUtil().setWidth(40.0)),
      child: Text(
        text,
        style: TextStyle(
          color: AppThemeUtils.getColorByKey(
            context,
            AppThemeKeys.mainBlueColor.name,
          ),
          fontSize: ScreenUtil().setSp(30.0),
        ),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBarWidget(text: S.of(context).personalInformation),
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(30.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildAvatar(),
                  _buildFieldLabel(S.of(context).login_email),
                  buildEmailRow(),
                  if ((userInfo?.inviteCode ?? '').isNotEmpty) ...[
                    _buildFieldLabel(S.of(context).g_referral_invite_code),
                    buildInviteCodeRow(),
                  ],
                  _buildFieldLabel(S.of(context).g_key_uuid),
                  buildUuidRow(),
                  if ((userInfo?.walletAddr ?? '').isNotEmpty) ...[
                    _buildFieldLabel(S.of(context).g_key_ens_name),
                    buildEnsRow(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
