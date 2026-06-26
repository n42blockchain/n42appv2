import '../../domain/entities/content_filter_entity.dart';

class ContentFilterDecision {
  final bool matched;
  final bool shouldHide;
  final String content;

  const ContentFilterDecision({
    required this.matched,
    required this.shouldHide,
    required this.content,
  });
}

ContentFilterDecision applyContentFilterToText(
  String content,
  ContentFilterConfig? filter,
) {
  if (filter == null || !filter.enabled) {
    return ContentFilterDecision(
      matched: false,
      shouldHide: false,
      content: content,
    );
  }

  final forbiddenWords = filter.forbiddenWords
      .map((word) => word.trim())
      .where((word) => word.isNotEmpty)
      .toList();

  var matched = false;
  var filteredContent = content;

  if (forbiddenWords.isNotEmpty) {
    final pattern = RegExp(
      forbiddenWords.map(RegExp.escape).join('|'),
      caseSensitive: false,
    );
    if (pattern.hasMatch(content)) {
      matched = true;
      if (filter.action == FilterAction.replace) {
        filteredContent = filteredContent.replaceAll(pattern, '***');
      }
    }
  }

  for (final type in filter.sensitiveDataTypes) {
    final updated = _applySensitiveDataType(
      filteredContent,
      type,
      replace: filter.action == FilterAction.replace,
    );
    if (updated.matched) {
      matched = true;
      filteredContent = updated.content;
    }
  }

  return ContentFilterDecision(
    matched: matched,
    shouldHide: matched && filter.action == FilterAction.hide,
    content: filteredContent,
  );
}

ContentFilterDecision _applySensitiveDataType(
  String input,
  SensitiveDataType type, {
  required bool replace,
}) {
  switch (type) {
    case SensitiveDataType.email:
      return _applyRegExp(input, _emailPattern, replace: replace);
    case SensitiveDataType.phoneNumber:
      return _applyRegExp(input, _phonePattern, replace: replace);
    case SensitiveDataType.walletAddress:
      return _applyRegExp(input, _walletAddressPattern, replace: replace);
    case SensitiveDataType.creditCard:
      return _applyCreditCardPattern(input, replace: replace);
  }
}

ContentFilterDecision _applyRegExp(
  String input,
  RegExp pattern, {
  required bool replace,
}) {
  final matched = pattern.hasMatch(input);
  if (!matched || !replace) {
    return ContentFilterDecision(
      matched: matched,
      shouldHide: false,
      content: input,
    );
  }
  return ContentFilterDecision(
    matched: true,
    shouldHide: false,
    content: input.replaceAll(pattern, '***'),
  );
}

ContentFilterDecision _applyCreditCardPattern(
  String input, {
  required bool replace,
}) {
  var matched = false;
  final content = input.replaceAllMapped(_creditCardPattern, (match) {
    final raw = match.group(0) ?? '';
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 13 || digits.length > 19 || !_passesLuhn(digits)) {
      return raw;
    }
    matched = true;
    return replace ? '***' : raw;
  });

  return ContentFilterDecision(
    matched: matched,
    shouldHide: false,
    content: content,
  );
}

bool _passesLuhn(String digits) {
  var sum = 0;
  var shouldDouble = false;

  for (var i = digits.length - 1; i >= 0; i--) {
    var digit = int.parse(digits[i]);
    if (shouldDouble) {
      digit *= 2;
      if (digit > 9) {
        digit -= 9;
      }
    }
    sum += digit;
    shouldDouble = !shouldDouble;
  }

  return sum % 10 == 0;
}

final RegExp _emailPattern = RegExp(
  r'\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b',
  caseSensitive: false,
);

final RegExp _phonePattern = RegExp(
  r'(?<!\w)(?:\+?\d[\d\s().-]{7,}\d)',
  caseSensitive: false,
);

final RegExp _walletAddressPattern = RegExp(r'\b0x[a-fA-F0-9]{40}\b');

final RegExp _creditCardPattern = RegExp(r'(?<!\d)(?:\d[\s-]?){13,19}(?!\d)');
