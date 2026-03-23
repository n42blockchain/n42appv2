class AddressBookCoinSelection {
  final String coinName;
  final String coinFullName;
  final String coinType;
  final String coinIcon;
  final String blockchainType;

  const AddressBookCoinSelection({
    required this.coinName,
    required this.coinFullName,
    required this.coinType,
    required this.coinIcon,
    required this.blockchainType,
  });
}

AddressBookCoinSelection addressBookSelectionFromCoinMap(
  Map<String, dynamic> coin,
) {
  final coinType = coin['coinType']?.toString().trim() ?? '';
  final miniName = coin['miniName']?.toString().trim() ?? '';
  final coinName = miniName.isNotEmpty ? miniName : coinType;
  final fullName = coin['name']?.toString().trim() ?? coinName;

  return AddressBookCoinSelection(
    coinName: coinName,
    coinFullName: fullName.isNotEmpty ? fullName : coinName,
    coinType: coinType.isNotEmpty ? coinType : coinName,
    coinIcon: coin['icon']?.toString() ?? '',
    blockchainType: coin['blockchainType']?.toString() ?? '',
  );
}

String normalizeAddressBookInput(String input) {
  var normalized = input.trim();
  final colonIndex = normalized.indexOf(':');
  if (colonIndex >= 0) {
    normalized = normalized.substring(colonIndex + 1);
  }

  if (normalized.startsWith('transfer/')) {
    normalized = normalized.substring('transfer/'.length);
  }

  final queryIndex = normalized.indexOf('?');
  if (queryIndex >= 0) {
    normalized = normalized.substring(0, queryIndex);
  }

  return normalized.trim();
}
