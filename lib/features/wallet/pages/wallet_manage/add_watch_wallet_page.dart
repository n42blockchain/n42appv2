import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_manage/watch_wallet_utils.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 添加观察钱包页面
/// 用户只需输入 EVM 地址，无需私钥或助记词
class AddWatchWalletPage extends ConsumerStatefulWidget {
  const AddWatchWalletPage({super.key});

  @override
  ConsumerState<AddWatchWalletPage> createState() => _AddWatchWalletPageState();
}

class _AddWatchWalletPageState extends ConsumerState<AddWatchWalletPage> {
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final address = _addressCtrl.text.trim();
    if (!isValidWatchWalletAddress(address)) {
      ToastUtils.show(S.of(context).g_key_watch_address_hint);
      return;
    }
    bool completedWithExit = false;
    setState(() => _loading = true);
    try {
      final wap = ref.read(wapBridgeProvider);
      final existingWallet = findExistingWatchWallet(
        wap.walletInfoLsit,
        address,
      );
      if (existingWallet != null) {
        ToastUtils.show(
          S.of(context).g_key_214(existingWallet.walletName ?? ''),
        );
        return;
      }
      final count = wap.walletInfoLsit.where((w) => w.watchOnly).length;
      final name = _nameCtrl.text.trim().isEmpty
          ? '${S.of(context).g_key_watch_wallet} ${count + 1}'
          : _nameCtrl.text.trim();
      await wap.addWatchOnlyWallet(name, address);
      if (!mounted) return;
      completedWithExit = true;
      Navigator.of(context).pop(true);
    } catch (e) {
      ToastUtils.show(e.toString());
    } finally {
      if (mounted && !completedWithExit) {
        setState(() => _loading = false);
      }
    }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required double fontSize,
    required Color textColor,
    required Color hintColor,
    required Color bgColor,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.bodySm.copyWith(
            fontWeight: FontWeight.w500,
            color: hintColor,
          ),
        ),
        SizedBox(height: AppSpacing.space4),
        Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: AppRadius.brMd,
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(fontSize),
              color: textColor,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: hintColor,
                fontSize: ScreenUtil().setSp(fontSize),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppSpacing.space6,
                vertical: AppSpacing.space4,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final mainText = AppColorTokens.of(context).textPrimary;
    final subText = AppColorTokens.of(context).textSubtitle;
    final blueColor = AppColorTokens.of(context).brand;
    final itemBg = AppColorTokens.of(context).bgSurface;
    final s = S.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          s.g_key_watch_wallet,
          style: AppTypography.headline.copyWith(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.space8,
          vertical: AppSpacing.space6,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(AppSpacing.space6),
              decoration: BoxDecoration(
                color: blueColor.withAlpha(20),
                borderRadius: AppRadius.brMd,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.visibility_outlined,
                    color: blueColor,
                    size: ScreenUtil().setWidth(40),
                  ),
                  SizedBox(width: AppSpacing.space4),
                  Expanded(
                    child: Text(
                      s.g_key_watch_wallet_desc,
                      style: AppTypography.caption.copyWith(color: subText),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.space8),
            _buildTextField(
              label: S.of(context).g_key_nft_2,
              controller: _nameCtrl,
              hint: s.g_key_watch_wallet,
              fontSize: 28,
              textColor: mainText,
              hintColor: subText,
              bgColor: itemBg,
            ),
            SizedBox(height: AppSpacing.space6),
            _buildTextField(
              label: S.of(context).g_key_address,
              controller: _addressCtrl,
              hint: s.g_key_watch_address_hint,
              fontSize: 26,
              textColor: mainText,
              hintColor: subText,
              bgColor: itemBg,
              maxLines: 2,
            ),
            SizedBox(height: AppSpacing.space12),
            SizedBox(
              width: double.infinity,
              height: ScreenUtil().setWidth(88),
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: blueColor,
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.brMd),
                ),
                child: _loading
                    ? SizedBox(
                        width: ScreenUtil().setWidth(40),
                        height: ScreenUtil().setWidth(40),
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        s.g_key_watch_wallet,
                        style: AppTypography.body.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
