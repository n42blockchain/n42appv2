// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/core/utils/event_bus.dart';
import 'package:n42_wallet/features/component/pages/scan_page.dart';
import 'package:n42_wallet/features/wallet/api/address_book_api.dart';
import 'package:n42_wallet/features/wallet/models/address_book_model.dart';
import 'package:n42_wallet/features/wallet/pages/address_book/add_address_page.dart';
import 'package:n42_wallet/features/wallet/pages/address_book/edit_address_page.dart';
import 'package:n42_wallet/features/wallet/widgets/ens_address_display.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/features/widgets/empty.dart';
import 'package:n42_wallet/features/widgets/image_network.dart';

// ─── 联系人头像色盘（基于姓名首字符确定性哈希）────────────────────────────
const List<Color> _kAvatarColors = [
  Color(0xFF5B86E5),
  Color(0xFF36D1C4),
  Color(0xFFFF7B54),
  Color(0xFFF9A825),
  Color(0xFF7E57C2),
  Color(0xFF26A69A),
  Color(0xFFEF5350),
  Color(0xFF42A5F5),
];

Color _avatarColor(String? name) {
  if (name == null || name.isEmpty) return _kAvatarColors[0];
  return _kAvatarColors[name.codeUnitAt(0) % _kAvatarColors.length];
}

/// 从 QR 字符串中提取地址部分
///
/// 支持格式：
///   - 纯地址: `0xABC…` / `So1Abc…`
///   - EIP-681: `ethereum:0xABC…?value=1.0`
///   - BIP-21:  `bitcoin:1BvBM…?amount=0.5`
///   - TON:     `ton:transfer/EQ…?amount=5`
String _parseAddressFromQr(String qrData) {
  final colonIdx = qrData.indexOf(':');
  if (colonIdx < 0) return qrData.trim();

  var rest = qrData.substring(colonIdx + 1);
  // TON: ton:transfer/<address>
  if (rest.startsWith('transfer/')) {
    rest = rest.substring('transfer/'.length);
  }
  // 去掉查询参数
  final questionIdx = rest.indexOf('?');
  if (questionIdx >= 0) rest = rest.substring(0, questionIdx);
  return rest.trim();
}

// ─── Widget ───────────────────────────────────────────────────────────────────

class AddressBookList extends StatefulWidget {
  /// 非空时：只显示对应链的地址，点击直接返回选中地址（选择器模式）
  final String coinName;

  const AddressBookList({this.coinName = '', super.key});

  @override
  State<AddressBookList> createState() => _AddressBookListState();
}

class _AddressBookListState extends State<AddressBookList> {
  // ─── 数据 ────────────────────────────────────────────────────────────────
  final _api = AddressBookApi();
  List<AddressBookModel> _allItems = [];
  List<AddressBookModel> _filteredItems = [];
  StreamSubscription? _eventSub;

  // ─── 搜索 ────────────────────────────────────────────────────────────────
  final _searchCtrl = TextEditingController();

  // ─── 选择器模式（从发送页调起，点击直接返回地址） ────────────────────────
  bool get _isPickerMode => widget.coinName.isNotEmpty;

