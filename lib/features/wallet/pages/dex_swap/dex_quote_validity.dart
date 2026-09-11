import 'package:n42_wallet/features/wallet/models/dex/dex_quote_model.dart';

/// A confirmation authorizes exactly the displayed quote, within its lifetime.
/// Order IDs alone are insufficient: refreshed payloads may reuse an ID.
bool isCurrentDexQuote({
  required DexQuoteModel confirmed,
  required DexQuoteModel? current,
  required DateTime? expiresAt,
  required DateTime now,
  Object? confirmedAccountKey,
  Object? currentAccountKey,
}) =>
    identical(confirmed, current) &&
    confirmedAccountKey == currentAccountKey &&
    expiresAt != null &&
    now.isBefore(expiresAt);
