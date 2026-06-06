// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

part of 'hardware_wallet_accounts_page.dart';

/// 常用主题色快捷方法
Color _hwSubtitleColor(BuildContext context) =>
    AppColorTokens.of(context).textSubtitle;

Color _hwBlueColor(BuildContext context) => AppColorTokens.of(context).brand;

Color _hwTextColor(BuildContext context) =>
    AppColorTokens.of(context).textPrimary;

/// 未连接状态视图
class _HWNotConnectedView extends StatelessWidget {
  final VoidCallback onGoBack;

  const _HWNotConnectedView({required this.onGoBack});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final subtitle = _hwSubtitleColor(context);
    final su = ScreenUtil();
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bluetooth_disabled,
            size: su.setWidth(80),
            color: subtitle,
          ),
          SizedBox(height: su.setWidth(20)),
          Text(
            s.g_key_hw_not_connected,
            style: TextStyle(fontSize: su.setSp(30), color: subtitle),
          ),
          SizedBox(height: su.setWidth(20)),
          ElevatedButton(onPressed: onGoBack, child: Text(s.g_key_hw_go_back)),
        ],
      ),
    );
  }
}

/// 设备信息卡片
class _HWDeviceInfoCard extends StatelessWidget {
  final HardwareWalletDevice device;

  const _HWDeviceInfoCard({required this.device});

