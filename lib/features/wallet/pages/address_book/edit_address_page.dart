import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/component/pages/scan_page.dart';
import 'package:n42_wallet/core/utils/app_logger.dart';
import 'package:n42_wallet/core/utils/event_bus.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/wallet/api/address_book_api.dart';
import 'package:n42_wallet/features/wallet/api/token_view_api.dart';
import 'package:n42_wallet/features/wallet/models/address_book_model.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/pages/address_book/address_book_input_utils.dart';
import 'package:n42_wallet/features/wallet/pages/address_book/choose_coins_page.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/features/widgets/container_widget.dart';
import 'package:n42_wallet/features/widgets/image_network.dart';
import 'package:n42_wallet/features/widgets/text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EditAddressPage extends StatefulWidget {
  final AddressBookModel info;
  const EditAddressPage({required this.info, super.key});

  @override
  State<EditAddressPage> createState() => _EditAddressPageState();
}

class _EditAddressPageState extends State<EditAddressPage> {
  final addressController = TextEditingController();
  final nameController = TextEditingController();
  final descController = TextEditingController();

  final addressFocusNode = FocusNode();
  final nameFocusNode = FocusNode();
  final descFocusNode = FocusNode();

  late AddressBookModel info;
  String coinName = 'BTC';
  String coinType = 'BTC';
  String coinIcon = '';
  bool editStatus = true;
  String errorMessage = "";

  static const _noShadow = BoxShadow(
    color: Color(0x00101828),
    offset: Offset.zero,
    blurRadius: 0,
    spreadRadius: 0,
  );

  @override
  void initState() {
    super.initState();
    info = widget.info;
    coinName = info.coinName ?? "BTC";
    coinType = info.coinName ?? "BTC";
    coinIcon = info.coinIcon ?? "";
    addressController.text = info.address ?? "";
    nameController.text = info.name ?? "";
    descController.text = info.desc ?? '';
  }

  @override
  void dispose() {
    addressController.dispose();
    nameController.dispose();
    descController.dispose();
    addressFocusNode.dispose();
    nameFocusNode.dispose();
    descFocusNode.dispose();
    super.dispose();
  }

