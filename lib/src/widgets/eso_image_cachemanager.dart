import 'dart:async';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:n42_wallet/core/security/security_config.dart';

///
class EsoImageCacheManager extends CacheManager {
  static const key = 'EsoImageCacheManager';

  static  EsoImageCacheManager? _instance;
  factory EsoImageCacheManager() {
    _instance ??= EsoImageCacheManager._();
    return _instance!;
  }
  static final HttpClient _httpClient = HttpClient();


  EsoImageCacheManager._() : super(Config(key, fileService: EsoHttpFileService(httpClient: _httpClient)));
}

class EsoHttpFileService extends FileService {
  late HttpClient _httpClient;
  EsoHttpFileService({HttpClient? httpClient}) {
    _httpClient = httpClient ?? HttpClient();
    _httpClient.badCertificateCallback = SecurityConfig.verifySslCertificate;
  }

  @override
  Future<FileServiceResponse> get(String url, {Map<String, String>? headers=const {}}) async{
    final Uri resolved = Uri.base.resolve(url);
    final HttpClientRequest req = await _httpClient.getUrl(resolved);
    headers?.forEach((key, value) {
      req.headers.add(key, value);
    });
    final HttpClientResponse httpResponse = await req.close();
    //print("httpResponse statusCode ${httpResponse.statusCode}");
    //print("httpResponse contentLength ${httpResponse.contentLength}");
    final http.StreamedResponse response = http.StreamedResponse(
      httpResponse.timeout(const Duration(seconds: 60)), httpResponse.statusCode,
      //contentLength: httpResponse.contentLength,
      //reasonPhrase: httpResponse.reasonPhrase,
      //isRedirect: httpResponse.isRedirect,
    );
    return HttpGetResponse(response);
  }

}