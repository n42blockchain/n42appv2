import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/component/pages/scan_page.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/wallet/api/address_book_api.dart';
import 'package:n42_wallet/features/wallet/api/token_view_api.dart';
import 'package:n42_wallet/features/wallet/models/address_book_model.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/pages/address_book/address_book_input_utils.dart';
import 'package:n42_wallet/features/wallet/pages/address_book/choose_coins_page.dart';
import 'package:n42_wallet/features/wallet/pages/face_matching/face_match.dart';
import 'package:n42_wallet/features/wallet/provider/trustdart.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/features/widgets/container_widget.dart';
import 'package:n42_wallet/features/widgets/image_network.dart';
import 'package:n42_wallet/features/widgets/sheet_bottom.dart';
import 'package:n42_wallet/features/widgets/text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider, Consumer;
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddAddressPage extends ConsumerStatefulWidget {
  final String? initialAddress;
  const AddAddressPage({this.initialAddress, super.key});

  @override
  ConsumerState<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends ConsumerState<AddAddressPage> {
  final addressController = TextEditingController();
  final nameController = TextEditingController();
  final descController = TextEditingController();

  final addressFocusNode = FocusNode();
  final nameFocusNode = FocusNode();
  final descFocusNode = FocusNode();

  var coinName = 'BTC';
  var coinFullName = "Bitcoin";
  var coinType = 'BTC';
  var coinIcon = '';
  var blockchainType = BlockchainType.Bitcoin.name;

  String errorMessage = "";

  Color _themeColor(AppThemeKeys key) =>
      AppThemeUtils.getColorByKey(context, key.name);

  @override
  void initState() {
    super.initState();
    final initial = widget.initialAddress;
    if (initial != null && initial.isNotEmpty) {
      addressController.text = initial;
    }
    Future.microtask(() async {
      if (!mounted) return;
      final list = ref.read(wapBridgeProvider).coinModels;
      if (list.isEmpty || !mounted) return;
      final selection = addressBookSelectionFromCoinMap(
        Map<String, dynamic>.from(list[0].coin),
      );
      setState(() {
        coinName = selection.coinName;
        coinFullName = selection.coinFullName;
        coinType = selection.coinType;
        coinIcon = selection.coinIcon;
        blockchainType = selection.blockchainType;
      });
    });
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
    String? result;

    if (addr.isEmpty) {
      errorMessage = S.current.g_key_41;
    } else {
      addr = normalizeAddressBookInput(addr);

      if (await Trustdart().validateAddress(coinType, addr)) {
        errorMessage = "";
        result = addr;
      } else if (coinType == CoinType.ETH.name) {
        final rmm = await TokenViewApi().getEnsResolve(addr);
        if (!rmm.error) {
          errorMessage = "";
          result = rmm.data;
        } else {
          errorMessage = S.current.g_key_t_50;
        }
      } else {
        errorMessage = S.current.g_key_t_50;
      }
    }

    setState(() {});
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_key_112,
        actions: [
          GestureDetector(
            onTap: handlerData,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(30.0),
              ),
              color: Colors.transparent,
              child: Center(
                child: Text(
                  S.of(context).g_key_115,
                  style: TextStyle(
                    color: _themeColor(AppThemeKeys.mainBlueColor),
                    fontSize: ScreenUtil().setSp(30.0),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: buildContentList(context),
    );
  }

  Widget buildContentList(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(30),
        vertical: ScreenUtil().setWidth(30.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSelectItem(),
          const SizedBox(height: 18),
          Text(
            S.of(context).address_Information,
            style: TextStyle(
              color: _themeColor(AppThemeKeys.mainTextColor),
              fontSize: ScreenUtil().setSp(28.0),
            ),
          ),
          const SizedBox(height: 10),
          _buildAddressView(context),
        ],
      ),
    );
  }

  Widget _buildSelectItem() {
    return GestureDetector(
      onTap: () async {
        final data = await Navigator.push<CoinModel>(
          context,
          MaterialPageRoute(builder: (_) => const ChooseCoinsPage()),
        );
        if (!mounted || data == null) return;
        final selection = addressBookSelectionFromCoinMap(
          Map<String, dynamic>.from(data.coin),
        );
        setState(() {
          coinType = selection.coinType;
          coinName = selection.coinName;
          coinFullName = selection.coinFullName;
          coinIcon = selection.coinIcon;
          blockchainType = selection.blockchainType;
        });
      },
      child: containerStyle1(
        context,
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20.0)),
        height: ScreenUtil().setWidth(88.0),
        child: Row(
          children: [
            (coinType == CoinType.N.name)
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
            SizedBox(width: ScreenUtil().setWidth(24.0)),
            Text(
              '$coinFullName ($coinName)',
              style: TextStyle(
                color: _themeColor(AppThemeKeys.mainTextColor),
                fontSize: ScreenUtil().setWidth(32.0),
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              size: ScreenUtil().setWidth(40.0),
              color: _themeColor(AppThemeKeys.itemSubtitleTextColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressView(BuildContext context) {
    return containerStyle1(
      context,
      padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(20.0)),
      child: Column(
        children: [
          scanItem(),
          Divider(
            height: ScreenUtil().setWidth(6.0),
            endIndent: ScreenUtil().setWidth(20.0),
            indent: ScreenUtil().setWidth(20.0),
          ),
          name(),
          Divider(
            height: ScreenUtil().setWidth(6.0),
            endIndent: ScreenUtil().setWidth(20.0),
            indent: ScreenUtil().setWidth(20.0),
          ),
          desc(),
        ],
      ),
    );
  }

  /// Transparent box shadow used to disable default shadow in textFieldStyle2
  static const _noShadow = BoxShadow(
    color: Color(0x00101828),
    offset: Offset(0, 0),
    blurRadius: 0,
    spreadRadius: 0,
  );

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
      bgColor: _themeColor(AppThemeKeys.itemBgColor),
      messageMargin: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(30.0),
      ),
      rightWidget3: blockchainType == BlockchainType.Ethereum.name
          ? Container(
              width: ScreenUtil().setWidth(60.0),
              height: ScreenUtil().setWidth(60.0),
              padding: EdgeInsets.all(ScreenUtil().setWidth(5.0)),
              child: Icon(
                Icons.face_outlined,
                size: ScreenUtil().setWidth(50.0),
                color: _themeColor(AppThemeKeys.mainBlueColor),
              ),
            )
          : null,
      rightOnTap3: blockchainType == BlockchainType.Ethereum.name
          ? faceMatchTypeWidget
          : null,
      rightWidget1: Container(
        width: ScreenUtil().setWidth(60.0),
        height: ScreenUtil().setWidth(60.0),
        padding: EdgeInsets.all(ScreenUtil().setWidth(5.0)),
        child: Image.asset(
          "assets/wallet/scan.png",
          color: _themeColor(AppThemeKeys.mainBlueColor),
          width: ScreenUtil().setWidth(50.0),
          height: ScreenUtil().setWidth(50.0),
        ),
      ),
      rightOnTap1: () async {
        final data = await Navigator.push<String>(
          context,
          MaterialPageRoute(builder: (_) => ScanPage()),
        );
        if (!mounted || data == null) return;
        setState(
          () => addressController.text = normalizeAddressBookInput(data),
        );
      },
      rightWidget2: Container(
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20.0)),
        height: ScreenUtil().setWidth(60.0),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _themeColor(AppThemeKeys.mainBlueColor),
          borderRadius: BorderRadius.all(Radius.circular(60.0)),
        ),
        child: Text(
          S.of(context).g_key_166,
          style: TextStyle(
            color: _themeColor(AppThemeKeys.mainWhiteColor),
            fontSize: ScreenUtil().setSp(26.0),
          ),
        ),
      ),
      rightOnTap2: () async {
        final data = await Clipboard.getData(Clipboard.kTextPlain);
        final text = data?.text;
        if (text != null && text != "null") {
          addressController.text = normalizeAddressBookInput(text);
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
      bgColor: _themeColor(AppThemeKeys.itemBgColor),
      onEditingComplete: () =>
          FocusScope.of(context).requestFocus(descFocusNode),
    );
  }

  Widget desc() {
    return textFieldStyle2(
      context,
      controller: descController,
      focusNode: descFocusNode,
      hintText: S.of(context).descO,
      boxShadow: _noShadow,
      bgColor: _themeColor(AppThemeKeys.itemBgColor),
      onEditingComplete: () =>
          FocusScope.of(context).requestFocus(addressFocusNode),
    );
  }

  void handlerData() async {
    final name = nameController.text.trim();
    final desc = descController.text.trim();
    final address = await addressCheck(addressController.text.trim());
    if (!mounted || address == null) return;

    if (coinType.isEmpty) {
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

    AddressBookModel info = AddressBookModel();
    info.coinName = coinName;
    info.coinIcon = coinIcon;
    info.address = address;
    info.name = name;
    info.desc = desc;

    try {
      final code = await AddressBookApi().saveAddressBookItem(info);
      if (!mounted) return;
      if (code != 0) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      debugPrint('[AddAddressPage] save failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Save failed. Please try again.')),
        );
      }
    }
  }

  void faceMatchTypeWidget() {
    final su = ScreenUtil();
    final textColor = _themeColor(AppThemeKeys.mainTextColor);

    Widget buildFaceOption(String label, int matchType) {
      return InkWell(
        onTap: () async {
          final address = await Navigator.push<String>(
            context,
            MaterialPageRoute(builder: (_) => FaceMatch(matchType)),
          );
          if (!mounted) return;
          if (address != null) {
            setState(() => addressController.text = address);
          }
          Navigator.pop(context);
        },
        child: SizedBox(
          height: su.setWidth(88.0),
          width: double.infinity,
          child: Text(
            label,
            style: TextStyle(fontSize: su.setWidth(32.0), color: textColor),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final child = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        buildFaceOption(S.of(context).photograph, 1),
        buildFaceOption(S.of(context).g_key_nft_16, 2),
      ],
    );
    sheetBottom(context, S.of(context).g_face_match_key1, child);
  }
}
