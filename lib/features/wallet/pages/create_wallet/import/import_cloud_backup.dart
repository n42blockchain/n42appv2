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

    FilePickerResult? result;
    try {
      result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['n42backup', 'json'],
        withData: false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Cannot open file picker: $e');
      return;
    }

    if (!mounted || result == null || result.files.isEmpty) return;

    final path = result.files.first.path;
    if (path == null) {
      if (!mounted) return;
      setState(() => _error = 'Cannot access the selected file');
      return;
    }

    try {
      final content = await File(path).readAsString();
      if (!mounted) return;
      // 快速格式验证（不解密）
      final decoded = jsonDecode(content);
      if (decoded is! Map || decoded['app'] != 'N42Wallet') {
        setState(() => _error = 'Not a valid N42Wallet backup file');
        return;
      }
      setState(() {
        _selectedFileName = result!.files.first.name;
        _backupContent = content;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Cannot read file: $e');
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
      ToastUtils.show('Please select a backup file first');
      return;
    }
    final password = _passwordController.text;
    if (password.isEmpty) {
      ToastUtils.show('Please enter the backup password');
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
        setState(() => _error = 'No wallets found in the backup file');
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
              ? 'No wallets could be restored from this backup'
              : 'No wallets found in the backup file';
        });
        return;
      }

      if (!mounted) return;
      final msg =
          'Imported $imported wallet(s)'
          '${skipped > 0 ? ', $skipped skipped' : ''}';
      ToastUtils.show(msg);
      completedWithExit = true;
      Navigator.of(context).pop(true);
    } on WalletBackupException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
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
      appBar: AppBarWidget(text: 'Import Cloud Backup'),
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
            'Restore your wallets from an encrypted backup stored on iCloud Drive or Google Drive.',
            style: TextStyle(
              color: _color(AppThemeKeys.itemSubtitleTextColor),
              fontSize: su.setSp(28),
            ),
          ),
          SizedBox(height: su.setWidth(40)),

          _label('Backup File'),
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
                    _selectedFileName ?? 'No file selected',
                    style: TextStyle(
                      color: _color(
                        _selectedFileName != null
                            ? AppThemeKeys.mainTextColor
                            : AppThemeKeys.itemSubtitleTextColor,
                      ),
                      fontSize: su.setSp(28),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: su.setWidth(16)),
                _chip('Select', onTap: _pickFile),
              ],
            ),
            onTap: _pickFile,
          ),

          _label('Backup Password'),
          containerStyle1(
            context,
            height: su.setWidth(120),
            padding: EdgeInsets.symmetric(horizontal: su.setWidth(20)),
            margin: EdgeInsets.symmetric(vertical: su.setWidth(20)),
            child: CommInput(
              type: InputFieldType.password,
              hintText: 'Enter the password used when creating the backup',
              controller: _passwordController,
              maxLines: 1,
              style: TextStyle(
                color: _color(AppThemeKeys.ff888888),
                fontSize: su.setSp(26),
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
                style: TextStyle(
                  color: _color(AppThemeKeys.errorTextColor),
                  fontSize: su.setSp(26),
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
                  'Your backup is encrypted with AES-256 + PBKDF2. Only the correct password can restore it.',
                  style: TextStyle(
                    color: _color(AppThemeKeys.itemSubtitleTextColor),
                    fontSize: su.setSp(24),
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
    style: TextStyle(
      color: _color(AppThemeKeys.mainTextColor),
      fontWeight: FontWeight.w600,
      fontSize: ScreenUtil().setSp(32),
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
          style: TextStyle(color: Colors.white, fontSize: su.setSp(26)),
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
            label: 'Import Wallets',
            onPressed: () => _import(),
            loading: isLoading,
          ),
        ),
      ],
    );
  }
}
