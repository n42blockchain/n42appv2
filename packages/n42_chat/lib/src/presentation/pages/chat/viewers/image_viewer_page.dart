// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:saver_gallery/saver_gallery.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/ai_provider_router.dart';
import '../../../../core/services/ai_service.dart';
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

  /// AI 识别 / OCR：打开底部弹层，下载图片字节并交云端视觉模型描述/转写。
  void _describeWithAi() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.grey[900],
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _AiDescribeSheet(imageUrl: widget.imageUrl),
    );
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
                case 'ai_describe':
                  _describeWithAi();
                  break;
              }
            },
            itemBuilder: (context) => [
              if (getIt<AiProviderRouter>().supportsVision)
                const PopupMenuItem(
                  value: 'ai_describe',
                  child: Row(
                    children: [
                      Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                      SizedBox(width: 12),
                      Text(
                        'AI describe / OCR',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
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

/// AI 图像理解 / OCR 结果底部弹层。下载图片字节后交云端视觉模型描述/转写。
class _AiDescribeSheet extends StatefulWidget {
  const _AiDescribeSheet({required this.imageUrl});

  final String imageUrl;

  @override
  State<_AiDescribeSheet> createState() => _AiDescribeSheetState();
}

class _AiDescribeSheetState extends State<_AiDescribeSheet> {
  bool _loading = true;
  String? _result;
  String? _error;

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    try {
      final headers = mx_utils.MatrixUtils.buildAuthenticatedMediaHeaders(
        widget.imageUrl,
        client: MatrixClientManager.instance.client,
      );
      final resp = await http.get(Uri.parse(widget.imageUrl), headers: headers);
      if (resp.statusCode != 200) {
        throw Exception('Download failed: ${resp.statusCode}');
      }
      final text = await getIt<AiProviderRouter>().describeImage(
        resp.bodyBytes,
        mimeType: 'image/jpeg',
      );
      if (!mounted) return;
      setState(() {
        _result = text.isEmpty ? '(empty result)' : text;
        _loading = false;
      });
    } on AiServiceException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'AI describe / OCR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              )
            else if (_error != null)
              Text(
                _error!,
                style: const TextStyle(color: AppColors.error),
              )
            else
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    _result ?? '',
                    style: const TextStyle(color: Colors.white, height: 1.4),
                  ),
                ),
              ),
            if (!_loading && _result != null) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _result!));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Copied')),
                    );
                  },
                  icon: const Icon(Icons.copy, color: Colors.white, size: 18),
                  label: const Text(
                    'Copy',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
