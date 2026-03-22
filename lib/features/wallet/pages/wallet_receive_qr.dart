import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/widgets/ens_address_display.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/features/widgets/image_network.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

part 'wallet_receive_qr_content.dart';

// ─── 各链品牌色（keyed by coinType）──────────────────────────────────────────
const Map<String, Color> _kChainColors = {
  'N':     Color(0xFF1E5EFF),
  'ETH':   Color(0xFF627EEA),
  'BTC':   Color(0xFFF7931A),
  'BNB':   Color(0xFFF0B90B),
  'SOL':   Color(0xFF9945FF),
  'ARB':   Color(0xFF28A0F0),
  'OP':    Color(0xFFFF0420),
  'BASE':  Color(0xFF0052FF),
  'AVAX':  Color(0xFFE84142),
  'MATIC': Color(0xFF8247E5),
  'TON':   Color(0xFF0098EA),
  'TRX':   Color(0xFFEF0027),
  'XRP':   Color(0xFF346AA9),
  'ATOM':  Color(0xFF6F6F76),
  'DOT':   Color(0xFFE6007A),
  'FIL':   Color(0xFF0090FF),
  'SUI':   Color(0xFF6FBCF0),
  'APT':   Color(0xFF2DC17B),
  'ALGO':  Color(0xFF1B1B1B),
  'XTZ':   Color(0xFF2C7DF7),
  'LTC':   Color(0xFFA6A9AA),
  'DOGE':  Color(0xFFBA9F33),
  'NEAR':  Color(0xFF3DC28E),
  'ZIL':   Color(0xFF29CCC4),
  'ETC':   Color(0xFF328432),
};

final _amountInputRegex = RegExp(r'^\d*\.?\d*');

// ─── QR 数据 URI 构建（BIP-21 / EIP-681 / Solana Pay 等）──────────────────────
String _buildQrData({
  required String address,
  required String blockchainType,
  required String amount,
}) {
  final trimmed = amount.trim();
  if (trimmed.isEmpty) return address;

  final prefix = switch (blockchainType) {
    'Ethereum'       => 'ethereum:$address?value=',
    'Bitcoin'        => 'bitcoin:$address?amount=',
    'Solana'         => 'solana:$address?amount=',
    'TheOpenNetwork' => 'ton:transfer/$address?amount=',
    'Tron'           => 'tron:$address?amount=',
    'Ripple'         => 'xrpl:$address?amount=',
    'Cosmos'         => 'cosmos:$address?amount=',
    'Near'           => 'near:$address?amount=',
    _                => '$address?amount=',
  };
  return '$prefix$trimmed';
}

// ─── Widget ───────────────────────────────────────────────────────────────────

class WalletReceiveQr extends ConsumerStatefulWidget {
  final CoinModel chainCoinModel;
  final CoinModel? tokenCoinModel;
  const WalletReceiveQr(this.chainCoinModel, {this.tokenCoinModel, super.key});

  @override
  ConsumerState<WalletReceiveQr> createState() => _WalletReceiveQrState();
}

class _WalletReceiveQrState extends ConsumerState<WalletReceiveQr> {
  String symbol = '';
  String logoUrl = '';
  String network = '';
  String address = '';
  String coinType = '';       // 主链 coinType（用于颜色标签）
  String blockchainType = ''; // 主链区块链类型（用于 URI 生成）
  String qrData = '';

  final GlobalKey previewKey = GlobalKey();
  final TextEditingController amountCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initData();
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
    _applyChainData(
      widget.chainCoinModel,
      displayModel: widget.tokenCoinModel ?? widget.chainCoinModel,
    );
  }

  /// 从 CoinModel 提取链和显示数据到字段。
  ///
  /// [chainModel] 用于链级别属性（name/icon/blockchainType/coinType），
  /// [displayModel] 用于显示属性（miniName/address），默认同 chainModel。
  void _applyChainData(CoinModel chainModel, {CoinModel? displayModel}) {
    final dm = displayModel ?? chainModel;
    network = chainModel.coin['name'] ?? '';
    logoUrl = chainModel.coin['icon'] ?? '';
    blockchainType = chainModel.coin['blockchainType'] ?? '';
    // coinType 始终取主链（用于品牌色；token 地址也在同一链上）
    coinType = chainModel.coin['coinType'] ?? '';
    symbol = dm.coin['miniName'] ?? '';
    address = dm.address;
    qrData = address;
  }

  void _onAmountChanged() {
    final newData = _buildQrData(
      address: address,
      blockchainType: blockchainType,
      amount: amountCtrl.text,
    );
    setState(() => qrData = newData);
  }

  /// 切换到另一条链接收
  void _switchChain(CoinModel cm) {
    if (cm.address.isEmpty) return;
    setState(() {
      _applyChainData(cm);
      amountCtrl.clear(); // 不同链单位不同，清空金额
    });
  }

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

  // ─── 截图分享（只截 QR 卡片区）────────────────────────────────────────────

  Future<void> _shareScreenshot() async {
    try {
      final boundary = previewKey.currentContext!.findRenderObject()
          as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final bytes = byteData.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/receive_qr.png')
          .create(recursive: true);
      await file.writeAsBytes(bytes);

      if (!mounted) return;
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'image/png')],
          subject: S.of(context).g_key_156,   // "Scan to copy address"
          text: S.of(context).g_key_179,       // "This is my wallet address"
        ),
      );
    } catch (e) {
      debugPrint('分享失败: $e');
    }
  }

  /// 分享收款链接（地址文本 / payment URI）
  Future<void> shareLink() async {
    // 有金额时分享完整 URI（如 ethereum:0x...?value=0.5）；无金额时仅分享地址
    final shareText = qrData.isNotEmpty ? qrData : address;
    if (!mounted) return;
    await SharePlus.instance.share(
      ShareParams(
        text: shareText,
        subject: '${S.of(context).g_key_33} $symbol',
      ),
    );
  }

  // ─── 链品牌色 ───────────────────────────────────────────────────────────────

  Color get chainColor =>
      _kChainColors[coinType] ?? const Color(0xFF6C7689);

  // ─── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final waValue = ref.watch(wapBridgeProvider);
    final su = ScreenUtil();

    final bgColor = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.backGroundColor.name);
    final mainText = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.mainTextColor.name);
    final blueColor = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.mainBlueColor.name);
    final w40 = su.setWidth(40.0);

    return Scaffold(
      appBar: AppBarWidget(
        text: '${S.of(context).g_key_33}($symbol)',
        actions: [
          InkWell(
            onTap: _shareScreenshot,
            child: Container(
              width: w40,
              height: w40,
              margin: EdgeInsets.symmetric(horizontal: su.setWidth(30.0)),
              child: Icon(Icons.share, size: w40, color: blueColor),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: su.setWidth(24)),
          child: Column(
            children: [
              // ── 链选择器（不进截图）
              buildChainSelector(waValue.coinModels, blueColor, mainText),
              SizedBox(height: su.setWidth(20)),

              // ── QR 卡片
              buildQrCard(
                bgColor: bgColor,
                mainText: mainText,
                blueColor: blueColor,
                chainColor: chainColor,
              ),

              // ── 交互区
              buildInteractionArea(
                mainText: mainText,
                blueColor: blueColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
