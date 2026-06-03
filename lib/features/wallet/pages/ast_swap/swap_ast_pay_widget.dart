import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/core/enums/load.dart';
import 'package:n42_wallet/features/utils/regular.dart';
import 'package:n42_wallet/features/wallet/models/ast_swap/swap_ast_model.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/pages/add_token/wallet_coin_add_all.dart';
import 'package:n42_wallet/features/wallet/pages/ast_swap/swap_ast_select_chain.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/features/widgets/image_network.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:decimal/decimal.dart' as dec;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider, Consumer;
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// "You Pay" section in the swap page: input, chain selector, balance, and add-token prompt.
class SwapAstPayWidget extends ConsumerWidget {
  final TextEditingController payController;
  final FocusNode payNode;
  final FocusNode getNode;
  final SwapAstModel? youPay;
  final CoinModel? payCoinModel;
  final Map<String, dynamic>? token;
  final bool hasValidInput;
  final List<SwapAstModel> swapAstList;
  final Regular regular;
  final void Function(String value) onPayChanged;
  final void Function() onPayEditingComplete;
  final void Function(SwapAstModel selected) onChainSelected;
  final void Function() onAddToken;
  final void Function() onCloseKeyboard;

  const SwapAstPayWidget({
    super.key,
    required this.payController,
    required this.payNode,
    required this.getNode,
    required this.youPay,
    required this.payCoinModel,
    required this.token,
    required this.hasValidInput,
    required this.swapAstList,
    required this.regular,
    required this.onPayChanged,
    required this.onPayEditingComplete,
    required this.onChainSelected,
    required this.onAddToken,
    required this.onCloseKeyboard,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balanceColor = AppThemeUtils.getColorByKey(
      context,
      hasValidInput
          ? AppThemeKeys.itemTextColor.name
          : AppThemeKeys.errorTextColor.name,
    );

    return Container(
      margin: EdgeInsets.fromLTRB(
        AppSpacing.space8,
        AppSpacing.space8,
        AppSpacing.space8,
        AppSpacing.space4,
      ),
      padding: EdgeInsets.all(AppSpacing.space8),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor4.name),
        borderRadius: AppRadius.brSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          _buildInputRow(context),
          if (payCoinModel == null && youPay != null)
            _buildAddRow(context, ref,
              label: S.of(context).g_swap_key_14(youPay?.payChain ?? ""),
              coinName: youPay?.payChain ?? "",
            ),
          if (payCoinModel != null)
            _buildBalanceRow(context, balanceColor),
          if (payCoinModel != null && token == null)
            _buildAddRow(context, ref,
              label: S.of(context).g_swap_key_14(youPay?.payCoin ?? ""),
              coinName: youPay?.payCoin ?? "",
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Text(
            S.of(context).g_swap_key_3,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.body.copyWith(
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemTextColor.name),
            ),
          ),
        ),
        SizedBox(width: AppSpacing.space2),
        Expanded(
          child: Text(
            '${payCoinModel?.coin['name'] ?? ""}(${payCoinModel?.coin['miniName'] ?? ""})',
            style: AppTypography.body.copyWith(
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.mainBlueColor.name),
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildInputRow(BuildContext context) {
    return SizedBox(
      height: ScreenUtil().setWidth(100),
      width: double.infinity,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              style: AppTypography.displayLg.copyWith(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.itemTextColor.name),
              ),
              controller: payController,
              focusNode: payNode,
              textInputAction: TextInputAction.next,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: S.of(context).g_key_44,
                hintStyle: AppTypography.displayLg.copyWith(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.textFieldHintColor.name),
                ),
                border: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isCollapsed: true,
                contentPadding: EdgeInsets.symmetric(
                    vertical: AppSpacing.space2),
              ),
              maxLines: 1,
              onChanged: onPayChanged,
              onEditingComplete: () {
                FocusScope.of(context).requestFocus(getNode);
                onPayEditingComplete();
              },
            ),
          ),
          _buildChainSelector(context),
        ],
      ),
    );
  }

  Widget _buildChainSelector(BuildContext context) {
    return InkWell(
      onTap: () async {
        onCloseKeyboard();
        final rModel = await Navigator.push<SwapAstModel>(
          context,
          MaterialPageRoute(builder: (_) => SwapAstSelectChain(swapAstList)),
        );
        if (rModel != null) onChainSelected(rModel);
      },
      child: Container(
        width: ScreenUtil().setWidth(200),
        margin: EdgeInsets.only(left: AppSpacing.space4),
        child: Row(
          children: [
            SizedBox(
              width: ScreenUtil().setWidth(52),
              height: ScreenUtil().setWidth(52),
              child: ImageNetWork(
                imageUrl: youPay?.uri ?? "",
                placeholder: "assets/img/list_default.png",
              ),
            ),
            Expanded(
              child: Text(
                youPay?.payCoin ?? "",
                style: AppTypography.body.copyWith(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.itemTextColor.name),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              width: ScreenUtil().setWidth(40),
              child: Icon(
                Icons.arrow_forward_ios,
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.itemBorderColor.name),
                size: ScreenUtil().setWidth(40),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceRow(BuildContext context, Color balanceColor) {
    final double balance = youPay?.balance ?? 0;
    final String balanceText = regular.formartNumDouble(
      dec.Decimal.parse(balance.toString()).toDouble(),
      14,
      isCrop: true,
      isFill0: false,
    ).toString();

    return Row(
      children: [
        Flexible(
          child: Text(
            "${S.of(context).g_key_29}:$balanceText",
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodySm.copyWith(color: balanceColor),
          ),
        ),
        if (youPay?.load == Load.loading)
          SizedBox(
            width: ScreenUtil().setWidth(26),
            height: ScreenUtil().setWidth(26),
            child: const CircularProgressIndicator(),
          ),
      ],
    );
  }

  Widget _buildAddRow(
    BuildContext context,
    WidgetRef ref, {
    required String label,
    required String coinName,
  }) {
    return Row(
      children: [
        Text(
          label,
          style: AppTypography.bodySm.copyWith(
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.errorTextColor.name),
          ),
        ),
        InkWell(
          onTap: () async {
            onCloseKeyboard();
            final r = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(builder: (_) => WalletCoinAddAll(coinName)),
                ) ??
                false;
            if (!context.mounted) return;
            if (r) {
              await ref.read(wapBridgeProvider).initWallet(shouldInitCoinInfo: true);
              onAddToken();
            }
          },
          child: Container(
            height: ScreenUtil().setWidth(50),
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.space4),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.mainButtonBgColor.name),
              borderRadius: AppRadius.brPill,
            ),
            child: Text(
              S.of(context).g_key_wallet_k47,
              style: AppTypography.captionSm.copyWith(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainButtonTextColor.name),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
