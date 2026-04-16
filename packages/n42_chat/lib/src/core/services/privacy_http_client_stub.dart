import 'package:http/http.dart' as http;

import '../../domain/entities/user_profile_entity.dart';

http.Client createPrivacyAwareHttpClient({
  required PrivacySettings? settings,
  http.Client Function()? fallbackFactory,
}) {
  return fallbackFactory?.call() ?? http.Client();
}
