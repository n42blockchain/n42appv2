class PaymentRequestData {
  final String amount;
  final String address;
  final String coinType;
  final String uuid;

  const PaymentRequestData({
    required this.amount,
    required this.address,
    required this.coinType,
    required this.uuid,
  });
}

enum PaymentAvailabilityIssue {
  none,
  tokenUnavailable,
  tokenInsufficient,
  nativeUnavailable,
  nativeInsufficient,
}

final RegExp _paymentUuidRe = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
  caseSensitive: false,
);

PaymentRequestData sanitizePaymentRequest({
  required String? amount,
  required String? address,
  required String? coinType,
  required String? uuid,
}) {
  final trimmedAmount = amount?.trim() ?? '';
  final parsedAmount = double.tryParse(trimmedAmount);
  final trimmedUuid = uuid?.trim() ?? '';

  return PaymentRequestData(
    amount: parsedAmount != null && parsedAmount.isFinite && parsedAmount > 0
        ? trimmedAmount
        : '',
    address: address?.trim() ?? '',
    coinType: coinType?.trim() ?? '',
    uuid: _paymentUuidRe.hasMatch(trimmedUuid) ? trimmedUuid : '',
  );
}

PaymentAvailabilityIssue resolvePaymentAvailabilityIssue({
  required bool hasSelectedToken,
  required double tokenBalance,
  required double requiredTokenAmount,
  required bool hasNativeToken,
  required BigInt nativeBalance,
}) {
  if (!hasSelectedToken) return PaymentAvailabilityIssue.tokenUnavailable;
  if (requiredTokenAmount > 0 && tokenBalance < requiredTokenAmount) {
    return PaymentAvailabilityIssue.tokenInsufficient;
  }
  if (!hasNativeToken) return PaymentAvailabilityIssue.nativeUnavailable;
  if (nativeBalance <= BigInt.zero) {
    return PaymentAvailabilityIssue.nativeInsufficient;
  }
  return PaymentAvailabilityIssue.none;
}
