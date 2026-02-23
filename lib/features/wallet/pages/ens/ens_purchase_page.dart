// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/wallet/services/ens_registration_service.dart';
import 'package:n42_wallet/features/wallet/widgets/ens/ens_price_card.dart';
import 'package:n42_wallet/features/wallet/widgets/ens/ens_registration_steps.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';

/// ENS 购买/注册页面
///
/// 实现两步注册流程:
/// 1. 提交承诺 (Commit) - 防止抢注
/// 2. 执行注册 (Register) - 完成注册
class EnsPurchasePage extends StatefulWidget {
  /// ENS 名称 (不含 .eth 后缀)
  final String name;

  /// 钱包地址
  final String walletAddress;

  /// 注册年限
  final int years;

  /// 价格信息
  final EnsPrice price;

  const EnsPurchasePage({
    super.key,
    required this.name,
    required this.walletAddress,
    required this.years,
    required this.price,
  });

  @override
  State<EnsPurchasePage> createState() => _EnsPurchasePageState();
}

class _EnsPurchasePageState extends State<EnsPurchasePage> {
  final EnsRegistrationService _ensService = EnsRegistrationServiceProvider.instance;

  // 注册步骤: 0=初始, 1=提交承诺中, 2=等待中, 3=注册中, 4=完成, -1=失败
  int _currentStep = 0;
  String? _errorMessage;

  CommitResult? _commitResult;
  RegisterResult? _registerResult;
  // 标记 register 步骤因承诺过期而失败，用于智能重试决策
  bool _commitmentExpiredOnRegister = false;

  Timer? _waitTimer;
  int _remainingSeconds = 0;

  @override
  void dispose() {
    _waitTimer?.cancel();
    super.dispose();
  }

  Future<void> _startRegistration() async {
    setState(() {
      _currentStep = 1;
      _errorMessage = null;
    });

    // 步骤 1: 提交承诺
    final commitResult = await _ensService.commit(
      widget.name,
      widget.walletAddress,
    );

    if (!mounted) return;

    if (commitResult.error || commitResult.data == null) {
      setState(() {
        _currentStep = -1;
        _errorMessage = S.of(context).g_key_ens_commit_failed;
      });
      return;
    }

    _commitResult = commitResult.data;

    // 步骤 2: 等待
    setState(() {
      _currentStep = 2;
      _remainingSeconds = _commitResult!.minWaitTime;
    });

    _startWaitTimer();
  }

