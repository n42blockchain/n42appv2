import 'dart:convert';

bool matrixUiaSupportsStage(String? rawBody, String stage) {
  if (rawBody == null || rawBody.isEmpty) {
    return false;
  }

  try {
    final decoded = jsonDecode(rawBody);
    if (decoded is! Map<String, dynamic>) {
      return false;
    }

    final flows = decoded['flows'];
    if (flows is! List) {
      return false;
    }

    for (final flow in flows) {
      if (flow is! Map) {
        continue;
      }
      final stages = flow['stages'];
      if (stages is List && stages.contains(stage)) {
        return true;
      }
    }
  } catch (_) {
    return false;
  }

  return false;
}

bool matrixUiaSupportsPassword(String? rawBody) {
  return matrixUiaSupportsStage(rawBody, 'm.login.password');
}
