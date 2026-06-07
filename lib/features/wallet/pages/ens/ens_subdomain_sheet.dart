// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/features/wallet/pages/ens/ens_chain_config.dart';
import 'package:n42_wallet/features/wallet/pages/ens/ens_subdomain_sheet_utils.dart';
import 'package:n42_wallet/features/wallet/services/ens_registration_service.dart';

/// 创建子域名的 BottomSheet
///
/// 独立为 StatefulWidget 以消除 showModalBottomSheet + StatefulBuilder 的嵌套复杂性。
/// 调用方通过 [EnsCreateSubdomainSheet.show] 展示，通过 [onCreated] 回调获知成功。
class EnsCreateSubdomainSheet extends StatefulWidget {
  final String parentName;
  final String walletAddress;
  final EnsChainConfig domainChain;
  final EnsRegistrationService ensService;
  final VoidCallback onCreated;

  const EnsCreateSubdomainSheet({
    super.key,
    required this.parentName,
    required this.walletAddress,
    required this.domainChain,
    required this.ensService,
    required this.onCreated,
  });

  /// 便捷方法：弹出创建子域名 Sheet
  static Future<void> show(
    BuildContext context, {
    required String parentName,
    required String walletAddress,
    required EnsChainConfig domainChain,
    required EnsRegistrationService ensService,
    required VoidCallback onCreated,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ScreenUtil().setWidth(24)),
        ),
      ),
      builder: (_) => EnsCreateSubdomainSheet(
        parentName: parentName,
        walletAddress: walletAddress,
        domainChain: domainChain,
        ensService: ensService,
        onCreated: onCreated,
      ),
    );
  }

  @override
  State<EnsCreateSubdomainSheet> createState() =>
      _EnsCreateSubdomainSheetState();
}

class _EnsCreateSubdomainSheetState extends State<EnsCreateSubdomainSheet> {
  final _labelController = TextEditingController();
  late final TextEditingController _ownerController;

  String? _labelError;
  String? _ownerError;
  bool _creating = false;

  static final _hexAddrRegex = RegExp(r'^0x[0-9a-fA-F]{40}$');

  @override
  void initState() {
    super.initState();
    _ownerController = TextEditingController(text: widget.walletAddress);
  }

  @override
  void dispose() {
    _labelController.dispose();
    _ownerController.dispose();
    super.dispose();
  }

  bool _isValidAddress(String addr) => _hexAddrRegex.hasMatch(addr.trim());

  Future<void> _onCreate() async {
    if (_creating) return;
    final label = _labelController.text.trim();
    final owner = _ownerController.text.trim();

    if (!widget.ensService.isValidSubdomainLabel(label)) {
      setState(
        () => _labelError = S.of(context).g_key_ens_subdomain_invalid_label,
      );
      return;
    }
    if (owner.isNotEmpty && !_isValidAddress(owner)) {
      setState(() => _ownerError = S.of(context).g_key_ens_invalid_address);
      return;
    }

    setState(() {
      _creating = true;
      _labelError = null;
      _ownerError = null;
    });

    // 在 await 前缓存 context 相关资源
    final nav = Navigator.of(context);
    final errorFallback = S.of(context).g_key_error_3;
    final successMsg = S.of(context).g_key_ens_subdomain_created;

    try {
      final result = await widget.ensService.createSubdomain(
        widget.parentName,
        label,
        owner.isNotEmpty ? owner : widget.walletAddress,
      );

      if (!mounted) return;

      final messenger = ScaffoldMessenger.of(context);
      if (result.error) {
        setState(() => _creating = false);
        messenger.showSnackBar(
          SnackBar(
            content: Text(result.data?.toString() ?? errorFallback),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        nav.pop();
        messenger.showSnackBar(
          SnackBar(content: Text(successMsg), backgroundColor: Colors.green),
        );
        widget.onCreated();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _creating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: canDismissEnsSubdomainSheet(_creating),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context),
              SizedBox(height: ScreenUtil().setWidth(8)),
              _buildPreview(context),
              SizedBox(height: ScreenUtil().setWidth(8)),
              _buildLabelField(context),
              SizedBox(height: ScreenUtil().setWidth(16)),
              _buildOwnerField(context),
              SizedBox(height: ScreenUtil().setWidth(24)),
              _buildCreateButton(context),
              SizedBox(height: ScreenUtil().setWidth(8)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            S.of(context).g_key_ens_subdomain_create,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(32),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        IconButton(
          onPressed: _creating ? null : () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }

  Widget _buildPreview(BuildContext context) {
    final label = _labelController.text.trim();
    if (label.isEmpty) return const SizedBox.shrink();
    final su = ScreenUtil();
    return Container(
      margin: EdgeInsets.only(bottom: su.setWidth(12)),
      padding: EdgeInsets.symmetric(
        horizontal: su.setWidth(16),
        vertical: su.setWidth(10),
      ),
      decoration: BoxDecoration(
        color: widget.domainChain.color.withAlpha(20),
        borderRadius: BorderRadius.circular(su.setWidth(10)),
      ),
      child: Text(
        '$label.${widget.parentName}',
        style: TextStyle(
          fontSize: su.setSp(26),
          fontWeight: FontWeight.w600,
          color: widget.domainChain.color,
        ),
      ),
    );
  }

  Widget _buildLabelField(BuildContext context) {
    return TextField(
      controller: _labelController,
      autofocus: true,
      textInputAction: TextInputAction.next,
      onChanged: (_) => setState(() => _labelError = null),
      decoration: InputDecoration(
        labelText: S.of(context).g_key_ens_subdomain_label,
        hintText: S.of(context).g_key_ens_subdomain_label_hint,
        errorText: _labelError,
        border: OutlineInputBorder(borderRadius: AppRadius.brMd),
        suffixText: '.${widget.parentName}',
        suffixStyle: TextStyle(
          color: widget.domainChain.color,
          fontWeight: FontWeight.w500,
          fontSize: ScreenUtil().setSp(22),
        ),
      ),
    );
  }

  Widget _buildOwnerField(BuildContext context) {
    return TextField(
      controller: _ownerController,
      onChanged: (_) => setState(() => _ownerError = null),
      decoration: InputDecoration(
        labelText: S.of(context).g_key_ens_subdomain_owner,
        hintText: S.of(context).g_key_ens_subdomain_owner_hint,
        errorText: _ownerError,
        border: OutlineInputBorder(borderRadius: AppRadius.brMd),
      ),
      style: TextStyle(fontSize: ScreenUtil().setSp(24)),
    );
  }

  Widget _buildCreateButton(BuildContext context) {
    return SizedBox(
      height: ScreenUtil().setWidth(88),
      child: ElevatedButton(
        onPressed: _creating ? null : _onCreate,
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.domainChain.color,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.brMd),
        ),
        child: _creating
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                S.of(context).g_key_ens_subdomain_create,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
