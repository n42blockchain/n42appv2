// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:n42_wallet/core/utils/app_logger.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
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

part 'address_book_list_item.dart';

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

class AddressBookList extends StatefulWidget {
  final String coinName;

  const AddressBookList({this.coinName = '', super.key});

  @override
  State<AddressBookList> createState() => _AddressBookListState();
}

class _AddressBookListState extends State<AddressBookList>
    with _AddressBookListItemMixin {
  final _api = AddressBookApi();
  List<AddressBookModel> _allItems = [];
  List<AddressBookModel> _filteredItems = [];
  StreamSubscription? _eventSub;

  final _searchCtrl = TextEditingController();

  @override
  bool get isPickerMode => widget.coinName.isNotEmpty;

  @override
  List<AddressBookModel> get filteredItems => _filteredItems;

  @override
  Future<void> Function(AddressBookModel info) get navigateToEdit =>
      _navigateToEdit;

  @override
  Future<bool> Function(AddressBookModel info) get confirmDelete =>
      _confirmDelete;

  @override
  Future<void> Function(AddressBookModel info) get deleteItem => _deleteItem;

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

  Future<void> _loadData() async {
    try {
      final items = await _api.getAddressBookList(widget.coinName);
      if (!mounted) return;
      setState(() {
        _allItems = items;
        _applyFilter(_searchCtrl.text);
      });
    } catch (e) {
      AppLogger.w('AddressBookList', '_loadData error: $e');
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
        title: Text(S.of(ctx).g_key_113),
        content: SingleChildScrollView(
          child: Text(info.name ?? info.address ?? ''),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(S.of(ctx).g_key_79),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: AppThemeUtils.getColorByKey(
                ctx,
                AppThemeKeys.errorTextColor.name,
              ),
            ),
            child: Text(S.of(ctx).g_key_113),
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
      AppLogger.w('AddressBookList', '_deleteItem error: $e');
    }
    if (mounted) _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final blueColor = AppColorTokens.of(context).brand;
    final mainText = AppColorTokens.of(context).textPrimary;
    final itemBg = AppColorTokens.of(context).bgSurface;

    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_key_108,
        actions: [
          IconButton(
            onPressed: _scanToAdd,
            icon: Icon(Icons.qr_code_scanner_outlined, color: blueColor),
            tooltip: S.of(context).g_key_4,
          ),
          IconButton(
            onPressed: _navigateToAdd,
            icon: Icon(Icons.add_circle_outline, color: blueColor),
            tooltip: S.of(context).g_key_112,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(mainText, blueColor, itemBg),

          Expanded(
            child: _filteredItems.isEmpty
                ? const Center(child: EmptyView())
                : ListView.builder(
                    padding: EdgeInsets.only(bottom: ScreenUtil().setWidth(20)),
                    itemCount: _filteredItems.length,
                    itemBuilder: (ctx, idx) => buildItem(ctx, idx),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(Color mainText, Color blueColor, Color itemBg) {
    final radius = BorderRadius.circular(ScreenUtil().setWidth(50));
    final defaultSide = BorderSide(color: mainText.withValues(alpha: 0.15));
    final fontSize = ScreenUtil().setSp(28);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.space8,
        vertical: AppSpacing.space4,
      ),
      child: TextField(
        controller: _searchCtrl,
        style: TextStyle(color: mainText, fontSize: fontSize),
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.search,
            size: ScreenUtil().setWidth(44),
            color: mainText.withValues(alpha: 0.4),
          ),
          hintText: S.of(context).search,
          hintStyle: TextStyle(
            color: mainText.withValues(alpha: 0.35),
            fontSize: fontSize,
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
            horizontal: AppSpacing.space6,
            vertical: AppSpacing.space4,
          ),
          border: OutlineInputBorder(
            borderRadius: radius,
            borderSide: defaultSide,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: radius,
            borderSide: defaultSide,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: radius,
            borderSide: BorderSide(color: blueColor, width: 1.5),
          ),
          filled: true,
          fillColor: itemBg,
        ),
      ),
    );
  }
}
