// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/matrix_utils.dart' as mx_utils;
import '../../../../data/datasources/matrix/matrix_client_manager.dart';
import '../../../../core/utils/debug_log.dart';

/// 视频播放器页面
class VideoPlayerPage extends StatefulWidget {
  final String videoUrl;
  final String? thumbnailUrl;

  const VideoPlayerPage({super.key, required this.videoUrl, this.thumbnailUrl});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late VideoPlayerController _controller;
  ChewieController? _chewieController;
  bool _isLoading = true;
  String? _error;
  File? _tempVideoFile;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      debugLog('=== Video Player Initialization ===');
      debugLog('Video URL: ${widget.videoUrl}');
      debugLog('Thumbnail URL: ${widget.thumbnailUrl}');

      // Validate video URL
      if (widget.videoUrl.isEmpty) {
        throw Exception('Video URL is empty');
      }

      final headers = mx_utils.MatrixUtils.buildAuthenticatedMediaHeaders(
        widget.videoUrl,
        client: getIt<MatrixClientManager>().client,
      );

      // 创建视频控制器
      // iOS AVFoundation 在 HTTP 重定向时会丢弃 Authorization header，
      // 导致 Matrix 媒体 CDN 重定向后 403/401。
      // 解决方案：iOS 上先用 http 包（正确保留 headers 跟随重定向）
      // 流式下载到临时文件，再用 VideoPlayerController.file() 播放本地文件。
      debugLog('Creating VideoPlayerController...');
      if (Platform.isIOS) {
        debugLog('iOS: streaming download with auth headers to temp file...');
        final request = http.Request('GET', Uri.parse(widget.videoUrl));
        request.headers.addAll(headers);
        final httpClient = http.Client();
        final streamResponse = await httpClient.send(request);
        if (streamResponse.statusCode != 200) {
          httpClient.close();
          throw Exception(
            'Video download failed: ${streamResponse.statusCode}',
          );
        }
        final dir = await getTemporaryDirectory();
        final file = File(
          '${dir.path}/video_${DateTime.now().millisecondsSinceEpoch}.mp4',
        );
        final sink = file.openWrite();
        await streamResponse.stream.pipe(sink);
        await sink.close();
        httpClient.close();
        _tempVideoFile = file;
        debugLog('iOS: temp file ready, size: ${await file.length()} bytes');
        _controller = VideoPlayerController.file(file);
      } else {
        _controller = VideoPlayerController.networkUrl(
          Uri.parse(widget.videoUrl),
          httpHeaders: headers,
        );
      }

      debugLog('Initializing video controller...');
      await _controller.initialize();
      // Seek to first frame to avoid black screen on some platforms
      await _controller.seekTo(Duration.zero);
      debugLog('Video controller initialized successfully');
      debugLog('Video duration: ${_controller.value.duration}');
      debugLog('Video size: ${_controller.value.size}');

      _chewieController = ChewieController(
        videoPlayerController: _controller,
        autoPlay: true,
        looping: false,
        aspectRatio: _controller.value.aspectRatio,
        placeholder: widget.thumbnailUrl != null
            ? CachedNetworkImage(
                imageUrl: widget.thumbnailUrl!,
                fit: BoxFit.cover,
                httpHeaders:
                    mx_utils.MatrixUtils.buildAuthenticatedMediaHeaders(
                      widget.thumbnailUrl,
                      client: getIt<MatrixClientManager>().client,
                    ),
              )
            : Container(color: Colors.black),
        errorBuilder: (ctx, errorMessage) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, color: AppColors.error, size: 48),
              const SizedBox(height: 16),
              Text(
                '${S.of(ctx)?.chatVideoPlaybackFailed ?? 'Video playback failed'}\n$errorMessage',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      debugLog('=== Video Player Error ===');
      debugLog('Error: $e');
      debugLog('Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _controller.dispose();
    _tempVideoFile?.delete().ignore();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          S.of(context)?.chatVideoTitle ?? 'Video',
          style: const TextStyle(color: Colors.white),
        ),
        elevation: 0,
      ),
      body: Center(
        child: _isLoading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Colors.white),
                  const SizedBox(height: 16),
                  Text(
                    S.of(context)?.chatLoadingText ?? 'Loading...',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              )
            : _error != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: AppColors.error, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    '${S.of(context)?.chatVideoLoadFailed ?? 'Video load failed'}\n$_error',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isLoading = true;
                        _error = null;
                      });
                      _initializePlayer();
                    },
                    child: Text(S.of(context)?.chatRetryButton ?? 'Retry'),
                  ),
                ],
              )
            : _chewieController != null
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio > 0
                    ? _controller.value.aspectRatio
                    : 16 / 9,
                child: Chewie(controller: _chewieController!),
              )
            : Text(
                S.of(context)?.chatPlayerInitFailed ??
                    'Player initialization failed',
                style: const TextStyle(color: Colors.white),
              ),
      ),
    );
  }
}
