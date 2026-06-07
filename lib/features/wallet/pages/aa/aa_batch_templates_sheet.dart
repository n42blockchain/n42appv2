// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/features/wallet/aa/provider/batch_template_provider.dart';

/// 批量模板列表底部弹层
///
/// 展示用户保存的批量操作模板，支持加载和删除。
class BatchTemplatesSheet extends StatefulWidget {
  final BatchTemplateProvider provider;
  final ValueChanged<BatchTemplate> onLoad;

  const BatchTemplatesSheet({
    super.key,
    required this.provider,
    required this.onLoad,
  });

  @override
  State<BatchTemplatesSheet> createState() => _BatchTemplatesSheetState();
}

class _BatchTemplatesSheetState extends State<BatchTemplatesSheet> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.provider,
      builder: (context, _) {
        final templates = widget.provider.templates;

        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
          decoration: BoxDecoration(
            color: AppColorTokens.of(context).bgSurface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(ScreenUtil().setWidth(24)),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      S.of(context).g_key_aa_batch_templates,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(32),
                        fontWeight: FontWeight.bold,
                        color: AppColorTokens.of(context).textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              SizedBox(height: ScreenUtil().setWidth(16)),
              if (templates.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: ScreenUtil().setWidth(32),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.bookmarks_outlined,
                        size: ScreenUtil().setWidth(48),
                        color: AppColorTokens.of(
                          context,
                        ).textSubtitle.withAlpha(80),
                      ),
                      SizedBox(height: ScreenUtil().setWidth(12)),
                      Text(
                        S.of(context).g_key_aa_batch_no_templates,
                        style: TextStyle(
                          color: AppColorTokens.of(context).textSubtitle,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: templates.length,
                    itemBuilder: (context, index) {
                      final template = templates[index];
                      return _TemplateItem(
                        template: template,
                        onLoad: () {
                          widget.onLoad(template);
                          Navigator.pop(context);
                        },
                        onDelete: () async {
                          if (template.id != null) {
                            await widget.provider.deleteTemplate(template.id!);
                          }
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _TemplateItem extends StatelessWidget {
  final BatchTemplate template;
  final VoidCallback onLoad;
  final VoidCallback onDelete;

  const _TemplateItem({
    required this.template,
    required this.onLoad,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(12)),
      padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(
          context,
          AppThemeKeys.itemBgColor2.name,
        ),
        borderRadius: AppRadius.brMd,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  template.name,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(26),
                    fontWeight: FontWeight.w600,
                    color: AppColorTokens.of(context).textPrimary,
                  ),
                ),
                SizedBox(height: ScreenUtil().setWidth(4)),
                Text(
                  '${template.operations.length} operations · ${template.chainSymbol}',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(22),
                    color: AppColorTokens.of(context).textSubtitle,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onLoad,
            child: Text(
              S.of(context).g_key_aa_batch_template_load,
              style: TextStyle(color: AppColorTokens.of(context).brand),
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(
              maxWidth: ScreenUtil().setWidth(36),
              maxHeight: ScreenUtil().setWidth(36),
            ),
          ),
        ],
      ),
    );
  }
}
