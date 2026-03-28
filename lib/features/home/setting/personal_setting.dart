import 'package:flutter/services.dart';
import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/core/enums/load.dart';
import 'package:n42_wallet/features/home/setting/account_logout_page.dart';
import 'package:n42_wallet/features/home/setting/change_email_page.dart';
import 'package:n42_wallet/features/home/setting/setting_share.dart';
import 'package:n42_wallet/features/wallet/services/ens_service.dart';
import 'package:n42_wallet/features/home/widgets/nav_select_image.dart';
import 'package:n42_wallet/features/home/widgets/nav_setting_item.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';
import 'package:n42_wallet/data/models/user_info.dart';
import 'package:n42_wallet/core/providers/core_providers.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/features/widgets/button_widget.dart';
import 'package:n42_wallet/features/widgets/image_network.dart';
import 'package:n42_wallet/features/widgets/sheet_bottom.dart';
import 'package:flutter/material.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'personal_setting_fields.dart';

class PersonalSetting extends ConsumerStatefulWidget {
  const PersonalSetting({super.key});

  @override
  ConsumerState<PersonalSetting> createState() => _PersonalSettingState();
}

class _PersonalSettingState extends ConsumerState<PersonalSetting> {
  Uint8List? imageEdit;
  bool isEdit = false;
  UserInfo? userInfo;
  Load load = Load.finish;
  String? _ensName;
  bool _ensLoading = false;

  TextEditingController nicknameEditingController = TextEditingController();
  TextEditingController descriptionEditingController = TextEditingController();
  FocusNode nicknameFocusNode = FocusNode();
  FocusNode descriptionFocusNode = FocusNode();
  String nickNameErrorMessage = "";
  String descriptionErrorMessage = "";

  @override
  void initState() {
    super.initState();
    userInfo = AppGlobals.userInfo;
    nicknameEditingController.text = userInfo?.name ?? "";
    descriptionEditingController.text = userInfo?.desc ?? "";
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
      // ENS 解析失败不影响页面正常使用
    } finally {
      if (mounted) setState(() => _ensLoading = false);
    }
  }

  /// 验证字段长度，返回错误信息（空字符串表示无错误）
  String _validateLength(String? value, int maxLength) {
    if (value != null && value.isNotEmpty && value.length > maxLength) {
      return S.of(context).nicknameMessage("$maxLength");
    }
    return "";
  }

  Future<void> saveUserInfo() async {
    bool completedWithExit = false;
    try {
      if (load == Load.loading) return;
      setState(() => load = Load.loading);

      final nickError = _validateLength(userInfo!.name, 50);
      final descError = _validateLength(userInfo!.desc, 1000);
      setState(() {
        nickNameErrorMessage = nickError;
        descriptionErrorMessage = descError;
      });
      if (nickError.isNotEmpty || descError.isNotEmpty) return;

      MessageModel r = await ref
          .read(userProfileProvider)
          .editUserInfo(userInfo!, imageData: imageEdit);
      if (!mounted) return;
      if (r.error == false) {
        ToastUtils.showSuccess(S.of(context).g_key_185);
        if (!mounted) return;
        completedWithExit = true;
        Navigator.pop(context);
      } else {
        ToastUtils.show(r.data);
      }
    } catch (e) {
      ToastUtils.show(e.toString());
    } finally {
      if (mounted && !completedWithExit) {
        setState(() => load = Load.finish);
      }
    }
  }

  @override
  void dispose() {
    nicknameFocusNode.dispose();
    descriptionFocusNode.dispose();
    nicknameEditingController.dispose();
    descriptionEditingController.dispose();
    super.dispose();
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

  Widget _buildErrorText(String message) {
    if (message.isEmpty) return const SizedBox.shrink();
    return Text(
      message,
      style: TextStyle(
        color: AppThemeUtils.getColorByKey(
          context,
          AppThemeKeys.errorTextColor.name,
        ),
        fontSize: ScreenUtil().setSp(26.0),
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
                  buildEditPhotoButton(),
                  Padding(
                    padding: EdgeInsets.only(top: ScreenUtil().setWidth(80.0)),
                    child: Text(
                      S.of(context).g_key_u_2,
                      style: TextStyle(
                        color: AppThemeUtils.getColorByKey(
                          context,
                          AppThemeKeys.mainBlueColor.name,
                        ),
                        fontSize: ScreenUtil().setSp(30.0),
                      ),
                    ),
                  ),
                  buildNicknameField(),
                  _buildErrorText(nickNameErrorMessage),
                  _buildFieldLabel(S.of(context).g_key_u_3),
                  buildDescriptionField(),
                  _buildErrorText(descriptionErrorMessage),
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
                  SizedBox(height: ScreenUtil().setWidth(240.0)),
                ],
              ),
            ),
          ),
          buildBottomButtons(),
        ],
      ),
    );
  }
}
