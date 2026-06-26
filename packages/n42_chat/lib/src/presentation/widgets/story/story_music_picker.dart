import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/debug_log.dart';

/// Story 音乐选择/搜索组件
///
/// 支持从设备本地音乐库选择音乐
/// 播放 15 秒片段预览
class StoryMusicPicker extends StatefulWidget {
  /// 选择音乐回调
  final void Function(StoryMusicSelection selection)? onMusicSelected;

  /// 取消回调
  final VoidCallback? onCancel;

  /// 当前已选音乐路径
  final String? currentMusicPath;

  const StoryMusicPicker({
    super.key,
    this.onMusicSelected,
    this.onCancel,
    this.currentMusicPath,
  });

  @override
  State<StoryMusicPicker> createState() => _StoryMusicPickerState();
}

class _StoryMusicPickerState extends State<StoryMusicPicker> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  String? _selectedFilePath;
  String? _selectedFileName;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  StreamSubscription<Duration>? _durationSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<void>? _completeSubscription;

  @override
  void dispose() {
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _completeSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _pickMusic() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.path != null) {
          if (!mounted) return;
          setState(() {
            _selectedFilePath = file.path;
            _selectedFileName = file.name;
          });
          await _previewMusic(file.path!);
        }
      }
    } catch (e) {
      debugLog('StoryMusicPicker: Pick failed: $e');
    }
  }

  Future<void> _previewMusic(String path) async {
    try {
      await _audioPlayer.stop();
      // 取消旧的订阅，避免内存泄漏
      unawaited(_durationSubscription?.cancel());
      unawaited(_positionSubscription?.cancel());
      unawaited(_completeSubscription?.cancel());

      await _audioPlayer.setSource(DeviceFileSource(path));
      _durationSubscription = _audioPlayer.onDurationChanged.listen((d) {
        if (mounted) setState(() => _duration = d);
      });
      _positionSubscription = _audioPlayer.onPositionChanged.listen((p) {
        if (mounted) {
          setState(() => _position = p);
          // 最多预览 15 秒
          if (p.inSeconds >= 15) {
            _audioPlayer.stop();
            setState(() => _isPlaying = false);
          }
        }
      });
      _completeSubscription = _audioPlayer.onPlayerComplete.listen((_) {
        if (mounted) setState(() => _isPlaying = false);
      });
      await _audioPlayer.resume();
      if (!mounted) return;
      setState(() => _isPlaying = true);
    } catch (e) {
      debugLog('StoryMusicPicker: Preview failed: $e');
    }
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.resume();
    }
    if (!mounted) return;
    setState(() => _isPlaying = !_isPlaying);
  }

  void _confirmSelection() {
    if (_selectedFilePath != null) {
      widget.onMusicSelected?.call(
        StoryMusicSelection(
          filePath: _selectedFilePath!,
          fileName: _selectedFileName ?? 'Unknown',
          duration: _duration,
        ),
      );
    }
  }

  void _removeMusic() {
    _audioPlayer.stop();
    setState(() {
      _selectedFilePath = null;
      _selectedFileName = null;
      _isPlaying = false;
    });
    widget.onMusicSelected?.call(const StoryMusicSelection.empty());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final l10n = S.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 标题
          Row(
            children: [
              const Icon(Icons.music_note, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n?.storyBackgroundMusic ?? 'Background Music',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: widget.onCancel,
                child: Text(l10n?.commonCancel ?? 'Cancel'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 已选音乐预览
          if (_selectedFilePath != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: isDark ? 0.1 : 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  // 播放/暂停按钮
                  GestureDetector(
                    onTap: _togglePlayPause,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 音乐信息
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedFileName ?? 'Unknown',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        // 进度条
                        LinearProgressIndicator(
                          value: _duration.inMilliseconds > 0
                              ? _position.inMilliseconds /
                                    _duration.inMilliseconds
                              : 0,
                          backgroundColor: AppColors.primary.withValues(
                            alpha: 0.2,
                          ),
                          valueColor: const AlwaysStoppedAnimation(
                            AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_formatDuration(_position)} / ${_formatDuration(_duration)} ${l10n?.storyMusicPreview ?? "(max 15s)"}',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.white38 : Colors.black38,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 删除按钮
                  IconButton(
                    onPressed: _removeMusic,
                    icon: const Icon(Icons.close, size: 18, color: AppColors.error),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // 选择音乐按钮
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _pickMusic,
              icon: const Icon(Icons.library_music_outlined),
              label: Text(
                _selectedFilePath != null
                    ? (l10n?.storyChangeMusic ?? 'Change Music')
                    : (l10n?.storyChooseFromDevice ?? 'Choose from Device'),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 确认按钮
          if (_selectedFilePath != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _confirmSelection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(l10n?.storyUseThisMusic ?? 'Use This Music'),
              ),
            ),

          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

/// Story 音乐选择结果
class StoryMusicSelection {
  final String? filePath;
  final String fileName;
  final Duration duration;
  final bool isEmpty;

  const StoryMusicSelection({
    this.filePath,
    this.fileName = '',
    this.duration = Duration.zero,
    this.isEmpty = false,
  });

  const StoryMusicSelection.empty()
    : filePath = null,
      fileName = '',
      duration = Duration.zero,
      isEmpty = true;
}
