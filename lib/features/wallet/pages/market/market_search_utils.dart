bool shouldApplyMarketSearchResponse({
  required int requestId,
  required int activeRequestId,
  required String requestQuery,
  required String activeQuery,
}) {
  final normalizedRequest = requestQuery.trim();
  final normalizedActive = activeQuery.trim();
  if (normalizedRequest.isEmpty || normalizedActive.isEmpty) {
    return false;
  }
  return requestId == activeRequestId && normalizedRequest == normalizedActive;
}
