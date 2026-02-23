// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/features/wallet/aa/models/smart_account.dart';

/// 智能账户部署状态指示器
class DeploymentStatusIndicator extends StatelessWidget {
  final SmartAccountState state;
  final bool showLabel;

  const DeploymentStatusIndicator({
    super.key,
    required this.state,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(12),
        vertical: ScreenUtil().setWidth(6),
      ),
      decoration: BoxDecoration(
        color: _getStatusColor().withAlpha(20),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
        border: Border.all(
          color: _getStatusColor().withAlpha(40),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStatusIcon(),
          if (showLabel) ...[
            SizedBox(width: ScreenUtil().setWidth(6)),
            Text(
              _getStatusText(context),
              style: TextStyle(
                fontSize: ScreenUtil().setSp(22),
                fontWeight: FontWeight.w500,
                color: _getStatusColor(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusIcon() {
    switch (state) {
      case SmartAccountState.notDeployed:
        return Icon(
          Icons.radio_button_unchecked,
          size: ScreenUtil().setWidth(18),
          color: _getStatusColor(),
        );
      case SmartAccountState.deploying:
        return SizedBox(
          width: ScreenUtil().setWidth(18),
          height: ScreenUtil().setWidth(18),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(_getStatusColor()),
          ),
        );
      case SmartAccountState.deployed:
        return Icon(
          Icons.check_circle,
          size: ScreenUtil().setWidth(18),
          color: _getStatusColor(),
        );
      case SmartAccountState.error:
        return Icon(
          Icons.error,
          size: ScreenUtil().setWidth(18),
          color: _getStatusColor(),
        );
    }
  }

  Color _getStatusColor() {
    switch (state) {
      case SmartAccountState.notDeployed:
        return Colors.grey;
      case SmartAccountState.deploying:
        return Colors.orange;
      case SmartAccountState.deployed:
        return Colors.green;
      case SmartAccountState.error:
        return Colors.red;
    }
  }

  String _getStatusText(BuildContext context) {
    switch (state) {
      case SmartAccountState.notDeployed:
        return S.of(context).g_key_aa_not_deployed;
      case SmartAccountState.deploying:
        return S.of(context).g_key_aa_deploying;
      case SmartAccountState.deployed:
        return S.of(context).g_key_aa_deployed;
      case SmartAccountState.error:
        return S.of(context).g_key_aa_error;
    }
  }
}
