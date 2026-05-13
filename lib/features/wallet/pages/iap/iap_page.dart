import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:n42_wallet/core/utils/app_logger.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';

/// App Store / Google Play 内购商品 ID，按需在 App Store Connect 中配置
const Set<String> _kProductIds = {
  'ai.n42.www.n.4',
  'ai.n42.www.n.10',
  'ai.n42.www.n.20',
  'ai.n42.www.n.55',
  'ai.n42.www.n.120',
  'ai.n42.www.n.280',
  'ai.n42.www.n.700',
  'ai.n42.www.n.1600'
};

class IapPage extends StatefulWidget {
  const IapPage({super.key});

  @override
  State<IapPage> createState() => _IapPageState();
}

class _IapPageState extends State<IapPage> {
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _sub;

  bool _available = false;
  bool _loading = true;
  List<ProductDetails> _products = [];
  final Set<String> _pending = {};

  @override
  void initState() {
    super.initState();
    _sub = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onError: (_) {},
    );
    _init();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _init() async {
    final available = await _iap.isAvailable();
    if (!mounted) return;
    if (!available) {
      setState(() {
        _available = false;
        _loading = false;
      });
      return;
    }
    setState(() => _available = true);
    await _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() => _loading = true);
    final response = await _iap.queryProductDetails(_kProductIds);
    AppLogger.w('IAP', 'product not found: $response');
    if (!mounted) return;
    setState(() {
      _products = response.productDetails
        ..sort((a, b) => a.rawPrice.compareTo(b.rawPrice));
      _loading = false;
    });
    if (response.notFoundIDs.isNotEmpty) {
      AppLogger.w('IAP', 'product not found: ${response.notFoundIDs}');
    }
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchases) {
    for (final p in purchases) {
      if (p.status == PurchaseStatus.pending) {
        // do nothing
      } else if (p.status == PurchaseStatus.purchased ||
          p.status == PurchaseStatus.restored) {
        _iap.completePurchase(p);
        if (mounted) {
          ToastUtils.show(p.status == PurchaseStatus.restored
              ? S.of(context).g_iap_restored(p.productID)
              : S.of(context).g_iap_purchased(p.productID));
        }
      } else if (p.status == PurchaseStatus.error) {
        if (mounted) ToastUtils.showError(S.of(context).g_iap_failed(p.error?.message ?? ''));
      } else if (p.status == PurchaseStatus.canceled) {
        if (mounted) ToastUtils.show(S.of(context).g_iap_cancelled);
      }
      if (mounted) {
        setState(() => _pending.remove(p.productID));
      }
    }
  }

  Future<void> _buy(ProductDetails product) async {
    if (_pending.contains(product.id)) return;
    setState(() => _pending.add(product.id));
    final param = PurchaseParam(productDetails: product);
    // 消耗型商品用 buyConsumable，非消耗型用 buyNonConsumable
    await _iap.buyConsumable(purchaseParam: param);
  }

  Future<void> _restore() async {
    await _iap.restorePurchases();
    if (mounted) ToastUtils.show(S.of(context).g_iap_restoring);
  }

  /// 下拉刷新：不触发全屏 loading，由 RefreshIndicator 自身管理指示器
  Future<void> _refresh() async {
    final available = await _iap.isAvailable();
    if (!mounted) return;
    setState(() => _available = available);
    if (!available) return;
    final response = await _iap.queryProductDetails(_kProductIds);
    if (!mounted) return;
    setState(() {
      _products = response.productDetails
        ..sort((a, b) => a.rawPrice.compareTo(b.rawPrice));
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = AppThemeUtils.getColorByKey(
      context,
      AppThemeKeys.backGroundColor.name,
    );
    final textPrimary = AppThemeUtils.getColorByKey(
      context,
      AppThemeKeys.mainTextColor.name,
    );
    final textSecondary = AppThemeUtils.getColorByKey(
      context,
      AppThemeKeys.mainTextColor3.name,
    );

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBarWidget(
        text: S.of(context).g_iap_title,
        actions: [
          if (Platform.isIOS || Platform.isMacOS)
            TextButton(
              onPressed: _restore,
              child: Text(
                S.of(context).g_iap_restore,
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.mainButtonBgColor.name,
                  ),
                  fontSize: ScreenUtil().setSp(26),
                ),
              ),
            ),
        ],
      ),
      body: _buildBody(isDark, textPrimary, textSecondary),
    );
  }

  Widget _buildBody(bool isDark, Color textPrimary, Color textSecondary) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final Widget scrollable;
    if (!_available) {
      scrollable = LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: constraints.maxHeight,
            child: _buildUnavailable(textPrimary, textSecondary),
          ),
        ),
      );
    } else if (_products.isEmpty) {
      scrollable = LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: constraints.maxHeight,
            child: _buildEmpty(textSecondary),
          ),
        ),
      );
    } else {
      scrollable = ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: ScreenUtil().setWidth(32),
          vertical: ScreenUtil().setWidth(24),
        ),
        itemCount: _products.length,
        separatorBuilder: (context, index) => SizedBox(height: ScreenUtil().setWidth(20)),
        itemBuilder: (context, index) => _buildProductCard(
          _products[index],
          isDark,
          textPrimary,
          textSecondary,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      backgroundColor: AppThemeUtils.getColorByKey(
        context,
        AppThemeKeys.mainButtonBgColor.name,
      ),
      color: AppThemeUtils.getColorByKey(
        context,
        AppThemeKeys.mainButtonTextColor.name,
      ),
      child: scrollable,
    );
  }

  Widget _buildUnavailable(Color textPrimary, Color textSecondary) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(ScreenUtil().setWidth(60)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.store_outlined,
              size: ScreenUtil().setWidth(120),
              color: textSecondary,
            ),
            SizedBox(height: ScreenUtil().setWidth(24)),
            Text(
              S.of(context).g_iap_store_unavailable,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(30),
                color: textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: ScreenUtil().setWidth(12)),
            Text(
              S.of(context).g_iap_check_network,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(24),
                color: textSecondary,
              ),
            ),
            SizedBox(height: ScreenUtil().setWidth(40)),
            _RetryButton(onTap: _init),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(Color textSecondary) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(ScreenUtil().setWidth(60)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: ScreenUtil().setWidth(120),
              color: textSecondary,
            ),
            SizedBox(height: ScreenUtil().setWidth(24)),
            Text(
              S.of(context).g_iap_no_products,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(30),
                color: textSecondary,
              ),
            ),
            SizedBox(height: ScreenUtil().setWidth(40)),
            _RetryButton(onTap: _fetchProducts),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(
    ProductDetails product,
    bool isDark,
    Color textPrimary,
    Color textSecondary,
  ) {
    final isPending = _pending.contains(product.id);
    final cardBg = isDark
        ? const Color(0xFF1A2236)
        : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.grey.withValues(alpha: 0.15);

    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(32)),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // 商品图标
          Container(
            width: ScreenUtil().setWidth(80),
            height: ScreenUtil().setWidth(80),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF7B1FA2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
            ),
            child: Icon(
              Icons.diamond_outlined,
              color: Colors.white,
              size: ScreenUtil().setWidth(44),
            ),
          ),
          SizedBox(width: ScreenUtil().setWidth(24)),
          // 商品信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(28),
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (product.description.isNotEmpty) ...[
                  SizedBox(height: ScreenUtil().setWidth(6)),
                  Text(
                    product.description,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(22),
                      color: textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: ScreenUtil().setWidth(16)),
          // 价格 + 购买
          GestureDetector(
            onTap: isPending ? null : () => _buy(product),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(24),
                vertical: ScreenUtil().setWidth(14),
              ),
              decoration: BoxDecoration(
                gradient: isPending
                    ? null
                    : const LinearGradient(
                        colors: [Color(0xFF1565C0), Color(0xFF7B1FA2)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                color: isPending ? Colors.grey.withValues(alpha: 0.3) : null,
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(14)),
              ),
              child: isPending
                  ? SizedBox(
                      width: ScreenUtil().setWidth(36),
                      height: ScreenUtil().setWidth(36),
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          product.price,
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(24),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          S.of(context).g_iap_title,
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(20),
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RetryButton extends StatelessWidget {
  final VoidCallback onTap;
  const _RetryButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ScreenUtil().setWidth(60),
          vertical: ScreenUtil().setWidth(22),
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1565C0), Color(0xFF7B1FA2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
        ),
        child: Text(
          S.of(context).g_iap_retry,
          style: TextStyle(
            color: Colors.white,
            fontSize: ScreenUtil().setSp(26),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
