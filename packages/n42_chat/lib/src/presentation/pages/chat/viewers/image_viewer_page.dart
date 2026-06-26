// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:saver_gallery/saver_gallery.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/matrix_utils.dart' as mx_utils;
import '../../../../data/datasources/matrix/matrix_client_manager.dart';
import '../../../../core/utils/debug_log.dart';

/// 图片查看器页面
class ImageViewerPage extends StatefulWidget {
  final String imageUrl;
  final String heroTag;

  const ImageViewerPage({
    super.key,
    required this.imageUrl,
    required this.heroTag,
  });

  @override
  State<ImageViewerPage> createState() => _ImageViewerPageState();
}

class _ImageViewerPageState extends State<ImageViewerPage> {
  bool _isSaving = false;

  Future<void> _saveImage() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      final headers = mx_utils.MatrixUtils.buildAuthenticatedMediaHeaders(
        widget.imageUrl,
        client: MatrixClientManager.instance.client,
      );
      final response = await http.get(
        Uri.parse(widget.imageUrl),
        headers: headers,
      );

      if (response.statusCode == 200) {
        // 保存到相册
        final result = await SaverGallery.saveImage(
          response.bodyBytes,
          fileName: 'n42_${DateTime.now().millisecondsSinceEpoch}.jpg',
          skipIfExists: false,
        );

        if (mounted) {
          if (result.isSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  S.of(context)?.commonSavedToGallery ?? 'Saved to gallery',
                ),
                backgroundColor: AppColors.success,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  S.of(context)?.commonFailedToSave ?? 'Failed to save',
                ),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                S
                        .of(context)
                        ?.chatDownloadFailed(response.statusCode.toString()) ??
                    'Download failed: ${response.statusCode}',
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      debugLog('Save image error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              S.of(context)?.chatErrorWithMessage(e.toString()) ?? 'Error: $e',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _shareImage() async {
    try {
      final headers = mx_utils.MatrixUtils.buildAuthenticatedMediaHeaders(
        widget.imageUrl,
        client: MatrixClientManager.instance.client,
      );
      final response = await http.get(
        Uri.parse(widget.imageUrl),
        headers: headers,
      );

      if (response.statusCode == 200) {
        // 创建临时文件
        final tempDir = await Directory.systemTemp.createTemp('n42_share');
        final tempFile = File('${tempDir.path}/image.jpg');
        await tempFile.writeAsBytes(response.bodyBytes);

        // 分享
        await SharePlus.instance.share(
          ShareParams(files: [XFile(tempFile.path)]),
        );

        // 清理临时文件
        await tempDir.delete(recursive: true);
      }
    } catch (e) {
      debugLog('Share image error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              S.of(context)?.commonShareFailed(e.toString()) ??
                  'Share failed: $e',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final headers = mx_utils.MatrixUtils.buildAuthenticatedMediaHeaders(
      widget.imageUrl,
      client: MatrixClientManager.instance.client,
    );
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          // 保存按钮
          IconButton(
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.download),
            onPressed: _isSaving ? null : _saveImage,
            tooltip: 'Save',
          ),
          // 分享按钮
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareImage,
            tooltip: 'Share',
          ),
          // 更多选项
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            color: Colors.grey[900],
            onSelected: (value) {
              switch (value) {
                case 'save':
                  _saveImage();
                  break;
                case 'share':
                  _shareImage();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'save',
                child: Row(
                  children: [
                    const Icon(Icons.download, color: Colors.white, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      S.of(context)?.chatSaveToGallery ?? 'Save to Gallery',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    const Icon(Icons.share, color: Colors.white, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      S.of(context)?.commonShare ?? 'Share',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Center(
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Hero(
              tag: widget.heroTag,
              child: CachedNetworkImage(
                imageUrl: widget.imageUrl,
                fit: BoxFit.contain,
                httpHeaders: headers,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
                errorWidget: (context, url, error) => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, color: AppColors.error, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      S.of(context)?.chatFailedToLoadImage ??
                          'Failed to load image',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
