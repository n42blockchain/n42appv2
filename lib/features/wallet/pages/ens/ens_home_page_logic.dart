part of 'ens_home_page.dart';

/// Business logic mixin for [_EnsHomePageState].
///
/// Declares all shared state fields and contains data loading
/// and navigation methods.
mixin _EnsHomeLogicMixin on State<EnsHomePage> {
  final EnsRegistrationService ensService =
      EnsRegistrationServiceProvider.instance;

  List<OwnedEns> ownedNames = [];
  bool isLoading = true;
  String? errorMessage;

  // 当前选择的链，默认 N42
  EnsChainConfig selectedChain = EnsChainConfig.defaultChain;

  Future<void> loadOwnedNames() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final result = await ensService.getOwnedNames(widget.walletAddress);

    if (mounted) {
      setState(() {
        isLoading = false;
        if (!result.error && result.data != null) {
          ownedNames = result.data!;
        } else {
          errorMessage = S.of(context).g_key_5;
        }
      });
    }
  }

  void navigateToSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EnsSearchPage(
          walletAddress: widget.walletAddress,
        ),
      ),
    ).then((_) => loadOwnedNames());
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
    ).then((_) => loadOwnedNames());
  }
}
