import 'package:n42_wallet/generated/l10n.dart';

import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider, Consumer;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/core/utils/app_logger.dart';
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

/// 从 iCloud Drive / Google Drive 加密备份文件导入钱包。
///
/// 流程：
///   1. 通过系统文件选择器选取 .n42backup 文件
///      （iOS 自动支持 iCloud Drive；Android 自动支持 Google Drive）
///   2. 输入备份密码
///   3. 解密并批量恢复钱包
class ImportCloudBackup extends ConsumerStatefulWidget {
  const ImportCloudBackup({super.key});

  @override
  ConsumerState<ImportCloudBackup> createState() => _ImportCloudBackupState();
}

class _ImportCloudBackupState extends ConsumerState<ImportCloudBackup> {
  final _passwordController = TextEditingController();

  String? _selectedFileName;
  String? _backupContent;
  Load _load = Load.finish;
  String _error = '';

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  // ── 选择文件 ──────────────────────────────────────────────

  Future<void> _pickFile() async {
    setState(() => _error = '');

    PlatformFile? result;
    try {
      result = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: const ['n42backup', 'json'],
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = S.of(context).g_ui_file_picker_failed);
      return;
    }

    if (!mounted || result == null) return;

    final path = result.path;
    if (path == null) {
      if (!mounted) return;
      setState(() => _error = S.of(context).g_ui_backup_file_access);
      return;
    }

    try {
      final content = await File(path).readAsString();
      if (!mounted) return;
      // 快速格式验证（不解密）
      final decoded = jsonDecode(content);
      if (decoded is! Map || decoded['app'] != 'N42Wallet') {
        setState(() => _error = S.of(context).g_ui_backup_invalid_file);
        return;
      }
      setState(() {
        _selectedFileName = result!.name;
        _backupContent = content;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = S.of(context).g_ui_file_read_failed);
    }
  }

  // ── 导入 ──────────────────────────────────────────────────

  bool _walletAlreadyExists(dynamic wap, WalletInfo info) {
    if (info.watchOnly) {
      return wap.walletInfoLsit.any(
        (wallet) =>
            wallet.watchOnly &&
            wallet.watchAddress.toLowerCase() ==
                info.watchAddress.toLowerCase(),
      );
    }
    if (info.privateKey != null && info.privateKey!.isNotEmpty) {
      return wap.findWallet(pk: info.privateKey!) != null;
    }
    if (info.mnemonic != null && info.mnemonic!.isNotEmpty) {
      return wap.findWallet(mnemonic: info.mnemonic!) != null;
    }
    return false;
  }

