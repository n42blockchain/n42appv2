import '../../domain/entities/message_entity.dart';

enum PaymentRequestLifecycleStatus { pending, paid, expired }

PaymentRequestLifecycleStatus resolvePaymentRequestStatus(
  MessageMetadata? metadata, {
  DateTime? now,
}) {
  if (metadata == null) {
    return PaymentRequestLifecycleStatus.pending;
  }

  final transferStatus = metadata.transferStatus?.toLowerCase();
  if (transferStatus == 'completed' ||
      transferStatus == 'paid' ||
      transferStatus == 'received') {
    return PaymentRequestLifecycleStatus.paid;
  }

  final expiresAt = metadata.paymentRequestExpiresAt;
  if (expiresAt != null && (now ?? DateTime.now()).isAfter(expiresAt)) {
    return PaymentRequestLifecycleStatus.expired;
  }

  return PaymentRequestLifecycleStatus.pending;
}
