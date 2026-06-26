import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/voip/incoming_call_ringtone_preference.dart';
import '../../../services/ringtone/system_ringtone_service.dart';
import '../../../core/utils/debug_log.dart';

class RingtoneSelectPage extends StatefulWidget {
  final String currentRingtone;

  const RingtoneSelectPage({super.key, required this.currentRingtone});

  @override
  State<RingtoneSelectPage> createState() => RingtoneSelectPageState();
}

class RingtoneSelectPageState extends State<RingtoneSelectPage> {
  late String _selectedRingtone;
  String? _selectedRingtoneKey;
  String? _playingRingtone;
  bool _isLoading = true;
  bool _hasLoadedRingtones = false;
  List<RingtoneItem> _ringtones = [];

  final _ringtoneService = SystemRingtoneService.instance;

  @override
  void initState() {
    super.initState();
    _selectedRingtone = widget.currentRingtone;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 只加载一次，避免重复调用
    if (!_hasLoadedRingtones) {
      _hasLoadedRingtones = true;
      _loadRingtones();
    }
  }

  /// 加载系统铃声
  Future<void> _loadRingtones() async {
    try {
      // RingtoneManager 获取系统铃声不需要 READ_MEDIA_AUDIO 权限
      // 该权限仅用于访问用户设备上的音乐文件，而非系统铃声
      final s = S.of(context);
      final systemRingtones = await _ringtoneService.getAvailableRingtones();
      final storedPreference =
          await IncomingCallRingtonePreference.loadIfPresent();

      final ringtoneItems = <RingtoneItem>[];

      // 添加系统铃声
      for (final ringtone in systemRingtones) {
        ringtoneItems.add(RingtoneItem(
          key: ringtone.id,
          name: ringtone.title,
          icon: ringtone.isDefault ? Icons.music_note : Icons.audiotrack,
          uri: ringtone.uri,
          isSystemRingtone: true,
          isDefault: ringtone.isDefault,
        ));
      }

      // 添加振动和静音选项
      ringtoneItems.add(RingtoneItem(
        key: 'vibrate',
        name: s?.profileRingtoneVibrate ?? 'Vibrate',
        icon: Icons.vibration,
        uri: null,
        isSystemRingtone: false,
      ));

      ringtoneItems.add(RingtoneItem(
        key: 'silent',
        name: s?.profileRingtoneSilent ?? 'Silent',
        icon: Icons.volume_off,
        uri: null,
        isSystemRingtone: false,
      ));

      if (mounted) {
        final selectedItem =
            _resolveSelectedItem(ringtoneItems, storedPreference) ??
            ringtoneItems.where(
              (item) => item.name == _selectedRingtone,
            ).firstOrNull;
        setState(() {
          _ringtones = ringtoneItems;
          _selectedRingtoneKey = selectedItem?.key ?? ringtoneItems.firstOrNull?.key;
          _selectedRingtone = selectedItem?.name ?? _selectedRingtone;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugLog('加载铃声失败: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _stopRingtone();
    super.dispose();
  }

  /// 播放铃声
  Future<void> _playRingtone(RingtoneItem ringtone) async {
    // 先停止当前播放
    await _stopRingtone();

    if (!mounted) return;
    final s = S.of(context);

    // 如果是振动，触发振动
    if (ringtone.key == 'vibrate') {
      unawaited(HapticFeedback.heavyImpact());
      await Future<void>.delayed(const Duration(milliseconds: 100));
      unawaited(HapticFeedback.heavyImpact());
      await Future<void>.delayed(const Duration(milliseconds: 100));
      unawaited(HapticFeedback.heavyImpact());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(s?.profileVibrateMode ?? 'Vibrate mode'),
            duration: const Duration(milliseconds: 800),
          ),
        );
      }
      return;
    }

    // 如果是静音，不播放
    if (ringtone.key == 'silent') {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(s?.profileSilentMode ?? 'Silent mode'),
            duration: const Duration(milliseconds: 800),
          ),
        );
      }
      return;
    }

    // 如果没有 URI，不播放
    if (ringtone.uri == null) {
      return;
    }

    setState(() {
      _playingRingtone = ringtone.name;
    });

