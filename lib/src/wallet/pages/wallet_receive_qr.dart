import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/wallet/models/coin_model.dart';
import 'package:n42appv2/src/wallet/widgets/ens_address_display.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:n42appv2/src/widgets/image_network.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

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

// ─── QR 数据 URI 构建（BIP-21 / EIP-681 / Solana Pay 等）──────────────────────
String _buildQrData({
  required String address,
  required String blockchainType,
  required String amount,
}) {
  final trimmed = amount.trim();
  if (trimmed.isEmpty) return address;

  switch (blockchainType) {
    case 'Ethereum':
      // EIP-681: ethereum:<address>?value=<wei_amount>
      return 'ethereum:$address?value=$trimmed';
    case 'Bitcoin':
      // BIP-21: bitcoin:<address>?amount=<btc>
      return 'bitcoin:$address?amount=$trimmed';
    case 'Solana':
      // Solana Pay: solana:<address>?amount=<sol>
      return 'solana:$address?amount=$trimmed';
    case 'TheOpenNetwork':
      return 'ton:transfer/$address?amount=$trimmed';
    case 'Tron':
      return 'tron:$address?amount=$trimmed';
    case 'Ripple':
      return 'xrpl:$address?amount=$trimmed';
    case 'Cosmos':
      return 'cosmos:$address?amount=$trimmed';
    case 'Near':
      return 'near:$address?amount=$trimmed';
    default:
      return '$address?amount=$trimmed';
  }
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
  String _qrData = '';

  final GlobalKey _previewKey = GlobalKey();
  final TextEditingController _amountCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initData();
    _amountCtrl.addListener(_onAmountChanged);
  }

  @override
  void dispose() {
    _amountCtrl
      ..removeListener(_onAmountChanged)
      ..dispose();
    super.dispose();
  }

  void _initData() {
    network = widget.chainCoinModel.coin['name'] ?? '';
    logoUrl = widget.chainCoinModel.coin['icon'] ?? '';
    blockchainType = widget.chainCoinModel.coin['blockchainType'] ?? '';
    // coinType 始终取主链（用于品牌色；token 地址也在同一链上）
    coinType = widget.chainCoinModel.coin['coinType'] ?? '';

    if (widget.tokenCoinModel == null) {
      symbol = widget.chainCoinModel.coin['miniName'] ?? '';
      address = widget.chainCoinModel.address;
    } else {
      symbol = widget.tokenCoinModel!.coin['miniName'] ?? '';
      address = widget.tokenCoinModel!.address;
    }
    _qrData = address;
  }

  void _onAmountChanged() {
    final newData = _buildQrData(
      address: address,
      blockchainType: blockchainType,
      amount: _amountCtrl.text,
    );
    setState(() => _qrData = newData);
  }

  /// 切换到另一条链接收
  void _switchChain(CoinModel cm) {
    if (cm.address.isEmpty) return;
    setState(() {
      network = cm.coin['name'] ?? '';
      logoUrl = cm.coin['icon'] ?? '';
      blockchainType = cm.coin['blockchainType'] ?? '';
      coinType = cm.coin['coinType'] ?? '';
      symbol = cm.coin['miniName'] ?? '';
      address = cm.address;
      _qrData = address;
      _amountCtrl.clear(); // 不同链单位不同，清空金额
    });
  }

  // ─── 复制地址 ───────────────────────────────────────────────────────────────

  Future<void> _copyAddress() async {
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
      final boundary = _previewKey.currentContext!.findRenderObject()
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
  Future<void> _shareLink() async {
    // 有金额时分享完整 URI（如 ethereum:0x...?value=0.5）；无金额时仅分享地址
    final shareText = _qrData.isNotEmpty ? _qrData : address;
    if (!mounted) return;
    await SharePlus.instance.share(
      ShareParams(
        text: shareText,
        subject: '${S.of(context).g_key_33} $symbol',
      ),
    );
  }

  // ─── 链品牌色 ───────────────────────────────────────────────────────────────

  Color get _chainColor =>
      _kChainColors[coinType] ?? const Color(0xFF6C7689);

  // ─── 链选择器（横向滚动 chip 列表）─────────────────────────────────────────

  Widget _buildChainSelector(
      List<CoinModel> chains, Color blueColor, Color mainText) {
    // 过滤掉地址为空的链（通常代表还未初始化）
    final available = chains.where((c) => c.address.isNotEmpty).toList();
    if (available.length <= 1) return const SizedBox.shrink();

    return SizedBox(
      height: ScreenUtil().setWidth(72),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
            horizontal: ScreenUtil().setWidth(40)),
        itemCount: available.length,
        separatorBuilder: (context, index) =>
            SizedBox(width: ScreenUtil().setWidth(12)),
        itemBuilder: (_, i) {
          final cm = available[i];
          final ct = cm.coin['coinType'] as String? ?? '';
          final chipColor = _kChainColors[ct] ?? blueColor;
          final isSelected = ct == coinType;

          return GestureDetector(
            onTap: () => _switchChain(cm),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(20),
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? chipColor.withValues(alpha: 0.12)
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? chipColor
                      : mainText.withValues(alpha: 0.2),
                  width: isSelected ? 1.5 : 1.0,
                ),
                borderRadius:
                    BorderRadius.circular(ScreenUtil().setWidth(36)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ImageNetWork(
                    imageUrl: cm.coin['icon'] ?? '',
                    width: ScreenUtil().setWidth(32),
                    height: ScreenUtil().setWidth(32),
                    placeholder: 'assets/img/list_default.png',
                  ),
                  SizedBox(width: ScreenUtil().setWidth(8)),
                  Text(
                    ct,
                    style: TextStyle(
                      color: isSelected ? chipColor : mainText,
                      fontSize: ScreenUtil().setSp(24),
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final waValue = ref.watch(wapBridgeProvider);

    final bgColor = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.backGroundColor.name);
    final mainText = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.mainTextColor.name);
    final blueColor = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.mainBlueColor.name);
    final chainColor = _chainColor;

    return Scaffold(
      appBar: AppBarWidget(
        text: '${S.of(context).g_key_33}($symbol)',
        actions: [
          InkWell(
            onTap: _shareScreenshot,
            child: Container(
              width: ScreenUtil().setWidth(40.0),
              height: ScreenUtil().setWidth(40.0),
              margin: EdgeInsets.symmetric(
                  horizontal: ScreenUtil().setWidth(30.0)),
              child: Icon(
                Icons.share,
                size: ScreenUtil().setWidth(40.0),
                color: blueColor,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(24)),
          child: Column(
            children: [
              // ── 链选择器（不进截图）──────────────────────────────────────────
              _buildChainSelector(waValue.coinModels, blueColor, mainText),
              SizedBox(height: ScreenUtil().setWidth(20)),

              // ── QR 卡片（RepaintBoundary 仅包裹此区域，用于截图分享）────────
              RepaintBoundary(
                key: _previewKey,
                child: Container(
                  color: bgColor,
                  padding: EdgeInsets.symmetric(
                    horizontal: ScreenUtil().setWidth(40),
                    vertical: ScreenUtil().setWidth(24),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 链图标 + 网络名称
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ImageNetWork(
                            imageUrl: logoUrl,
                            width: ScreenUtil().setWidth(60.0),
                            height: ScreenUtil().setWidth(60.0),
                            placeholder: 'assets/img/list_default.png',
                          ),
                          SizedBox(width: ScreenUtil().setWidth(16)),
                          Text(
                            network,
                            style: TextStyle(
                              color: mainText,
                              fontSize: ScreenUtil().setSp(38.0),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: ScreenUtil().setWidth(16)),

                      // 链品牌色标签（彩色边框胶囊）
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: ScreenUtil().setWidth(28),
                          vertical: ScreenUtil().setWidth(8),
                        ),
                        decoration: BoxDecoration(
                          color: chainColor.withValues(alpha: 0.12),
                          border:
                              Border.all(color: chainColor, width: 1.2),
                          borderRadius: BorderRadius.circular(
                              ScreenUtil().setWidth(40)),
                        ),
                        child: Text(
                          coinType,
                          style: TextStyle(
                            color: chainColor,
                            fontSize: ScreenUtil().setSp(24),
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                      SizedBox(height: ScreenUtil().setWidth(40)),

                      // QR 码（数据随金额实时更新）
                      Container(
                        width: ScreenUtil().setWidth(360.0),
                        height: ScreenUtil().setWidth(360.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            width: 1.0,
                            color: const Color(0xFFE4E4E4),
                          ),
                          borderRadius: BorderRadius.circular(
                              ScreenUtil().setWidth(30.0)),
                        ),
                        child: QrImageView(
                          padding: EdgeInsets.all(
                              ScreenUtil().setWidth(20.0)),
                          data: _qrData,
                          version: QrVersions.auto,
                        ),
                      ),
                      SizedBox(height: ScreenUtil().setWidth(24)),

                      // ENS 名称 + 地址（详细模式，内建复制按钮关闭）
                      EnsAddressDisplay(
                        address: address,
                        coinType: coinType,
                        style: EnsDisplayStyle.detailed,
                        showAvatar: true,
                        showCopy: false, // 使用下方独立复制按钮
                        fontSize: ScreenUtil().setSp(26.0),
                      ),
                      SizedBox(height: ScreenUtil().setWidth(24)),

                      // 警告文本（"只能在同一网络发送…"）
                      Text(
                        S.of(context).g_app_share_key_1,
                        style: TextStyle(
                          color: mainText.withValues(alpha: 0.55),
                          fontSize: ScreenUtil().setSp(24.0),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: ScreenUtil().setWidth(12)),

                      // "扫码收款"
                      Text(
                        S.of(context).g_app_share_key_2,
                        style: TextStyle(
                          color: blueColor,
                          fontSize: ScreenUtil().setSp(28.0),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: ScreenUtil().setWidth(8)),
                    ],
                  ),
                ),
              ),

              // ── 交互区（不包含在截图内）─────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtil().setWidth(60),
                  vertical: ScreenUtil().setWidth(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 显眼的复制地址按钮
                    ElevatedButton.icon(
                      onPressed: _copyAddress,
                      icon: Icon(
                        Icons.copy_outlined,
                        size: ScreenUtil().setWidth(36),
                      ),
                      label: Text(S.of(context).g_key_119), // "Copy"
                      style: ElevatedButton.styleFrom(
                        backgroundColor: blueColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                            vertical: ScreenUtil().setWidth(28)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              ScreenUtil().setWidth(16)),
                        ),
                        textStyle: TextStyle(
                          fontSize: ScreenUtil().setSp(32),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: ScreenUtil().setWidth(20)),

                    // 分享链接按钮（分享地址文本 / payment URI）
                    OutlinedButton.icon(
                      onPressed: _shareLink,
                      icon: Icon(
                        Icons.link_rounded,
                        size: ScreenUtil().setWidth(36),
                      ),
                      label: Text(S.of(context).g_key_share_link),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: blueColor,
                        side: BorderSide(color: blueColor, width: 1.2),
                        padding: EdgeInsets.symmetric(
                            vertical: ScreenUtil().setWidth(28)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              ScreenUtil().setWidth(16)),
                        ),
                        textStyle: TextStyle(
                          fontSize: ScreenUtil().setSp(32),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: ScreenUtil().setWidth(36)),

                    // 金额预填标签
                    Text(
                      '${S.of(context).g_key_44} ($symbol)', // "Amount (SOL)"
                      style: TextStyle(
                        color: mainText,
                        fontSize: ScreenUtil().setSp(28),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: ScreenUtil().setWidth(16)),

                    // 金额输入框（实时刷新 QR）
                    TextField(
                      controller: _amountCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d*')),
                      ],
                      style: TextStyle(
                        color: mainText,
                        fontSize: ScreenUtil().setSp(28),
                      ),
                      decoration: InputDecoration(
                        hintText: '0.0',
                        hintStyle: TextStyle(
                          color: mainText.withValues(alpha: 0.35),
                          fontSize: ScreenUtil().setSp(28),
                        ),
                        suffixIcon: _amountCtrl.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  size: ScreenUtil().setWidth(36),
                                  color: mainText.withValues(alpha: 0.5),
                                ),
                                onPressed: _amountCtrl.clear,
                              )
                            : null,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: ScreenUtil().setWidth(28),
                          vertical: ScreenUtil().setWidth(22),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              ScreenUtil().setWidth(16)),
                          borderSide:
                              const BorderSide(color: Color(0xFFE4E4E4)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              ScreenUtil().setWidth(16)),
                          borderSide:
                              const BorderSide(color: Color(0xFFE4E4E4)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              ScreenUtil().setWidth(16)),
                          borderSide:
                              BorderSide(color: blueColor, width: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