  void _startWaitTimer() {
    _waitTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _remainingSeconds--;
      });

      if (_remainingSeconds <= 0) {
        timer.cancel();
        _executeRegister();
      }
    });
  }

  Future<void> _executeRegister() async {
    if (_commitResult == null) return;

    setState(() {
      _currentStep = 3;
    });

    // 步骤 3: 执行注册
    final registerParams = RegisterParams(
      name: widget.name,
      owner: widget.walletAddress,
      years: widget.years,
      secret: _commitResult!.secret,
      setReverseRecord: true,
    );

    final registerResult = await _ensService.register(registerParams);

    if (!mounted) return;

    if (registerResult.error || registerResult.data == null || !registerResult.data!.success) {
      final isExpired = registerResult.data?.error ==
          EnsRegisterErrorType.commitmentExpired.name;
      setState(() {
        _currentStep = -1;
        _commitmentExpiredOnRegister = isExpired;
        _errorMessage = isExpired
            ? S.of(context).g_key_ens_commitment_expired_msg
            : (registerResult.data?.error ?? S.of(context).g_key_ens_register_failed);
      });
      return;
    }

    _registerResult = registerResult.data;

    setState(() {
      _currentStep = 4;
    });
  }

  void _retryRegistration() {
    _waitTimer?.cancel();

    if (_commitResult == null || _commitResult!.isExpired || _commitmentExpiredOnRegister) {
      // 承诺不存在或已过期 → 通知服务端回滚（best-effort），然后从步骤 0 重新开始
      if (_commitmentExpiredOnRegister || _commitResult?.isExpired == true) {
        _ensService.rollbackCommit(widget.name); // intentionally not awaited (best-effort)
      }
      setState(() {
        _currentStep = 0;
        _errorMessage = null;
        _commitResult = null;
        _registerResult = null;
        _commitmentExpiredOnRegister = false;
      });
    } else if (_commitResult!.canRegister) {
      // 承诺仍在有效窗口内 → 跳过 commit 步骤，直接重试 register
      setState(() {
        _errorMessage = null;
        _commitmentExpiredOnRegister = false;
      });
      _executeRegister();
    } else {
      // 承诺已提交但仍在等待期 → 恢复倒计时
      setState(() {
        _currentStep = 2;
        _errorMessage = null;
        _remainingSeconds = _commitResult!.remainingWaitTime;
        _commitmentExpiredOnRegister = false;
      });
      _startWaitTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_key_ens_purchase_title,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 域名信息卡片
            _buildDomainCard(),
            SizedBox(height: ScreenUtil().setWidth(24)),

            // 注册步骤指示器
            EnsRegistrationSteps(currentStep: _currentStep),
            SizedBox(height: ScreenUtil().setWidth(24)),

            // 步骤内容
            _buildStepContent(),
            SizedBox(height: ScreenUtil().setWidth(24)),

            // 价格信息
            if (_currentStep >= 0 && _currentStep < 4)
              EnsPriceCard(price: widget.price),
            SizedBox(height: ScreenUtil().setWidth(32)),

            // 操作按钮
            _buildActionButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildDomainCard() {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name)
                .withAlpha(30),
            AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name)
                .withAlpha(10),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
      ),
      child: Column(
        children: [
          Text(
            '${widget.name}.eth',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(40),
              fontWeight: FontWeight.bold,
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.mainTextColor.name,
              ),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(8)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.access_time,
                size: ScreenUtil().setWidth(20),
                color: AppThemeUtils.getColorByKey(
                  context,
                  AppThemeKeys.itemSubtitleTextColor.name,
                ),
              ),
              SizedBox(width: ScreenUtil().setWidth(6)),
              Text(
                '${widget.years} ${widget.years == 1 ? S.of(context).g_key_ens_year : S.of(context).g_key_ens_years}',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(26),
                  color: AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.itemSubtitleTextColor.name,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildInitialContent();
      case 1:
        return _buildCommittingContent();
      case 2:
        return _buildWaitingContent();
      case 3:
        return _buildRegisteringContent();
      case 4:
        return _buildSuccessContent();
      case -1:
        return _buildErrorContent();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildInitialContent() {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).g_key_ens_registration_info,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(28),
              fontWeight: FontWeight.w600,
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.mainTextColor.name,
              ),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(12)),
          _buildInfoRow(
            Icons.security,
            S.of(context).g_key_ens_two_step_process,
          ),
          _buildInfoRow(
            Icons.timer,
            S.of(context).g_key_ens_wait_time_info,
          ),
          _buildInfoRow(
            Icons.warning_amber_rounded,
            S.of(context).g_key_ens_keep_app_open,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(8)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: ScreenUtil().setWidth(24),
            color: AppThemeUtils.getColorByKey(
              context,
              AppThemeKeys.mainBlueColor.name,
            ),
          ),
          SizedBox(width: ScreenUtil().setWidth(12)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(24),
                color: AppThemeUtils.getColorByKey(
                  context,
                  AppThemeKeys.itemSubtitleTextColor.name,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommittingContent() {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(32)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(),
          SizedBox(height: ScreenUtil().setWidth(20)),
          Text(
            S.of(context).g_key_ens_committing,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(28),
              fontWeight: FontWeight.w600,
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.mainTextColor.name,
              ),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(8)),
          Text(
            S.of(context).g_key_ens_please_wait,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(24),
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.itemSubtitleTextColor.name,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingContent() {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;

    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(32)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
      ),
      child: Column(
        children: [
          // 倒计时圆环
          SizedBox(
            width: ScreenUtil().setWidth(120),
            height: ScreenUtil().setWidth(120),
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: (_commitResult?.minWaitTime ?? 0) > 0
                      ? (1 - (_remainingSeconds / _commitResult!.minWaitTime)).clamp(0.0, 1.0)
                      : 1.0,
                  strokeWidth: 8,
                  backgroundColor: AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.mainBlueColor.name,
                  ).withAlpha(30),
                  valueColor: AlwaysStoppedAnimation(
                    AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.mainBlueColor.name,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(32),
                      fontWeight: FontWeight.bold,
                      color: AppThemeUtils.getColorByKey(
                        context,
                        AppThemeKeys.mainTextColor.name,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(24)),
          Text(
            S.of(context).g_key_ens_waiting,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(28),
              fontWeight: FontWeight.w600,
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.mainTextColor.name,
              ),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(8)),
          Text(
            S.of(context).g_key_ens_wait_explanation,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(24),
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.itemSubtitleTextColor.name,
              ),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRegisteringContent() {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(32)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(),
          SizedBox(height: ScreenUtil().setWidth(20)),
          Text(
            S.of(context).g_key_ens_registering,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(28),
              fontWeight: FontWeight.w600,
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.mainTextColor.name,
              ),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(8)),
          Text(
            S.of(context).g_key_ens_finalizing,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(24),
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.itemSubtitleTextColor.name,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessContent() {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(32)),
      decoration: BoxDecoration(
        color: Colors.green.withAlpha(20),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
        border: Border.all(
          color: Colors.green.withAlpha(50),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.check_circle,
            size: ScreenUtil().setWidth(80),
            color: Colors.green,
          ),
          SizedBox(height: ScreenUtil().setWidth(20)),
          Text(
            S.of(context).g_key_ens_success,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(32),
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(8)),
          Text(
            '${widget.name}.eth ${S.of(context).g_key_ens_is_yours}',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(26),
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.mainTextColor.name,
              ),
            ),
          ),
          if (_registerResult?.txHash != null) ...[
            SizedBox(height: ScreenUtil().setWidth(16)),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(12),
                vertical: ScreenUtil().setWidth(8),
              ),
              decoration: BoxDecoration(
                color: Colors.green.withAlpha(20),
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
              ),
              child: Text(
                'Tx: ${_shortenHash(_registerResult!.txHash!)}',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(22),
                  fontFamily: 'monospace',
                  color: AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.itemSubtitleTextColor.name,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorContent() {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(32)),
      decoration: BoxDecoration(
        color: Colors.red.withAlpha(20),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
        border: Border.all(
          color: Colors.red.withAlpha(50),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error,
            size: ScreenUtil().setWidth(64),
            color: Colors.red,
          ),
          SizedBox(height: ScreenUtil().setWidth(16)),
          Text(
            S.of(context).g_key_ens_failed,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(28),
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(8)),
          Text(
            _errorMessage ?? S.of(context).g_key_error_3,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(24),
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.itemSubtitleTextColor.name,
              ),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    switch (_currentStep) {
      case 0:
        return ElevatedButton(
          onPressed: _startRegistration,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppThemeUtils.getColorByKey(
              context,
              AppThemeKeys.mainBlueColor.name,
            ),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(18)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
            ),
          ),
          child: Text(
            S.of(context).g_key_ens_start_registration,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(30),
              fontWeight: FontWeight.w600,
            ),
          ),
        );

      case 1:
      case 2:
      case 3:
        return ElevatedButton(
          onPressed: null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(18)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
            ),
          ),
          child: Text(
            S.of(context).g_key_ens_processing,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(30),
              fontWeight: FontWeight.w600,
            ),
          ),
        );

      case 4:
        return ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(18)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
            ),
          ),
          child: Text(
            S.of(context).g_swap_key_18,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(30),
              fontWeight: FontWeight.w600,
            ),
          ),
        );

      case -1:
        return ElevatedButton(
          onPressed: _retryRegistration,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppThemeUtils.getColorByKey(
              context,
              AppThemeKeys.mainBlueColor.name,
            ),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(18)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
            ),
          ),
          child: Text(
            S.of(context).g_swap_key_6,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(30),
              fontWeight: FontWeight.w600,
            ),
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  String _shortenHash(String hash) {
    if (hash.length <= 16) return hash;
    return '${hash.substring(0, 10)}...${hash.substring(hash.length - 6)}';
  }
}
