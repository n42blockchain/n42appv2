import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/core/enums/load.dart';
import 'package:n42_wallet/features/widgets/login_title.dart';
import 'package:n42_wallet/features/utils/regular.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/eth_api.dart';
import 'package:n42_wallet/features/wallet/pages/add_token/evm_chain_presets.dart';
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
  late final browserController = TextEditingController();
  late final nameNode = FocusNode();
  late final symbolNode = FocusNode();
  late final decimalNode = FocusNode();
  late final chainIdNode = FocusNode();
  late final rpcNode = FocusNode();
  late final browserNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // RPC 填完失焦时自动探测 eth_chainId 回填（仅当 chainId 为空，绝不覆盖
    // 用户已填的值）——减少手抄 chainId 出错；提交时仍有强制交叉校验兜底。
    rpcNode.addListener(_onRpcFocusChanged);
  }

  void _onRpcFocusChanged() {
    if (!rpcNode.hasFocus) _probeChainId();
  }

  bool _probing = false;

  Future<void> _probeChainId() async {
    final rpc = rpcController.text.trim();
    if (_probing ||
        chainIdController.text.trim().isNotEmpty ||
        !rpc.toLowerCase().startsWith('https://')) {
      return;
    }
    _probing = true;
    try {
      final res = await EthAPI.init(
        null,
        rpc,
        null,
      ).baseRPCEth('eth_chainId', [], enableRetry: false);
      final hex = res.valueOrNull?.toString() ?? '';
      final id = hex.startsWith('0x')
          ? int.tryParse(hex.substring(2), radix: 16)
          : int.tryParse(hex);
      if (mounted && id != null && chainIdController.text.trim().isEmpty) {
        setState(() => chainIdController.text = id.toString());
      }
    } catch (_) {
      // 静默：探测只是便利功能，失败不打扰；提交时的校验会给出明确错误。
    } finally {
      _probing = false;
    }
  }

  /// 预设一键填充（仅填表，提交仍走全部校验）。
  void _applyPreset(EvmChainPreset p) {
    setState(() {
      nameController.text = p.name;
      symbolController.text = p.symbol;
      chainIdController.text = p.chainId.toString();
      decimalController.text = p.decimals.toString();
      rpcController.text = p.rpcUrl;
      browserController.text = p.explorerUrl;
      nameErrorMessage = symbolErrorMessage = decimalErrorMessage =
          chainIdErrorMessage = rpcErrorMessage = errorMessage = '';
    });
  }

  String nameErrorMessage = "";
  String symbolErrorMessage = "";
  String decimalErrorMessage = "";
  String chainIdErrorMessage = "";
  String rpcErrorMessage = "";
  String browserErrorMessage = "";
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
    rpcNode.removeListener(_onRpcFocusChanged);
    nameController.dispose();
    symbolController.dispose();
    decimalController.dispose();
    chainIdController.dispose();
    rpcController.dispose();
    browserController.dispose();
    nameNode.dispose();
    symbolNode.dispose();
    decimalNode.dispose();
    chainIdNode.dispose();
    rpcNode.dispose();
    browserNode.dispose();
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
    // 区块浏览器 URL 可选；填了就必须是 https URL。
    final browserStr = browserController.text.trim();
    if (browserStr.isNotEmpty &&
        (!isURL(browserStr) ||
            !browserStr.toLowerCase().startsWith('https://'))) {
      return _setFieldError(
        (v) => browserErrorMessage = v,
        s.g_token_m_key_21,
      );
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
    final browserStr = browserController.text.trim();
    baseInfo
      ..['mKey'] = mKey
      ..['custom'] = true
      ..['coinType'] = mKey
      ..['miniName'] = mKey
      ..['unit'] = mKey
      ..['name'] = name
      ..['decimals'] = decimal
      ..['chainId'] = chainId
      ..['service'] = rpcStr
      // 区块浏览器（EIP-3085 blockExplorerUrls 对应物）：自定义链不在网络层
      // URL 表里，getBrowserAddress 会回退读这里（空则该链无浏览器跳转）。
      ..['browser'] = browserStr.isEmpty
          ? ''
          : (browserStr.endsWith('/') ? browserStr : '$browserStr/');

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
                    // 热门链一键填充（仅填表；提交仍走全部校验）
                    Text(
                      s.g_key_chain_presets,
                      style: AppTypography.caption.copyWith(
                        color: AppColorTokens.of(context).textSubtitle,
                      ),
                    ),
                    SizedBox(height: AppSpacing.space2),
                    SizedBox(
                      height: ScreenUtil().setWidth(64),
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: evmChainPresets.length,
                        separatorBuilder: (_, _) =>
                            SizedBox(width: AppSpacing.space2),
                        itemBuilder: (context, i) {
                          final p = evmChainPresets[i];
                          return Semantics(
                            button: true,
                            label: p.name,
                            child: ActionChip(
                              label: Text(
                                p.name,
                                style: AppTypography.caption.copyWith(
                                  color: AppColorTokens.of(
                                    context,
                                  ).textPrimary,
                                ),
                              ),
                              onPressed: () => _applyPreset(p),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: AppSpacing.space4),
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
                      nextFocus: browserNode,
                      useStyle3: false,
                    ),
                    // 区块浏览器 URL（可选，EIP-3085 blockExplorerUrls）
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LoginTitle(
                          title: s.g_key_block_explorer_optional,
                          must: false,
                        ),
                        SizedBox(height: AppSpacing.space2),
                        textFieldStyle2(
                          context,
                          controller: browserController,
                          focusNode: browserNode,
                          hintText: 'https://…',
                          maxLines: 1,
                          height: ScreenUtil().setWidth(88.0),
                          errorMessage: browserErrorMessage,
                          onEditingComplete: () =>
                              FocusScope.of(context).unfocus(),
                          onChanged: (_) {},
                        ),
                        SizedBox(height: AppSpacing.space4),
                      ],
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
