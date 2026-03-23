import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/core/di/service_locator_setup.dart';
import 'package:n42_wallet/core/storage/sp_util.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/component/enums/load.dart';
import 'package:n42_wallet/features/login/api/user_info_api.dart';
import 'package:n42_wallet/features/models/message_model.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/features/widgets/button_widget.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';

part 'security_google_vedification_logic.dart';
part 'security_google_vedification_widgets.dart';

class SecurityGoogleVedification extends StatefulWidget {
  const SecurityGoogleVedification({super.key});

  @override
  SecurityGoogleVedificationState createState() =>
      SecurityGoogleVedificationState();
}

class SecurityGoogleVedificationState
    extends State<SecurityGoogleVedification>
    with _SecurityGoogleVedificationLogic {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).Verification,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  buildGoogleSection(),
                  buildEmailSection(),
                  buildPasswordSection(),
                ],
              ),
            ),
          ),
          _buildBottomButton(context),
        ],
      ),
    );
  }
}
