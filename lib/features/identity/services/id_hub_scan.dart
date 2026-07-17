import 'package:n42_wallet/core/providers/service_providers.dart';
import 'package:n42_wallet/main.dart' show globalProviderContainer;

/// If [scanValue] is an `n42id://` scan-to-sign link, route it through the deep
/// link pipeline (same allowlist validation as an OS-delivered link) and return
/// true so the caller stops treating it as a wallet address. Returns false for
/// any non-`n42id` string, leaving existing scan handling untouched.
bool tryHandleIdHubScan(String scanValue) {
  if (!scanValue.startsWith('n42id://')) return false;
  final uri = Uri.tryParse(scanValue);
  if (uri == null) return false;
  globalProviderContainer.read(deepLinkServiceProvider).handleUri(uri);
  return true;
}
