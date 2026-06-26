import 'package:connectivity_plus/connectivity_plus.dart';

import '../../data/datasources/local/preferences_datasource.dart';

enum AutoDownloadMediaType {
  image,
  voice,
  video,
  file,
}

class AutoDownloadPolicyService {
  final PreferencesDataSource _preferencesDataSource;
  final Connectivity _connectivity;

  AutoDownloadPolicyService({
    required PreferencesDataSource preferencesDataSource,
    Connectivity? connectivity,
  })  : _preferencesDataSource = preferencesDataSource,
        _connectivity = connectivity ?? Connectivity();

  Future<bool> shouldAutoDownload(AutoDownloadMediaType mediaType) async {
    final settings = await _preferencesDataSource.getAutoDownloadSettings();
    final connectivityResults = await _connectivity.checkConnectivity();
    final profile = _resolveNetworkProfile(connectivityResults);

    if (profile == null) {
      return false;
    }

    final key = '${profile}_${_mediaTypeKey(mediaType)}';
    final value = settings[key];
    if (value is bool) {
      return value;
    }

    return PreferencesDataSource.defaultAutoDownloadSettings[key] ?? false;
  }

  String _mediaTypeKey(AutoDownloadMediaType mediaType) {
    switch (mediaType) {
      case AutoDownloadMediaType.image:
        return 'images';
      case AutoDownloadMediaType.voice:
        return 'voice';
      case AutoDownloadMediaType.video:
        return 'video';
      case AutoDownloadMediaType.file:
        return 'files';
    }
  }

  String? _resolveNetworkProfile(List<ConnectivityResult> results) {
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      return null;
    }
    if (results.contains(ConnectivityResult.wifi) ||
        results.contains(ConnectivityResult.ethernet) ||
        results.contains(ConnectivityResult.vpn)) {
      return 'wifi';
    }
    if (results.contains(ConnectivityResult.mobile)) {
      return 'mobile';
    }
    return 'wifi';
  }
}
