// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/features/wallet/pages/ens/ens_purchase_page.dart';
import 'package:n42_wallet/features/wallet/services/ens_registration_service.dart';
import 'package:n42_wallet/features/wallet/utils/feature_address_utils.dart';
import 'package:n42_wallet/features/wallet/widgets/ens/ens_search_bar.dart';
import 'package:n42_wallet/features/wallet/widgets/ens/ens_search_result_view.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';

/// ENS 搜索页面
///
/// 搜索 ENS 名称可用性并显示价格信息
class EnsSearchPage extends StatefulWidget {
  /// 当前钱包地址
  final String walletAddress;

  const EnsSearchPage({super.key, required this.walletAddress});

  @override
  State<EnsSearchPage> createState() => _EnsSearchPageState();
}

class _EnsSearchPageState extends State<EnsSearchPage> {
  final EnsRegistrationService _ensService =
      EnsRegistrationServiceProvider.instance;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  Timer? _debounceTimer;
  String _searchQuery = '';
  EnsAvailabilityResult? _availabilityResult;
  EnsPrice? _priceInfo;
  bool _isSearching = false;
  bool _isLoadingPrice = false;
  int _selectedYears = 1;
  int _priceLoadVersion = 0;

  bool get _hasWalletAddress =>
      FeatureAddressUtils.isValidEvmAddress(widget.walletAddress);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (value.isNotEmpty && value.length >= 3) {
        _performSearch(value);
      } else {
        setState(() {
          _availabilityResult = null;
          _priceInfo = null;
          _searchQuery = value;
        });
      }
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _isSearching = true;
      _searchQuery = query;
      _availabilityResult = null;
      _priceInfo = null;
    });
    try {
      final result = await _ensService.checkAvailability(query);

      if (mounted && _searchQuery == query) {
        setState(() {
          _isSearching = false;
          _availabilityResult = result;
        });

        if (result.isAvailable) _loadPrice(query);
      }
    } catch (_) {
      if (mounted && _searchQuery == query) {
        setState(() => _isSearching = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).g_key_error_14),
            backgroundColor: AppColorTokens.of(context).danger,
          ),
        );
      }
    }
  }

  Future<void> _loadPrice(String name) async {
    final loadVersion = ++_priceLoadVersion;
    setState(() => _isLoadingPrice = true);
    try {
      final result = await _ensService.getPrice(name, _selectedYears);

      if (mounted && _searchQuery == name && loadVersion == _priceLoadVersion) {
        setState(() {
          _isLoadingPrice = false;
          if (!result.error) {
            _priceInfo = result.data;
          }
        });
      }
    } catch (_) {
      if (mounted && _searchQuery == name && loadVersion == _priceLoadVersion) {
        setState(() => _isLoadingPrice = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).g_key_error_14),
            backgroundColor: AppColorTokens.of(context).danger,
          ),
        );
      }
    }
  }

  void _onYearsChanged(int years) {
    setState(() => _selectedYears = years);
    if (_availabilityResult?.isAvailable == true) {
      unawaited(_loadPrice(_searchQuery));
    }
  }

  void _onSuggestionTap(String name) {
    _searchController.text = name;
    _onSearchChanged(name);
  }

  void _navigateToPurchase() {
    if (_availabilityResult?.isAvailable != true || _priceInfo == null) return;
    if (!_hasWalletAddress) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).g_key_bridge_chain_not_supported)),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EnsPurchasePage(
          name: _searchQuery,
          walletAddress: widget.walletAddress,
          years: _selectedYears,
          price: _priceInfo!,
        ),
      ),
    ).then((result) {
      if (result == true && mounted) {
        Navigator.pop(context, true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(text: S.of(context).g_key_ens_search_title),
      body: Column(
        children: [
          EnsSearchBar(
            controller: _searchController,
            focusNode: _searchFocusNode,
            onChanged: _onSearchChanged,
            searchQuery: _searchQuery,
            ensService: _ensService,
          ),
          Expanded(
            child: EnsSearchResultView(
              searchQuery: _searchQuery,
              isSearching: _isSearching,
              isLoadingPrice: _isLoadingPrice,
              availabilityResult: _availabilityResult,
              priceInfo: _priceInfo,
              selectedYears: _selectedYears,
              onYearsChanged: _onYearsChanged,
              onSuggestionTap: _onSuggestionTap,
              onRetry: () => _performSearch(_searchQuery),
              onRegisterTap: _priceInfo != null && _hasWalletAddress
                  ? _navigateToPurchase
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