  Future<String?> addressCheck(String addr) async {
    if (addr.isEmpty) {
      setState(() => errorMessage = S.current.g_key_41);
      return null;
    }

    addr = normalizeAddressBookInput(addr);

    final valid = await Trustdart().validateAddress(coinType, addr);
    if (!mounted) return null;
    if (valid) {
      setState(() => errorMessage = "");
      return addr;
    }

    if (coinName == CoinType.ETH.name) {
      final rmm = await TokenViewApi().getEnsResolve(addr);
      if (!mounted) return null;
      if (!rmm.error) {
        setState(() => errorMessage = "");
        return rmm.data;
      }
    }

    setState(() => errorMessage = S.current.g_key_t_50);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_key_address_4,
        actions: [
          GestureDetector(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.space8),
              color: Colors.transparent,
              child: Center(
                child: Text(
                  editStatus ? S.of(context).g_key_115 : S.of(context).Edit,
                  style: AppTypography.headline.copyWith(
                    color: AppColorTokens.of(context).textPrimary,
                  ),
                ),
              ),
            ),
            onTap: () async {
              if (editStatus) {
                // 编辑状态 提交数据
                await handlerData();
              } else {
                setState(() {
                  editStatus = true;
                });
              }
            },
          ),
        ],
      ),
      body: buildContentList(context),
    );
  }

  Widget buildContentList(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        left: ScreenUtil().setWidth(30.0),
        right: ScreenUtil().setWidth(30.0),
        top: ScreenUtil().setWidth(30.0),
        bottom: ScreenUtil().setWidth(36.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSelectItem(),
          SizedBox(height: ScreenUtil().setWidth(36.0)),
          Text(
            S.of(context).address_Information,
            style: AppTypography.body.copyWith(
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.ff888888.name,
              ),
            ),
          ),
          SizedBox(height: AppSpacing.space4),
          _buildAddressView(context),
          const Spacer(),
          delete(),
        ],
      ),
    );
  }

  Widget _buildSelectItem() {
    return GestureDetector(
      onTap: editStatus
          ? () async {
              final CoinModel? data = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChooseCoinsPage()),
              );
              if (!mounted) return;
              if (data != null) {
                final selection = addressBookSelectionFromCoinMap(
                  Map<String, dynamic>.from(data.coin),
                );
                setState(() {
                  coinName = selection.coinName;
                  coinType = selection.coinType;
                  coinIcon = selection.coinIcon;
                });
              }
            }
          : null,
      child: containerStyle1(
        context,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.space4),
        height: ScreenUtil().setWidth(88.0),
        child: Row(
          children: [
            SizedBox(
              width: ScreenUtil().setWidth(50.0),
              height: ScreenUtil().setWidth(50.0),
              child: (coinName == CoinType.N.name)
                  ? Image.asset(
                      'assets/img/ast.png',
                      width: ScreenUtil().setWidth(50.0),
                      height: ScreenUtil().setWidth(50.0),
                      fit: BoxFit.cover,
                    )
                  : ImageNetWork(
                      imageUrl: coinIcon,
                      width: ScreenUtil().setWidth(50.0),
                      height: ScreenUtil().setWidth(50.0),
                      placeholder: "assets/img/list_default.png",
                    ),
            ),
            SizedBox(width: AppSpacing.space6),
            Text(
              coinName,
              style: AppTypography.body.copyWith(
                color: AppColorTokens.of(context).textPrimary,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              size: ScreenUtil().setWidth(40.0),
              color: AppColorTokens.of(context).textSubtitle,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressView(BuildContext context) {
    return containerStyle1(
      context,
      padding: EdgeInsets.symmetric(vertical: AppSpacing.space4),
      child: Column(
        children: [
          scanItem(),
          Divider(
            height: ScreenUtil().setWidth(6.0),
            indent: ScreenUtil().setWidth(20.0),
            endIndent: ScreenUtil().setWidth(20.0),
          ),
          name(),
          Divider(
            height: ScreenUtil().setWidth(6.0),
            indent: ScreenUtil().setWidth(20.0),
            endIndent: ScreenUtil().setWidth(20.0),
          ),
          desc(),
        ],
      ),
    );
  }

  Widget scanItem() {
    return textFieldStyle2(
      context,
      controller: addressController,
      focusNode: addressFocusNode,
      hintText: S.of(context).please_input_address,
      errorMessage: errorMessage,
      onEditingComplete: () {
        FocusScope.of(context).requestFocus(nameFocusNode);
      },
      boxShadow: _noShadow,
      messageMargin: EdgeInsets.symmetric(horizontal: AppSpacing.space8),
      rightWidget1: Image.asset(
        "assets/wallet/scan.png",
        color: AppColorTokens.of(context).textPrimary,
        width: ScreenUtil().setWidth(50.0),
        height: ScreenUtil().setWidth(50.0),
      ),
      rightOnTap1: () async {
        final data = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ScanPage()),
        );
        if (!mounted) return;
        if (data != null) {
          setState(
            () => addressController.text = normalizeAddressBookInput(data),
          );
        }
      },
      rightWidget2: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        margin: EdgeInsets.only(left: 10),
        height: ScreenUtil().setWidth(60.0),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColorTokens.of(context).brand,
          borderRadius: BorderRadius.all(Radius.circular(60.0)),
        ),
        child: Text(
          S.of(context).g_key_166,
          style: AppTypography.bodySm.copyWith(
            color: AppThemeUtils.getColorByKey(
              context,
              AppThemeKeys.mainWhiteColor.name,
            ),
          ),
        ),
      ),
      rightOnTap2: () async {
        final data = await Clipboard.getData(Clipboard.kTextPlain);
        if (!mounted) return;
        if (data?.text != null && data!.text != "null") {
          addressController.text = normalizeAddressBookInput(data.text!);
        }
      },
    );
  }

  Widget name() {
    return textFieldStyle2(
      context,
      controller: nameController,
      focusNode: nameFocusNode,
      hintText: S.of(context).g_key_nft_2,
      boxShadow: _noShadow,
      onEditingComplete: () {
        FocusScope.of(context).requestFocus(descFocusNode);
      },
    );
  }

  Widget desc() {
    return textFieldStyle2(
      context,
      controller: descController,
      focusNode: descFocusNode,
      hintText: S.of(context).descO,
      boxShadow: _noShadow,
      onEditingComplete: () {
        FocusScope.of(context).requestFocus(addressFocusNode);
      },
    );
  }

  Future<void> handlerData() async {
    final name = nameController.text.trim();
    final desc = descController.text.trim();
    final address = await addressCheck(addressController.text.trim());
    if (!mounted || address == null) return;

    if (coinName.isEmpty) {
      ToastUtils.show(S.of(context).g_key_address_3);
      return;
    }
    if (address.isEmpty) {
      ToastUtils.show(S.of(context).g_key_address_2);
      return;
    }
    if (name.isEmpty) {
      ToastUtils.show(S.of(context).g_key_address_1);
      return;
    }

    info
      ..coinName = coinName
      ..coinIcon = coinIcon
      ..address = address
      ..name = name
      ..desc = desc;

    try {
      final code = await AddressBookApi().updateAddressBookItem(info);
      if (!mounted) return;
      if (code != 0) {
        eventBus.fire(EventPublic(EventPublicType.refreshData));
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      AppLogger.w('EditAddressPage', 'update failed: $e');
    }
  }

  Widget delete() {
    return GestureDetector(
      onTap: () async {
        final data = await AddressBookApi().deleteAddressBookItem(info);
        if (!mounted) return;
        if (data != 0) {
          ToastUtils.show(S.of(context).g_key_address_5);
          eventBus.fire(EventPublic(EventPublicType.refreshData));
          Navigator.of(context).pop(true);
        }
      },
      child: Container(
        height: ScreenUtil().setWidth(80.0),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColorTokens.of(context).danger,
          borderRadius: AppRadius.brMd,
        ),
        child: Text(
          S.of(context).g_key_113,
          style: AppTypography.headline.copyWith(
            color: AppThemeUtils.getColorByKey(
              context,
              AppThemeKeys.mainWhiteColor.name,
            ),
          ),
        ),
      ),
    );
  }
}
