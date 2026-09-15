import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web3dart/web3dart.dart' as web3;

import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/wallet/models/coin_config_view.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_manage/keystore/keystore_export_utils.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';

/// 支持主动消息签名的非 EVM 链（CoinType 名）。
/// EVM 走 web3dart 的 personal_sign(EIP-191 前缀，与 DApp/WalletConnect 一致)；
/// 这几条非 EVM 链走原生 `trustdart.signMessage`，与 WalletConnect 已验证路径同源。
/// 其它链的“消息签名”语义不标准，暂不放开以免产生易被误用的原始签名。
const Set<String> kMsgSignNonEvmCoins = {'TRX', 'APT', 'SUI', 'SOL'};

/// 当前 [model] 对应的链是否支持主动消息签名。入口与页面都用它做门禁。
bool messageSignSupported(CoinModel model) {
  if (model.config.blockchainType == BlockchainType.Ethereum.name) return true;
  return kMsgSignNonEvmCoins.contains(model.config.coinType);
}

/// 主动消息签名工具页：用户输入任意消息 → 用当前账户当前链的私钥签名 →
/// 展示并复制签名结果。区别于 DApp/WalletConnect 的被动弹窗签名。
class MessageSignPage extends StatefulWidget {
  final WalletInfo walletInfo;
  final CoinModel model;

  /// 已经拼好 account index 的派生路径（`getPathWithIndex` 的结果）。
  final String path;
  final String? mnemonic;
  final String? pk;

  const MessageSignPage({
    required this.walletInfo,
    required this.model,
    required this.path,
    this.mnemonic,
    this.pk,
    super.key,
  });

  @override
  State<MessageSignPage> createState() => _MessageSignPageState();
}

class _MessageSignPageState extends State<MessageSignPage> {
  final TextEditingController _controller = TextEditingController();
  String? _signature;
  bool _signing = false;

  Color _c(AppThemeKeys key) => AppThemeUtils.getColorByKey(context, key.name);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _isHex(String s) =>
      s.isNotEmpty && s.length.isEven && RegExp(r'^[0-9a-fA-F]+$').hasMatch(s);

  /// 解出 EVM 签名所需的 [web3.EthPrivateKey]：助记词钱包从助记词派生，
  /// 私钥导入钱包直接用其 base64 私钥。
  Future<web3.EthPrivateKey> _resolveEthKey(String coinType) async {
    final mn = widget.mnemonic ?? '';
    if (mn.isNotEmpty) {
      final b64 = await Trustdart().getPrivateKey(mn, coinType, widget.path);
      return web3.EthPrivateKey.fromHex(decodeExportablePrivateKey(b64));
    }
    final pkB64 = widget.pk ?? '';
    return web3.EthPrivateKey.fromHex(web3.bytesToHex(base64Decode(pkB64)));
  }

  Future<void> _onSign() async {
    final msg = _controller.text.trim();
    if (msg.isEmpty) {
      ToastUtils.show(S.of(context).g_key_msgsign_empty);
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _signing = true);
    try {
      final coinType = widget.model.config.coinType;
      final isEvm =
          widget.model.config.blockchainType == BlockchainType.Ethereum.name;
      String sig;
      if (isEvm) {
        final key = await _resolveEthKey(coinType);
        // DApp 惯例：消息可能是 0x 十六进制字节，也可能是纯 UTF-8 文本。
        final stripped = web3.strip0x(msg);
        final bytes = _isHex(stripped)
            ? web3.hexToBytes(stripped)
            : Uint8List.fromList(utf8.encode(msg));
        sig = web3.bytesToHex(
          key.signPersonalMessageToUint8List(bytes),
          include0x: true,
        );
      } else if (kMsgSignNonEvmCoins.contains(coinType)) {
        sig = await Trustdart().signMessage(
          coinType,
          widget.path,
          msg,
          mnemonic: widget.mnemonic ?? '',
          pk: widget.pk ?? '',
        );
        if (sig.isEmpty) throw Exception('empty signature');
      } else {
        if (!mounted) return;
        ToastUtils.show(S.of(context).g_key_msgsign_unsupported);
        return;
      }
      if (!mounted) return;
      setState(() => _signature = sig);
    } catch (_) {
      if (!mounted) return;
      ToastUtils.show(S.of(context).g_key_msgsign_failed);
    } finally {
      if (mounted) setState(() => _signing = false);
    }
  }

