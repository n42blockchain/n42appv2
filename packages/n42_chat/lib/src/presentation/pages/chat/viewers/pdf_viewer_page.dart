import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../widgets/common/common_widgets.dart';

/// PDF 文件查看器
///
/// 支持从本地文件路径或网络 URL 加载 PDF
class PdfViewerPage extends StatefulWidget {
  /// 本地文件路径
  final String? filePath;

  /// 网络 URL
  final String? url;

  /// 文件名
  final String fileName;

  /// HTTP 头（用于认证媒体）
  final Map<String, String>? headers;

  const PdfViewerPage({
    super.key,
    this.filePath,
    this.url,
    required this.fileName,
    this.headers,
  }) : assert(filePath != null || url != null, 'Either filePath or url must be provided');

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  PdfControllerPinch? _controller;
  bool _isLoading = true;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 0;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      PdfDocument document;

      if (widget.filePath != null) {
        document = await PdfDocument.openFile(widget.filePath!);
      } else if (widget.url != null) {
        final bytes = await _downloadFile(widget.url!);
        document = await PdfDocument.openData(
          Uint8List.fromList(bytes),
        );
      } else {
        throw Exception('No file source provided');
      }

      if (!mounted) return;

      setState(() {
        _controller = PdfControllerPinch(
          document: Future.value(document),
        );
        _totalPages = document.pagesCount;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  static const _maxDownloadSize = 50 * 1024 * 1024; // 50MB

  Future<List<int>> _downloadFile(String url) async {
    final uri = Uri.parse(url);
    // Only allow http/https to prevent SSRF
    if (uri.scheme != 'http' && uri.scheme != 'https') {
      throw Exception('Unsupported URL scheme: ${uri.scheme}');
    }

    final httpClient = HttpClient()
      ..connectionTimeout = const Duration(seconds: 15);
    try {
      final request = await httpClient.getUrl(uri);

      if (widget.headers != null) {
        widget.headers!.forEach((key, value) {
          request.headers.set(key, value);
        });
      }

      final response = await request.close();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final bytes = <int>[];
      await for (final chunk in response) {
        bytes.addAll(chunk);
        if (bytes.length > _maxDownloadSize) {
          throw Exception('File too large (max 50MB)');
        }
      }
      return bytes;
    } finally {
      httpClient.close();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: N42AppBar(
        title: widget.fileName,
        showBackButton: true,
        onBackPressed: () => Navigator.pop(context),
        actions: [
          if (widget.filePath != null)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _sharePdf,
            ),
        ],
      ),
      body: _buildBody(isDark),
      bottomNavigationBar: _totalPages > 0
          ? _buildPageIndicator(isDark)
          : null,
    );
  }

  Widget _buildBody(bool isDark) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              S.of(context)?.pdfLoadFailed ?? 'Failed to load PDF',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _error!,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    if (_controller == null) return const SizedBox();

    return PdfViewPinch(
      controller: _controller!,
      onPageChanged: (page) {
        setState(() => _currentPage = page);
      },
      padding: 8,
      scrollDirection: Axis.vertical,
    );
  }

  Widget _buildPageIndicator(bool isDark) {
    return Container(
      height: 44,
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      child: Center(
        child: Text(
          '$_currentPage / $_totalPages',
          style: TextStyle(
            fontSize: 14,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Future<void> _sharePdf() async {
    if (widget.filePath == null) return;
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(widget.filePath!)],
        subject: widget.fileName,
      ),
    );
  }
}
