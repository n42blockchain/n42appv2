import '../models/id_hub_models.dart';

const String idHubRequestExpiredMessage =
    'This request has expired. Ask the other device to retry.';

/// Converts stable Hub problem codes into user-facing copy without exposing
/// backend details such as "session not found" on an expired QR request.
String idHubUserFacingError(IdHubException error) {
  if (error.code == 'binding-conflict') {
    return 'This wallet is already linked to another identity.';
  }
  if (error.statusCode == 404 ||
      error.code == 'session-expired' ||
      error.code == 'challenge-expired' ||
      error.code == 'session-not-found') {
    return idHubRequestExpiredMessage;
  }
  return error.message;
}
