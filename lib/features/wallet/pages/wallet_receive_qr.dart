import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/features/wallet/models/coin_config_view.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/api/coin_wallet_ops.dart';
import 'package:n42_wallet/features/wallet/utils/decimal_amount.dart';
import 'package:n42_wallet/features/wallet/utils/eip681.dart';
import 'package:n42_wallet/features/wallet/utils/chain_payment_uri.dart';
import 'package:n42_wallet/features/wallet/widgets/ens_address_display.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/features/widgets/image_network.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

part 'wallet_receive_qr_content.dart';

// ─── 各链品牌色（keyed by coinType）──────────────────────────────────────────
const Map<String, Color> _kChainColors = {
  'N': Color(0xFF1E5EFF),
  'ETH': Color(0xFF627EEA),
  'BTC': Color(0xFFF7931A),
  'BNB': Color(0xFFF0B90B),
  'SOL': Color(0xFF9945FF),
  'ARB': Color(0xFF28A0F0),
  'OP': Color(0xFFFF0420),
  'BASE': Color(0xFF0052FF),
  'AVAX': Color(0xFFEF4444),
  'MATIC': Color(0xFF8247E5),
  'TON': Color(0xFF0098EA),
  'TRX': Color(0xFFEF0027),
  'XRP': Color(0xFF346AA9),
  'ATOM': Color(0xFF6B7280),
  'DOT': Color(0xFFE6007A),
  'FIL': Color(0xFF0090FF),
  'SUI': Color(0xFF6FBCF0),
  'APT': Color(0xFF2ECC71),
  'ALGO': Color(0xFF222222),
  'XTZ': Color(0xFF2C7DF7),
  'LTC': Color(0xFF9E9E9E),
  'DOGE': Color(0xFFBA9F33),
  'NEAR': Color(0xFF3DC28E),
  'ZIL': Color(0xFF29CCC4),
  'ETC': Color(0xFF388E3C),
};

final _amountInputRegex = RegExp(r'^\d*\.?\d*');

// ─── QR 数据 URI 构建（BIP-21 / EIP-681 / Solana Pay 等）──────────────────────
String buildReceiveQrData({
  required String address,
  required String blockchainType,
  required String amount,
  String? erc20Contract,
  int erc20Decimals = 18,
  int nativeDecimals = 18,
  int? chainId,
  String chainMKey = '',
  bool isTest = false,
}) {
  final trimmed = amount.trim();
  final contract = erc20Contract?.trim();
  final isToken = contract != null && contract.isNotEmpty;
  final decimals = isToken ? erc20Decimals : nativeDecimals;
  if (address.trim().isEmpty ||
      (trimmed.isNotEmpty && !_isValidReceiveAmount(trimmed, decimals))) {
    return '';
  }

  // EIP-681 carries the EVM chain ID and contract even when amount is open.
  if (blockchainType == 'Ethereum' && chainId != null && chainId > 0) {
    try {
      if (isToken) {
        final units = trimmed.isEmpty
            ? null
            : decimalStringToBigInt(trimmed, decimals).toString();
        return Eip681.buildErc20Transfer(
          token: contract,
          recipient: address,
          amount: units,
          chainId: chainId,
        );
      }
      final units = trimmed.isEmpty
          ? null
          : decimalStringToBigInt(trimmed, decimals).toString();
      return Eip681.buildNative(
        recipient: address,
        chainId: chainId,
        amountWei: units,
      );
    } catch (_) {
      return '';
    }
  }

  final mKey = chainMKey.trim().isEmpty
      ? _canonicalReceiveChainKey(blockchainType)
      : chainMKey.trim();

  // Keep interoperable public URIs when they identify this canonical mainnet
  // asset. Testnets and tokens without a standard token identifier use N42 v1.
  if (!isToken) {
    final query = <String, String>{};
    if (trimmed.isNotEmpty) query['amount'] = trimmed;
    if (blockchainType == 'Bitcoin' && mKey == 'BTC') {
      if (isTest) query['tb'] = address;
      return Uri(
        scheme: 'bitcoin',
        path: isTest ? '' : address,
        queryParameters: query.isEmpty ? null : query,
      ).toString();
    }
    if (!isTest) {
      if (blockchainType == 'TheOpenNetwork' && mKey == 'TON') {
        return _buildReceiveSchemeUri('ton', 'transfer/$address', query);
      }
      if (blockchainType == 'Tron' && mKey == 'TRX') {
        return _buildReceiveSchemeUri('tron', address, query);
      }
      if (blockchainType == 'Ripple' && mKey == 'XRP') {
        return _buildReceiveSchemeUri('xrpl', address, query);
      }
      if (blockchainType == 'Cosmos' && mKey == 'ATOM') {
        return _buildReceiveSchemeUri('cosmos', address, query);
      }
      if (blockchainType == 'Near' && mKey == 'NEAR') {
        return _buildReceiveSchemeUri('near', address, query);
      }
    }
  }

  // Solana Pay identifies SPL tokens by mint and expresses amounts in user
  // units. Its URI does not identify a cluster, so only mainnet uses it.
  if (!isTest && blockchainType == 'Solana' && mKey == 'SOL') {
    final query = <String, String>{};
    if (trimmed.isNotEmpty) query['amount'] = trimmed;
    if (isToken) query['spl-token'] = contract;
    return _buildReceiveSchemeUri('solana', address, query);
  }

  if (mKey.isEmpty) return '';
  try {
    return ChainPaymentUri.encode(
      ChainPaymentRequest(
        chain: mKey,
        network: isTest
            ? ChainPaymentNetwork.testnet
            : ChainPaymentNetwork.mainnet,
        assetType: isToken
            ? ChainPaymentAssetType.token
            : ChainPaymentAssetType.native,
        recipient: address,
        contract: isToken ? contract : null,
        amount: trimmed.isEmpty ? null : trimmed,
      ),
    );
  } on ArgumentError {
    return '';
  }
}

