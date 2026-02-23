import 'package:n42_wallet/src/wallet/models/coin_model.dart';
import 'package:n42_wallet/src/wallet/models/wallet_info.dart';

/// Abstraction layer to break the CoinModel → WalletActionProvider circular dependency.
///
/// CoinModel needs wallet data (mnemonic, address storage) but should not
/// directly depend on WalletActionProvider. This interface defines the
/// minimal surface CoinModel requires.
abstract class ICoinModelWalletAccess {
  /// Current active wallet info
  WalletInfo get walletInfo;

  /// All wallet infos
  List<WalletInfo> get walletInfoList;

  /// Store a generated address for a coin type
  void setAddress(String key, Map<String, dynamic> value);

  /// Notify listeners that data has changed
  void refresh();

  /// Fetch balance for a specific CoinModel. Returns true if error occurred.
  Future<bool> getBalanceWithCoinModel(CoinModel coinModel);

  /// Recalculate total balance across all coins
  void calculateBalanceWidthCoinModel();
}
