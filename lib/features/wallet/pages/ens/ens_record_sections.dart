// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 解析地址 Section
// ─────────────────────────────────────────────────────────────────────────────

/// 解析地址编辑区块
class EnsAddressSection extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSave;
  final VoidCallback onChanged;

  const EnsAddressSection({
    super.key,
    required this.controller,
    required this.onSave,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: S.of(context).g_key_ens_resolved_address,
            onSave: onSave,
          ),
          SizedBox(height: ScreenUtil().setWidth(12)),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: '0x...',
              prefixIcon: const Icon(Icons.account_balance_wallet_outlined, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(16),
                vertical: ScreenUtil().setWidth(14),
              ),
              suffixIcon: controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        controller.clear();
                        onChanged();
                      },
                    )
                  : null,
            ),
            style: TextStyle(
              fontSize: ScreenUtil().setSp(24),
              fontFamily: 'monospace',
            ),
            onChanged: (_) => onChanged(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 文本记录 Section
// ─────────────────────────────────────────────────────────────────────────────

/// 文本记录编辑区块
class EnsTextRecordsSection extends StatelessWidget {
  final Map<String, TextEditingController> controllers;
  final List<String> recordKeys;
  final VoidCallback onSave;

  const EnsTextRecordsSection({
    super.key,
    required this.controllers,
    required this.recordKeys,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: S.of(context).g_key_ens_text_records,
            onSave: onSave,
          ),
          SizedBox(height: ScreenUtil().setWidth(16)),
          ...recordKeys.map((key) => _RecordField(
                recordKey: key,
                controller: controllers[key]!,
              )),
        ],
      ),
    );
  }
}

class _RecordField extends StatelessWidget {
  final String recordKey;
  final TextEditingController controller;

  const _RecordField({required this.recordKey, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: ScreenUtil().setWidth(16)),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: _labelFor(recordKey),
          prefixIcon: Icon(_iconFor(recordKey), size: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: ScreenUtil().setWidth(16),
            vertical: ScreenUtil().setWidth(14),
          ),
        ),
        style: TextStyle(fontSize: ScreenUtil().setSp(26)),
      ),
    );
  }

  static String _labelFor(String key) {
    switch (key) {
      case 'email':
        return 'Email';
      case 'url':
        return 'Website';
      case 'com.twitter':
        return 'Twitter / X';
      case 'com.github':
        return 'GitHub';
      case 'com.discord':
        return 'Discord';
      case 'org.telegram':
        return 'Telegram';
      case 'description':
        return 'Description';
      default:
        return key;
    }
  }

  static IconData _iconFor(String key) {
    switch (key) {
      case 'email':
        return Icons.email_outlined;
      case 'url':
        return Icons.link;
      case 'com.twitter':
        return Icons.alternate_email;
      case 'com.github':
        return Icons.code;
      case 'com.discord':
        return Icons.chat_bubble_outline;
      case 'org.telegram':
        return Icons.send_outlined;
      case 'description':
        return Icons.description_outlined;
      default:
        return Icons.text_fields;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 共享内部 widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final Widget child;

  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
      ),
      child: child,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSave;

  const _SectionHeader({required this.title, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(28),
            fontWeight: FontWeight.w600,
            color: AppThemeUtils.getColorByKey(
              context,
              AppThemeKeys.mainTextColor.name,
            ),
          ),
        ),
        TextButton(
          onPressed: onSave,
          child: Text(S.of(context).g_key_115),
        ),
      ],
    );
  }
}
