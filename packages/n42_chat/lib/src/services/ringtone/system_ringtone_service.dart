import 'package:flutter/services.dart';
import '../../core/utils/debug_log.dart';

/// 系统铃声信息
class SystemRingtone {
  final String id;
  final String title;
  final String uri;
  final bool isDefault;

  const SystemRingtone({
    required this.id,
    required this.title,
    required this.uri,
    this.isDefault = false,
  });

  factory SystemRingtone.fromMap(Map<dynamic, dynamic> map) {
    return SystemRingtone(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? 'Unknown',
      uri: map['uri'] as String? ?? '',
      isDefault: map['isDefault'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'uri': uri,
      'isDefault': isDefault,
    };
  }

  @override
  String toString() => 'SystemRingtone(id: $id, title: $title, isDefault: $isDefault)';
}

/// 系统铃声服务
///
/// 通过平台通道获取和播放设备系统铃声
class SystemRingtoneService {
  static const MethodChannel _channel = MethodChannel('n42_chat/ringtone');

  static SystemRingtoneService? _instance;
  static SystemRingtoneService get instance => _instance ??= SystemRingtoneService._();

  SystemRingtoneService._();

  List<SystemRingtone>? _cachedRingtones;

  /// 获取系统可用的铃声列表
  Future<List<SystemRingtone>> getAvailableRingtones() async {
    // 使用缓存避免重复查询
    if (_cachedRingtones != null) {
      return _cachedRingtones!;
    }

    try {
      final List<dynamic>? result = await _channel.invokeMethod('getAvailableRingtones');
      if (result == null) {
        debugLog('SystemRingtoneService: No ringtones returned from platform');
        return _getDefaultRingtones();
      }

      _cachedRingtones = result
          .map((e) => SystemRingtone.fromMap(e as Map<dynamic, dynamic>))
          .toList();

      debugLog('SystemRingtoneService: Found ${_cachedRingtones!.length} ringtones');
      return _cachedRingtones!;
    } on PlatformException catch (e) {
      debugLog('SystemRingtoneService: Platform error - ${e.message}');
      return _getDefaultRingtones();
    } on MissingPluginException catch (e) {
      debugLog('SystemRingtoneService: Plugin not implemented - $e');
      return _getDefaultRingtones();
    } catch (e) {
      debugLog('SystemRingtoneService: Error getting ringtones - $e');
      return _getDefaultRingtones();
    }
  }

  /// 播放指定铃声
  Future<bool> playRingtone(String uri) async {
    try {
      final result = await _channel.invokeMethod<bool>('playRingtone', {'uri': uri});
      return result ?? false;
    } on PlatformException catch (e) {
      debugLog('SystemRingtoneService: Failed to play ringtone - ${e.message}');
      return false;
    } catch (e) {
      debugLog('SystemRingtoneService: Error playing ringtone - $e');
      return false;
    }
  }

  /// 停止播放铃声
  Future<void> stopRingtone() async {
    try {
      await _channel.invokeMethod('stopRingtone');
    } catch (e) {
      debugLog('SystemRingtoneService: Error stopping ringtone - $e');
    }
  }

  /// 获取默认铃声 URI
  Future<String?> getDefaultRingtoneUri() async {
    try {
      return await _channel.invokeMethod<String>('getDefaultRingtoneUri');
    } catch (e) {
      debugLog('SystemRingtoneService: Error getting default ringtone - $e');
      return null;
    }
  }

  /// 清除缓存
  void clearCache() {
    _cachedRingtones = null;
  }

  /// 默认铃声列表（当平台通道不可用时使用）
  List<SystemRingtone> _getDefaultRingtones() {
    return const [
      SystemRingtone(
        id: 'default',
        title: 'Default',
        uri: 'default',
        isDefault: true,
      ),
    ];
  }
}
