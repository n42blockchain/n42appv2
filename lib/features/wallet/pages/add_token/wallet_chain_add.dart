import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/core/enums/load.dart';
import 'package:n42_wallet/features/widgets/login_title.dart';
import 'package:n42_wallet/features/utils/regular.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/eth_api.dart';
import 'package:n42_wallet/features/wallet/utils/chain/chain_url_registry.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/features/widgets/dialog_widget/tips_dialog_2.dart';
import 'package:n42_wallet/features/widgets/text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider, Consumer;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:validators/validators.dart';
import 'package:n42_wallet/generated/l10n.dart';

class WalletChainAdd extends ConsumerStatefulWidget {
  const WalletChainAdd({super.key});

  @override
  ConsumerState<WalletChainAdd> createState() => _WalletChainAddState();
}

class _WalletChainAddState extends ConsumerState<WalletChainAdd> {
  late final nameController = TextEditingController();
  late final symbolController = TextEditingController();
  late final decimalController = TextEditingController();
  late final chainIdController = TextEditingController();
  late final rpcController = TextEditingController();
  late final nameNode = FocusNode();
  late final symbolNode = FocusNode();
  late final decimalNode = FocusNode();
  late final chainIdNode = FocusNode();
  late final rpcNode = FocusNode();

  String nameErrorMessage = "";
  String symbolErrorMessage = "";
  String decimalErrorMessage = "";
  String chainIdErrorMessage = "";
  String rpcErrorMessage = "";
  String errorMessage = "";
  Load load = Load.finish;

  final Map<String, dynamic> ethMap = {
    "showList": true,
    "isTest": false,
    "supportTest": true,
    "addrType": "legacy",
    "pathIndex": 0,
    "pathList": [0],
    "baseInfo": {
      "mKey": "ETH",
      "blockchainType": BlockchainType.Ethereum.name,
      "coinType": CoinType.ETH.name,
      "icon": "",
      "name": "Ethereum",
      "miniName": "ETH",
      "unit": "ETH",
      "decimals": 18,
      "balance": "0",
      "balance_test": "0",
      "coinPrice": 0.0,
      "percentage": 0.0,
      "isContract": false,
      "path": {"legacy": "m/44'/60'/0'/0/0"},
      "service": "",
      "service_test": "",
      "chainId": 1,
      "chainId_test": 3,
      "contract": "",
      "contract_test": "",
      "canEdit": true,
      "rules": "ERC20",
    },
    "mainnetChainID": 1,
    "testnetChainID": 3,
    "testnetIndex": 0,
    "testnets": [
      {
        "testnetWS": "",
        "testnetRPC": "",
        "testnetChainID": 3,
        "testnetContract": {},
      },
    ],
    "mainnets": {},
  };

  @override
  void dispose() {
    nameController.dispose();
    symbolController.dispose();
    decimalController.dispose();
    chainIdController.dispose();
    rpcController.dispose();
    nameNode.dispose();
    symbolNode.dispose();
    decimalNode.dispose();
    chainIdNode.dispose();
    rpcNode.dispose();
    super.dispose();
  }

  /// Sets a field error and returns false (for early-return validation).
  bool _setFieldError(void Function(String) setter, String msg) {
    setState(() => setter(msg));
    return false;
  }

  bool _validateInputs(
    String name,
    String mKey,
    String chainIdStr,
    String decimalStr,
    String rpcStr,
  ) {
    final reg = Regular();
    final s = S.of(context);

    if (name.isEmpty || name.length > 30) {
      return _setFieldError((v) => nameErrorMessage = v, s.g_token_m_key_1(30));
    }
    if (mKey.isEmpty || mKey.length > 10) {
      return _setFieldError(
        (v) => symbolErrorMessage = v,
        s.g_token_m_key_1(10),
      );
    }
    if (!reg.regularNums(chainIdStr) ||
        chainIdStr.length > 10 ||
        int.parse(chainIdStr) <= 0) {
      return _setFieldError((v) => chainIdErrorMessage = v, s.g_token_m_key_21);
    }
    if (!reg.regularNums(decimalStr)) {
      return _setFieldError((v) => decimalErrorMessage = v, s.g_token_m_key_21);
    }
    final decimal = int.parse(decimalStr);
    if (decimal < 0 || decimal > 18) {
      return _setFieldError((v) => decimalErrorMessage = v, s.g_token_m_key_2);
    }
    // 强制 https：http 明文 RPC 会让余额/nonce/gas 查询与已签名交易广播全程
    // 可被 MITM 篡改（配合假余额诱导或替换广播目标网络）。
    if (!isURL(rpcStr) || !rpcStr.toLowerCase().startsWith('https://')) {
      return _setFieldError((v) => rpcErrorMessage = v, s.g_token_m_key_21);
    }
    return true;
  }

