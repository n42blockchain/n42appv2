import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

EdgeInsets _sectionMargin() => EdgeInsets.all(ScreenUtil().setWidth(30.0));

TextStyle _labelStyle(BuildContext context) => TextStyle(
      color: AppThemeUtils.getColorByKey(
          context, AppThemeKeys.mainTextColor.name),
      fontSize: ScreenUtil().setSp(28.0),
    );

Color _itemBg(BuildContext context) =>
    AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name);

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
          SizedBox(height: su.setWidth(20.0)),
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
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainBlueColor.name),
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
          SizedBox(height: ScreenUtil().setWidth(20.0)),
          textFieldStyle2(
            context,
            controller: controller,
            focusNode: focusNode,
            hintText: S.of(context).nicknameMessage(100),
            errorMessage: noteErrorMessage,
            suffix: Text(
              '${controller.text.length}/100',
              style: TextStyle(
                fontSize: ScreenUtil().setSp(20.0),
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.itemSubtitleTextColor.name),
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
    final r16 = Radius.circular(su.setWidth(16.0));

    return containerStyle1(
      context,
      margin: _sectionMargin(),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: su.setWidth(30.0),
              right: su.setWidth(30.0),
              top: su.setWidth(30.0),
            ),
            child: Row(
              children: [
                Text(S.of(context).g_key_44, style: _labelStyle(context)),
                SizedBox(width: su.setWidth(20.0)),
                Expanded(child: _BalanceLabel(coinModel: coinModel)),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: su.setWidth(20.0)),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(r16),
              color: _itemBg(context),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xff101828).withAlpha(0),
                  offset: const Offset(0, 1),
                  blurRadius: su.setWidth(4.0),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                textFieldStyle2(
                  context,
                  controller: controller,
                  focusNode: focusNode,
                  hintText: S.of(context).g_key_44,
                  hintStyle: TextStyle(
                    fontSize: su.setSp(54.0),
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.textFieldHintColor.name),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: onChanged,
                  onEditingComplete: () {
                    onEditingComplete();
                    FocusScope.of(context).requestFocus(nextFocusNode);
                  },
                  fontSize: su.setWidth(70.0),
                  height: su.setWidth(120.0),
                  boxShadow: BoxShadow(
                    color: const Color(0xff101828).withAlpha(0),
                    offset: const Offset(0, 0),
                    blurRadius: su.setWidth(0),
                  ),
                  borderRadius: BorderRadius.only(topLeft: r16, topRight: r16),
                  bgColor: _itemBg(context),
                  errorMessage: amountErrorMessage,
                  messageMargin: EdgeInsets.symmetric(
                      horizontal: su.setWidth(30.0)),
                  rightWidget1: const _MaxButton(),
                  rightOnTap1: onMaxTap,
                ),
                Divider(
                  height: su.setWidth(1.0),
                  indent: su.setWidth(30.0),
                  endIndent: su.setWidth(30.0),
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
      margin: EdgeInsets.only(left: su.setWidth(10.0)),
      height: su.setWidth(60.0),
      padding: EdgeInsets.symmetric(horizontal: su.setWidth(20.0)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(
            context, AppThemeKeys.mainBlueColor.name),
        borderRadius: BorderRadius.all(Radius.circular(su.setWidth(60.0))),
      ),
      alignment: Alignment.center,
      child: Text(
        S.of(context).g_key_197,
        style: TextStyle(
          fontSize: su.setSp(26.0),
          color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.mainWhiteColor.name),
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
        vertical: ScreenUtil().setWidth(20.0),
        horizontal: ScreenUtil().setWidth(30.0),
      ),
      child: Text(
        addr,
        style: TextStyle(
          color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.itemSubtitleTextColor.name),
          fontSize: ScreenUtil().setSp(30.0),
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
