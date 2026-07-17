import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/identity/models/id_hub_models.dart';
import 'package:n42_wallet/features/identity/services/id_hub_error_message.dart';

void main() {
  test('maps a missing session to the expired-request copy', () {
    final error = IdHubException(
      'session not found or expired',
      statusCode: 404,
      code: 'not-found',
    );

    expect(idHubUserFacingError(error), idHubRequestExpiredMessage);
  });

  test('maps all stable expiry codes to the same actionable copy', () {
    for (final code in [
      'session-expired',
      'challenge-expired',
      'session-not-found',
    ]) {
      expect(
        idHubUserFacingError(IdHubException('raw error', code: code)),
        idHubRequestExpiredMessage,
      );
    }
  });

  test('maps binding conflict without exposing the backend detail', () {
    final error = IdHubException(
      'database unique constraint',
      statusCode: 409,
      code: 'binding-conflict',
    );

    expect(
      idHubUserFacingError(error),
      'This wallet is already linked to another identity.',
    );
  });

  test('preserves a safe Hub message for an unknown problem', () {
    final error = IdHubException(
      'Please try again later.',
      statusCode: 503,
      code: 'unavailable',
    );

    expect(idHubUserFacingError(error), 'Please try again later.');
  });
}