  /// 已存在任一 EVM 链（内建或自定义）使用相同 chainId？用于阻止创建与内建
  /// 链 chainId 冲突的并行自定义链（nonce/转账语义混乱 + 重放风险）。仅比对
  /// EVM(Ethereum) 类型，避免与非 EVM 链的小整数 chainId 误撞。
  bool _chainIdExists(int chainId) {
    for (final entry in allChainUrlMap.values) {
      if (entry is! Map) continue;
      final base = entry['baseInfo'];
      if (base is! Map) continue;
      if (base['blockchainType'] != BlockchainType.Ethereum.name) continue;
      final cid = base['chainId'];
      if (cid is int && cid == chainId) return true;
      if (cid is String && int.tryParse(cid) == chainId) return true;
    }
    return false;
  }

  Future<void> addChain() async {
    final mKey = symbolController.text.toUpperCase();
    final chainIdStr = chainIdController.text;
    final name = nameController.text.toUpperCase();
    final decimalStr = decimalController.text;
    final rpcStr = rpcController.text;

    if (!_validateInputs(name, mKey, chainIdStr, decimalStr, rpcStr)) return;

    final chainId = int.parse(chainIdStr);
    final decimal = int.parse(decimalStr);

    if (allChainUrlMap[mKey] != null) {
      errorMessage = S.of(context).g_token_m_key_22(name);
      final r = await tipsDialog2(
        context,
        S.of(context).g_token_m_key_23(name),
      );
      if (!mounted) return;
      if (r == true) {
        await ref.read(wapBridgeProvider).addWalletChain(allChainUrlMap[mKey]);
        if (!mounted) return;
        Navigator.pop(context, true);
      }
      return;
    }
    // 按 chainId 判重：symbol 判重（上方 allChainUrlMap[mKey]）挡不住"换个
    // symbol、chainId 撞内建链"的并行链。
    if (_chainIdExists(chainId)) {
      setState(() {
        chainIdErrorMessage = S.of(context).g_token_m_key_chainid_conflict;
      });
      return;
    }
    errorMessage = "";

    setState(() => load = Load.loading);
    // RPC 探活。
    final rmm = await EthAPI.init(null, rpcStr, null).getGasPrice();
    if (!mounted) return;
    if (rmm.error) {
      setState(() {
        errorMessage = S
            .of(context)
            .g_token_m_key_24(S.of(context).g_token_m_key_17);
        load = Load.finish;
      });
      ToastUtils.show(errorMessage);
      return;
    }

    // chainId 交叉校验：向 RPC 查 eth_chainId，必须与用户填写的 chainId 一致。
    // 否则攻击者可诱导用户把恶意 RPC 绑到主网 chainId——余额走恶意 RPC 显示
    // 假数据，签名却用主网 chainId、签出的交易可被重放到真主网。
    final cidRes = await EthAPI.init(null, rpcStr, null).baseRPCEth(
      'eth_chainId',
      [],
      enableRetry: false,
    );
    if (!mounted) return;
    final reportedHex = cidRes.valueOrNull?.toString() ?? '';
    final reportedChainId = reportedHex.startsWith('0x')
        ? int.tryParse(reportedHex.substring(2), radix: 16)
        : int.tryParse(reportedHex);
    if (cidRes.isFailure || reportedChainId == null) {
      setState(() {
        errorMessage = S
            .of(context)
            .g_token_m_key_24(S.of(context).g_token_m_key_17);
        load = Load.finish;
      });
      ToastUtils.show(errorMessage);
      return;
    }
    if (reportedChainId != chainId) {
      setState(() {
        chainIdErrorMessage =
            S.of(context).g_token_m_key_chainid_mismatch(reportedChainId);
        load = Load.finish;
      });
      return;
    }

    final baseInfo = ethMap['baseInfo'] as Map<String, dynamic>;
    baseInfo
      ..['mKey'] = mKey
      ..['custom'] = true
      ..['coinType'] = mKey
      ..['miniName'] = mKey
      ..['unit'] = mKey
      ..['name'] = name
      ..['decimals'] = decimal
      ..['chainId'] = chainId
      ..['service'] = rpcStr;

    await ref.read(wapBridgeProvider).addWalletChain(ethMap);
    if (!mounted) return;
    setState(() => load = Load.finish);
    Navigator.pop(context, true);
  }

