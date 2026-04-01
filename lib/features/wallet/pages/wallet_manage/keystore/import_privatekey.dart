import 'dart:convert';

import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/core/enums/load.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';
import 'package:n42_wallet/features/utils/regular.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/pages/create_wallet/create_password.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_manage/keystore/keystore_flow_utils.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';
import 'package:n42_wallet/features/wallet/utils/chain/chain_url_registry.dart';
import 'package:n42_wallet/features/wallet/widgets/choose_import_coin.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/features/widgets/button_widget.dart';
import 'package:n42_wallet/features/widgets/comm_input.dart';
import 'package:n42_wallet/features/widgets/container_widget.dart';
import 'package:n42_wallet/features/widgets/image_network.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider, Consumer;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:fast_base58/fast_base58.dart' as fast;
import 'package:crypto/crypto.dart';
import 'package:web3dart/web3dart.dart';

class ImportPrivatekey extends ConsumerStatefulWidget {
  const ImportPrivatekey({super.key});

  @override
  ConsumerState<ImportPrivatekey> createState() => _ImportPrivatekeyState();
}

class _ImportPrivatekeyState extends ConsumerState<ImportPrivatekey> {
  final _keystoreController = TextEditingController();
  Load load = Load.finish;
  String errorMessage = "";
  Map<String, dynamic> selectChain = allChainUrlMap[CoinType.N.name];

  String get _selectedCoinType => resolveSelectedImportCoinType(selectChain);

  void _showError(String message) {
    errorMessage = message;
    setState(() {});
    ToastUtils.show(errorMessage);
  }

  Future<MessageModel> checkPraviteKey(String pk) async {
    final mm = MessageModel();
    final invalidKeyMsg = S.of(context).g_key_210;
    pk = pk.trim();

    MessageModel invalidKey() {
      mm.error = true;
      mm.data = invalidKeyMsg;
      return mm;
    }

    if (pk.length == 66) {
      if (pk.substring(0, 2).toLowerCase() != "0x") return invalidKey();
      if (!Regular().regularHex(pk)) return invalidKey();
    } else if (pk.length == 64) {
      if (!Regular().regularHex(pk)) return invalidKey();
    } else if (pk.length == 51 || pk.length == 52) {
      if (!Regular().regularBase58(pk)) return invalidKey();
      final wifResult = decodeWIF(pk);
      if (wifResult.error) {
        wifResult.data = 'Invalid WIF checksum';
        return wifResult;
      }
      if (!await _verifyPrivateKeyCanGenerateAddress(wifResult.data)) {
        wifResult.error = true;
        wifResult.data = 'Private key cannot generate valid address';
      }
      return wifResult;
    } else {
      if (!Regular().regularBase58(pk)) return invalidKey();
      return decodeBase58(pk);
    }

    if (!await _verifyPrivateKeyCanGenerateAddress(pk)) {
      mm.error = true;
      mm.data = 'Private key cannot generate valid address';
      return mm;
    }

    mm.data = pk;
    return mm;
  }

  Future<bool> _verifyPrivateKeyCanGenerateAddress(String privateKey) async {
    try {
      final rm = await Trustdart().generateAddress(
        _selectedCoinType,
        selectChain['baseInfo']['path'][selectChain['addrType']],
        selectChain['addrType'],
        mnemonic: "",
        pk: privateKey,
        isImport: true,
      );
      final address = rm['legacy'];
      if (address == null || address.toString().isEmpty) return false;
      return await Trustdart().validateAddress(
        _selectedCoinType,
        address.toString(),
      );
    } catch (e) {
      debugPrint('Private key verification failed: $e');
      return false;
    }
  }

  Uint8List sha256Twice(Uint8List data) {
    final first = sha256.convert(data).bytes;
    final second = sha256.convert(first).bytes;
    return Uint8List.fromList(second);
  }

  MessageModel decodeBase58(String bs58) {
    final mm = MessageModel();
    final decoded = Uint8List.fromList(fast.Base58Decode(bs58));
    mm.data = bytesToHex(decoded);
    return mm;
  }

  MessageModel decodeWIF(String wif) {
    final mm = MessageModel();
    final decoded = Uint8List.fromList(fast.Base58Decode(wif));
    if (decoded.length < 37) return mm..error = true;

    final payload = decoded.sublist(0, decoded.length - 4);
    final checksum = decoded.sublist(decoded.length - 4);
    final calculatedChecksum = sha256Twice(payload).sublist(0, 4);

    if (!listEquals(checksum, calculatedChecksum)) return mm..error = true;
    if (payload[0] != 0x80) return mm..error = true;

    final isCompressed = payload.length == 34 && payload.last == 0x01;
    final privateKey = isCompressed
        ? payload.sublist(1, 33)
        : payload.sublist(1);
    mm.data = bytesToHex(privateKey);
    return mm;
  }