  // ─── 生命周期 ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _eventSub = eventBus.on().listen((event) {
      if (event is EventPublic && event.type == EventPublicType.refreshData) {
        if (mounted) _loadData();
      }
    });
    _searchCtrl.addListener(() {
      if (mounted) setState(() => _applyFilter(_searchCtrl.text));
    });
    _loadData();
  }

  @override
  void dispose() {
    _eventSub?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ─── 数据 ─────────────────────────────────────────────────────────────────

  Future<void> _loadData() async {
    try {
      final items = await _api.getAddressBookList(widget.coinName);
      if (!mounted) return;
      setState(() {
        _allItems = items;
        _applyFilter(_searchCtrl.text);
      });
    } catch (e) {
      debugPrint('AddressBookList._loadData error: $e');
    }
  }

  void _applyFilter(String query) {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) {
      _filteredItems = List.of(_allItems);
      return;
    }
    _filteredItems = _allItems.where((item) {
      return (item.name?.toLowerCase().contains(q) ?? false) ||
          (item.desc?.toLowerCase().contains(q) ?? false) ||
          (item.address?.toLowerCase().contains(q) ?? false) ||
          (item.coinName?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  // ─── 操作 ─────────────────────────────────────────────────────────────────

  Future<void> _scanToAdd() async {
    final qrData = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => ScanPage()),
    );
    if (!mounted || qrData == null) return;
    final address = _parseAddressFromQr(qrData);
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddAddressPage(initialAddress: address),
      ),
    );
    if (mounted) _loadData();
  }

  Future<void> _navigateToAdd() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddAddressPage()),
    );
    if (mounted) _loadData();
  }

  Future<void> _navigateToEdit(AddressBookModel info) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditAddressPage(info: info)),
    );
    if (mounted) _loadData();
  }

  Future<bool> _confirmDelete(AddressBookModel info) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.of(ctx).g_key_113), // "Delete"
        content: Text(info.name ?? info.address ?? ''),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(S.of(ctx).g_key_79), // "Cancel"
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: AppThemeUtils.getColorByKey(
                  ctx, AppThemeKeys.errorTextColor.name),
            ),
            child: Text(S.of(ctx).g_key_113), // "Delete"
          ),
        ],
      ),
    );
    return confirm == true;
  }

  Future<void> _deleteItem(AddressBookModel info) async {
    try {
      await _api.deleteAddressBookItem(info);
      HapticFeedback.lightImpact();
    } catch (e) {
      debugPrint('AddressBookList._deleteItem error: $e');
    }
    if (mounted) _loadData();
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final blueColor =
        AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name);
    final mainText =
        AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name);
    final itemBg =
        AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name);

    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_key_108, // "Address Book"
        actions: [
          // 扫码添加联系人
          IconButton(
            onPressed: _scanToAdd,
            icon: Icon(
              Icons.qr_code_scanner_outlined,
              color: blueColor,
            ),
            tooltip: S.of(context).g_key_4, // "Scan QR code"
          ),
          // 手动新建联系人
          IconButton(
            onPressed: _navigateToAdd,
            icon: Icon(
              Icons.add_circle_outline,
              color: blueColor,
            ),
            tooltip: S.of(context).g_key_112, // "New address"
          ),
        ],
      ),
      body: Column(
        children: [
          // ── 搜索栏 ──────────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ScreenUtil().setWidth(30),
              vertical: ScreenUtil().setWidth(16),
            ),
            child: TextField(
              controller: _searchCtrl,
              style: TextStyle(
                color: mainText,
                fontSize: ScreenUtil().setSp(28),
              ),
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.search,
                  size: ScreenUtil().setWidth(44),
                  color: mainText.withValues(alpha: 0.4),
                ),
                hintText: S.of(context).search, // "Search"
                hintStyle: TextStyle(
                  color: mainText.withValues(alpha: 0.35),
                  fontSize: ScreenUtil().setSp(28),
                ),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          size: ScreenUtil().setWidth(36),
                          color: mainText.withValues(alpha: 0.4),
                        ),
                        onPressed: _searchCtrl.clear,
                      )
                    : null,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: ScreenUtil().setWidth(24),
                  vertical: ScreenUtil().setWidth(18),
                ),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(ScreenUtil().setWidth(50)),
                  borderSide:
                      BorderSide(color: mainText.withValues(alpha: 0.15)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(ScreenUtil().setWidth(50)),
                  borderSide:
                      BorderSide(color: mainText.withValues(alpha: 0.15)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(ScreenUtil().setWidth(50)),
                  borderSide: BorderSide(color: blueColor, width: 1.5),
                ),
                filled: true,
                fillColor: itemBg,
              ),
            ),
          ),

          // ── 联系人列表 ──────────────────────────────────────────────────
          Expanded(
            child: _filteredItems.isEmpty
                ? const Center(child: EmptyView())
                : ListView.builder(
                    padding:
                        EdgeInsets.only(bottom: ScreenUtil().setWidth(20)),
                    itemCount: _filteredItems.length,
                    itemBuilder: (ctx, idx) => _buildItem(ctx, idx),
                  ),
          ),
        ],
      ),
    );
  }

  // ─── 列表项 ───────────────────────────────────────────────────────────────

  Widget _buildItem(BuildContext context, int index) {
    final info = _filteredItems[index];
    final content = _buildItemContent(context, info);

    // 选择器模式：点击返回地址，不提供滑动删除
    if (_isPickerMode) {
      return GestureDetector(
        onTap: () => Navigator.pop(context, info.address),
        child: content,
      );
    }

    // 普通模式：点击进入编辑页，支持左滑删除
    return Dismissible(
      key: ValueKey(info.id ?? '${info.address}_$index'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(info),
      onDismissed: (_) => _deleteItem(info),
      background: Container(
        alignment: Alignment.centerRight,
        color: AppThemeUtils.getColorByKey(
            context, AppThemeKeys.errorTextColor.name),
        padding: EdgeInsets.only(right: ScreenUtil().setWidth(48)),
        child: Icon(
          Icons.delete_outline,
          color: Colors.white,
          size: ScreenUtil().setWidth(52),
        ),
      ),
      child: GestureDetector(
        onTap: () => _navigateToEdit(info),
        child: content,
      ),
    );
  }

  Widget _buildItemContent(BuildContext context, AddressBookModel info) {
    final mainText =
        AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name);
    final subtitleText = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.itemSubtitleTextColor.name);
    final itemBg =
        AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name);
    final mutedText =
        AppThemeUtils.getColorByKey(context, AppThemeKeys.ff888888.name);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(30),
        vertical: ScreenUtil().setWidth(8),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(30),
        vertical: ScreenUtil().setWidth(20),
      ),
      decoration: BoxDecoration(
        color: itemBg,
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
      ),
      child: Row(
        children: [
          // ── 联系人头像（首字母圆形 + 链图标徽章）
          _buildAvatar(info),
          SizedBox(width: ScreenUtil().setWidth(20)),

          // ── 信息区
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 姓名 + 链名胶囊标签
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        info.name ?? '',
                        style: TextStyle(
                          color: mainText,
                          fontSize: ScreenUtil().setSp(30),
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: ScreenUtil().setWidth(12)),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: ScreenUtil().setWidth(14),
                        vertical: ScreenUtil().setWidth(4),
                      ),
                      decoration: BoxDecoration(
                        color: subtitleText.withValues(alpha: 0.1),
                        borderRadius:
                            BorderRadius.circular(ScreenUtil().setWidth(20)),
                      ),
                      child: Text(
                        info.coinName ?? '',
                        style: TextStyle(
                          color: subtitleText,
                          fontSize: ScreenUtil().setSp(20),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: ScreenUtil().setWidth(8)),

                // 地址（支持 ENS 解析显示）
                EnsAddressText(
                  address: info.address ?? '',
                  coinType: info.coinName ?? 'ETH',
                  style: TextStyle(
                    color: subtitleText,
                    fontSize: ScreenUtil().setSp(24),
                  ),
                ),

                // 备注（可选）
                if (info.desc != null && info.desc!.isNotEmpty) ...[
                  SizedBox(height: ScreenUtil().setWidth(6)),
                  Text(
                    info.desc!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: mutedText,
                      fontSize: ScreenUtil().setSp(24),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // 右箭头（仅普通模式显示）
          if (!_isPickerMode)
            Icon(
              Icons.chevron_right,
              size: ScreenUtil().setWidth(40),
              color: subtitleText,
            ),
        ],
      ),
    );
  }

  // ─── 联系人头像：首字母彩色圆形 + 链图标小徽章 ────────────────────────────

  Widget _buildAvatar(AddressBookModel info) {
    final name = info.name ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final bgColor = _avatarColor(name);
    final avatarSize = ScreenUtil().setWidth(72);
    final badgeSize = ScreenUtil().setWidth(26);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // 彩色圆形 + 首字母
        Container(
          width: avatarSize,
          height: avatarSize,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            initial,
            style: TextStyle(
              color: Colors.white,
              fontSize: ScreenUtil().setSp(30),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        // 链图标小徽章（右下角）
        Positioned(
          right: -ScreenUtil().setWidth(4),
          bottom: -ScreenUtil().setWidth(4),
          child: Container(
            width: badgeSize,
            height: badgeSize,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            padding: const EdgeInsets.all(1.5),
            child: ClipOval(
              child: info.coinName == CoinType.N.name
                  ? Image.asset('assets/img/ast.png', fit: BoxFit.cover)
                  : ImageNetWork(
                      imageUrl: info.coinIcon ?? '',
                      placeholder: 'assets/img/list_default.png',
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
