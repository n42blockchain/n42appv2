import 'dart:async';

import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/core/providers/core_providers.dart';
import 'package:n42_wallet/shared/domain/entities/wallet_info.dart';
import 'package:n42_wallet/features/component/enums/load.dart';
import 'package:n42_wallet/features/login/api/handtype.dart';
import 'package:n42_wallet/features/login/api/user_info_api.dart';
import 'package:n42_wallet/features/login/widgets/login_title.dart';
import 'package:n42_wallet/data/models/user_info.dart';
import 'package:n42_wallet/features/utils/device_info_util.dart';
import 'package:n42_wallet/features/utils/md5_util.dart';
import 'package:n42_wallet/features/utils/regular.dart';
import 'package:n42_wallet/core/storage/sp_util.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/features/widgets/button_widget.dart';
import 'package:n42_wallet/features/widgets/text_field_widget.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';

part 'account_create_and_reset_logic.dart';
part 'account_create_and_reset_widgets.dart';

/// Account Create and Reset Page - Migrated to Riverpod
class AccountCreateAndReset extends ConsumerStatefulWidget {
  final HandType type;
  final int pushType; // 0 push, 1 content
  const AccountCreateAndReset({required this.type, this.pushType = 0, super.key});

  @override
  ConsumerState<AccountCreateAndReset> createState() => _AccountCreateAndResetState();
}

class _AccountCreateAndResetState extends ConsumerState<AccountCreateAndReset>
    with _AccountCreateAndResetLogic {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBarWidget(
        text: _currentType == HandType.restPassword
            ? S.of(context).rest_your_password
            : S.of(context).Create_your_account,
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
          child: Stack(
            children: [
              Positioned.fill(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPageTitle(context),
                      _buildEmailField(context),
                      SizedBox(height: ScreenUtil().setWidth(20)),
                      _buildPasswordField(context),
                      SizedBox(height: ScreenUtil().setHeight(20)),
                      _buildConfirmPasswordField(context),
                      if (_currentType == HandType.createAccount)
                        _buildInviteView(context),
                      SizedBox(height: ScreenUtil().setHeight(20)),
                      _buildVerificationCodeField(context),
                      SizedBox(height: ScreenUtil().setWidth(44)),
                      if (_currentType == HandType.createAccount)
                        _buildForgotPasswordLink(context),
                      _buildLoginLink(context),
                      SizedBox(height: ScreenUtil().setWidth(148.0)),
                    ],
                  ),
                ),
              ),
              _buildBottomSubmitButton(context),
            ],
          ),
        ),
      ),
    );
  }
}
