final RegExp _digitRegExp = RegExp(r'\d');

String? maskPhoneNumber(String? phoneNumber) {
  final raw = phoneNumber?.trim();
  if (raw == null || raw.isEmpty) {
    return null;
  }

  final digitMatches = _digitRegExp.allMatches(raw).toList();
  if (digitMatches.isEmpty) {
    return raw;
  }

  final totalDigits = digitMatches.length;
  final leadingVisible = totalDigits >= 10 ? 4 : (totalDigits >= 7 ? 3 : 1);
  final trailingVisible = totalDigits >= 7 ? 2 : 1;

  final buffer = StringBuffer();
  var digitIndex = 0;

  for (final rune in raw.runes) {
    final char = String.fromCharCode(rune);
    final isDigit = _digitRegExp.hasMatch(char);
    if (!isDigit) {
      buffer.write(char);
      continue;
    }

    final shouldReveal =
        digitIndex < leadingVisible ||
        digitIndex >= totalDigits - trailingVisible;
    buffer.write(shouldReveal ? char : '*');
    digitIndex++;
  }

  return buffer.toString();
}
