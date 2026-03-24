part of 'ens_home_page.dart';

/// Business logic mixin for [_EnsHomePageState].
///
/// Declares all shared state fields and contains data loading
/// and navigation methods.
mixin _EnsHomeLogicMixin on State<EnsHomePage> {
  final EnsRegistrationService ensService =
      EnsRegistrationServiceProvider.instance;

  List<OwnedEns> ownedNames = [];
  List<OwnedEns> allOwnedNames = [];
  bool isLoading = true;
  String? errorMessage;
  int _loadVersion = 0;

  // 当前选择的链，默认 Ethereum
  EnsChainConfig selectedChain = EnsChainConfig.defaultChain;

  bool get _hasWalletAddress =>
      FeatureAddressUtils.isValidEvmAddress(widget.walletAddress);

  void _showUnsupportedSnack() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(S.of(context).g_key_bridge_chain_not_supported)),
    );
  }

  Future<void> loadOwnedNames() async {
    if (!mounted) return;
    final loadVersion = ++_loadVersion;
    if (!_hasWalletAddress) {
      setState(() {
        isLoading = false;
        errorMessage = null;
        ownedNames = const [];
        allOwnedNames = const [];
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final result = await ensService.getOwnedNames(widget.walletAddress);

    if (mounted && loadVersion == _loadVersion) {
      setState(() {
        isLoading = false;
        if (!result.error && result.data != null) {
          allOwnedNames = List<OwnedEns>.from(result.data! as List<OwnedEns>);
          ownedNames = filterOwnedEnsByChain(allOwnedNames, selectedChain);
        } else {
          ownedNames = filterOwnedEnsByChain(allOwnedNames, selectedChain);
          errorMessage = _shouldShowOwnedNamesError
              ? S.of(context).g_key_5
              : null;
        }
      });
    }
  }

  bool get _shouldShowOwnedNamesError =>
      selectedChain.id == EnsChainConfig.defaultChain.id &&
      allOwnedNames.isEmpty;

  void selectChain(EnsChainConfig chain) {
    if (selectedChain.id == chain.id) return;

    setState(() {
      selectedChain = chain;
      errorMessage = null;
      ownedNames = filterOwnedEnsByChain(allOwnedNames, selectedChain);
    });

    if (_hasWalletAddress && allOwnedNames.isEmpty) {
      loadOwnedNames();
    }
  }

  void navigateToSearch() {
    if (!_hasWalletAddress) {
      _showUnsupportedSnack();
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EnsSearchPage(walletAddress: widget.walletAddress),
      ),
    ).then((_) {
      if (!mounted) return;
      loadOwnedNames();
    });
  }

  void navigateToManagement(OwnedEns ens) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EnsManagementPage(
          ownedEns: ens,
          walletAddress: widget.walletAddress,
        ),
      ),
    ).then((_) {
      if (!mounted) return;
      loadOwnedNames();
    });
  }
}
