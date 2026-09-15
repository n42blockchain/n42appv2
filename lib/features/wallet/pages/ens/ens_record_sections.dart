// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';

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
          SizedBox(height: AppSpacing.space4),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: '0x...',
              prefixIcon: const Icon(
                Icons.account_balance_wallet_outlined,
                size: 20,
              ),
              border: OutlineInputBorder(borderRadius: AppRadius.brMd),
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppSpacing.space4,
                vertical: AppSpacing.space4,
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
            style: AppTypography.caption.copyWith(fontFamily: 'monospace'),
            onChanged: (_) => onChanged(),
          ),
        ],
      ),
    );
  }
}

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
          SizedBox(height: AppSpacing.space4),
          ...recordKeys.map(
            (key) =>
                _RecordField(recordKey: key, controller: controllers[key]!),
          ),
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
          border: OutlineInputBorder(borderRadius: AppRadius.brMd),
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppSpacing.space4,
            vertical: AppSpacing.space4,
          ),
        ),
        style: AppTypography.bodySm,
      ),
    );
  }

  static String _labelFor(String key) => switch (key) {
    'email' => 'Email',
    'url' => 'Website',
    'com.twitter' => 'Twitter / X',
    'com.github' => 'GitHub',
    'com.discord' => 'Discord',
    'org.telegram' => 'Telegram',
    'description' => 'Description',
    _ => key,
  };

  static IconData _iconFor(String key) => switch (key) {
    'email' => Icons.email_outlined,
    'url' => Icons.link,
    'com.twitter' => Icons.alternate_email,
    'com.github' => Icons.code,
    'com.discord' => Icons.chat_bubble_outline,
    'org.telegram' => Icons.send_outlined,
    'description' => Icons.description_outlined,
    _ => Icons.text_fields,
  };
}

class _SectionCard extends StatelessWidget {
  final Widget child;

  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        color: AppColorTokens.of(context).bgSurface,
        borderRadius: AppRadius.brMd,
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
          style: AppTypography.body.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColorTokens.of(context).textPrimary,
          ),
        ),
        TextButton(onPressed: onSave, child: Text(S.of(context).g_key_115)),
      ],
    );
  }
}
