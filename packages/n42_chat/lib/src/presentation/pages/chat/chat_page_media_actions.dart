// ignore_for_file: invalid_use_of_protected_member
part of 'chat_page.dart';

enum _PhotoSendMode { media, originalFile }

class _PersistedScheduledAttachment {
  final String localPath;
  final int fileSize;

  const _PersistedScheduledAttachment({
    required this.localPath,
    required this.fileSize,
  });
}

/// 媒体操作相关方法（图片、视频、文件、语音的选择与发送）
extension _ChatPageMediaActionsMethods on _ChatPageState {
  static const int _maxEncryptedRoomFileBytes = 64 * 1024 * 1024;

  Future<void> _pickImage({DateTime? scheduledAt}) async {
    try {
      final picker = ImagePicker();
      final mediaFiles = await picker.pickMultipleMedia();

      if (mediaFiles.isEmpty) return;

      for (final file in mediaFiles) {
        final mimeType = lookupMimeType(file.path) ?? '';
        if (mimeType.startsWith('video/')) {
          await _sendVideo(file, scheduledAt: scheduledAt);
        } else {
          // 单张图片时提供编辑选项
          if (mediaFiles.length == 1) {
            await _editAndSendImage(file, scheduledAt: scheduledAt);
          } else {
            await _sendImage(file, scheduledAt: scheduledAt);
          }
        }
      }
    } catch (e) {
      debugLog('Pick media error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              S.of(context)?.commonSelectImageFailed(e.toString()) ??
                  'Failed to select media: $e',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _showPhotoPickerOptions({DateTime? scheduledAt}) async {
    final selectedMode = await showModalBottomSheet<_PhotoSendMode>(
      context: context,
      backgroundColor: context.surfaceColor,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(S.of(context)?.contactPhotos ?? 'Photos'),
              subtitle: const Text(
                'Send photos and videos in chat-friendly format',
              ),
              onTap: () => Navigator.pop(sheetContext, _PhotoSendMode.media),
            ),
            ListTile(
              leading: const Icon(Icons.insert_photo_outlined),
              title: const Text('Original Images'),
              subtitle: const Text('Send uncompressed photos as files'),
              onTap: () =>
                  Navigator.pop(sheetContext, _PhotoSendMode.originalFile),
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: Text(S.of(context)?.commonCancel ?? 'Cancel'),
              onTap: () => Navigator.pop(sheetContext),
            ),
          ],
        ),
      ),
    );

    if (selectedMode == null) {
      return;
    }
    if (!mounted) {
      return;
    }

    if (selectedMode == _PhotoSendMode.originalFile) {
      await _pickOriginalImagesAsFiles(scheduledAt: scheduledAt);
      return;
    }

