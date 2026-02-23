import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider, Consumer;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/src/component/enums/load.dart';
import 'package:n42_wallet/src/wallet/models/wallet_info.dart';
import 'package:n42_wallet/src/wallet/utils/wallet_backup_crypto.dart';
import 'package:n42_wallet/src/widgets/app_bar_widget.dart';
import 'package:n42_wallet/src/widgets/button_widget.dart';
import 'package:n42_wallet/src/widgets/comm_input.dart';
import 'package:n42_wallet/src/widgets/container_widget.dart';

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
      setState(() => _error = 'Cannot open file picker: $e');
      return;
    }

    if (result == null || result.files.isEmpty) return;

    final path = result.files.first.path;
    if (path == null) {
      setState(() => _error = 'Cannot access the selected file');
      return;
    }

    try {
      final content = await File(path).readAsString();
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
      setState(() => _error = 'Cannot read file: $e');
    }
  }

  // ── 导入 ──────────────────────────────────────────────────

  Future<void> _import() async {
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
      final wallets =
          await WalletBackupCrypto.decrypt(_backupContent!, password);
      if (!mounted) return;

      if (wallets.isEmpty) {
        setState(() => _error = 'No wallets found in the backup file');
        return;
      }

      int imported = 0;
      int skipped = 0;
      for (final w in wallets) {
        final info = WalletInfo(
          walletName: w['walletName'] as String?,
          mnemonic: w['mnemonic'] as String?,
          privateKey: w['privateKey'] as String?,
          walletUuid: ref.read(wapBridgeProvider).userUUID,
          timestamp: w['timestamp'] as String?,
        );
        final ok =
            await ref.read(wapBridgeProvider).addImportWalletInfo(info);
        if (!mounted) return;
        if (ok) {
          imported++;
        } else {
          skipped++;
        }
      }

      if (!mounted) return;
      final msg = 'Imported $imported wallet(s)'
          '${skipped > 0 ? ', $skipped already existed' : ''}';
      ToastUtils.show(msg);
      Navigator.of(context).pop(true);
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
    return Scaffold(
      appBar: AppBarWidget(text: 'Import Cloud Backup'),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(child: _buildBody()),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomBar(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(30),
        vertical: ScreenUtil().setWidth(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 说明
          Text(
            'Restore your wallets from an encrypted backup stored on iCloud Drive or Google Drive.',
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemSubtitleTextColor.name),
              fontSize: ScreenUtil().setSp(28),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(40)),

          // 文件选择
          _label('Backup File'),
          SizedBox(height: ScreenUtil().setWidth(16)),
          containerStyle1(
            context,
            padding: EdgeInsets.symmetric(
              horizontal: ScreenUtil().setWidth(20),
              vertical: ScreenUtil().setWidth(20),
            ),
            margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(30)),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedFileName ?? 'No file selected',
                    style: TextStyle(
                      color: _selectedFileName != null
                          ? AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.mainTextColor.name)
                          : AppThemeUtils.getColorByKey(context,
                              AppThemeKeys.itemSubtitleTextColor.name),
                      fontSize: ScreenUtil().setSp(28),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: ScreenUtil().setWidth(16)),
                _chip('Select', onTap: _pickFile),
              ],
            ),
            onTap: _pickFile,
          ),

          // 密码
          _label('Backup Password'),
          containerStyle1(
            context,
            height: ScreenUtil().setWidth(120),
            padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20)),
            margin: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(20)),
            child: CommInput(
              type: InputFieldType.password,
              hintText: 'Enter the password used when creating the backup',
              controller: _passwordController,
              maxLines: 1,
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.ff888888.name),
                fontSize: ScreenUtil().setSp(26),
              ),
            ),
          ),

          // 错误
          if (_error.isNotEmpty) ...[
            Container(
              padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
              decoration: BoxDecoration(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.errorBgColor.name),
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
              ),
              child: Text(
                _error,
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.errorTextColor.name),
                  fontSize: ScreenUtil().setSp(26),
                ),
              ),
            ),
            SizedBox(height: ScreenUtil().setWidth(16)),
          ],

          // 安全提示
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.shield_outlined,
                size: ScreenUtil().setWidth(32),
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainBlueColor.name),
              ),
              SizedBox(width: ScreenUtil().setWidth(12)),
              Expanded(
                child: Text(
                  'Your backup is encrypted with AES-256 + PBKDF2. Only the correct password can restore it.',
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.itemSubtitleTextColor.name),
                    fontSize: ScreenUtil().setSp(24),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: ScreenUtil().setWidth(160)),
        ],
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: TextStyle(
          color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.mainTextColor.name),
          fontWeight: FontWeight.bold,
          fontSize: ScreenUtil().setSp(32),
        ),
      );

  Widget _chip(String text, {required VoidCallback onTap}) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: ScreenUtil().setWidth(24),
            vertical: ScreenUtil().setWidth(12),
          ),
          decoration: BoxDecoration(
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.mainBlueColor.name),
            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: ScreenUtil().setSp(26),
            ),
          ),
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
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.backGroundColor.name),
            child: buttonStyle6(
              context,
              () { if (_load != Load.loading) _import(); },
              'Import Wallets',
              AppThemeUtils.getColorByKey(
                context,
                _load == Load.loading
                    ? AppThemeKeys.mainButtonBgColor3.name
                    : AppThemeKeys.mainButtonBgColor.name,
              ),
              AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.mainButtonTextColor.name),
              _load == Load.loading,
            ),
          ),
        ],
      );
}
