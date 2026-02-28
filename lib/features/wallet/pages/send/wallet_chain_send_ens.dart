import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/features/wallet/services/ens_service.dart';
import 'package:n42_wallet/features/wallet/utils/validation/address_validator.dart';
import 'package:n42_wallet/features/wallet/widgets/ens_address_field.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';

/// ENS 解析状态管理 mixin，供 _WalletChainSendState 混入。
///
/// 负责：
/// - 防抖监听地址输入变化
/// - 调用 EnsService 实时解析 ENS 名称
/// - 维护 [ensStatus] / [ensResult] / [ensConfirmed] 状态
mixin EnsResolveMixin<T extends StatefulWidget> on State<T> {
  final EnsService ensService = EnsServiceProvider.instance;

  EnsResolveStatus ensStatus = EnsResolveStatus.idle;
  EnsResolutionResult? ensResult;
  bool ensConfirmed = false;

  Timer? ensDebounceTimer;

  /// 判断链是否支持域名解析
  bool isEnsSupported(String coinType) => EnsService.chainSupportsEns(coinType);

  /// 地址输入变化回调，防抖 500ms 后触发解析
  void onToAddressInputChanged(
    String text,
    String coinType,
  ) {
    if (!isEnsSupported(coinType)) return;

    ensDebounceTimer?.cancel();

    if (text.isEmpty || !EnsService.isEnsName(text)) {
      if (ensStatus != EnsResolveStatus.idle) {
        setState(() {
          ensStatus = EnsResolveStatus.idle;
          ensResult = null;
        });
      }
      return;
    }

    setState(() {
      ensStatus = EnsResolveStatus.resolving;
      ensResult = null;
    });

    ensDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      _resolveEnsRealtime(text, coinType);
    });
  }

  Future<void> _resolveEnsRealtime(String ensName, String coinType) async {
    final result = await ensService.resolveName(ensName, preferredChain: coinType);
    if (!mounted) return;
    final resolved = result.success && result.address != null;
    setState(() {
      ensStatus = resolved ? EnsResolveStatus.resolved : EnsResolveStatus.failed;
      ensResult = result;
    });
  }

  void cancelEnsTimer() {
    ensDebounceTimer?.cancel();
  }
}

/// 地址输入框下方的 ENS 实时解析状态横幅。
///
/// 根据 [status] 展示：
/// - idle → 不渲染（SizedBox.shrink）
/// - resolving → 转圈 + 文字
/// - failed → 橙色警告
/// - resolved → 绿色卡片（可点击复制地址）
class EnsStatusBanner extends StatelessWidget {
  const EnsStatusBanner({
    super.key,
    required this.status,
    required this.result,
  });

  final EnsResolveStatus status;
  final EnsResolutionResult? result;

  @override
  Widget build(BuildContext context) {
    final subtitleColor = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.itemSubtitleTextColor.name);
    final mainTextColor =
        AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name);
    final blueColor =
        AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name);

    return switch (status) {
      EnsResolveStatus.idle => const SizedBox.shrink(),
      EnsResolveStatus.resolving => _ResolvingBanner(
          subtitleColor: subtitleColor, blueColor: blueColor),
      EnsResolveStatus.failed => _FailedBanner(
          message: result?.error ?? S.of(context).g_key_t_50),
      EnsResolveStatus.resolved => result?.address != null
          ? _ResolvedBanner(
              result: result!,
              subtitleColor: subtitleColor,
              mainTextColor: mainTextColor,
              blueColor: blueColor,
            )
          : const SizedBox.shrink(),
    };
  }
}

class _ResolvingBanner extends StatelessWidget {
  const _ResolvingBanner({
    required this.subtitleColor,
    required this.blueColor,
  });

  final Color subtitleColor;
  final Color blueColor;

  @override
  Widget build(BuildContext context) {
    final su = ScreenUtil();
    final w8 = su.setWidth(8);
    final w20 = su.setWidth(20);

    return Padding(
      padding: EdgeInsets.only(top: w8),
      child: Row(
        children: [
          SizedBox(
            width: w20,
            height: w20,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              valueColor: AlwaysStoppedAnimation<Color>(blueColor),
            ),
          ),
          SizedBox(width: w8),
          Text(
            S.of(context).g_key_ens_resolving,
            style: TextStyle(
              fontSize: su.setSp(22),
              color: subtitleColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _FailedBanner extends StatelessWidget {
  const _FailedBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final su = ScreenUtil();
    final w6 = su.setWidth(6);

    return Padding(
      padding: EdgeInsets.only(top: w6, left: su.setWidth(4)),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded,
              color: Colors.orange, size: su.setWidth(20)),
          SizedBox(width: w6),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: su.setSp(22),
                color: Colors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResolvedBanner extends StatelessWidget {
  const _ResolvedBanner({
    required this.result,
    required this.subtitleColor,
    required this.mainTextColor,
    required this.blueColor,
  });

  final EnsResolutionResult result;
  final Color subtitleColor;
  final Color mainTextColor;
  final Color blueColor;

  @override
  Widget build(BuildContext context) {
    final su = ScreenUtil();
    final w8 = su.setWidth(8);
    final resolvedAddr = result.address!;
    final shortAddr = AddressValidator.getAddressPreview(
      resolvedAddr,
      prefixLength: 6,
      suffixLength: 4,
    );
    const successColor = Color(0xFF4CAF50);

    return GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: resolvedAddr));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).g_key_ens_copy_address),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(top: w8),
        padding: EdgeInsets.symmetric(
          horizontal: su.setWidth(12),
          vertical: w8,
        ),
        decoration: BoxDecoration(
          color: successColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(w8),
          border: Border.all(
            color: successColor.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: successColor,
              size: su.setWidth(20),
            ),
            SizedBox(width: w8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    S.of(context).g_key_ens_resolved_address,
                    style: TextStyle(
                      fontSize: su.setSp(20),
                      color: subtitleColor,
                    ),
                  ),
                  Text(
                    shortAddr,
                    style: TextStyle(
                      fontSize: su.setSp(24),
                      fontWeight: FontWeight.w600,
                      color: mainTextColor,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            if (result.sourceChain != null)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: su.setWidth(6),
                  vertical: su.setWidth(3),
                ),
                decoration: BoxDecoration(
                  color: blueColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(su.setWidth(5)),
                ),
                child: Text(
                  result.sourceChain!,
                  style: TextStyle(
                    fontSize: su.setSp(18),
                    fontWeight: FontWeight.w600,
                    color: blueColor,
                  ),
                ),
              ),
            SizedBox(width: su.setWidth(4)),
            Icon(
              Icons.copy_rounded,
              color: subtitleColor,
              size: su.setWidth(18),
            ),
          ],
        ),
      ),
    );
  }
}