  Widget _buildField({
    required String title,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    required String errorMsg,
    required FocusNode? nextFocus,
    int? maxLengths,
    bool useStyle3 = true,
  }) {
    final h = ScreenUtil().setWidth(useStyle3 ? 120.0 : 88.0);
    void onComplete() {
      if (nextFocus != null) {
        FocusScope.of(context).requestFocus(nextFocus);
      } else {
        FocusScope.of(context).unfocus();
      }
    }

    final field = useStyle3
        ? textFieldStyle3(
            context,
            controller: controller,
            focusNode: focusNode,
            hintText: hintText,
            maxLines: 1,
            maxLengths: maxLengths ?? 30,
            height: h,
            errorMessage: errorMsg,
            onEditingComplete: onComplete,
            onChanged: (_) {},
          )
        : textFieldStyle2(
            context,
            controller: controller,
            focusNode: focusNode,
            hintText: hintText,
            maxLines: 1,
            height: h,
            errorMessage: errorMsg,
            onEditingComplete: onComplete,
            onChanged: (_) {},
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LoginTitle(title: title, must: true),
        SizedBox(height: AppSpacing.space2),
        field,
        SizedBox(height: AppSpacing.space4),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final bgColor = AppColorTokens.of(context).bgBase;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBarWidget(text: s.g_token_m_key_19),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppSpacing.space8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildField(
                      title: s.g_token_m_key_13,
                      controller: nameController,
                      focusNode: nameNode,
                      hintText: s.g_token_m_key_1(30),
                      errorMsg: nameErrorMessage,
                      nextFocus: symbolNode,
                      maxLengths: 30,
                    ),
                    _buildField(
                      title: s.g_token_m_key_14,
                      controller: symbolController,
                      focusNode: symbolNode,
                      hintText: s.g_token_m_key_1(10),
                      errorMsg: symbolErrorMessage,
                      nextFocus: chainIdNode,
                      maxLengths: 10,
                    ),
                    _buildField(
                      title: s.g_token_m_key_15,
                      controller: chainIdController,
                      focusNode: chainIdNode,
                      hintText: s.g_token_m_key_15,
                      errorMsg: chainIdErrorMessage,
                      nextFocus: decimalNode,
                      maxLengths: 10,
                    ),
                    _buildField(
                      title: s.g_token_m_key_16,
                      controller: decimalController,
                      focusNode: decimalNode,
                      hintText: s.g_token_m_key_2,
                      errorMsg: decimalErrorMessage,
                      nextFocus: rpcNode,
                      useStyle3: false,
                    ),
                    _buildField(
                      title: s.g_token_m_key_17,
                      controller: rpcController,
                      focusNode: rpcNode,
                      hintText: s.g_token_m_key_17,
                      errorMsg: rpcErrorMessage,
                      nextFocus: null,
                      useStyle3: false,
                    ),
                    SizedBox(height: AppSpacing.space2),
                    if (errorMessage.isNotEmpty)
                      Container(
                        padding: EdgeInsets.all(AppSpacing.space8),
                        alignment: Alignment.center,
                        color: AppColorTokens.of(context).dangerBg,
                        child: Text(
                          errorMessage,
                          style: AppTypography.body.copyWith(
                            color: AppColorTokens.of(context).danger,
                          ),
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
              child: Container(
                color: bgColor,
                child: Column(
                  children: [
                    Divider(
                      height: ScreenUtil().setWidth(1),
                      endIndent: 0,
                      indent: 0,
                    ),
                    Container(
                      margin: EdgeInsets.all(AppSpacing.space8),
                      height: ScreenUtil().setWidth(88),
                      child: AppButton(label: s.g_key_159, onPressed: addChain),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
