import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/features/wallet/api/dex_swap_api.dart';
import 'package:n42_wallet/features/wallet/models/dex/dex_limit_order_model.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';

/// 限价单列表页面
class DexLimitOrdersPage extends StatefulWidget {
  const DexLimitOrdersPage({super.key});

  @override
  State<DexLimitOrdersPage> createState() => _DexLimitOrdersPageState();
}

class _DexLimitOrdersPageState extends State<DexLimitOrdersPage> {
  final DexSwapApi _api = DexSwapApi();
  List<DexLimitOrderModel> _orders = [];
  bool _loading = true;
  final Set<String> _cancelling = {};

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _loading = true);
    final result = await _api.getLimitOrders(AppGlobals.userInfo?.uuid ?? '');
    if (!mounted) return;

    if (!result.error && result.data is List) {
      _orders = (result.data as List)
          .map((e) => DexLimitOrderModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    setState(() => _loading = false);
  }

  Future<void> _cancelOrder(DexLimitOrderModel order) async {
    if (_cancelling.contains(order.orderId)) return;
    setState(() => _cancelling.add(order.orderId));

    final result = await _api.cancelLimitOrder(
      order.orderId,
      AppGlobals.userInfo?.uuid ?? '',
    );
    if (!mounted) return;

    setState(() => _cancelling.remove(order.orderId));

    if (!result.error) {
      _loadOrders();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Order cancelled')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.data?.toString() ?? 'Cancel failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(text: 'Limit Orders'),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
          ? Center(
              child: Text(
                'No limit orders',
                style: TextStyle(
                  color: AppColorTokens.of(context).textSubtitle,
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadOrders,
              child: ListView.separated(
                padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
                itemCount: _orders.length,
                separatorBuilder: (_, _) =>
                    SizedBox(height: ScreenUtil().setWidth(12)),
                itemBuilder: (context, index) =>
                    _buildOrderCard(_orders[index]),
              ),
            ),
    );
  }

  Widget _buildOrderCard(DexLimitOrderModel order) {
    final textColor = AppColorTokens.of(context).textPrimary;
    final subColor = AppColorTokens.of(context).textSubtitle;
    final blueColor = AppColorTokens.of(context).brand;

    final statusColor = switch (order.status) {
      0 => blueColor,
      1 => Colors.orange,
      2 => const Color(0xFF4CAF50),
      3 => Colors.grey,
      4 => Colors.grey,
      _ => Colors.grey,
    };

    final expiryDate = DateTime.fromMillisecondsSinceEpoch(
      order.expiresAt * 1000,
    );
    final createdDate = DateTime.fromMillisecondsSinceEpoch(
      order.createdAt * 1000,
    );

    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
      decoration: BoxDecoration(
        color: AppColorTokens.of(context).bgSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: pair + status
          Row(
            children: [
              Text(
                '${order.symbolIn} → ${order.symbolOut}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  order.statusLabel,
                  style: TextStyle(
                    fontSize: 12,
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: ScreenUtil().setWidth(10)),

          // Details
          _detailRow(
            'Amount',
            '${order.amountIn} ${order.symbolIn}',
            textColor,
            subColor,
          ),
          _detailRow(
            'Limit Price',
            '${order.limitPrice} ${order.symbolOut}/${order.symbolIn}',
            textColor,
            subColor,
          ),
          _detailRow('Chain', order.chain, textColor, subColor),
          _detailRow('Created', _formatDate(createdDate), textColor, subColor),
          if (order.isActive)
            _detailRow('Expires', _formatDate(expiryDate), textColor, subColor),
          if (order.txHash.isNotEmpty)
            _detailRow(
              'Tx',
              '${order.txHash.substring(0, 10)}...',
              textColor,
              subColor,
            ),

          // Cancel button for active orders
          if (order.isActive) ...[
            SizedBox(height: ScreenUtil().setWidth(12)),
            SizedBox(
              width: double.infinity,
              height: 36,
              child: OutlinedButton(
                onPressed: _cancelling.contains(order.orderId)
                    ? null
                    : () => _cancelOrder(order),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _cancelling.contains(order.orderId)
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Cancel Order',
                        style: TextStyle(fontSize: 13),
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _detailRow(
    String label,
    String value,
    Color textColor,
    Color subColor,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: ScreenUtil().setWidth(4)),
      child: Row(
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: subColor)),
          const Spacer(),
          Text(value, style: TextStyle(fontSize: 12, color: textColor)),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.month}/${dt.day} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