    try {
      // 使用系统铃声服务播放
      final success = await _ringtoneService.playRingtone(ringtone.uri!);

      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(s?.profilePlayFailed(ringtone.name) ?? 'Failed to play: ${ringtone.name}'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 1),
          ),
        );
        setState(() {
          _playingRingtone = null;
        });
        return;
      }

      // 显示播放提示
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.play_arrow, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    s?.profilePlaying(ringtone.name) ?? 'Playing: ${ringtone.name}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: s?.profileStop ?? 'Stop',
              textColor: Colors.white,
              onPressed: _stopRingtone,
            ),
          ),
        );
      }

      // 5秒后自动停止
      await Future<void>.delayed(const Duration(seconds: 5));
      if (mounted && _playingRingtone == ringtone.name) {
        await _stopRingtone();
      }
    } catch (e) {
      debugLog('播放铃声失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(s?.profilePlayFailed(ringtone.name) ?? 'Failed to play: ${ringtone.name}'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 1),
          ),
        );
        setState(() {
          _playingRingtone = null;
        });
      }
    }
  }

  /// 停止铃声
  Future<void> _stopRingtone() async {
    try {
      await _ringtoneService.stopRingtone();
    } catch (e) {
      debugLog('停止铃声失败: $e');
    }
    if (mounted && _playingRingtone != null) {
      setState(() {
        _playingRingtone = null;
      });
    }
  }

  RingtoneItem? _resolveSelectedItem(
    List<RingtoneItem> items,
    IncomingCallRingtonePreference? preference,
  ) {
    if (preference == null) return null;

    final key = switch (preference.mode) {
      IncomingCallRingtoneMode.silent => 'silent',
      IncomingCallRingtoneMode.vibrate => 'vibrate',
      IncomingCallRingtoneMode.system => preference.sourceKey,
    };

    if (key != null && key.isNotEmpty) {
      final byKey = items.where((item) => item.key == key).firstOrNull;
      if (byKey != null) return byKey;
    }

    return items.where((item) => item.name == preference.label).firstOrNull;
  }

  /// 确认保存
  Future<void> _confirmSave() async {
    final selectedItem = _ringtones.where(
      (item) => item.key == _selectedRingtoneKey,
    ).firstOrNull;
    if (selectedItem != null) {
      await IncomingCallRingtonePreference.saveSelection(
        key: selectedItem.key,
        label: selectedItem.name,
        isSystemRingtone: selectedItem.isSystemRingtone,
        isDefault: selectedItem.isDefault,
      );
    }
    if (!mounted) return;
    Navigator.pop(context, _selectedRingtone);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final s = S.of(context);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: context.surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: context.textPrimary,
          ),
          onPressed: () => Navigator.pop(context), // 取消不保存
        ),
        title: Text(
          s?.profileSelectRingtone ?? 'Select Ringtone',
          style: TextStyle(
            color: context.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _confirmSave,
            child: Text(
              s?.commonConfirm ?? 'Confirm',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    s?.profileLoadingRingtones ?? 'Loading ringtones...',
                    style: TextStyle(
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          : _ringtones.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.music_off,
                        size: 64,
                        color: context.textTertiary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        s?.profileNoRingtonesFound ?? 'No ringtones found',
                        style: TextStyle(
                          color: context.textTertiary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _ringtones.length,
                  itemBuilder: (context, index) {
                    final ringtone = _ringtones[index];
                    final isSelected = ringtone.key == _selectedRingtoneKey;
                    final isPlaying = ringtone.name == _playingRingtone;

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: context.surfaceColor,
                        borderRadius: BorderRadius.circular(8),
                        border: isSelected
                            ? Border.all(color: AppColors.primary, width: 2)
                            : null,
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isPlaying
                                ? AppColors.primary.withValues(alpha: 0.2)
                                : (isDark ? const Color(0xFF3A3A3C) : const Color(0xFFF2F2F7)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            isPlaying ? Icons.pause : ringtone.icon,
                            color: isPlaying ? AppColors.primary : context.textSecondary,
                          ),
                        ),
                        title: Text(
                          ringtone.name,
                          style: TextStyle(
                            color: context.textPrimary,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 试听按钮
                            if (ringtone.uri != null || ringtone.key == 'vibrate')
                              IconButton(
                                icon: Icon(
                                  isPlaying ? Icons.stop : Icons.play_circle_outline,
                                  color: AppColors.primary,
                                ),
                                onPressed: () {
                                  if (isPlaying) {
                                    _stopRingtone();
                                  } else {
                                    _playRingtone(ringtone);
                                  }
                                },
                              ),
                            // 选中标记
                            if (isSelected)
                              const Icon(
                                Icons.check_circle,
                                color: AppColors.primary,
                              ),
                          ],
                        ),
                        onTap: () {
                          setState(() {
                            _selectedRingtone = ringtone.name;
                            _selectedRingtoneKey = ringtone.key;
                          });
                          // 选中后自动试听
                          _playRingtone(ringtone);
                        },
                      ),
                    );
                  },
                ),
    );
  }
}

/// 铃声项数据模型
class RingtoneItem {
  final String key;
  final String name;
  final IconData icon;
  final String? uri;
  final bool isSystemRingtone;
  final bool isDefault;

  const RingtoneItem({
    required this.key,
    required this.name,
    required this.icon,
    this.uri,
    this.isSystemRingtone = false,
    this.isDefault = false,
  });
}