    await _pickImage(scheduledAt: scheduledAt);
  }

  Future<void> _pickOriginalImagesAsFiles({DateTime? scheduledAt}) async {
    try {
      final picker = ImagePicker();
      final images = await picker.pickMultiImage();
      if (images.isEmpty) {
        return;
      }

      for (final image in images) {
        if (!mounted) {
          return;
        }
        await _sendOriginalImageAsFile(image, scheduledAt: scheduledAt);
      }
    } catch (e) {
      debugLog('Pick original images error: $e');
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to select original images: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  /// 打开编辑器编辑图片后发送
  ///
  /// 编辑器中确认发送编辑后的图片，取消则不发送。
  Future<void> _editAndSendImage(XFile image, {DateTime? scheduledAt}) async {
    try {
      final bytes = await image.readAsBytes();
      if (!mounted) return;

      final editedBytes = await MediaEditorPage.open(
        context,
        imageBytes: bytes,
        filename: image.name,
      );

      // 用户取消编辑，不发送
      if (editedBytes == null || !mounted) return;

      var filename = image.name.isNotEmpty ? image.name : 'edited_image.jpg';
      final mimeType = _resolveMimeType(
        filename: filename,
        sourcePath: image.path,
        headerBytes: editedBytes,
        fallbackMimeType: 'image/jpeg',
      );
      filename = _ensureFilenameMatchesMimeType(filename, mimeType);

      if (scheduledAt != null) {
        await _scheduleLocalAttachmentDraft(
          type: MessageType.image,
          scheduledAt: scheduledAt,
          filename: filename,
          mimeType: mimeType,
          fileBytes: editedBytes,
          fileSize: editedBytes.length,
          selfDestructAfter: _isViewOnce ? 1 : null,
        );

        if (_isViewOnce) {
          setState(() => _isViewOnce = false);
        }
        _showScheduledAttachmentSnackBar(filename, scheduledAt);
        return;
      }

      context.read<ChatBloc>().add(
        SendImageMessage(
          imageBytes: editedBytes,
          filename: filename,
          mimeType: mimeType,
          selfDestructAfter: _isViewOnce ? 1 : null,
        ),
      );

      if (_isViewOnce) {
        setState(() => _isViewOnce = false);
      }
    } catch (e) {
      debugLog('Edit image error: $e');
      // 编辑器出错时回退到直接发送
      await _sendImage(image, scheduledAt: scheduledAt);
    }
  }

  Future<void> _takePhoto() async {
    // 显示选择菜单：拍照或录像
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(S.of(context)?.commonTakePhoto ?? 'Take Photo'),
              onTap: () => Navigator.pop(context, 'photo'),
            ),
            ListTile(
              leading: const Icon(Icons.videocam),
              title: Text(S.of(context)?.chatRecording ?? 'Recording'),
              onTap: () => Navigator.pop(context, 'video'),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.close),
              title: Text(S.of(context)?.commonCancel ?? 'Cancel'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );

    if (choice == null) return;

    try {
      final picker = ImagePicker();

      if (choice == 'photo') {
        final image = await picker.pickImage(source: ImageSource.camera);

        if (image == null) return;
        await _editAndSendImage(image);
      } else if (choice == 'video') {
        debugLog('Starting video recording...');
        final video = await picker.pickVideo(
          source: ImageSource.camera,
          maxDuration: const Duration(minutes: 5),
        );

        debugLog('Video picker returned: ${video?.path ?? "null"}');

        if (video == null) {
          debugLog(
            'Video is null - user may have cancelled or recording failed',
          );
          return;
        }

        // 验证视频文件存在
        final videoFile = File(video.path);
        if (!await videoFile.exists()) {
          debugLog('Video file does not exist at path: ${video.path}');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  S.of(context)?.chatVideoRecordingFailed ??
                      'Video recording failed',
                ),
                backgroundColor: AppColors.error,
              ),
            );
          }
          return;
        }

        final fileSize = await videoFile.length();
        debugLog('Video file exists, size: $fileSize bytes');

        if (fileSize == 0) {
          debugLog('Video file is empty');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  S.of(context)?.chatVideoRecordingFailed ??
                      'Video recording failed',
                ),
                backgroundColor: AppColors.error,
              ),
            );
          }
          return;
        }

        await _sendVideo(video);
      }
    } catch (e) {
      debugLog('Take photo/video error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              S.of(context)?.chatCaptureFailed(e.toString()) ??
                  'Capture failed: $e',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _sendVideo(XFile video, {DateTime? scheduledAt}) async {
    try {
      debugLog('=== _sendVideo start ===');
      debugLog('Video path: ${video.path}');
      debugLog('Video name: ${video.name}');

      // 显示发送中提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              S.of(context)?.chatProcessingVideo ?? 'Processing video...',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }

      // 读取视频字节 - 优先使用 XFile.readAsBytes()
      Uint8List bytes;
      try {
        bytes = await video.readAsBytes();
      } catch (e) {
        debugLog('XFile.readAsBytes failed, trying File: $e');
        final file = File(video.path);
        if (!await file.exists()) {
          debugLog('Video file not found: ${video.path}');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  S.of(context)?.chatVideoFileNotExist ??
                      'Video file does not exist',
                ),
                backgroundColor: AppColors.error,
              ),
            );
          }
          return;
        }
        bytes = await file.readAsBytes();
      }

      if (bytes.isEmpty) {
        debugLog('Video bytes is empty');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                S.of(context)?.chatVideoDataEmpty ?? 'Video data is empty',
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      // 处理文件名
      String filename = video.name;
      if (filename.isEmpty) {
        filename = 'video_${DateTime.now().millisecondsSinceEpoch}.mp4';
      }

      // 从路径获取扩展名
      final pathExt = video.path.split('.').last.toLowerCase();
      final hasExtInName = filename.contains('.');

      if (!hasExtInName && pathExt.isNotEmpty && pathExt.length <= 5) {
        filename = '$filename.$pathExt';
      }

      // 确保文件名有扩展名
      if (!filename.toLowerCase().endsWith('.mp4') &&
          !filename.toLowerCase().endsWith('.mov') &&
          !filename.toLowerCase().endsWith('.avi') &&
          !filename.toLowerCase().endsWith('.mkv') &&
          !filename.toLowerCase().endsWith('.webm')) {
        filename = '$filename.mp4';
      }

      // 确定 MIME 类型
      final String mimeType =
          lookupMimeType(filename) ?? lookupMimeType(video.path) ?? 'video/mp4';

      // 检查文件大小（限制 100MB）
      const maxSize = 100 * 1024 * 1024; // 100MB
      if (bytes.length > maxSize) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                S.of(context)?.chatVideoTooLarge ??
                    'Video size cannot exceed 100MB',
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      if (scheduledAt != null) {
        await _scheduleLocalAttachmentDraft(
          type: MessageType.video,
          scheduledAt: scheduledAt,
          filename: filename,
          mimeType: mimeType,
          fileBytes: video.path.isEmpty || kIsWeb ? bytes : null,
          filePath: video.path.isEmpty || kIsWeb ? null : video.path,
          fileSize: bytes.length,
          selfDestructAfter: _isViewOnce ? 1 : null,
        );

        if (_isViewOnce) {
          setState(() {
            _isViewOnce = false;
          });
        }
        _showScheduledAttachmentSnackBar(filename, scheduledAt);
        return;
      }

      // 生成视频缩略图（第一帧）
      Uint8List? thumbnailBytes;
      try {
        debugLog('Generating video thumbnail...');
        final thumbnailPath = await VideoThumbnail.thumbnailFile(
          video: video.path,
          thumbnailPath: (await Directory.systemTemp.createTemp()).path,
          imageFormat: ImageFormat.JPEG,
          maxHeight: 320,
          quality: 75,
        );

        if (thumbnailPath != null) {
          final thumbnailFile = File(thumbnailPath);
          if (await thumbnailFile.exists()) {
            thumbnailBytes = await thumbnailFile.readAsBytes();
            debugLog('Thumbnail generated: ${thumbnailBytes.length} bytes');
            // 清理临时文件
            await thumbnailFile.delete();
          }
        }
      } catch (e) {
        debugLog('Failed to generate thumbnail: $e');
        // 缩略图生成失败不阻止视频发送
      }

      debugLog('Final filename: $filename');
      debugLog('Final mimeType: $mimeType');
      debugLog('Video size: ${bytes.length} bytes');
      debugLog('Thumbnail size: ${thumbnailBytes?.length ?? 0} bytes');
      debugLog('=== Sending video to ChatBloc ===');

      if (!mounted) return;
      // 使用视频消息发送（带缩略图）
      context.read<ChatBloc>().add(
        SendVideoMessage(
          videoBytes: bytes,
          filename: filename,
          mimeType: mimeType,
          thumbnailBytes: thumbnailBytes,
          selfDestructAfter: _isViewOnce ? 1 : null,
        ),
      );

      // 发送后重置 View Once 模式
      if (_isViewOnce) {
        setState(() {
          _isViewOnce = false;
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              S.of(context)?.chatSendingVideo ?? 'Sending video...',
            ),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e, stackTrace) {
      debugLog('Send video error: $e');
      debugLog('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              S.of(context)?.chatSendVideoFailed(e.toString()) ??
                  'Failed to send video: $e',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _sendImage(XFile image, {DateTime? scheduledAt}) async {
    try {
      debugLog('=== _sendImage start ===');
      debugLog('Image path: ${image.path}');
      debugLog('Image name: ${image.name}');

      // 读取图片字节 - 优先使用 XFile.readAsBytes() 因为它支持所有平台
      Uint8List bytes;
      try {
        bytes = await image.readAsBytes();
      } catch (e) {
        // 如果 XFile.readAsBytes 失败，尝试使用 File
        debugLog('XFile.readAsBytes failed, trying File: $e');
        final file = File(image.path);
        if (!await file.exists()) {
          debugLog('Image file not found: ${image.path}');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  S.of(context)?.chatImageFileNotExist ??
                      'Image file does not exist',
                ),
                backgroundColor: AppColors.error,
              ),
            );
          }
          return;
        }
        bytes = await file.readAsBytes();
      }

      if (bytes.isEmpty) {
        debugLog('Image bytes is empty');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                S.of(context)?.commonImageDataEmpty ?? 'Image data is empty',
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      // 处理文件名 - iOS 相机拍照可能没有扩展名
      String filename = image.name;
      if (filename.isEmpty) {
        filename = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      }

      // 从路径获取扩展名（更可靠）
      final pathExt = image.path.split('.').last.toLowerCase();
      final hasExtInName = filename.contains('.');

      if (!hasExtInName && pathExt.isNotEmpty && pathExt.length <= 5) {
        filename = '$filename.$pathExt';
      }

      // 确保文件名有扩展名
      if (!filename.toLowerCase().endsWith('.jpg') &&
          !filename.toLowerCase().endsWith('.jpeg') &&
          !filename.toLowerCase().endsWith('.png') &&
          !filename.toLowerCase().endsWith('.gif') &&
          !filename.toLowerCase().endsWith('.webp') &&
          !filename.toLowerCase().endsWith('.heic') &&
          !filename.toLowerCase().endsWith('.heif')) {
        filename = '$filename.jpg';
      }

      // 确定 MIME 类型
      var mimeType = _resolveMimeType(
        filename: filename,
        sourcePath: image.path,
        headerBytes: bytes,
        fallbackMimeType: 'image/jpeg',
      );

      // 自动检测人脸并模糊
      if (_autoFaceBlur && !kIsWeb) {
        debugLog('FaceBlur: Auto face blur enabled, processing image...');
        bytes = await FaceBlurUtil.blurFaces(bytes);
        debugLog(
          'FaceBlur: Processing complete, image size: ${bytes.length} bytes',
        );
        mimeType = _resolveMimeType(
          filename: filename,
          sourcePath: image.path,
          headerBytes: bytes,
          fallbackMimeType: 'image/jpeg',
        );
        filename = _ensureFilenameMatchesMimeType(filename, mimeType);
      }

      debugLog('Final filename: $filename');
      debugLog('Final mimeType: $mimeType');
      debugLog('Image size: ${bytes.length} bytes');
      debugLog('=== Sending image to ChatBloc ===');

      if (scheduledAt != null) {
        await _scheduleLocalAttachmentDraft(
          type: MessageType.image,
          scheduledAt: scheduledAt,
          filename: filename,
          mimeType: mimeType,
          fileBytes: bytes,
          fileSize: bytes.length,
          selfDestructAfter: _isViewOnce ? 1 : null,
        );

        if (_isViewOnce) {
          setState(() {
            _isViewOnce = false;
          });
        }
        _showScheduledAttachmentSnackBar(filename, scheduledAt);
        return;
      }

      if (!mounted) return;
      context.read<ChatBloc>().add(
        SendImageMessage(
          imageBytes: bytes,
          filename: filename,
          mimeType: mimeType,
          selfDestructAfter: _isViewOnce ? 1 : null,
        ),
      );

      // 发送后重置 View Once 模式
      if (_isViewOnce) {
        setState(() {
          _isViewOnce = false;
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              S.of(context)?.chatSendingImage ?? 'Sending image...',
            ),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e, stackTrace) {
      debugLog('Send image error: $e');
      debugLog('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              S.of(context)?.chatSendImageFailed(e.toString()) ??
                  'Failed to send image: $e',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _pickFile({DateTime? scheduledAt}) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: true,
        withReadStream: true,
      );

      if (result == null || result.files.isEmpty) return;

      // 发送选中的文件
      for (final file in result.files) {
        if ((file.path == null || file.path!.isEmpty) &&
            (file.readStream == null) &&
            (file.bytes == null || file.bytes!.isEmpty)) {
          debugLog('File bytes is empty: ${file.name}');
          continue;
        }

        await _sendFile(file, scheduledAt: scheduledAt);
      }
    } catch (e) {
      debugLog('Pick file error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              S.of(context)?.chatPickFileFailed(e.toString()) ??
                  'Failed to pick file: $e',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _sendFile(PlatformFile file, {DateTime? scheduledAt}) async {
    try {
      final filename = file.name;
      final mimeType = lookupMimeType(filename) ?? 'application/octet-stream';
      final fileSize = file.size;

      debugLog(
        'Sending file: $filename, size: $fileSize bytes, mimeType: $mimeType',
      );

      await _queueFileMessage(
        filename: filename,
        mimeType: mimeType,
        fileSize: fileSize,
        fileBytes: file.bytes,
        filePath: file.path,
        fileStream: file.readStream,
        scheduledAt: scheduledAt,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              scheduledAt == null
                  ? (S.of(context)?.chatFileSending(filename) ??
                        'Sending file: $filename')
                  : 'Scheduled file: $filename',
            ),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      debugLog('Send file error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              S.of(context)?.chatSendFileFailed(e.toString()) ??
                  'Failed to send file: $e',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _sendOriginalImageAsFile(
    XFile image, {
    DateTime? scheduledAt,
  }) async {
    try {
      var filename = image.name.trim();
      if (filename.isEmpty) {
        filename = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      }

      Uint8List? imageBytes;
      String? filePath;
      if (image.path.isNotEmpty && !kIsWeb) {
        filePath = image.path;
      }

      int fileSize;
      if (filePath != null) {
        fileSize = await File(filePath).length();
      } else {
        imageBytes = await image.readAsBytes();
        fileSize = imageBytes.length;
      }

      final mimeType = _resolveMimeType(
        filename: filename,
        sourcePath: filePath,
        headerBytes: imageBytes,
        fallbackMimeType: 'image/jpeg',
      );
      filename = _ensureFilenameMatchesMimeType(filename, mimeType);

      await _queueFileMessage(
        filename: filename,
        mimeType: mimeType,
        fileSize: fileSize,
        fileBytes: imageBytes,
        filePath: filePath,
        scheduledAt: scheduledAt,
      );

      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            scheduledAt == null
                ? 'Sending original image: $filename'
                : 'Scheduled original image: $filename',
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e) {
      debugLog('Send original image as file error: $e');
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send original image: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _sendVoiceMessage(String path, Duration duration) async {
    debugLog(
      'Sending voice message: path=$path, duration=${duration.inSeconds}s',
    );

    try {
      final file = File(path);
      if (!await file.exists()) {
        debugLog('Voice file not found: $path');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                S.of(context)?.chatVoiceFileNotExist ??
                    'Voice file does not exist',
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      final fileSize = await file.length();
      debugLog('Voice file size: $fileSize bytes');

      if (fileSize == 0) {
        debugLog('Voice file is empty');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                S.of(context)?.chatVoiceFileEmpty ?? 'Voice file is empty',
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      final bytes = await file.readAsBytes();
      final filename = path.split(Platform.pathSeparator).last;

      // 根据文件扩展名确定 MIME 类型
      String mimeType = 'audio/mp4';
      if (filename.endsWith('.m4a')) {
        mimeType = 'audio/mp4';
      } else if (filename.endsWith('.ogg')) {
        mimeType = 'audio/ogg';
      } else if (filename.endsWith('.wav')) {
        mimeType = 'audio/wav';
      } else if (filename.endsWith('.mp3')) {
        mimeType = 'audio/mpeg';
      }

      debugLog(
        'Sending voice: filename=$filename, mimeType=$mimeType, size=${bytes.length}',
      );

      if (!mounted) return;
      context.read<ChatBloc>().add(
        SendVoiceMessage(
          audioBytes: bytes,
          filename: filename,
          duration: duration.inMilliseconds,
          mimeType: mimeType,
        ),
      );

      // 删除临时文件
      try {
        await file.delete();
        debugLog('Temporary voice file deleted');
      } catch (e) {
        debugLog('Failed to delete temp file: $e');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              S.of(context)?.chatSendingVoice ?? 'Sending voice...',
            ),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e, stackTrace) {
      debugLog('Send voice message error: $e');
      debugLog('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              S.of(context)?.chatSendVoiceFailed(e.toString()) ??
                  'Failed to send voice: $e',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<Uint8List> _readAllBytes(Stream<List<int>> stream) async {
    final builder = BytesBuilder(copy: false);
    await for (final chunk in stream) {
      builder.add(chunk);
    }
    return builder.takeBytes();
  }

  Future<void> _queueFileMessage({
    required String filename,
    required String mimeType,
    required int fileSize,
    Uint8List? fileBytes,
    String? filePath,
    Stream<List<int>>? fileStream,
    DateTime? scheduledAt,
  }) async {
    if (!mounted) {
      return;
    }

    if (widget.conversation.isEncrypted &&
        fileSize > _maxEncryptedRoomFileBytes) {
      throw Exception(
        'Encrypted rooms currently support secure file uploads up to 64MB',
      );
    }

    if (scheduledAt != null) {
      await _scheduleLocalAttachmentDraft(
        type: MessageType.file,
        scheduledAt: scheduledAt,
        filename: filename,
        mimeType: mimeType,
        fileBytes: fileBytes,
        filePath: filePath,
        fileStream: fileStream,
        fileSize: fileSize,
      );
      return;
    }

    final chatBloc = context.read<ChatBloc>();

    if (widget.conversation.isEncrypted) {
      final secureBytes = await _resolveFileBytes(
        fileBytes: fileBytes,
        filePath: filePath,
        fileStream: fileStream,
      );
      if (!mounted) {
        return;
      }
      if (secureBytes == null || secureBytes.isEmpty) {
        throw Exception('No readable file source available');
      }

      chatBloc.add(
        SendFileMessage(
          fileBytes: secureBytes,
          filename: filename,
          mimeType: mimeType,
          fileSize: fileSize,
        ),
      );
      return;
    }

    if (filePath != null && filePath.isNotEmpty) {
      chatBloc.add(
        SendFileMessage(
          filename: filename,
          mimeType: mimeType,
          filePath: filePath,
          fileSize: fileSize,
        ),
      );
      return;
    }

    if (fileStream != null) {
      chatBloc.add(
        SendFileMessage(
          filename: filename,
          mimeType: mimeType,
          fileStream: fileStream,
          fileSize: fileSize,
        ),
      );
      return;
    }

    if (fileBytes != null && fileBytes.isNotEmpty) {
      chatBloc.add(
        SendFileMessage(
          fileBytes: fileBytes,
          filename: filename,
          mimeType: mimeType,
          fileSize: fileSize,
        ),
      );
      return;
    }

    throw Exception('No readable file source available');
  }

  Future<Uint8List?> _resolveFileBytes({
    Uint8List? fileBytes,
    String? filePath,
    Stream<List<int>>? fileStream,
  }) async {
    if (fileBytes != null && fileBytes.isNotEmpty) {
      return fileBytes;
    }
    if (filePath != null && filePath.isNotEmpty) {
      return File(filePath).readAsBytes();
    }
    if (fileStream != null) {
      return _readAllBytes(fileStream);
    }
    return null;
  }

  Future<void> _scheduleLocalAttachmentDraft({
    required MessageType type,
    required DateTime scheduledAt,
    required String filename,
    required String mimeType,
    Uint8List? fileBytes,
    String? filePath,
    Stream<List<int>>? fileStream,
    int? fileSize,
    int? selfDestructAfter,
  }) async {
    final persisted = await _persistScheduledAttachment(
      filename: filename,
      fileBytes: fileBytes,
      filePath: filePath,
      fileStream: fileStream,
      fileSize: fileSize,
    );

    if (!mounted) {
      return;
    }

    context.read<ChatBloc>().add(
      SendScheduledMessage(
        text: filename,
        type: type,
        payload: {
          'localPath': persisted.localPath,
          'filename': filename,
          'mimeType': mimeType,
          'fileSize': persisted.fileSize,
        },
        scheduledAt: scheduledAt,
        selfDestructAfter: selfDestructAfter,
      ),
    );
  }

  Future<_PersistedScheduledAttachment> _persistScheduledAttachment({
    required String filename,
    Uint8List? fileBytes,
    String? filePath,
    Stream<List<int>>? fileStream,
    int? fileSize,
  }) async {
    final targetDirectory = await _ensureScheduledAttachmentDirectory();
    final targetFile = File(
      '${targetDirectory.path}/${_buildScheduledAttachmentFilename(filename)}',
    );

    if (filePath != null && filePath.isNotEmpty) {
      final sourceFile = File(filePath);
      if (!await sourceFile.exists()) {
        throw FileSystemException(
          'Scheduled attachment source is no longer readable',
          filePath,
        );
      }

      final copiedFile = await sourceFile.copy(targetFile.path);
      return _PersistedScheduledAttachment(
        localPath: copiedFile.path,
        fileSize: fileSize ?? await copiedFile.length(),
      );
    }

    final resolvedBytes = await _resolveFileBytes(
      fileBytes: fileBytes,
      filePath: filePath,
      fileStream: fileStream,
    );
    if (resolvedBytes == null || resolvedBytes.isEmpty) {
      throw Exception('No readable file source available');
    }

    await targetFile.writeAsBytes(resolvedBytes, flush: true);
    return _PersistedScheduledAttachment(
      localPath: targetFile.path,
      fileSize: fileSize ?? resolvedBytes.length,
    );
  }

  Future<Directory> _ensureScheduledAttachmentDirectory() async {
    final appSupportDir = await getApplicationSupportDirectory();
    final directory = Directory('${appSupportDir.path}/scheduled_attachments');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  String _buildScheduledAttachmentFilename(String filename) {
    final sanitized = filename
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
        .replaceAll(' ', '_');
    return '${DateTime.now().microsecondsSinceEpoch}_$sanitized';
  }

  void _showScheduledAttachmentSnackBar(String filename, DateTime scheduledAt) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Scheduled $filename for ${scheduledAt.month}/${scheduledAt.day} '
          '${scheduledAt.hour.toString().padLeft(2, '0')}:'
          '${scheduledAt.minute.toString().padLeft(2, '0')}',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _resolveMimeType({
    required String filename,
    String? sourcePath,
    Uint8List? headerBytes,
    required String fallbackMimeType,
  }) {
    return lookupMimeType(sourcePath ?? filename, headerBytes: headerBytes) ??
        lookupMimeType(filename, headerBytes: headerBytes) ??
        (sourcePath != null ? lookupMimeType(sourcePath) : null) ??
        fallbackMimeType;
  }

  String _ensureFilenameMatchesMimeType(String filename, String mimeType) {
    final extension = switch (mimeType) {
      'image/jpeg' => '.jpg',
      'image/png' => '.png',
      'image/gif' => '.gif',
      'image/webp' => '.webp',
      'image/heic' => '.heic',
      'image/heif' => '.heif',
      _ => '',
    };
    if (extension.isEmpty) {
      return filename;
    }
    if (filename.toLowerCase().endsWith(extension)) {
      return filename;
    }
    final dotIndex = filename.lastIndexOf('.');
    if (dotIndex <= 0) {
      return '$filename$extension';
    }
    return '${filename.substring(0, dotIndex)}$extension';
  }
}
