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
import 'package:n42_wallet/features/wallet/widgets/ens/ens_purchase_step_content.dart';
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

      setState(() => _remainingSeconds--);

      if (_remainingSeconds <= 0) {
        timer.cancel();
        _executeRegister();
      }
    });
  }

  Future<void> _executeRegister() async {
    if (_commitResult == null) return;

    setState(() => _currentStep = 3);

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

    setState(() => _currentStep = 4);
  }

  void _retryRegistration() {
    _waitTimer?.cancel();

    final bool needsFullRestart =
        _commitResult == null || _commitResult!.isExpired || _commitmentExpiredOnRegister;

    if (needsFullRestart) {
      if (_commitmentExpiredOnRegister || _commitResult?.isExpired == true) {
        _ensService.rollbackCommit(widget.name);
      }
      setState(() {
        _currentStep = 0;
        _errorMessage = null;
        _commitResult = null;
        _registerResult = null;
        _commitmentExpiredOnRegister = false;
      });
      return;
    }

    // 共享重置
    _errorMessage = null;
    _commitmentExpiredOnRegister = false;

    if (_commitResult!.canRegister) {
      setState(() {});
      _executeRegister();
    } else {
      setState(() {
        _currentStep = 2;
        _remainingSeconds = _commitResult!.remainingWaitTime;
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
            EnsPurchaseStepContent(
              currentStep: _currentStep,
              remainingSeconds: _remainingSeconds,
              commitResult: _commitResult,
              registerResult: _registerResult,
              errorMessage: _errorMessage,
              domainName: widget.name,
            ),
            SizedBox(height: ScreenUtil().setWidth(24)),

            // 价格信息
            if (_currentStep >= 0 && _currentStep < 4)
              EnsPriceCard(price: widget.price),
            SizedBox(height: ScreenUtil().setWidth(32)),

            // 操作按钮
            EnsPurchaseActionButton(
              currentStep: _currentStep,
              onStart: _startRegistration,
              onRetry: _retryRegistration,
              onDone: () => Navigator.pop(context, true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDomainCard() {
    final s = S.of(context);
    final su = ScreenUtil();
    final blueColor = AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name);
    final subtitleColor = AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name);
    final yearLabel = widget.years == 1 ? s.g_key_ens_year : s.g_key_ens_years;

    return Container(
      padding: EdgeInsets.all(su.setWidth(24)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [blueColor.withAlpha(30), blueColor.withAlpha(10)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(su.setWidth(20)),
      ),
      child: Column(
        children: [
          Text(
            '${widget.name}.eth',
            style: TextStyle(
              fontSize: su.setSp(40),
              fontWeight: FontWeight.bold,
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
            ),
          ),
          SizedBox(height: su.setWidth(8)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.access_time, size: su.setWidth(20), color: subtitleColor),
              SizedBox(width: su.setWidth(6)),
              Text(
                '${widget.years} $yearLabel',
                style: TextStyle(fontSize: su.setSp(26), color: subtitleColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
