import 'package:n42_wallet/core/config/app_config.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/features/widgets/button_widget.dart';
import 'package:n42_wallet/features/widgets/comm_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider, Consumer;
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_manage/edit_wallet_utils.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EditWallet extends ConsumerStatefulWidget {
  final WalletInfo walletInfo;
  final int walletIndex;
  const EditWallet({
    required this.walletInfo,
    required this.walletIndex,
    super.key,
  });

  @override
  ConsumerState<EditWallet> createState() => _EditWalletState();
}

class _EditWalletState extends ConsumerState<EditWallet> {
  final _controller = TextEditingController();
  final _tagController = TextEditingController();
  late List<String> _tags;

  static const _presetTags = [
    'Trading',
    'HODL',
    'DeFi',
    'NFT',
    'Airdrop',
    'Test',
  ];

  @override
  void initState() {
    super.initState();
    _controller.text = widget.walletInfo.walletName ?? "";
    _tags = List<String>.from(widget.walletInfo.tags);
  }

  @override
  void dispose() {
    _controller.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _addTag(String tag) {
    final trimmed = tag.trim();
    if (trimmed.isEmpty || _tags.contains(trimmed) || _tags.length >= 5) return;
    setState(() => _tags.add(trimmed));
    _tagController.clear();
  }

  void _removeTag(String tag) {
    setState(() => _tags.remove(tag));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_key_wallet_edit,
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.all(ScreenUtil().setWidth(30)),
                color: AppThemeUtils.getColorByKey(
                  context,
                  AppThemeKeys.itemBgColor.name,
                ),
                child: CommInput(
                  type: InputFieldType.account,
                  controller: _controller,
                  autofocus: true,
                  maxLength: AppConfig.walletNameMaxLength,
                ),
              ),

              // Tag section
              _buildTagSection(),

              const Spacer(),
              Divider(
                height: ScreenUtil().setWidth(1),
                indent: 0,
                endIndent: 0,
              ),
              Container(
                height: ScreenUtil().setWidth(148),
                width: double.infinity,
                padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
                child: buttonStyle2(context, () async {
                  widget.walletInfo.walletName = resolveEditedWalletName(
                    input: _controller.text,
                    existingName: widget.walletInfo.walletName ?? '',
                    walletIndex: widget.walletIndex,
                  );
                  widget.walletInfo.tags = _tags;
                  await ref
                      .read(wapBridgeProvider)
                      .saveWalletInfo(widget.walletInfo, widget.walletIndex);
                  if (!context.mounted) return;
                  Navigator.of(context).pop(widget.walletInfo);
                }, S.of(context).g_key_115),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTagSection() {
    final textColor = AppThemeUtils.getColorByKey(
      context,
      AppThemeKeys.mainTextColor.name,
    );
    final subColor = AppThemeUtils.getColorByKey(
      context,
      AppThemeKeys.itemSubtitleTextColor.name,
    );
    final blueColor = AppThemeUtils.getColorByKey(
      context,
      AppThemeKeys.mainBlueColor.name,
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: ScreenUtil().setWidth(16)),
          Text(
            'Tags',
            style: TextStyle(
              color: textColor,
              fontSize: ScreenUtil().setSp(28),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(12)),

          // Current tags
          if (_tags.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: _tags
                  .map((tag) => Chip(
                        label: Text(tag, style: TextStyle(fontSize: ScreenUtil().setSp(24))),
                        deleteIcon: Icon(Icons.close, size: 16, color: subColor),
                        onDeleted: () => _removeTag(tag),
                        backgroundColor: blueColor.withValues(alpha: 0.1),
                        side: BorderSide.none,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ))
                  .toList(),
            ),

          SizedBox(height: ScreenUtil().setWidth(12)),

          // Preset tags (only show unselected ones)
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: _presetTags
                .where((t) => !_tags.contains(t))
                .map((tag) => ActionChip(
                      label: Text(
                        '+ $tag',
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(22),
                          color: subColor,
                        ),
                      ),
                      onPressed: _tags.length < 5 ? () => _addTag(tag) : null,
                      backgroundColor: Colors.transparent,
                      side: BorderSide(color: subColor.withValues(alpha: 0.3)),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ))
                .toList(),
          ),

          // Custom tag input
          if (_tags.length < 5) ...[
            SizedBox(height: ScreenUtil().setWidth(12)),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 36,
                    child: TextField(
                      controller: _tagController,
                      style: TextStyle(fontSize: ScreenUtil().setSp(24)),
                      decoration: InputDecoration(
                        hintText: 'Custom tag...',
                        hintStyle: TextStyle(
                          fontSize: ScreenUtil().setSp(24),
                          color: subColor,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: subColor.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                      onSubmitted: _addTag,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 36,
                  child: TextButton(
                    onPressed: () => _addTag(_tagController.text),
                    child: Text('Add', style: TextStyle(color: blueColor)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
