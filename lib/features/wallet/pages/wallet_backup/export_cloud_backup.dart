import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider, Consumer;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/enums/load.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/utils/wallet_backup_crypto.dart';
import 'package:n42_wallet/features/wallet/utils/wallet_backup_payload.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/features/widgets/comm_input.dart';
import 'package:n42_wallet/features/widgets/container_widget.dart';
import 'package:share_plus/share_plus.dart';

/// 将选中的钱包加密后备份到 iCloud Drive / Google Drive。
///
/// 流程：
///   1. 勾选要备份的钱包
///   2. 设置备份密码（须二次确认）
///   3. 生成加密 .n42backup 文件
///   4. 通过系统分享面板保存
///      - iOS：「存储到文件」→ iCloud Drive / 本机
///      - Android：「保存到云端硬盘」等
///
/// 安全保证：
///   AES-256-CBC + PBKDF2-SHA256（60 万次）+ HMAC-SHA256 完整性校验。
///   备份文件中包含钱包恢复所需敏感字段，且仅受备份密码保护。
class ExportCloudBackup extends ConsumerStatefulWidget {
  const ExportCloudBackup({super.key});

  @override
  ConsumerState<ExportCloudBackup> createState() => _ExportCloudBackupState();
}

class _ExportCloudBackupState extends ConsumerState<ExportCloudBackup> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  final Set<int> _selectedIndexes = {};
  Load _load = Load.finish;
  String _error = '';

  List<WalletInfo> get _wallets => ref.read(wapBridgeProvider).walletInfoList;

  @override
  void initState() {
    super.initState();
    // 默认全选
    _selectedIndexes.addAll(List.generate(_wallets.length, (i) => i));
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  // ── 导出 ──────────────────────────────────────────────────

  Future<void> _export() async {
    if (_load == Load.loading) return;
    setState(() => _error = '');

    if (_selectedIndexes.isEmpty) {
      ToastUtils.show('Please select at least one wallet to backup');
      return;
    }

    final password = _passwordController.text;
    if (password.length < 8) {
      setState(() => _error = 'Password must be at least 8 characters');
      return;
    }
    if (password != _confirmController.text) {
      setState(() => _error = 'Passwords do not match');
      return;
    }

    setState(() => _load = Load.loading);

    try {
      final wallets = _wallets;
      final selected = _selectedIndexes
          .where((i) => i >= 0 && i < wallets.length)
          .map((i) => wallets[i])
          .toList();

      if (selected.isEmpty) {
        setState(() => _error = 'No valid wallets selected for backup');
        return;
      }

      final payload = selected.map(walletInfoToBackupPayload).toList();

      final encrypted = await WalletBackupCrypto.encrypt(payload, password);

      if (!mounted) return;

      final bytes = Uint8List.fromList(utf8.encode(encrypted));
      final ts = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'n42wallet_backup_$ts.n42backup';

      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile.fromData(
              bytes,
              name: fileName,
              mimeType: 'application/octet-stream',
            ),
          ],
          subject: 'N42Wallet Backup',
        ),
      );
    } on WalletBackupException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _load = Load.finish);
    }
  }

  // ── Build ─────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final wallets = _wallets;

    return Scaffold(
      appBar: AppBarWidget(text: 'Export Cloud Backup'),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(child: _buildBody(wallets)),
            Positioned(bottom: 0, left: 0, right: 0, child: _buildBottomBar()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(List<WalletInfo> wallets) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(30),
        vertical: ScreenUtil().setWidth(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 警告
          _buildWarningBanner(),
          SizedBox(height: ScreenUtil().setWidth(30)),

          // 钱包列表选择
          _label('Select Wallets to Backup'),
          SizedBox(height: ScreenUtil().setWidth(16)),
          ...List.generate(wallets.length, (i) => _walletTile(wallets[i], i)),
          SizedBox(height: ScreenUtil().setWidth(30)),

          // 密码
          _label('Backup Password'),
          _buildPasswordField(
            controller: _passwordController,
            hintText: 'Set a strong backup password (min 8 chars)',
          ),

          // 确认密码
          _label('Confirm Password'),
          _buildPasswordField(
            controller: _confirmController,
            hintText: 'Re-enter the backup password',
          ),

          // 错误
          if (_error.isNotEmpty) ...[
            Container(
              padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
              decoration: BoxDecoration(
                color: AppColorTokens.of(context).dangerBg,
                borderRadius: AppRadius.brSm,
              ),
              child: Text(
                _error,
                style: AppTypography.bodySm.copyWith(
                  color: AppColorTokens.of(context).danger,
                ),
              ),
            ),
            SizedBox(height: ScreenUtil().setWidth(16)),
          ],

          SizedBox(height: ScreenUtil().setWidth(160)),
        ],
      ),
    );
  }

  Widget _buildWarningBanner() => Container(
    padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF3CD),
      borderRadius: AppRadius.brMd,
      border: Border.all(color: const Color(0xFFFFD700), width: 1),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.warning_amber_rounded,
          color: Color(0xFFD4A017),
          size: 20,
        ),
        SizedBox(width: ScreenUtil().setWidth(12)),
        Expanded(
          child: Text(
            'This backup contains your private keys / mnemonics. '
            'wallet passwords and wallet settings. '
            'Keep the backup file and password safe. '
            'Never share them with anyone.',
            style: AppTypography.caption.copyWith(
              color: const Color(0xFF856404),
            ),
          ),
        ),
      ],
    ),
  );

  void _toggleSelection(int index) {
    setState(() {
      _selectedIndexes.contains(index)
          ? _selectedIndexes.remove(index)
          : _selectedIndexes.add(index);
    });
  }

  Widget _walletTile(WalletInfo wallet, int index) {
    final isSelected = _selectedIndexes.contains(index);
    return containerStyle1(
      context,
      margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(16)),
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(20),
        vertical: ScreenUtil().setWidth(16),
      ),
      child: Row(
        children: [
          // 备份类型图标
          Container(
            width: ScreenUtil().setWidth(48),
            height: ScreenUtil().setWidth(48),
            decoration: BoxDecoration(
              color: AppColorTokens.of(context).brand.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              wallet.hasMnemonic ? Icons.vpn_key : Icons.key,
              size: ScreenUtil().setWidth(24),
              color: AppColorTokens.of(context).brand,
            ),
          ),
          SizedBox(width: ScreenUtil().setWidth(16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  wallet.walletName ?? 'Wallet ${index + 1}',
                  style: AppTypography.body.copyWith(
                    color: AppColorTokens.of(context).textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  wallet.hasMnemonic ? 'Mnemonic wallet' : 'Private key wallet',
                  style: AppTypography.caption.copyWith(
                    color: AppColorTokens.of(context).textSubtitle,
                  ),
                ),
              ],
            ),
          ),
          Checkbox(
            value: isSelected,
            activeColor: AppColorTokens.of(context).brand,
            onChanged: (_) => _toggleSelection(index),
          ),
        ],
      ),
      onTap: () => _toggleSelection(index),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
  }) => containerStyle1(
    context,
    height: ScreenUtil().setWidth(120),
    padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20)),
    margin: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(16)),
    child: CommInput(
      type: InputFieldType.password,
      hintText: hintText,
      controller: controller,
      maxLines: 1,
      style: AppTypography.bodySm.copyWith(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.ff888888.name),
      ),
    ),
  );

  Widget _label(String text) => Text(
    text,
    style: TextStyle(
      color: AppColorTokens.of(context).textPrimary,
      fontWeight: FontWeight.w600,
      fontSize: ScreenUtil().setSp(32),
    ),
  );

  Widget _buildBottomBar() => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Divider(height: ScreenUtil().setWidth(1)),
      Container(
        padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
        height: ScreenUtil().setWidth(148),
        width: double.infinity,
        color: AppColorTokens.of(context).bgBase,
        child: AppButton(
          label: 'Create & Save Backup',
          onPressed: () => _export(),
          loading: _load == Load.loading,
        ),
      ),
    ],
  );
}
