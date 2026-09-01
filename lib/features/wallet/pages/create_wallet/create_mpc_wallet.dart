import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/core/enums/load.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/mpc/mpc_provider.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';

/// MPC 无助记词钱包创建页面
///
/// 用户通过社交登录（Google/Apple/Email）创建钱包，
/// 无需记录或保管助记词和私钥。
class CreateMpcWallet extends ConsumerStatefulWidget {
  const CreateMpcWallet({super.key});

  @override
  ConsumerState<CreateMpcWallet> createState() => _CreateMpcWalletState();
}

class _CreateMpcWalletState extends ConsumerState<CreateMpcWallet> {
  Load _loginLoad = Load.finish;
  String _errorMsg = '';
  MpcLoginType? _selectedType;

  static const _loginOptions = [
    (
      type: MpcLoginType.google,
      icon: Icons.g_mobiledata,
      label: 'Google',
      color: Color(0xFF3C85FF),
    ),
    (
      type: MpcLoginType.apple,
      icon: Icons.apple,
      label: 'Apple',
      color: Color(0xFF373739),
    ),
    (
      type: MpcLoginType.email,
      icon: Icons.email_outlined,
      label: 'Email',
      color: Color(0xFF6C63FF),
    ),
    (
      type: MpcLoginType.phone,
      icon: Icons.phone_outlined,
      label: 'Phone',
      color: Color(0xFF00BFA5),
    ),
    (
      type: MpcLoginType.twitter,
      icon: Icons.close,
      label: 'X (Twitter)',
      color: Color(0xFF28A0F0),
    ),
    (
      type: MpcLoginType.discord,
      icon: Icons.discord,
      label: 'Discord',
      color: Color(0xFF6366F1),
    ),
  ];

  Future<void> _loginWith(MpcLoginType type) async {
    final provider = MpcProviderRegistry.instance.defaultProvider;
    if (provider == null) {
      setState(() => _errorMsg = 'MPC provider not configured');
      return;
    }

    setState(() {
      _loginLoad = Load.loading;
      _selectedType = type;
      _errorMsg = '';
    });

    try {
      if (!provider.isInitialized) {
        await provider.initialize();
      }

      final result = await provider.login(type);

      if (!mounted) return;

      // Create wallet info from MPC result
      final wap = ref.read(wapBridgeProvider);
      final walletInfo = WalletInfo(
        walletName: 'MPC Wallet',
        walletUuid: wap.userUUID,
        timestamp: DateTime.now().millisecondsSinceEpoch.toString(),
      );
      walletInfo.isMpc = true;
      walletInfo.mpcProvider = result.provider;
      walletInfo.mpcUserId = result.userId;
      walletInfo.mpcRecoveryFactors = [result.loginHint];

      // MPC wallets: the private key lives in the MPC session,
      // not in local storage. Signing goes through the MpcProvider.
      // We store the EVM address as watchAddress for balance tracking,
      // and mark isMpc=true so the signing layer knows to use MpcProvider.
      walletInfo.coinInfo = {
        'ETH': {'address': result.address},
      };

      await wap.addWalletInfo(walletInfo);

      if (!mounted) return;

      // Success — navigate back to wallet list
      final nav = Navigator.of(context);
      nav.pop(); // pop this page
      nav.pop(); // pop create wallet menu
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loginLoad = Load.finish;
        _errorMsg = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final blueColor = AppColorTokens.of(context).brand;
    final textColor = AppColorTokens.of(context).textPrimary;
    final subColor = AppColorTokens.of(context).textSubtitle;

    return Scaffold(
      appBar: AppBarWidget(text: 'Create Wallet'),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.space8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: AppSpacing.space4),

              // Header
              Icon(Icons.shield_outlined, size: 48, color: blueColor),
              SizedBox(height: AppSpacing.space4),
              Text(
                'No Seed Phrase Needed',
                style: AppTypography.titleLg.copyWith(
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              SizedBox(height: AppSpacing.space4),
              Text(
                'Sign in with your social account to create a secure MPC wallet. '
                'Your private key is split into encrypted shares — no seed phrase to lose.',
                style: AppTypography.bodySm.copyWith(
                  color: subColor,
                  height: 1.5,
                ),
              ),
              SizedBox(height: AppSpacing.space12),

              // Login options
              ...(_loginOptions.map(
                (opt) => Padding(
                  padding: EdgeInsets.only(bottom: ScreenUtil().setWidth(16)),
                  child: _buildLoginButton(
                    type: opt.type,
                    icon: opt.icon,
                    label: opt.label,
                    color: opt.color,
                    textColor: textColor,
                  ),
                ),
              )),

              // Error
              if (_errorMsg.isNotEmpty) ...[
                SizedBox(height: AppSpacing.space4),
                Container(
                  padding: EdgeInsets.all(AppSpacing.space4),
                  decoration: BoxDecoration(
                    color: AppColorTokens.of(context).danger.withValues(
                      alpha: 0.1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMsg,
                    style: AppTypography.caption.copyWith(
                      color: AppColorTokens.of(context).danger,
                    ),
                  ),
                ),
              ],

              const Spacer(),

              // Security note
              Container(
                padding: EdgeInsets.all(AppSpacing.space4),
                decoration: BoxDecoration(
                  color: blueColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 18, color: blueColor),
                    SizedBox(width: AppSpacing.space4),
                    Expanded(
                      child: Text(
                        'Powered by MPC-TSS. Your key is split into 3 encrypted shares across your device, our servers, and a recovery backup.',
                        style: AppTypography.caption.copyWith(
                          color: subColor,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton({
    required MpcLoginType type,
    required IconData icon,
    required String label,
    required Color color,
    required Color textColor,
  }) {
    final isLoading = _loginLoad == Load.loading && _selectedType == type;
    final isDisabled = _loginLoad == Load.loading && _selectedType != type;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: isDisabled ? null : () => _loginWith(type),
        icon: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: color),
              )
            : Icon(icon, color: color, size: 24),
        label: Text(
          label,
          style: AppTypography.body.copyWith(
            fontWeight: FontWeight.w600,
            color: isDisabled
                ? AppColorTokens.of(context).textTertiary
                : textColor,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: isDisabled
                ? AppColorTokens.of(context).border
                : color.withValues(alpha: 0.4),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.space6),
        ),
      ),
    );
  }
}
