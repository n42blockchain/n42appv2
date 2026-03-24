import 'package:flutter/foundation.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/component/enums/load.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_manage/keystore/keystore_flow_utils.dart';
import 'package:n42_wallet/features/wallet/provider/trustdart.dart';
import 'package:n42_wallet/features/wallet/utils/chain/chain_url_registry.dart';
import 'package:n42_wallet/features/wallet/widgets/choose_import_coin.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/features/widgets/button_widget.dart';
import 'package:n42_wallet/features/widgets/comm_input.dart';
import 'package:n42_wallet/features/widgets/container_widget.dart';
import 'package:n42_wallet/features/widgets/image_network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider, Consumer;
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ImportKeystore extends ConsumerStatefulWidget {
  const ImportKeystore({super.key});

  @override
  ConsumerState<ImportKeystore> createState() => _ImportKeystoreState();
}

class _ImportKeystoreState extends ConsumerState<ImportKeystore> {
  final _keystoreController = TextEditingController();
  final _passwordController = TextEditingController();
  Load load = Load.finish;
  Map<String, dynamic> selectChain = allChainUrlMap[CoinType.N.name];

  @override
  void dispose() {
    _keystoreController.clear();
    _passwordController.clear();
    _keystoreController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  TextStyle _sectionLabelStyle() => TextStyle(
    color: AppThemeUtils.getColorByKey(
      context,
      AppThemeKeys.mainTextColor.name,
    ),
    fontWeight: FontWeight.bold,
    fontSize: ScreenUtil().setSp(32),
  );

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (!mounted) return;
    final text = data?.text;
    if (text != null && text != "null") {
      _keystoreController.text = text;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(text: S.of(context).g_key_wallet_m22),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtil().setWidth(30),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            S.of(context).g_key_keystore_22,
                            style: _sectionLabelStyle(),
                          ),
                        ),
                        InkWell(
                          onTap: _pasteFromClipboard,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: ScreenUtil().setWidth(20.0),
                            ),
                            height: ScreenUtil().setWidth(60.0),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppThemeUtils.getColorByKey(
                                context,
                                AppThemeKeys.mainBlueColor.name,
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(ScreenUtil().setWidth(20.0)),
                              ),
                            ),
                            child: Text(
                              S.of(context).g_key_166,
                              style: TextStyle(
                                color: AppThemeUtils.getColorByKey(
                                  context,
                                  AppThemeKeys.mainWhiteColor.name,
                                ),
                                fontSize: ScreenUtil().setSp(26.0),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    containerStyle1(
                      context,
                      height: ScreenUtil().setWidth(440),
                      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
                      margin: EdgeInsets.symmetric(
                        vertical: ScreenUtil().setWidth(20),
                      ),
                      child: CommInput(
                        type: InputFieldType.account,
                        hintText: S.of(context).g_key_ex_keystore_17,
                        controller: _keystoreController,
                        maxLines: 30,
                        style: TextStyle(
                          color: AppThemeUtils.getColorByKey(
                            context,
                            AppThemeKeys.ff888888.name,
                          ),
                          fontSize: ScreenUtil().setSp(26),
                        ),
                      ),
                    ),
                    Text(
                      S.of(context).login_password,
                      style: _sectionLabelStyle(),
                    ),
                    containerStyle1(
                      context,
                      height: ScreenUtil().setWidth(120),
                      padding: EdgeInsets.symmetric(
                        horizontal: ScreenUtil().setWidth(20),
                      ),
                      margin: EdgeInsets.symmetric(
                        vertical: ScreenUtil().setWidth(20),
                      ),
                      child: CommInput(
                        type: InputFieldType.password,
                        hintText: S.of(context).g_key_21,
                        controller: _passwordController,
                        maxLines: 1,
                        style: TextStyle(
                          color: AppThemeUtils.getColorByKey(
                            context,
                            AppThemeKeys.ff888888.name,
                          ),
                          fontSize: ScreenUtil().setSp(26),
                        ),
                      ),
                    ),
                    Text(S.of(context).g_key_17, style: _sectionLabelStyle()),
                    _buildChainSelector(),
                    SizedBox(height: ScreenUtil().setWidth(148)),
                  ],
                ),
              ),
            ),
            _buildBottomButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildChainSelector() {
    return containerStyle1(
      context,
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      margin: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(20)),
      child: Row(
        children: [
          Container(
            width: ScreenUtil().setWidth(60),
            height: ScreenUtil().setWidth(60),
            margin: EdgeInsets.only(right: ScreenUtil().setWidth(20)),
            child: ImageNetWork(imageUrl: selectChain['baseInfo']['icon']),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectChain['baseInfo']['name'],
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(30),
                    color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.itemTextColor.name,
                    ),
                  ),
                ),
                Text(
                  selectChain['baseInfo']['miniName'],
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(30),
                    color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.itemTextColor.name,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: AppThemeUtils.getColorByKey(
              context,
              AppThemeKeys.itemSubtitleTextColor.name,
            ),
            size: ScreenUtil().setWidth(30),
          ),
        ],
      ),
      onTap: () async {
        final rData = await Navigator.push<Map<String, dynamic>>(
          context,
          MaterialPageRoute(
            builder: (context) => ChooseImportCoin(selectChain: selectChain),
          ),
        );
        if (!mounted || rData == null) return;
        setState(() => selectChain = rData);
      },
    );
  }

  Widget _buildBottomButton() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Column(
        children: [
          Divider(height: ScreenUtil().setWidth(1), indent: 0, endIndent: 0),
          Container(
            padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
            height: ScreenUtil().setWidth(148),
            width: double.infinity,
            color: AppThemeUtils.getColorByKey(
              context,
              AppThemeKeys.backGroundColor.name,
            ),
            child: buttonStyle6(
              context,
              () async {
                if (load == Load.loading) return;
                FocusScope.of(context).requestFocus(FocusNode());
                final keystoreJson = _keystoreController.text.trim();
                if (keystoreJson.isEmpty) {
                  ToastUtils.show(S.of(context).g_key_ex_keystore_18);
                  return;
                }
                await createWallet(
                  selectChain,
                  keystoreJson,
                  _passwordController.text,
                );
              },
              S.of(context).g_key_78,
              AppThemeUtils.getColorByKey(
                context,
                load == Load.loading
                    ? AppThemeKeys.mainButtonBgColor3.name
                    : AppThemeKeys.mainButtonBgColor.name,
              ),
              AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.mainButtonTextColor.name,
              ),
              load == Load.loading,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> createWallet(
    Map<String, dynamic> cInfo,
    String keystoreJson,
    String password,
  ) async {
    try {
      setState(() => load = Load.loading);

      final coinType = resolveSelectedImportCoinType(cInfo);
      final walletInfo = await Trustdart().getWalletInfoWithKeyStore(
        keystoreJson,
        coinType,
        password,
      );
      if (!mounted) return;

      final privateKey = normalizeImportedPrivateKey(
        walletInfo['privateKey']?.toString() ?? '',
      );
      final address = extractImportedWalletAddress(walletInfo);

      if (privateKey.isEmpty || address.isEmpty) {
        ToastUtils.show(S.of(context).g_key_keystore_21);
        return;
      }

      if (kDebugMode) {
        debugPrint('ImportKeystore.createWallet address: $address');
      }
      final name = cInfo['baseInfo']['coinType'];
      final info = WalletInfo(
        walletName: name,
        password: password,
        walletUuid: ref.read(wapBridgeProvider).userUUID,
        privateKey: privateKey,
        coinInfo: {selectChain['baseInfo']['mKey']: selectChain},
      );
      final res = await ref.read(wapBridgeProvider).addImportWalletInfo(info);
      if (!mounted) return;
      if (res) {
        Navigator.of(context).pop(true);
      } else {
        ToastUtils.show(S.of(context).g_key_keystore_19);
      }
    } catch (err) {
      debugPrint("import keystore json err: ${err.toString()}");
      ToastUtils.show(err.toString());
    } finally {
      if (mounted) {
        setState(() => load = Load.finish);
      }
    }
  }
}
