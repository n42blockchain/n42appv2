import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/core/utils/payment_request_status_utils.dart';
import 'package:n42_chat/src/domain/entities/message_entity.dart';

void main() {
  test('returns paid when transfer status is completed', () {
    const metadata = MessageMetadata(
      transferStatus: 'completed',
      paymentRequestExpiresAt: null,
    );

    expect(
      resolvePaymentRequestStatus(metadata),
      PaymentRequestLifecycleStatus.paid,
    );
  });

  test('returns paid before expired when a paid request has passed expiry', () {
    final metadata = MessageMetadata(
      transferStatus: 'completed',
      paymentRequestExpiresAt: DateTime(2000, 1, 1),
    );

    expect(
      resolvePaymentRequestStatus(metadata),
      PaymentRequestLifecycleStatus.paid,
    );
  });

  test('returns expired when unpaid request is past expiry', () {
    final metadata = MessageMetadata(
      paymentRequestExpiresAt: DateTime(2000, 1, 1),
    );

    expect(
      resolvePaymentRequestStatus(metadata),
      PaymentRequestLifecycleStatus.expired,
    );
  });
}