  Future<void> _copySignature() async {
    final sig = _signature;
    if (sig == null) return;
    await Clipboard.setData(ClipboardData(text: sig));
    if (!mounted) return;
    ToastUtils.show(S.of(context).copy);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(text: S.of(context).g_key_msgsign_title),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _accountCard(),
              SizedBox(height: AppSpacing.space16),
              _messageField(),
              SizedBox(height: AppSpacing.space12),
              _warningBanner(),
              SizedBox(height: AppSpacing.space16),
              _signButton(),
              if (_signature != null) ...[
                SizedBox(height: AppSpacing.space16),
                _resultCard(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _accountCard() {
    final addr = widget.model.address ?? '';
    final shortAddr = addr.length > 16
        ? '${addr.substring(0, 8)}…${addr.substring(addr.length - 6)}'
        : addr;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.space12),
      decoration: BoxDecoration(
        color: _c(AppThemeKeys.itemBgColor),
        borderRadius: AppRadius.brMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  widget.walletInfo.walletName ?? '',
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyStrong.copyWith(
                    color: _c(AppThemeKeys.mainTextColor),
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.space6),
              Text(
                '· ${widget.model.config.name}',
                style: AppTypography.body.copyWith(
                  color: _c(AppThemeKeys.mainTextColor4),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.space4),
          Text(
            shortAddr,
            style: AppTypography.bodySm.copyWith(
              color: _c(AppThemeKeys.mainTextColor4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _messageField() {
    return Container(
      decoration: BoxDecoration(
        color: _c(AppThemeKeys.itemBgColor),
        borderRadius: AppRadius.brMd,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.space12,
        vertical: AppSpacing.space8,
      ),
      child: TextField(
        controller: _controller,
        maxLines: 6,
        minLines: 4,
        style: AppTypography.body.copyWith(
          color: _c(AppThemeKeys.mainTextColor),
        ),
        decoration: InputDecoration(
          isCollapsed: true,
          border: InputBorder.none,
          hintText: S.of(context).g_key_msgsign_input_hint,
          hintStyle: AppTypography.body.copyWith(
            color: _c(AppThemeKeys.mainTextColor4),
          ),
        ),
      ),
    );
  }

  Widget _warningBanner() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.space12),
      decoration: BoxDecoration(
        color: _c(AppThemeKeys.errorBgColor),
        borderRadius: AppRadius.brMd,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 20,
            color: _c(AppThemeKeys.textColorOrange),
          ),
          SizedBox(width: AppSpacing.space8),
          Expanded(
            child: Text(
              S.of(context).g_key_msgsign_warning,
              style: AppTypography.bodySm.copyWith(
                color: _c(AppThemeKeys.textColorOrange),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _signButton() {
    return SizedBox(
      width: double.infinity,
      child: AppButton(
        label: S.of(context).g_key_msgsign_btn,
        loading: _signing,
        onPressed: _onSign,
      ),
    );
  }

  Widget _resultCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.space12),
      decoration: BoxDecoration(
        color: _c(AppThemeKeys.itemBgColor),
        borderRadius: AppRadius.brMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                S.of(context).g_key_msgsign_result,
                style: AppTypography.headline.copyWith(
                  color: _c(AppThemeKeys.mainTextColor),
                ),
              ),
              InkWell(
                onTap: _copySignature,
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.space4),
                  child: Icon(
                    Icons.copy_rounded,
                    size: 20,
                    color: _c(AppThemeKeys.mainBlueColor),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.space6),
          SelectableText(
            _signature ?? '',
            style: AppTypography.bodySm.copyWith(
              color: _c(AppThemeKeys.mainTextColor4),
            ),
          ),
        ],
      ),
    );
  }
}
