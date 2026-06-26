import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../../../core/extensions/context_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../widgets/common/common_widgets.dart';

class TextDocumentPreviewPage extends StatefulWidget {
  final String fileName;
  final String url;
  final Map<String, String>? headers;

  const TextDocumentPreviewPage({
    super.key,
    required this.fileName,
    required this.url,
    this.headers,
  });

  @override
  State<TextDocumentPreviewPage> createState() => _TextDocumentPreviewPageState();
}

class _TextDocumentPreviewPageState extends State<TextDocumentPreviewPage> {
  static const _maxPreviewSize = 2 * 1024 * 1024;

  bool _isLoading = true;
  String? _error;
  String _content = '';

  @override
  void initState() {
    super.initState();
    _loadDocument();
  }

  Future<void> _loadDocument() async {
    final uri = Uri.parse(widget.url);
    if (uri.scheme != 'http' && uri.scheme != 'https') {
      setState(() {
        _error = 'Unsupported URL scheme: ${uri.scheme}';
        _isLoading = false;
      });
      return;
    }

    final httpClient = HttpClient()
      ..connectionTimeout = const Duration(seconds: 15);

    try {
      final request = await httpClient.getUrl(uri);
      widget.headers?.forEach(request.headers.set);

      final response = await request.close();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final bytes = <int>[];
      await for (final chunk in response) {
        bytes.addAll(chunk);
        if (bytes.length > _maxPreviewSize) {
          throw Exception('Preview limit exceeded (max 2MB)');
        }
      }

      if (!mounted) return;
      setState(() {
        _content = const Utf8Decoder(allowMalformed: true).convert(bytes);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    } finally {
      httpClient.close();
    }
  }

  bool get _isMarkdown {
    final lowerName = widget.fileName.toLowerCase();
    return lowerName.endsWith('.md') || lowerName.endsWith('.markdown');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.pageBackground,
      appBar: N42AppBar(
        title: widget.fileName,
        showBackButton: true,
        onBackPressed: () => Navigator.pop(context),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.description_outlined,
                size: 56,
                color: context.textSecondary,
              ),
              const SizedBox(height: 16),
              Text(
                'Preview',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: context.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    const padding = EdgeInsets.all(16);
    if (_isMarkdown) {
      return Markdown(
        data: _content,
        padding: padding,
        selectable: true,
      );
    }

    return SingleChildScrollView(
      padding: padding,
      child: SelectableText(
        _content,
        style: TextStyle(
          fontSize: 14,
          height: 1.5,
          color: context.textPrimary,
        ),
      ),
    );
  }
}
