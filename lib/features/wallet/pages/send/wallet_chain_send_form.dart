import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/pages/send/wallet_chain_send_ens.dart';
import 'package:n42_wallet/features/wallet/services/ens_service.dart';
import 'package:n42_wallet/features/wallet/widgets/ens_address_field.dart';
import 'package:n42_wallet/features/widgets/container_widget.dart';
import 'package:n42_wallet/features/widgets/text_field_widget.dart';
import 'package:n42_wallet/features/utils/data_utils.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';

// ── Shared helpers ───────────────────────────────────────────────────────────

EdgeInsets _sectionMargin() => EdgeInsets.all(AppSpacing.space8);

TextStyle _labelStyle(BuildContext context) =>
    AppTypography.body.copyWith(color: AppColorTokens.of(context).textPrimary);

Color _itemBg(BuildContext context) => AppColorTokens.of(context).bgSurface;

// ── SendToWidget ─────────────────────────────────────────────────────────────

class SendToWidget extends StatelessWidget {
  const SendToWidget({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.nextFocusNode,
    required this.toErrorMessage,
    required this.ensStatus,
    required this.ensResult,
    required this.onAddressValidate,
    required this.onSearchTap,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final FocusNode nextFocusNode;
  final String toErrorMessage;
  final EnsResolveStatus ensStatus;
  final EnsResolutionResult? ensResult;
  final VoidCallback onSearchTap;
  final Future<void> Function(String address) onAddressValidate;

  @override
  Widget build(BuildContext context) {
    final su = ScreenUtil();
    return Container(
      margin: _sectionMargin(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(S.of(context).g_key_38, style: _labelStyle(context)),
          SizedBox(height: AppSpacing.space4),
          textFieldStyle2(
            context,
            controller: controller,
            focusNode: focusNode,
            hintText: S.of(context).g_key_155,
            onEditingComplete: () {
              FocusScope.of(context).requestFocus(nextFocusNode);
              onAddressValidate(controller.text.trim());
            },
            maxLines: 3,
            height: su.setWidth(170.0),
            errorMessage: toErrorMessage,
            rightWidget1: Container(
              width: su.setWidth(60.0),
              height: su.setWidth(60.0),
              padding: EdgeInsets.all(su.setWidth(5.0)),
              child: Icon(
                Icons.add,
                size: su.setWidth(50.0),
                color: AppColorTokens.of(context).brand,
              ),
            ),
            rightOnTap1: onSearchTap,
            bgColor: _itemBg(context),
          ),
          EnsStatusBanner(status: ensStatus, result: ensResult),
        ],
      ),
    );
  }
}

class SendNoteWidget extends StatelessWidget {
  const SendNoteWidget({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.nextFocusNode,
    required this.noteErrorMessage,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final FocusNode nextFocusNode;
  final String noteErrorMessage;
  final void Function(String value) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: _sectionMargin(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(S.of(context).g_key_wallet_k58, style: _labelStyle(context)),
          SizedBox(height: AppSpacing.space4),
          textFieldStyle2(
            context,
            controller: controller,
            focusNode: focusNode,
            hintText: S.of(context).nicknameMessage(100),
            errorMessage: noteErrorMessage,
            suffix: Text(
              '${controller.text.length}/100',
              style: AppTypography.captionSm.copyWith(
                color: AppColorTokens.of(context).textSubtitle,
              ),
            ),
            onEditingComplete: () {
              FocusScope.of(context).requestFocus(nextFocusNode);
            },
            onChanged: onChanged,
            maxLines: 2,
            height: ScreenUtil().setWidth(108.0),
            bgColor: _itemBg(context),
          ),
        ],
      ),
    );
  }
}

class SendAmountWidget extends StatelessWidget {
  const SendAmountWidget({
    super.key,
    required this.coinModel,
    required this.controller,
    required this.focusNode,
    required this.nextFocusNode,
    required this.amountErrorMessage,
    required this.onChanged,
    required this.onEditingComplete,
    required this.onMaxTap,
  });

  final CoinModel coinModel;
  final TextEditingController controller;
  final FocusNode focusNode;
  final FocusNode nextFocusNode;
  final String amountErrorMessage;
  final void Function(String value) onChanged;
  final VoidCallback onEditingComplete;
  final VoidCallback onMaxTap;

  @override
  Widget build(BuildContext context) {
    final su = ScreenUtil();
    final r16 = Radius.circular(AppRadius.md);

    return containerStyle1(
      context,
      margin: _sectionMargin(),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: AppSpacing.space8,
              right: AppSpacing.space8,
              top: AppSpacing.space8,
            ),
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    S.of(context).g_key_44,
                    style: _labelStyle(context),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: AppSpacing.space4),
                Expanded(child: _BalanceLabel(coinModel: coinModel)),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: AppSpacing.space4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(r16),
              color: _itemBg(context),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                textFieldStyle2(
                  context,
                  controller: controller,
                  focusNode: focusNode,
                  hintText: S.of(context).g_key_44,
                  hintStyle: AppTypography.displayLg.copyWith(
                    color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.textFieldHintColor.name,
                    ),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: onChanged,
                  onEditingComplete: () {
                    onEditingComplete();
                    FocusScope.of(context).requestFocus(nextFocusNode);
                  },
                  fontSize: AppTypography.displayLg.fontSize,
                  height: su.setWidth(120.0),
                  boxShadow: const BoxShadow(color: Colors.transparent),
                  borderRadius: BorderRadius.only(topLeft: r16, topRight: r16),
                  bgColor: _itemBg(context),
                  errorMessage: amountErrorMessage,
                  messageMargin: EdgeInsets.symmetric(
                    horizontal: AppSpacing.space8,
                  ),
                  rightWidget1: const _MaxButton(),
                  rightOnTap1: onMaxTap,
                ),
                Divider(
                  height: su.setWidth(1.0),
                  indent: AppSpacing.space8,
                  endIndent: AppSpacing.space8,
                ),
                _OwnerAddressRow(coinModel: coinModel),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BalanceLabel extends StatelessWidget {
  const _BalanceLabel({required this.coinModel});

  final CoinModel coinModel;

  @override
  Widget build(BuildContext context) {
    final unit = coinModel.coin['unit'].toString().toUpperCase();
    return Text(
      '${coinModel.balanceStringAll()} $unit',
      style: _labelStyle(context),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.right,
    );
  }
}

class _MaxButton extends StatelessWidget {
  const _MaxButton();

  @override
  Widget build(BuildContext context) {
    final su = ScreenUtil();
    return Container(
      margin: EdgeInsets.only(left: AppSpacing.space2),
      height: su.setWidth(60.0),
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.space4),
      decoration: BoxDecoration(
        color: AppColorTokens.of(context).brand,
        borderRadius: AppRadius.brPill,
      ),
      alignment: Alignment.center,
      child: Text(
        S.of(context).g_key_197,
        style: AppTypography.bodySm.copyWith(
          color: AppThemeUtils.getColorByKey(
            context,
            AppThemeKeys.mainWhiteColor.name,
          ),
        ),
      ),
    );
  }
}

class _OwnerAddressRow extends StatelessWidget {
  const _OwnerAddressRow({required this.coinModel});

  final CoinModel coinModel;

  @override
  Widget build(BuildContext context) {
    final addr = DataUtils().addressFarmat(coinModel.address.toString());
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: AppSpacing.space4,
        horizontal: AppSpacing.space8,
      ),
      child: Text(
        addr,
        style: AppTypography.body.copyWith(
          color: AppColorTokens.of(context).textSubtitle,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
