import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
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

  bool _isValidEvmAddress(String addr) {
    final trimmed = addr.trim();
    return trimmed.startsWith('0x') && trimmed.length == 42;
  }

  Future<void> _submit() async {
    final address = _addressCtrl.text.trim();
    if (!_isValidEvmAddress(address)) {
      ToastUtils.show(S.of(context).g_key_watch_address_hint);
      return;
    }
    setState(() => _loading = true);
    try {
      final wap = ref.read(wapBridgeProvider);
      final count = wap.walletInfoLsit.where((w) => w.watchOnly).length;
      final name = _nameCtrl.text.trim().isEmpty
          ? '${S.of(context).g_key_watch_wallet} ${count + 1}'
          : _nameCtrl.text.trim();
      await wap.addWatchOnlyWallet(name, address);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      ToastUtils.show(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mainText = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.mainTextColor.name);
    final subText = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.itemSubtitleTextColor.name);
    final blueColor = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.mainBlueColor.name);
    final itemBg = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.itemBgColor.name);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          S.of(context).g_key_watch_wallet,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(32),
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: ScreenUtil().setWidth(32),
          vertical: ScreenUtil().setWidth(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 说明文字
            Container(
              padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
              decoration: BoxDecoration(
                color: blueColor.withAlpha(20),
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
              ),
              child: Row(
                children: [
                  Icon(Icons.visibility_outlined,
                      color: blueColor, size: ScreenUtil().setWidth(40)),
                  SizedBox(width: ScreenUtil().setWidth(16)),
                  Expanded(
                    child: Text(
                      S.of(context).g_key_watch_wallet_desc,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(24),
                        color: subText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: ScreenUtil().setWidth(32)),

            // 钱包名称
            Text(
              'Name',
              style: TextStyle(
                fontSize: ScreenUtil().setSp(26),
                fontWeight: FontWeight.w500,
                color: subText,
              ),
            ),
            SizedBox(height: ScreenUtil().setWidth(12)),
            Container(
              decoration: BoxDecoration(
                color: itemBg,
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
              ),
              child: TextField(
                controller: _nameCtrl,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(28),
                  color: mainText,
                ),
                decoration: InputDecoration(
                  hintText: S.of(context).g_key_watch_wallet,
                  hintStyle: TextStyle(
                    color: subText,
                    fontSize: ScreenUtil().setSp(28),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: ScreenUtil().setWidth(24),
                    vertical: ScreenUtil().setWidth(20),
                  ),
                ),
              ),
            ),
            SizedBox(height: ScreenUtil().setWidth(24)),

            // EVM 地址
            Text(
              'Address',
              style: TextStyle(
                fontSize: ScreenUtil().setSp(26),
                fontWeight: FontWeight.w500,
                color: subText,
              ),
            ),
            SizedBox(height: ScreenUtil().setWidth(12)),
            Container(
              decoration: BoxDecoration(
                color: itemBg,
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
              ),
              child: TextField(
                controller: _addressCtrl,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(26),
                  color: mainText,
                ),
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: S.of(context).g_key_watch_address_hint,
                  hintStyle: TextStyle(
                    color: subText,
                    fontSize: ScreenUtil().setSp(26),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: ScreenUtil().setWidth(24),
                    vertical: ScreenUtil().setWidth(20),
                  ),
                ),
              ),
            ),
            SizedBox(height: ScreenUtil().setWidth(48)),

            // 添加按钮
            SizedBox(
              width: double.infinity,
              height: ScreenUtil().setWidth(88),
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: blueColor,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(ScreenUtil().setWidth(20)),
                  ),
                ),
                child: _loading
                    ? SizedBox(
                        width: ScreenUtil().setWidth(40),
                        height: ScreenUtil().setWidth(40),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        S.of(context).g_key_watch_wallet,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(30),
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