bool _isValidReceiveAmount(String amount, int decimals) {
  if (!RegExp(r'^\d+(?:\.\d+)?$').hasMatch(amount)) return false;
  if (!amount.replaceAll('.', '').contains(RegExp(r'[1-9]'))) return false;
  final decimalPoint = amount.indexOf('.');
  return decimalPoint == -1 || amount.length - decimalPoint - 1 <= decimals;
}

String? receiveQrTokenContract({
  required String mainnetContract,
  required String testnetContract,
  required bool isTest,
}) {
  final contract = (isTest ? testnetContract : mainnetContract).trim();
  return contract.isEmpty ? null : contract;
}

String _canonicalReceiveChainKey(String blockchainType) =>
    switch (blockchainType) {
      'Ethereum' => '', // EVM always needs its configured chain ID or N42 mKey.
      'Bitcoin' => 'BTC',
      'Solana' => 'SOL',
      'TheOpenNetwork' => 'TON',
      'Tron' => 'TRX',
      'Ripple' => 'XRP',
      'Cosmos' => 'ATOM',
      'Near' => 'NEAR',
      _ => '',
    };

String _buildReceiveSchemeUri(
  String scheme,
  String path,
  Map<String, String> parameters,
) => Uri(
  scheme: scheme,
  path: path,
  queryParameters: parameters.isEmpty ? null : parameters,
).toString();

// ─── Widget ───────────────────────────────────────────────────────────────────

class WalletReceiveQr extends ConsumerStatefulWidget {
  final CoinModel chainCoinModel;
  final CoinModel? tokenCoinModel;
  final bool allowChainSelection;
  const WalletReceiveQr(
    this.chainCoinModel, {
    this.tokenCoinModel,
    this.allowChainSelection = true,
    super.key,
  });

  @override
  ConsumerState<WalletReceiveQr> createState() => _WalletReceiveQrState();
}

class _WalletReceiveQrState extends ConsumerState<WalletReceiveQr> {
  String symbol = '';
  String logoUrl = '';
  String network = '';
  String address = '';
  String coinType = ''; // 主链 coinType（用于颜色标签）
  String blockchainType = ''; // 主链区块链类型（用于 URI 生成）
  String qrData = '';

  // 当前选中的链/代币。切链后 chainId/decimals/contract 必须跟着走，
  // 否则金额二维码会带上旧链参数（付款方会付错链/错代币）。
  late CoinModel _selectedChainModel;
  CoinModel? _selectedTokenModel;

