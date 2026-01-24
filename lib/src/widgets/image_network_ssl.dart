//https忽略证书，图片加载控件
import 'dart:io';
import 'dart:ui' as ui show instantiateImageCodec, Codec;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ImageNetWorkSSL extends StatelessWidget {
  final String imageUrl;
  final String placeholder;
  final double? width;
  final double? height;
  final BoxFit? fit;

  const ImageNetWorkSSL(
      {
        required this.imageUrl,
        super.key,
        this.placeholder = "assets/img/list_default.png",
        this.width,
        this.height,
        this.fit = BoxFit.cover,
      });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return const SizedBox();
    }
    if (!imageUrl.contains("http") && !imageUrl.contains("https")) {
      return Image.asset(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
      );
    }
    return SizedBox(
      width: width,
      height: height,
      child: FadeInImage(
        width: width,
        height: height,
        fit: fit,
        placeholder: AssetImage(placeholder),
        //Image.asset(widget.defImgUrl),
        image: NetworkImageSSL(imageUrl, {"Origin":"app"}),
        /// url错误时 fireBase 会收集到这个错误日志 一直上传到控制台
        /// 必须重写这个errorWidget
        imageErrorBuilder: (
            BuildContext context,
            Object error,
            StackTrace? stackTrace,){
          return Image.asset(placeholder);
        },
      ),
    );
  }
}

class NetworkImageSSL extends ImageProvider<NetworkImageSSL> {
  const NetworkImageSSL(this.url, this.headers, {this.scale = 1.0});

  final String url;

  final double scale;

  final Map<String, String> headers;

  @override
  Future<NetworkImageSSL> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<NetworkImageSSL>(this);
  }

  @override
  ImageStreamCompleter loadBuffer(NetworkImageSSL key, DecoderBufferCallback decode
      ) {
    return MultiFrameImageStreamCompleter(
        codec: _loadAsync(key), scale: key.scale);
  }

  static final HttpClient _httpClient = HttpClient()
    ..badCertificateCallback =
    ((X509Certificate cert, String host, int port) => true);

  Future<ui.Codec> _loadAsync(NetworkImageSSL key) async {
    assert(key == this);
    final Uri resolved = Uri.base.resolve(key.url);
    final HttpClientRequest request = await _httpClient.getUrl(resolved);
    headers.forEach((String name, String value) {
      request.headers.add(name, value);
    });
    final HttpClientResponse response = await request.close();
    if (response.statusCode != HttpStatus.ok) {
      //print("ImageNetWork:${response.statusCode},");
      throw Exception(
          'HTTP request failed, statusCode: ${response.statusCode}, $resolved');
    }

    final Uint8List bytes = await consolidateHttpClientResponseBytes(response);
    if (bytes.lengthInBytes == 0) {
      throw Exception('NetworkImageSSL is an empty file: $resolved');
    }

    return await ui.instantiateImageCodec(bytes);
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    final NetworkImageSSL typedOther = other as NetworkImageSSL;
    return url == typedOther.url && scale == typedOther.scale;
  }

  @override
  int get hashCode => Object.hash(url, scale);

  // hashValues 过期方法
  // int get hashCode => hashValues(url, scale);

  @override
  String toString() => '$runtimeType("$url", scale: $scale)';
}