  Future<void> _import() async {
    var completedWithExit = false;
    if (_backupContent == null) {
      ToastUtils.show(S.of(context).g_ui_backup_select_file_first);
      return;
    }
    final password = _passwordController.text;
    if (password.isEmpty) {
      ToastUtils.show(S.of(context).g_ui_backup_enter_password);
      return;
    }

    setState(() {
      _load = Load.loading;
      _error = '';
    });

    try {
      final wallets = await WalletBackupCrypto.decrypt(
        _backupContent!,
        password,
      );
      if (!mounted) return;

      if (wallets.isEmpty) {
        setState(() => _error = S.of(context).g_ui_backup_empty);
        return;
      }

      int imported = 0;
      int skipped = 0;
      final wap = ref.read(wapBridgeProvider);
      for (final w in wallets) {
        try {
          final info = walletInfoFromBackupPayload(
            Map<String, dynamic>.from(w),
            userUUID: wap.userUUID,
          );
          if (_walletAlreadyExists(wap, info)) {
            skipped++;
            continue;
          }
          await wap.addWalletInfo(info);
          if (!mounted) return;
          imported++;
        } catch (e) {
          skipped++;
          AppLogger.w('ImportCloudBackup', 'skipping wallet payload: $e');
        }
      }

      if (imported == 0) {
        setState(() {
          _error = skipped > 0
              ? S.of(context).g_ui_backup_restore_none
              : S.of(context).g_ui_backup_empty;
        });
        return;
      }

      if (!mounted) return;
      final msg = S.of(context).g_ui_backup_import_result(imported, skipped);
      ToastUtils.show(msg);
      completedWithExit = true;
      Navigator.of(context).pop(true);
    } on WalletBackupException {
      if (!mounted) return;
      setState(() => _error = S.of(context).g_ui_backup_import_failed);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = S.of(context).g_ui_backup_import_failed);
    } finally {
      if (mounted && !completedWithExit) {
        setState(() => _load = Load.finish);
      }
    }
  }

  Color _color(AppThemeKeys key) =>
      AppThemeUtils.getColorByKey(context, key.name);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(text: S.of(context).g_ui_backup_import),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(child: _buildBody()),
            Positioned(bottom: 0, left: 0, right: 0, child: _buildBottomBar()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    final su = ScreenUtil();
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: su.setWidth(30),
        vertical: su.setWidth(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).g_ui_backup_restore_hint,
            style: AppTypography.body.copyWith(
              color: _color(AppThemeKeys.itemSubtitleTextColor),
            ),
          ),
          SizedBox(height: su.setWidth(40)),

          _label(S.of(context).g_ui_backup_file),
          SizedBox(height: su.setWidth(16)),
          containerStyle1(
            context,
            padding: EdgeInsets.symmetric(
              horizontal: su.setWidth(20),
              vertical: su.setWidth(20),
            ),
            margin: EdgeInsets.only(bottom: su.setWidth(30)),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedFileName ?? S.of(context).g_ui_backup_no_file,
                    style: AppTypography.body.copyWith(
                      color: _color(
                        _selectedFileName != null
                            ? AppThemeKeys.mainTextColor
                            : AppThemeKeys.itemSubtitleTextColor,
                      ),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: su.setWidth(16)),
                _chip(S.of(context).g_key_dex_select_token, onTap: _pickFile),
              ],
            ),
            onTap: _pickFile,
          ),

          _label(S.of(context).g_ui_backup_password),
          containerStyle1(
            context,
            height: su.setWidth(120),
            padding: EdgeInsets.symmetric(horizontal: su.setWidth(20)),
            margin: EdgeInsets.symmetric(vertical: su.setWidth(20)),
            child: CommInput(
              type: InputFieldType.password,
              hintText: S.of(context).g_ui_backup_restore_password_hint,
              controller: _passwordController,
              maxLines: 1,
              style: AppTypography.bodySm.copyWith(
                color: _color(AppThemeKeys.ff888888),
              ),
            ),
          ),

          if (_error.isNotEmpty) ...[
            Container(
              padding: EdgeInsets.all(su.setWidth(20)),
              decoration: BoxDecoration(
                color: _color(AppThemeKeys.errorBgColor),
                borderRadius: BorderRadius.circular(su.setWidth(8)),
              ),
              child: Text(
                _error,
                style: AppTypography.bodySm.copyWith(
                  color: _color(AppThemeKeys.errorTextColor),
                ),
              ),
            ),
            SizedBox(height: su.setWidth(16)),
          ],

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.shield_outlined,
                size: su.setWidth(32),
                color: _color(AppThemeKeys.mainBlueColor),
              ),
              SizedBox(width: su.setWidth(12)),
              Expanded(
                child: Text(
                  S.of(context).g_ui_backup_encryption_hint,
                  style: AppTypography.caption.copyWith(
                    color: _color(AppThemeKeys.itemSubtitleTextColor),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: su.setWidth(160)),
        ],
      ),
    );
  }

  Widget _label(String text) => Text(
    text,
    style: AppTypography.headline.copyWith(
      color: _color(AppThemeKeys.mainTextColor),
      fontWeight: FontWeight.w600,
    ),
  );

  Widget _chip(String text, {required VoidCallback onTap}) {
    final su = ScreenUtil();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: su.setWidth(24),
          vertical: su.setWidth(12),
        ),
        decoration: BoxDecoration(
          color: _color(AppThemeKeys.mainBlueColor),
          borderRadius: BorderRadius.circular(su.setWidth(20)),
        ),
        child: Text(
          text,
          style: AppTypography.bodySm.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    final su = ScreenUtil();
    final bool isLoading = _load == Load.loading;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Divider(height: su.setWidth(1)),
        Container(
          padding: EdgeInsets.all(su.setWidth(30)),
          height: su.setWidth(148),
          width: double.infinity,
          color: _color(AppThemeKeys.backGroundColor),
          child: AppButton(
            label: S.of(context).g_ui_backup_import_wallets,
            onPressed: () => _import(),
            loading: isLoading,
          ),
        ),
      ],
    );
  }
}
