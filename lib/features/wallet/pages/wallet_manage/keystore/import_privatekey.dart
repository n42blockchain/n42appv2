import 'dart:convert';

import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/component/enums/load.dart';
import 'package:n42_wallet/features/models/message_model.dart';
import 'package:n42_wallet/features/utils/regular.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/pages/create_wallet/create_password.dart';
import 'package:n42_wallet/features/wallet/provider/trustdart.dart';
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
  Load load=Load.finish;
  String errorMessage="";
  Map<String,dynamic> selectChain=allChainUrlMap[CoinType.N.name];
  @override
  void initState() {
    //_keystoreController.text=bytesToHex(base64Decode("pa0i0UL4y7cgG6j5WDf3GPRATxZ/c37tzcn1GdGsfYk="));
    //_keystoreController.text='CVFM5HyKx2b35Z2eLvGQ4QDLA5mB7mCowYmqwPtx12k';
    super.initState();
  }
  /// Enhanced private key validation
  ///
  /// Security features:
  /// - Format validation (hex, WIF, base58)
  /// - Length validation
  /// - WIF checksum verification
  /// - Post-import public key generation verification
  Future<MessageModel> checkPraviteKey(String pk) async {
    MessageModel mm = MessageModel();

    // Layer 1: Trim whitespace
    pk = pk.trim();

    // Layer 2: Format and length validation
    if (pk.length == 66) {
      // Hex format with 0x prefix
      String sStr = pk.substring(0, 2);
      if (sStr.toLowerCase() != "0x") {
        mm.error = true;
        mm.data = S.of(context).g_key_210;
        return mm;
      }
      if (!Regular().regularHex(pk)) {
        mm.error = true;
        mm.data = S.of(context).g_key_210;
        return mm;
      }
    } else if (pk.length == 64) {
      // Hex format without prefix
      if (!Regular().regularHex(pk)) {
        mm.error = true;
        mm.data = S.of(context).g_key_210;
        return mm;
      }
    } else if (pk.length == 51 || pk.length == 52) {
      // WIF format (Bitcoin)
      if (!Regular().regularBase58(pk)) {
        mm.error = true;
        mm.data = S.of(context).g_key_210;
        return mm;
      }
      // Layer 3: WIF checksum verification
      mm = decodeWIF(pk);
      if (mm.error) {
        mm.data = 'Invalid WIF checksum';
        return mm;
      }
      // Verify the decoded key can generate valid address
      final verifyResult = await _verifyPrivateKeyCanGenerateAddress(mm.data);
      if (!verifyResult) {
        mm.error = true;
        mm.data = 'Private key cannot generate valid address';
      }
      return mm;
    } else {
      // Base58 format
      if (!Regular().regularBase58(pk)) {
        mm.error = true;
        mm.data = S.of(context).g_key_210;
        return mm;
      }
      mm = decodeBase58(pk);
      return mm;
    }

    // Layer 4: Verify the key can generate a valid public key
    final verifyResult = await _verifyPrivateKeyCanGenerateAddress(pk);
    if (!verifyResult) {
      mm.error = true;
      mm.data = 'Private key cannot generate valid address';
      return mm;
    }

    mm.data = pk;
    return mm;
  }

  /// Verify that a private key can generate a valid address
  ///
  /// This is a critical security check to ensure the imported key is valid
  Future<bool> _verifyPrivateKeyCanGenerateAddress(String privateKey) async {
    try {
      // Try to generate an address using the private key
      Map<Object?, Object?> rm = await Trustdart().generateAddress(
        CoinType.N.name,
        selectChain['baseInfo']['path'][selectChain['addrType']],
        selectChain['addrType'],
        mnemonic: "",
        pk: privateKey,
        isImport: true,
      );

      // Check if valid address was generated
      final address = rm['legacy'];
      if (address == null || address.toString().isEmpty) {
        return false;
      }

      // Additional validation: verify address format
      final isValid = await Trustdart().validateAddress(
        selectChain['baseInfo']['mKey'] ?? CoinType.N.name,
        address.toString(),
      );

      return isValid;
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
  MessageModel decodeBase58(String bs58){
    MessageModel mm=MessageModel();
    final decoded = Uint8List.fromList(fast.Base58Decode(bs58));
    mm.data=bytesToHex(decoded);
    return mm;
  }
  MessageModel decodeWIF(String wif) {
    MessageModel mm=MessageModel();
    final decoded = Uint8List.fromList(fast.Base58Decode(wif));
    if (decoded.length < 37) {
      mm.error=true;
      return mm;
    }

    final payload = decoded.sublist(0, decoded.length - 4);
    final checksum = decoded.sublist(decoded.length - 4);
    final calculatedChecksum = sha256Twice(payload).sublist(0, 4);

    if (!listEquals(checksum, calculatedChecksum)) {
      mm.error=true;
      return mm;
    }

    if (payload[0] != 0x80) {
      mm.error=true;
      return mm;
    }

    final isCompressed = payload.length == 34 && payload.last == 0x01;
    final privateKey = isCompressed ? payload.sublist(1, 33) : payload.sublist(1);
    mm.data=bytesToHex(privateKey);
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
    _keystoreController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_key_wallet_m22,
        //"Import ${widget.model.coin['miniName']} Wallet",
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Text(
                            S.of(context).g_key_209,
                            style: TextStyle(
                                color: AppThemeUtils.getColorByKey(
                                    context, AppThemeKeys.mainTextColor.name),
                                fontWeight: FontWeight.bold,
                                fontSize: ScreenUtil().setSp(32)),
                          ),
                        ),
                        InkWell(
                          onTap: ()async{
                            ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
                            if (!mounted) return;
                            if (data != null) {
                              if (data.text != null && data.text != "null") {
                                _keystoreController.text = data.text!;
                              }
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20.0)),
                            //margin: EdgeInsets.only(left: 10,),
                            height: ScreenUtil().setWidth(60.0),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: AppThemeUtils.getColorByKey(
                                    context, AppThemeKeys.mainBlueColor.name),
                                borderRadius: BorderRadius.all(Radius.circular(ScreenUtil().setWidth(20.0)))
                            ),
                            child: Text(
                              S.of(context).g_key_166,
                              style: TextStyle(
                                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainWhiteColor.name),
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
                      margin: EdgeInsets.symmetric( vertical: ScreenUtil().setWidth(20)),
                      child: CommInput(
                        type: InputFieldType.account,
                        //"Keystore json文件内容"
                        hintText: S.of(context).g_key_209,
                        controller: _keystoreController,
                        maxLines: 30,
                        style: TextStyle(
                          color: AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.ff888888.name),
                          fontSize: ScreenUtil().setSp(26),
                        ),
                      ),
                    ),
                    Text(
                      S.of(context).g_key_17,
                      style: TextStyle(
                          color: AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.mainTextColor.name),
                          fontWeight: FontWeight.bold,
                          fontSize: ScreenUtil().setSp(32)),
                    ),
                    containerStyle1(
                      context,
                      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
                        margin: EdgeInsets.symmetric( vertical: ScreenUtil().setWidth(20)),
                      child: Row(
                        children: [
                          Container(
                            width: ScreenUtil().setWidth(60),
                            height: ScreenUtil().setWidth(60),
                            margin: EdgeInsets.only(right:ScreenUtil().setWidth(20)),
                            child: ImageNetWork(imageUrl: selectChain['baseInfo']['icon']),
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  selectChain['baseInfo']['name'],
                                  style: TextStyle(
                                    fontSize: ScreenUtil().setSp(30),
                                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemTextColor.name),
                                  ),
                                ),
                                Text(
                                  selectChain['baseInfo']['miniName'],
                                  style: TextStyle(
                                    fontSize: ScreenUtil().setSp(30),
                                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemTextColor.name),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: ScreenUtil().setWidth(30),
                            height: ScreenUtil().setWidth(30),
                            margin: EdgeInsets.only(left:ScreenUtil().setWidth(20)),
                            child: Icon(
                              Icons.arrow_forward_ios,
                              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                              size: ScreenUtil().setWidth(30),
                            ),
                          ),
                        ],
                      ),
                      onTap: ()async{
                        Map<String,dynamic>? rData=await Navigator.push(context, MaterialPageRoute(builder: (context)=>ChooseImportCoin(selectChain: selectChain,)));
                        if (!mounted) return;
                        if(rData !=null){
                          setState(() {
                            selectChain=rData;
                          });
                        }
                      }
                    ),
                    if(errorMessage !="")
                      Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
                        margin: EdgeInsets.only(top: ScreenUtil().setWidth(30)),
                        decoration: BoxDecoration(
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.errorBgColor.name),
                          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
                        ),
                        child: Text(
                          errorMessage,
                          style: TextStyle(
                              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.errorTextColor.name),
                              fontSize: ScreenUtil().setSp(26)
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    SizedBox(height: ScreenUtil().setWidth(148),)
                  ],
                ),
              ),),
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
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
                    child: buttonStyle6(
                        context,
                            () async {
                          if(load==Load.loading)return;
                          FocusScope.of(context).requestFocus(FocusNode());
                          // 导入逻辑处理
                          String keystoreJson = _keystoreController.text.trim();

                          if (keystoreJson.isEmpty) {
                            errorMessage=S.of(context).g_key_210;
                            setState(() {});
                            //请输入keystore文件内容
                            ToastUtils.show(errorMessage);
                            return;
                          }
                          MessageModel mm=await checkPraviteKey(keystoreJson);
                          if (!mounted) return;
                          if(mm.error){
                            errorMessage=S.of(this.context).g_key_210;
                            setState(() {});
                            ToastUtils.show(errorMessage);
                            return;
                          }
                          keystoreJson=mm.data;
                          //Uint8List uint8List = Uint8List.fromList(utf8.encode(keystoreJson));
                          //String pk=base64Encode(uint8List);
                          Map<Object?, Object?> rm= await Trustdart().generateAddress(
                            CoinType.N.name,
                            selectChain['baseInfo']['path'][selectChain['addrType']],
                            selectChain['addrType'],
                            mnemonic: "",
                            pk: keystoreJson,
                            isImport: true,
                          );
                          if (!mounted) return;
                          if(rm['legacy']!=""){
                            Uint8List ksjByte=hexToBytes(keystoreJson);
                            String base64Str=base64Encode(ksjByte);
                            WalletInfo? findWalletInfo=ref.read(wapBridgeProvider).findWallet(pk: base64Str);
                            if(findWalletInfo != null){
                              errorMessage=S.of(this.context).g_key_214(findWalletInfo.walletName??"");
                              setState(() {});
                              //The wallet already exists, the wallet name is "Armani"
                              ToastUtils.show(errorMessage);
                              return;
                            }
                            WalletInfo wInfo = WalletInfo(
                                walletName: "",
                                password: "",
                                //path: WalletPath.init(),
                                walletUuid: ref.read(wapBridgeProvider).userUUID,
                                mnemonic: "",
                              privateKey: base64Str,
                              coinInfo: {selectChain['baseInfo']['mKey']:selectChain},
                            );
                            errorMessage="";
                            setState(() {});
                            await Navigator.push(this.context,MaterialPageRoute(
                                builder: (_) => CreatePassword(wInfo, createMetod: "PrivateKey",)));
                            if (!mounted) return;
                            Navigator.of(this.context).pop(true);
                          }else{
                            errorMessage=S.of(this.context).g_key_210;
                            setState(() {});
                            ToastUtils.show(errorMessage);
                          }
                        },
                        S.of(context).g_key_78,
                        AppThemeUtils.getColorByKey(context, load==Load.loading?AppThemeKeys.mainButtonBgColor3.name:AppThemeKeys.mainButtonBgColor.name),
                        AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonTextColor.name),
                        load==Load.loading),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