  bool listEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  void dispose() {
    _keystoreController.clear();
    _keystoreController.dispose();
    super.dispose();
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
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            S.of(context).g_key_209,
                            style: TextStyle(
                              color: AppThemeUtils.getColorByKey(
                                context,
                                AppThemeKeys.mainTextColor.name,
                              ),
                              fontWeight: FontWeight.bold,
                              fontSize: ScreenUtil().setSp(32),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            final data = await Clipboard.getData(
                              Clipboard.kTextPlain,
                            );
                            if (!mounted) return;
                            final text = data?.text;
                            if (text != null && text != "null") {
                              _keystoreController.text = text;
                            }
                          },
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
                      padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
                      margin: EdgeInsets.symmetric(
                        vertical: ScreenUtil().setWidth(20),
                      ),
                      child: CommInput(
                        type: InputFieldType.account,
                        hintText: S.of(context).g_key_209,
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
                      S.of(context).g_key_17,
                      style: TextStyle(
                        color: AppThemeUtils.getColorByKey(
                          context,
                          AppThemeKeys.mainTextColor.name,
                        ),
                        fontWeight: FontWeight.bold,
                        fontSize: ScreenUtil().setSp(32),
                      ),
                    ),
                    containerStyle1(
                      context,
                      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
                      margin: EdgeInsets.symmetric(
                        vertical: ScreenUtil().setWidth(20),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: ScreenUtil().setWidth(60),
                            height: ScreenUtil().setWidth(60),
                            margin: EdgeInsets.only(
                              right: ScreenUtil().setWidth(20),
                            ),
                            child: ImageNetWork(
                              imageUrl: selectChain['baseInfo']['icon'],
                            ),
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
                          Container(
                            width: ScreenUtil().setWidth(30),
                            height: ScreenUtil().setWidth(30),
                            margin: EdgeInsets.only(
                              left: ScreenUtil().setWidth(20),
                            ),
                            child: Icon(
                              Icons.arrow_forward_ios,
                              color: AppThemeUtils.getColorByKey(
                                context,
                                AppThemeKeys.itemSubtitleTextColor.name,
                              ),
                              size: ScreenUtil().setWidth(30),
                            ),
                          ),
                        ],
                      ),
                      onTap: () async {
                        final rData =
                            await Navigator.push<Map<String, dynamic>>(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ChooseImportCoin(selectChain: selectChain),
                              ),
                            );
                        if (!mounted || rData == null) return;
                        setState(() => selectChain = rData);
                      },
                    ),
                    if (errorMessage != "")
                      Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
                        margin: EdgeInsets.only(top: ScreenUtil().setWidth(30)),
                        decoration: BoxDecoration(
                          color: AppThemeUtils.getColorByKey(
                            context,
                            AppThemeKeys.errorBgColor.name,
                          ),
                          borderRadius: BorderRadius.circular(
                            ScreenUtil().setWidth(8),
                          ),
                        ),
                        child: Text(
                          errorMessage,
                          style: TextStyle(
                            color: AppThemeUtils.getColorByKey(
                              context,
                              AppThemeKeys.errorTextColor.name,
                            ),
                            fontSize: ScreenUtil().setSp(26),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    SizedBox(height: ScreenUtil().setWidth(148)),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Divider(
                    height: ScreenUtil().setWidth(1),
                    indent: 0,
                    endIndent: 0,
                  ),
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
                        if (!mounted) return;
                        if (load == Load.loading) return;
                        var completedWithExit = false;
                        final s = S.of(context);
                        final navigator = Navigator.of(context);
                        FocusScope.of(context).unfocus();
                        setState(() => load = Load.loading);
                        try {
                          String keystoreJson = _keystoreController.text.trim();
                          if (keystoreJson.isEmpty) {
                            _showError(s.g_key_210);
                            return;
                          }
                          final mm = await checkPraviteKey(keystoreJson);
                          if (!mounted) return;
                          if (mm.error) {
                            _showError(s.g_key_210);
                            return;
                          }
                          keystoreJson = mm.data;
                          final rm = await Trustdart().generateAddress(
                            _selectedCoinType,
                            selectChain['baseInfo']['path'][selectChain['addrType']],
                            selectChain['addrType'],
                            mnemonic: "",
                            pk: keystoreJson,
                            isImport: true,
                          );
                          if (!mounted) return;
                          if (rm['legacy'] != "") {
                            final ksjByte = hexToBytes(keystoreJson);
                            final base64Str = base64Encode(ksjByte);
                            final walletProvider = ref.read(wapBridgeProvider);
                            final beforeWalletCount =
                                walletProvider.walletInfoLsit.length;
                            final findWalletInfo = walletProvider.findWallet(
                              pk: base64Str,
                            );
                            if (findWalletInfo != null) {
                              _showError(
                                s.g_key_214(findWalletInfo.walletName ?? ""),
                              );
                              return;
                            }
                            final wInfo = WalletInfo(
                              walletName: "",
                              password: "",
                              walletUuid: ref.read(wapBridgeProvider).userUUID,
                              mnemonic: "",
                              privateKey: base64Str,
                              coinInfo: {
                                selectChain['baseInfo']['mKey']: selectChain,
                              },
                            );
                            errorMessage = "";
                            setState(() {});
                            await navigator.push(
                              MaterialPageRoute(
                                builder: (_) => CreatePassword(
                                  wInfo,
                                  createMetod: "PrivateKey",
                                ),
                              ),
                            );
                            if (!mounted) return;
                            final afterWalletCount = ref
                                .read(wapBridgeProvider)
                                .walletInfoLsit
                                .length;
                            if (afterWalletCount > beforeWalletCount) {
                              completedWithExit = true;
                              navigator.pop(true);
                            }
                          } else {
                            _showError(s.g_key_210);
                          }
                        } finally {
                          if (mounted && !completedWithExit) {
                            setState(() => load = Load.finish);
                          }
                        }
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
            ),
          ],
        ),
      ),
    );
  }
}