  @override
  Widget build(BuildContext context) {
    final su = ScreenUtil();
    return Container(
      margin: EdgeInsets.all(su.setWidth(30)),
      padding: EdgeInsets.all(su.setWidth(20)),
      decoration: BoxDecoration(
        color: AppColorTokens.of(context).bgSurface,
        borderRadius: BorderRadius.circular(su.setWidth(12)),
      ),
      child: Row(
        children: [
          Container(
            width: su.setWidth(48),
            height: su.setWidth(48),
            decoration: BoxDecoration(
              color: Colors.green.withAlpha(30),
              borderRadius: BorderRadius.circular(su.setWidth(12)),
            ),
            child: Icon(
              Icons.check_circle,
              color: Colors.green,
              size: su.setWidth(28),
            ),
          ),
          SizedBox(width: su.setWidth(16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.name,
                  style: TextStyle(
                    fontSize: su.setSp(28),
                    fontWeight: FontWeight.w600,
                    color: _hwTextColor(context),
                  ),
                ),
                Text(
                  S.of(context).g_key_hw_connected,
                  style: TextStyle(fontSize: su.setSp(24), color: Colors.green),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 币种选择器
class _HWCoinSelector extends StatelessWidget {
  final List<Map<String, String>> coins;
  final String selectedCoinType;
  final ValueChanged<String> onCoinSelected;

  const _HWCoinSelector({
    required this.coins,
    required this.selectedCoinType,
    required this.onCoinSelected,
  });

  @override
  Widget build(BuildContext context) {
    final blueColor = _hwBlueColor(context);
    final textColor = _hwTextColor(context);
    final subtitle = _hwSubtitleColor(context);
    final su = ScreenUtil();

    return Container(
      height: su.setWidth(80),
      margin: EdgeInsets.symmetric(horizontal: su.setWidth(30)),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: coins.length,
        itemBuilder: (context, index) {
          final coin = coins[index];
          final isSelected = coin['symbol'] == selectedCoinType;

          return GestureDetector(
            onTap: () => onCoinSelected(coin['symbol']!),
            child: Container(
              margin: EdgeInsets.only(right: su.setWidth(12)),
              padding: EdgeInsets.symmetric(
                horizontal: su.setWidth(20),
                vertical: su.setWidth(12),
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? blueColor
                    : AppColorTokens.of(context).bgSurface,
                borderRadius: BorderRadius.circular(su.setWidth(20)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    coin['symbol']!,
                    style: TextStyle(
                      fontSize: su.setSp(26),
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : textColor,
                    ),
                  ),
                  SizedBox(width: su.setWidth(8)),
                  Text(
                    coin['name']!,
                    style: TextStyle(
                      fontSize: su.setSp(22),
                      color: isSelected ? Colors.white70 : subtitle,
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
}

/// 加载中视图
class _HWLoadingView extends StatelessWidget {
  const _HWLoadingView();

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final subtitle = _hwSubtitleColor(context);
    final su = ScreenUtil();
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          SizedBox(height: su.setWidth(20)),
          Text(
            s.g_key_hw_loading_accounts,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: su.setSp(26), color: subtitle),
          ),
          SizedBox(height: su.setWidth(8)),
          Text(
            s.g_key_hw_loading_hint,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: su.setSp(22), color: subtitle),
          ),
        ],
      ),
    );
  }
}

/// 空账户视图
class _HWEmptyAccountsView extends StatelessWidget {
  final String appName;
  final VoidCallback onRetry;

  const _HWEmptyAccountsView({required this.appName, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final subtitle = _hwSubtitleColor(context);
    final su = ScreenUtil();
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: su.setWidth(60),
            color: subtitle,
          ),
          SizedBox(height: su.setWidth(16)),
          Text(
            S.of(context).g_key_hw_no_accounts_found,
            style: TextStyle(fontSize: su.setSp(28), color: subtitle),
          ),
          SizedBox(height: su.setWidth(8)),
          Text(
            S.of(context).g_key_hw_open_ledger_app_hint(appName),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: su.setSp(24), color: subtitle),
          ),
          SizedBox(height: su.setWidth(20)),
          ElevatedButton(
            onPressed: onRetry,
            child: Text(S.of(context).g_key_aa_retry),
          ),
        ],
      ),
    );
  }
}

/// 加载更多按钮
class _HWLoadMoreButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onLoadMore;

  const _HWLoadMoreButton({required this.isLoading, required this.onLoadMore});

  @override
  Widget build(BuildContext context) {
    final su = ScreenUtil();
    return Padding(
      padding: EdgeInsets.symmetric(vertical: su.setWidth(16)),
      child: isLoading
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
          : TextButton(
              onPressed: onLoadMore,
              child: Text(
                S.of(context).g_key_hw_load_more,
                style: TextStyle(
                  fontSize: su.setSp(26),
                  color: _hwBlueColor(context),
                ),
              ),
            ),
    );
  }
}

/// 单个账户列表项
class _HWAccountItem extends StatelessWidget {
  final HardwareWalletAccount account;
  final ValueChanged<String> onCopy;
  final ValueChanged<HardwareWalletAccount> onUse;

  const _HWAccountItem({
    required this.account,
    required this.onCopy,
    required this.onUse,
  });

  @override
  Widget build(BuildContext context) {
    final blueColor = _hwBlueColor(context);
    final textColor = _hwTextColor(context);
    final su = ScreenUtil();

    return Container(
      margin: EdgeInsets.only(bottom: su.setWidth(12)),
      padding: EdgeInsets.all(su.setWidth(20)),
      decoration: BoxDecoration(
        color: AppColorTokens.of(context).bgSurface,
        borderRadius: BorderRadius.circular(su.setWidth(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: su.setWidth(40),
                height: su.setWidth(40),
                decoration: BoxDecoration(
                  color: blueColor.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${account.index + 1}',
                    style: TextStyle(
                      fontSize: su.setSp(24),
                      fontWeight: FontWeight.bold,
                      color: blueColor,
                    ),
                  ),
                ),
              ),
              SizedBox(width: su.setWidth(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.displayName,
                      style: TextStyle(
                        fontSize: su.setSp(28),
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    SizedBox(height: su.setWidth(4)),
                    Text(
                      account.derivationPath,
                      style: TextStyle(
                        fontSize: su.setSp(22),
                        color: _hwSubtitleColor(context),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => onCopy(account.address),
                icon: Icon(Icons.copy, color: blueColor, size: su.setWidth(28)),
              ),
              IconButton(
                onPressed: () => onUse(account),
                icon: Icon(
                  Icons.add_circle_outline,
                  color: Colors.green,
                  size: su.setWidth(28),
                ),
              ),
            ],
          ),
          SizedBox(height: su.setWidth(12)),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(su.setWidth(12)),
            decoration: BoxDecoration(
              color: blueColor.withAlpha(10),
              borderRadius: BorderRadius.circular(su.setWidth(8)),
            ),
            child: Text(
              account.address,
              style: TextStyle(
                fontSize: su.setSp(22),
                fontFamily: 'monospace',
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
