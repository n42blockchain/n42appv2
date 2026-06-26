import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../domain/entities/moment_entity.dart';
import '../../blocs/contact/contact_bloc.dart';
import '../../blocs/moment/moment_bloc.dart';
import '../../blocs/moment/moment_event.dart';
import '../../blocs/moment/moment_state.dart';
import '../media/social_image_preparation.dart';
import 'visibility_selection_page.dart';
import '../../../core/utils/debug_log.dart';

const _kLastVisibilityKey = 'moment_last_visibility';

/// 发布动态页面
class CreateMomentPage extends StatefulWidget {
  final bool autoPickImages;

  const CreateMomentPage({super.key, this.autoPickImages = false});

  @override
  State<CreateMomentPage> createState() => _CreateMomentPageState();
}

class _CreateMomentPageState extends State<CreateMomentPage> {
  final TextEditingController _contentController = TextEditingController();
  final List<_MediaItem> _selectedMedia = [];
  MomentLocation? _location;
  MomentVisibility _visibility = MomentVisibility.public;
  List<String> _visibilityUserIds = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadLastVisibility();
    if (widget.autoPickImages) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _pickImages();
      });
    }
  }

  Future<void> _loadLastVisibility() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_kLastVisibilityKey);
      if (saved != null && mounted) {
        final v = MomentVisibility.values.firstWhere(
          (e) => e.name == saved,
          orElse: () => MomentVisibility.public,
        );
        // partial/excluded 需要重新选择好友，只恢复 public/private
        if (v == MomentVisibility.public || v == MomentVisibility.private) {
          setState(() => _visibility = v);
        }
      }
    } catch (e) {
      debugLog('Failed to load last visibility: $e');
    }
  }

  Future<void> _saveLastVisibility(MomentVisibility v) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kLastVisibilityKey, v.name);
    } catch (e) {
      debugLog('Failed to save last visibility: $e');
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s = S.of(context);

    return BlocListener<MomentBloc, MomentState>(
      listenWhen: (previous, current) =>
          previous.isPosting && !current.isPosting,
      listener: (context, state) {
        if (!state.hasError) {
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? 'Error')),
          );
        }
      },
      child: Scaffold(
        backgroundColor: context.pageBackground,
        appBar: AppBar(
          title: const Text('Create Moment'),
          backgroundColor: context.surfaceColor,
          actions: [
            BlocBuilder<MomentBloc, MomentState>(
              buildWhen: (prev, curr) => prev.isPosting != curr.isPosting,
              builder: (context, state) {
                if (state.isPosting) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }

                return ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _contentController,
                  builder: (context, textValue, _) {
                    final canPost =
                        textValue.text.trim().isNotEmpty ||
                        _selectedMedia.isNotEmpty;
                    return TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        disabledForegroundColor: AppColors.textTertiary,
                      ),
                      onPressed: canPost ? _postMoment : null,
                      child: Text(
                        s?.commonSend ?? 'Post',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 文字输入
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.surfaceColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _contentController,
                  maxLines: 5,
                  maxLength: 500,
                  decoration: InputDecoration(
                    hintText: "What's on your mind?",
                    border: InputBorder.none,
                    counterStyle: TextStyle(
                      color: context.textSecondary,
                    ),
                  ),
                  // Text changes are handled by ValueListenableBuilder on the controller
                ),
              ),

              const SizedBox(height: 16),

              // 已选择的媒体
              if (_selectedMedia.isNotEmpty) ...[
                _buildMediaPreview(),
                const SizedBox(height: 16),
              ],

              // 操作按钮
              Container(
                decoration: BoxDecoration(
                  color: context.surfaceColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    _buildOptionTile(
                      icon: Icons.photo_library,
                      title: 'Add Photos',
                      onTap: _pickImages,
                      isDark: isDark,
                    ),
                    Divider(
                      height: 1,
                      color: context.dividerColor,
                    ),
                    _buildOptionTile(
                      icon: Icons.videocam,
                      title: 'Add Video',
                      onTap: _pickVideo,
                      isDark: isDark,
                    ),
                    Divider(
                      height: 1,
                      color: context.dividerColor,
                    ),
                    _buildOptionTile(
                      icon: Icons.location_on,
                      title: _location?.displayText ?? 'Add Location',
                      onTap: _selectLocation,
                      isDark: isDark,
                      trailing: _location != null
                          ? IconButton(
                              icon: const Icon(Icons.close, size: 20),
                              onPressed: () => setState(() => _location = null),
                            )
                          : null,
                    ),
                    Divider(
                      height: 1,
                      color: context.dividerColor,
                    ),
                    _buildOptionTile(
                      icon: Icons.visibility,
                      title: _getVisibilityText(s),
                      onTap: _selectVisibility,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMediaPreview() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Selected Media (${_selectedMedia.length})',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: context.textPrimary,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => setState(() => _selectedMedia.clear()),
                child: const Text('Clear All'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _selectedMedia.length,
            itemBuilder: (context, index) {
              final media = _selectedMedia[index];
              return Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: media.isVideo
                        ? (media.thumbnailBytes != null
                              ? Image.memory(
                                  media.thumbnailBytes!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) =>
                                      Container(color: Colors.grey[850]),
                                )
                              : Container(color: Colors.grey[850]))
                        : Image.memory(media.bytes, fit: BoxFit.cover),
                  ),
                  if (media.isVideo)
                    const Center(
                      child: Icon(
                        Icons.play_circle_filled,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _selectedMedia.removeAt(index)),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isDark,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: context.textSecondary),
      title: Text(
        title,
        style: TextStyle(color: context.textPrimary),
      ),
      trailing:
          trailing ??
          Icon(
            AppIcons.chevron,
            color: context.textTertiary,
          ),
      onTap: onTap,
    );
  }

  String _getVisibilityText(S? s) {
    switch (_visibility) {
      case MomentVisibility.public:
        return s?.momentVisibilityPublic ?? 'Public';
      case MomentVisibility.private:
        return s?.momentVisibilityPrivate ?? 'Private';
      case MomentVisibility.partial:
        if (_visibilityUserIds.isNotEmpty) {
          return '${s?.momentVisibilityPartial ?? 'Selected Friends'} (${_visibilityUserIds.length})';
        }
        return s?.momentVisibilityPartial ?? 'Selected Friends';
      case MomentVisibility.excluded:
        if (_visibilityUserIds.isNotEmpty) {
          return '${s?.momentVisibilityExcluded ?? 'Exclude Some Friends'} (${_visibilityUserIds.length})';
        }
        return s?.momentVisibilityExcluded ?? 'Exclude Some Friends';
    }
  }

  Future<void> _pickImages() async {
    final images = await _picker.pickMultiImage(
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );

    if (images.isNotEmpty) {
      if (!mounted) return;
      if (_selectedMedia.any((m) => m.isVideo)) {
        setState(() => _selectedMedia.clear());
      }
      final shouldOpenEditor = images.length == 1;
      for (final image in images) {
        if (_selectedMedia.length >= 9) break;

        final prepared = await prepareSocialImage(
          context,
          image: image,
          openEditor: shouldOpenEditor,
        );
        if (prepared == null || !mounted) {
          if (shouldOpenEditor) {
            return;
          }
          continue;
        }

        setState(() {
          _selectedMedia.add(
            _MediaItem(
              bytes: prepared.bytes,
              filename: prepared.filename,
              mimeType: prepared.mimeType,
              isVideo: false,
            ),
          );
        });
      }
    }
  }

  Future<void> _pickVideo() async {
    final video = await _picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(minutes: 5),
    );

    if (video != null) {
      final bytes = await video.readAsBytes();

      // 提取视频首帧作为缩略图（Matrix thumbnail API 不支持视频）
      Uint8List? thumbnailBytes;
      try {
        thumbnailBytes = await VideoThumbnail.thumbnailData(
          video: video.path,
          imageFormat: ImageFormat.JPEG,
          maxWidth: 640,
          quality: 80,
          timeMs: 0,
        );
      } catch (e) {
        debugLog('Failed to extract video thumbnail: $e');
      }

      setState(() {
        _selectedMedia.clear();
        _selectedMedia.add(
          _MediaItem(
            bytes: bytes,
            thumbnailBytes: thumbnailBytes,
            filename: video.name,
            mimeType: video.mimeType,
            isVideo: true,
          ),
        );
      });
    }
  }

  Future<void> _selectLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      final resolved = (permission == LocationPermission.denied)
          ? await Geolocator.requestPermission()
          : permission;
      if (!mounted) return;
      if (resolved == LocationPermission.deniedForever ||
          resolved == LocationPermission.denied) {
        debugLog('_selectLocation: location permission denied');
        setState(() => _location = null);
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );
      if (!mounted) return;
      setState(() {
        _location = MomentLocation(
          latitude: pos.latitude,
          longitude: pos.longitude,
        );
      });
    } catch (e) {
      debugLog('_selectLocation error: $e');
      if (!mounted) return;
      setState(() => _location = null);
    }
  }

  void _selectVisibility() {
    final s = S.of(context);
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.public),
              title: Text(s?.momentVisibilityPublic ?? 'Public'),
              subtitle: const Text('All friends can see'),
              trailing: _visibility == MomentVisibility.public
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                setState(() {
                  _visibility = MomentVisibility.public;
                  _visibilityUserIds = [];
                });
                unawaited(_saveLastVisibility(MomentVisibility.public));
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.lock),
              title: Text(s?.momentVisibilityPrivate ?? 'Private'),
              subtitle: const Text('Only you can see'),
              trailing: _visibility == MomentVisibility.private
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                setState(() {
                  _visibility = MomentVisibility.private;
                  _visibilityUserIds = [];
                });
                unawaited(_saveLastVisibility(MomentVisibility.private));
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.group),
              title: Text(s?.momentVisibilityPartial ?? 'Selected Friends'),
              subtitle: const Text('Choose who can see'),
              trailing: _visibility == MomentVisibility.partial
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                Navigator.pop(ctx);
                _selectVisibilityFriends(MomentVisibility.partial);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_off),
              title: Text(
                s?.momentVisibilityExcluded ?? 'Exclude Some Friends',
              ),
              subtitle: const Text('Hide from specific friends'),
              trailing: _visibility == MomentVisibility.excluded
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                Navigator.pop(ctx);
                _selectVisibilityFriends(MomentVisibility.excluded);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectVisibilityFriends(MomentVisibility visibility) async {
    // 获取 ContactBloc（如果可用）
    ContactBloc? contactBloc;
    try {
      contactBloc = context.read<ContactBloc>();
    } catch (e) {
      debugLog('Error: $e');
    }

    final result = await Navigator.of(context).push<List<String>>(
      MaterialPageRoute<List<String>>(
        builder: (ctx) {
          final page = VisibilitySelectionPage(
            initialSelectedIds: _visibility == visibility
                ? _visibilityUserIds
                : [],
            title: visibility == MomentVisibility.partial
                ? (S.of(context)?.momentVisibilityPartial ?? 'Selected Friends')
                : (S.of(context)?.momentVisibilityExcluded ??
                      'Exclude Some Friends'),
          );
          if (contactBloc != null) {
            return BlocProvider.value(value: contactBloc, child: page);
          }
          return page;
        },
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        _visibility = visibility;
        _visibilityUserIds = result;
      });
      unawaited(_saveLastVisibility(visibility));
    }
  }

  void _postMoment() {
    final bloc = context.read<MomentBloc>();

    if (_selectedMedia.isEmpty) {
      // 纯文字动态
      bloc.add(
        PostTextMoment(
          content: _contentController.text.trim(),
          location: _location,
          visibility: _visibility,
        ),
      );
    } else if (_selectedMedia.first.isVideo) {
      // 视频动态
      final video = _selectedMedia.first;
      bloc.add(
        PostVideoMoment(
          content: _contentController.text.trim().isEmpty
              ? null
              : _contentController.text.trim(),
          videoBytes: video.bytes,
          thumbnailBytes: video.thumbnailBytes,
          filename: video.filename,
          mimeType: video.mimeType,
          location: _location,
          visibility: _visibility,
        ),
      );
    } else {
      // 图片动态
      final images = _selectedMedia
          .map(
            (m) => MomentImageInput(
              bytes: m.bytes,
              filename: m.filename,
              mimeType: m.mimeType,
            ),
          )
          .toList();

      bloc.add(
        PostImageMoment(
          content: _contentController.text.trim().isEmpty
              ? null
              : _contentController.text.trim(),
          images: images,
          location: _location,
          visibility: _visibility,
        ),
      );
    }
  }
}

/// 媒体项
class _MediaItem {
  final Uint8List bytes;

  /// 视频缩略图帧（使用 video_thumbnail 提取的首帧 JPEG）
  final Uint8List? thumbnailBytes;
  final String filename;
  final String? mimeType;
  final bool isVideo;

  const _MediaItem({
    required this.bytes,
    this.thumbnailBytes,
    required this.filename,
    this.mimeType,
    required this.isVideo,
  });
}
