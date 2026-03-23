String resolveEditedWalletName({
  required String input,
  required String existingName,
  required int walletIndex,
}) {
  final trimmedInput = input.trim();
  if (trimmedInput.isNotEmpty) return trimmedInput;

  final trimmedExisting = existingName.trim();
  if (trimmedExisting.isNotEmpty) return trimmedExisting;

  return 'Account${walletIndex + 1}';
}