  final TextEditingController amountCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initData();
    _hydrateMissingAddress();
    amountCtrl.addListener(_onAmountChanged);
  }

  @override
  void dispose() {
    amountCtrl
      ..removeListener(_onAmountChanged)
      ..dispose();
    super.dispose();
  }

  void _initData() {
    _selectedChainModel = widget.chainCoinModel;
    _selectedTokenModel = widget.tokenCoinModel;
    _applyChainData(
      _selectedChainModel,
      displayModel: _selectedTokenModel ?? _selectedChainModel,
    );
  }

  /// 从 CoinModel 提取链和显示数据到字段。
  ///
  /// [chainModel] 用于链级别属性（name/icon/blockchainType/coinType），
  /// [displayModel] 用于显示属性（miniName/address），默认同 chainModel。
  void _applyChainData(CoinModel chainModel, {CoinModel? displayModel}) {
    final dm = displayModel ?? chainModel;
    network = chainModel.config.name;
    logoUrl = chainModel.config.icon;
    blockchainType = chainModel.config.blockchainType;
    // coinType 始终取主链（用于品牌色；token 地址也在同一链上）
    coinType = chainModel.config.coinType;
    symbol = dm.config.miniName;
    // 代币收款始终使用父链账户地址。token 模型本身可能尚未同步 address，
    // 过去会把空字符串交给二维码组件，结果页面只显示空白。
    // 取址回退链与 _hasAddress 保持一致（address → addressType[addrType]），
    // 否则仅 addressType 有值的链通过筛选后会渲染空地址二维码。
    final chainAddr = _extractAddress(chainModel);
    address = chainAddr.isNotEmpty ? chainAddr : _extractAddress(dm);
    qrData = _buildCurrentQrData();
  }

  static String _extractAddress(CoinModel coin) {
    final direct = coin.address?.toString().trim() ?? '';
    if (direct.isNotEmpty) return direct;
    return coin.addressType[coin.addrType]?.toString().trim() ?? '';
  }

  Future<void> _hydrateMissingAddress() async {
    if (address.isNotEmpty) return;
    try {
      await buildCoinWallet(widget.chainCoinModel, ref.read(wapBridgeProvider));
    } catch (e) {
      debugPrint('WalletReceiveQr: derive address failed: $e');
      return;
    }
    if (!mounted) return;
    // 用户可能已切到别的链，补出来的初始链地址不能覆盖当前选择。
    if (!identical(_selectedChainModel, widget.chainCoinModel)) return;
    setState(() {
      _applyChainData(
        _selectedChainModel,
        displayModel: _selectedTokenModel ?? _selectedChainModel,
      );
    });
  }

  void _onAmountChanged() {
    setState(() => qrData = _buildCurrentQrData());
  }

  String _buildCurrentQrData() {
    final token = _selectedTokenModel;
    final tokenContract = token == null
        ? null
        : receiveQrTokenContract(
            mainnetContract: token.config.contract,
            testnetContract: token.config.contractTest,
            isTest: _selectedChainModel.isTest,
          );
    if (token != null && tokenContract == null) return '';
    return buildReceiveQrData(
      address: address,
      blockchainType: blockchainType,
      amount: amountCtrl.text,
      erc20Contract: tokenContract,
      erc20Decimals: token?.config.decimals ?? 18,
      nativeDecimals: _selectedChainModel.config.decimals,
      chainId: _selectedChainModel.isTest
          ? _selectedChainModel.config.chainIdTest
          : _selectedChainModel.config.chainId,
      chainMKey: _selectedChainModel.config.mKey,
      isTest: _selectedChainModel.isTest,
    );
  }

  /// 切换到另一条链接收
  void _switchChain(CoinModel cm) {
    if (!_hasAddress(cm)) return;
    setState(() {
      _selectedChainModel = cm;
      _selectedTokenModel = null; // 切链后收该链原生币
      _applyChainData(cm);
      amountCtrl.clear(); // 不同链单位不同，清空金额
    });
  }

  static bool _hasAddress(CoinModel coin) =>
      coin.address?.toString().trim().isNotEmpty == true ||
      coin.addressType[coin.addrType]?.toString().trim().isNotEmpty == true;

  // ─── 复制地址 ───────────────────────────────────────────────────────────────

  Future<void> copyAddress() async {
    await Clipboard.setData(ClipboardData(text: address));
    HapticFeedback.lightImpact();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(S.of(context).g_key_119), // "Copy"
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// 分享收款链接（地址文本 / payment URI）
  Future<void> shareLink() async {
    if (qrData.trim().isEmpty) return;

    final amount = amountCtrl.text.trim();
    final s = S.of(context);
    final shareText = [
      '${s.g_key_33} $symbol',
      '${s.g_key_address}: $address',
      if (amount.isNotEmpty) ...[
        s.g_key_receive_request_line(amount, symbol, network),
        '${s.g_key_receive_payment_request}: $qrData',
      ],
    ].join('\n');
    final qrImage = await _buildQrImage(
      title: '${s.g_key_33} $symbol',
      addressLabel: s.g_key_address,
      requestLine: amount.isEmpty
          ? null
          : s.g_key_receive_request_line(amount, symbol, network),
    );
    if (!mounted) return;
    await SharePlus.instance.share(
      ShareParams(
        text: shareText,
        subject: '${S.of(context).g_key_33} $symbol',
        files: [
          XFile.fromData(
            qrImage,
            mimeType: 'image/png',
            name: 'receive_${symbol.toLowerCase()}.png',
          ),
        ],
        fileNameOverrides: ['receive_${symbol.toLowerCase()}.png'],
      ),
    );
  }

  Future<Uint8List> _buildQrImage({
    required String title,
    required String addressLabel,
    String? requestLine,
  }) async {
    const width = 1024;
    const height = 1500;
    const qrAreaSize = 900.0;
    const quietZone = 96.0;
    final painter = QrPainter(
      data: qrData,
      version: QrVersions.auto,
      gapless: true,
    );
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    final bounds = ui.Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble());
    canvas.drawRect(bounds, ui.Paint()..color = Colors.white);
    canvas.save();
    canvas.translate((width - qrAreaSize) / 2 + quietZone, 120 + quietZone);
    painter.paint(
      canvas,
      ui.Size(qrAreaSize - quietZone * 2, qrAreaSize - quietZone * 2),
    );
    canvas.restore();

    var textTop = 40.0;
    void paintText(
      String text, {
      required double fontSize,
      FontWeight fontWeight = FontWeight.normal,
      bool centered = false,
    }) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: Colors.black,
            fontSize: fontSize,
            fontWeight: fontWeight,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: centered ? TextAlign.center : TextAlign.left,
      )..layout(maxWidth: width - 96);
      textPainter.paint(
        canvas,
        Offset(centered ? (width - textPainter.width) / 2 : 48, textTop),
      );
      textTop += textPainter.height + 18;
      textPainter.dispose();
    }

    paintText(title, fontSize: 42, fontWeight: FontWeight.w600, centered: true);
    textTop = 1050;
    paintText(addressLabel, fontSize: 28, fontWeight: FontWeight.w600);
    paintText(address, fontSize: 28);
    if (requestLine != null) paintText(requestLine, fontSize: 26);

    final image = await recorder.endRecording().toImage(width, height);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    if (data == null) throw StateError('Could not encode receive QR image');
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }

  // ─── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final waValue = ref.watch(wapBridgeProvider);
    final bgColor = AppColorTokens.of(context).bgBase;
    final mainText = AppColorTokens.of(context).textPrimary;
    final blueColor = AppColorTokens.of(context).brand;
    return Scaffold(
      appBar: AppBarWidget(
        text: '${S.of(context).g_key_33}($symbol)',
        actions: const [],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.space6),
          child: Column(
            children: [
              if (widget.allowChainSelection) ...[
                // ── 链选择器（不进截图）
                buildChainSelector(waValue.coinModels, blueColor, mainText),
                SizedBox(height: AppSpacing.space6),
              ],

              // ── QR 卡片
              buildQrCard(bgColor: bgColor, mainText: mainText),

              // ── 交互区
              buildInteractionArea(mainText: mainText, blueColor: blueColor),
            ],
          ),
        ),
      ),
    );
  }
}
