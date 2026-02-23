import 'package:flutter_riverpod/legacy.dart';
import 'package:n42_wallet/src/browser/provider/browser_provider.dart';

/// Riverpod provider wrapping the existing BrowserProvider ChangeNotifier.
final browserNotifierProvider = ChangeNotifierProvider<BrowserProvider>((ref) {
  return BrowserProvider();
});
