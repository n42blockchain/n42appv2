import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n42_wallet/core/providers/core_providers.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/features/wallet/api/dex_swap_api.dart';
import 'package:n42_wallet/features/wallet/models/dex/dex_limit_order_model.dart';
import 'package:n42_wallet/features/wallet/pages/dex_swap/dex_swap_home.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';

/// 限价单列表页面
class DexLimitOrdersPage extends ConsumerWidget {
  final DexSwapApi? api;
  const DexLimitOrdersPage({super.key, this.api});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentUserProvider)?.uuid ?? '';
    return _LimitOrdersView(key: ValueKey(userId), userId: userId, api: api);
  }
}

class _LimitOrdersView extends StatefulWidget {
  final String userId;
  final DexSwapApi? api;
  const _LimitOrdersView({super.key, required this.userId, this.api});
  @override
  State<_LimitOrdersView> createState() => _DexLimitOrdersPageState();
}

class _DexLimitOrdersPageState extends State<_LimitOrdersView> {
  late final DexSwapApi _api = widget.api ?? DexSwapApi();
  int _generation = 0;
  String? _error;
  List<DexLimitOrderModel> _orders = [];
  bool _loading = true;
  final Set<String> _cancelling = {};

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final generation = ++_generation;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (widget.userId.isEmpty) {
        _orders = [];
        return;
      }
      final result = await _api.getLimitOrders(widget.userId);
      if (!mounted || generation != _generation) return;
      if (result.error || result.data is! List) throw StateError('Load failed');
      final orders = (result.data as List)
          .map((e) => DexLimitOrderModel.fromJson(e as Map<String, dynamic>))
          .toList();
      setState(() => _orders = orders);
    } catch (_) {
      if (mounted && generation == _generation) {
        setState(() => _error = S.of(context).g_ui_orders_load_failed);
      }
    } finally {
      if (mounted && generation == _generation) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _cancelOrder(DexLimitOrderModel order) async {
    if (_cancelling.contains(order.orderId) || widget.userId.isEmpty) return;
    setState(() => _cancelling.add(order.orderId));
    try {
      final result = await _api.cancelLimitOrder(order.orderId, widget.userId);
      if (!mounted) return;
      if (result.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.data?.toString() ?? S.of(context).g_ui_order_cancel_failed,
            ),
          ),
        );
      } else {
        await _loadOrders();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).g_ui_order_cancelled)),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).g_ui_order_cancel_failed)),
        );
      }
    } finally {
      if (mounted) setState(() => _cancelling.remove(order.orderId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(text: S.of(context).g_ui_limit_orders),
      body: RefreshIndicator(
        onRefresh: _loadOrders,
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(AppSpacing.space6),
          itemCount: _loading || _error != null || _orders.isEmpty
              ? 1
              : _orders.length,
          separatorBuilder: (_, _) => SizedBox(height: AppSpacing.space4),
          itemBuilder: (context, index) {
            if (_loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (_error != null) {
              return Column(
                children: [
                  Text(_error!),
                  TextButton(
                    onPressed: _loadOrders,
                    child: Text(S.of(context).g_key_retry),
                  ),
                ],
              );
            }
            if (_orders.isEmpty) {
              return Center(child: Text(S.of(context).g_ui_no_limit_orders));
            }
            return _buildOrderCard(_orders[index]);
          },
        ),
      ),
    );
  }

  Widget _buildOrderCard(DexLimitOrderModel order) {
    final textColor = AppColorTokens.of(context).textPrimary;
    final subColor = AppColorTokens.of(context).textSubtitle;
    final c = AppColorTokens.of(context);
    final blueColor = c.brand;

    final statusColor = switch (order.status) {
      0 => blueColor,
      1 => c.warning,
      2 => c.success,
      3 => c.textTertiary,
      4 => c.textTertiary,
      _ => c.textTertiary,
    };

    final expiryDate = DateTime.fromMillisecondsSinceEpoch(
      order.expiresAt * 1000,
    );
    final createdDate = DateTime.fromMillisecondsSinceEpoch(
      order.createdAt * 1000,
    );

    return Container(
      padding: EdgeInsets.all(AppSpacing.space4),
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
              Expanded(
                child: Text(
                  '${order.symbolIn} → ${order.symbolOut}',
                  style: AppTypography.headline.copyWith(
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  switch (order.status) {
                    0 => S.of(context).g_key_airdrop_active,
                    1 => S.of(context).g_ui_order_triggered,
                    2 => S.of(context).g_ui_order_executed,
                    3 => S.of(context).g_iap_cancelled,
                    4 => S.of(context).g_key_ens_expired,
                    _ => S.of(context).g_ui_unknown_status,
                  },
                  style: AppTypography.caption.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.space2),

          // Details
          _detailRow(
            S.of(context).g_key_44,
            '${order.amountIn} ${order.symbolIn}',
            textColor,
            subColor,
          ),
          _detailRow(
            S.of(context).g_ui_limit_price,
            '${order.limitPrice} ${order.symbolOut}/${order.symbolIn}',
            textColor,
            subColor,
          ),
          _detailRow(
            S.of(context).g_key_dex_chain,
            order.chain,
            textColor,
            subColor,
          ),
          _detailRow(
            S.of(context).g_key_aa_created,
            _formatDate(createdDate),
            textColor,
            subColor,
          ),
          if (order.isActive)
            _detailRow(
              S.of(context).g_key_ens_expires,
              _formatDate(expiryDate),
              textColor,
              subColor,
            ),
          if (order.txHash.isNotEmpty)
            _detailRow(
              'Tx',
              order.txHash.length > 10
                  ? '${order.txHash.substring(0, 10)}...'
                  : order.txHash,
              textColor,
              subColor,
            ),

          // Cancel button for active orders
          if (order.isActive) ...[
            SizedBox(height: AppSpacing.space4),
            SizedBox(
              width: double.infinity,
              height: 36,
              child: OutlinedButton(
                onPressed: _cancelling.contains(order.orderId)
                    ? null
                    : () => _cancelOrder(order),
                style: OutlinedButton.styleFrom(
                  foregroundColor: c.danger,
                  side: BorderSide(color: c.danger),
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
                    : Text(
                        S.of(context).g_ui_cancel_order,
                        style: AppTypography.caption.copyWith(
                          fontWeight: FontWeight.w400,
                        ),
                      ),
              ),
            ),
          ],

          // 到价订单:提供手动兑换入口(接线复审第二轮 P1——此前 triggered 只
          // 显示状态标签、无任何执行路径,与通知"open the app to swap"不符)。
          // 非托管钱包无自动成交,跳转 Swap 页由用户手动完成。
          if (order.isTriggered) ...[
            SizedBox(height: AppSpacing.space4),
            SizedBox(
              width: double.infinity,
              height: 36,
              child: OutlinedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DexSwapHome()),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: c.brand,
                  side: BorderSide(color: c.brand),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  S.of(context).g_key_stake_go_to_swap,
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w400,
                  ),
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
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: subColor,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTypography.caption.copyWith(
                color: textColor,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.month}/${dt.day} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
