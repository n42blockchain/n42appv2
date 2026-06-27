import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../domain/entities/message_entity.dart';
import '../../../domain/entities/scheduled_message_draft.dart';
import '../../../domain/entities/user_profile_entity.dart';
import '../../../core/utils/debug_log.dart';

/// 偏好设置数据源
///
/// 使用 SharedPreferences 存储非敏感数据（外观、备注、草稿等）。
/// 敏感数据（会话、凭据、账号、生物识别）仍保留在 SecureStorageDataSource 中。
class PreferencesDataSource {
  static const String _keySettings = 'n42_chat_settings';
  static const String _keyContactRemarks = 'n42_chat_contact_remarks';
  static const String _keyAppearanceSettings = 'n42_chat_appearance_settings';
  static const String _keyNotificationSettings =
      'n42_chat_notification_settings';
  static const String _keyStrongReminders = 'n42_chat_strong_reminders';
  static const String _keyLocallyDeletedMessages =
      'n42_chat_locally_deleted_messages';
  static const String _keyMessageDestructionTimes =
      'n42_chat_message_destruction_times';
  static const String _keyPrivacySettings = 'n42_chat_privacy_settings';
  static const String _keyScheduledMessages = 'n42_chat_scheduled_messages';
  static const String _keyMomentSettings = 'n42_chat_moment_settings';
  static const String _keyHiddenMomentUsers = 'n42_chat_hidden_moment_users';
  static const String _keyBlockedMomentUsers = 'n42_chat_blocked_moment_users';
  static const String _keyMomentLastReadTime = 'n42_chat_moment_last_read_time';
  static const String _keyHiddenChats = 'n42_chat_hidden_chats';
  static const String _keyQuickReplies = 'n42_chat_quick_replies';
  static const String _keyTranslationCache = 'n42_chat_translation_cache';
  static const String _keyTranslationSettings = 'n42_chat_translation_settings';
  static const String _keyFavoriteMessages = 'n42_chat_favorite_messages';
  static const String _keyFavoriteMeta = 'n42_chat_favorite_meta';
  static const String _keyChatFolders = 'n42_chat_folders';
  static const Map<String, bool> defaultAutoDownloadSettings = {
    'wifi_images': true,
    'wifi_voice': true,
    'wifi_video': true,
    'wifi_files': true,
    'mobile_images': true,
    'mobile_voice': true,
    'mobile_video': false,
    'mobile_files': false,
    'roaming_images': false,
    'roaming_voice': false,
    'roaming_video': false,
    'roaming_files': false,
  };

  Completer<SharedPreferences>? _prefsCompleter;

  Future<SharedPreferences> get prefs {
    if (_prefsCompleter == null) {
      _prefsCompleter = Completer<SharedPreferences>();
      SharedPreferences.getInstance().then(
        _prefsCompleter!.complete,
        onError: (Object e, StackTrace s) {
          _prefsCompleter!.completeError(e, s);
          // Reset so next access retries instead of returning stale error
          _prefsCompleter = null;
        },
      );
    }
    return _prefsCompleter!.future;
  }

  // ============================================
  // 外观设置
  // ============================================

  /// 保存外观设置
  Future<void> saveAppearanceSettings({
    required String themeMode,
    required String fontSize,
    String? chatBackground,
    required String bubbleStyle,
  }) async {
    final data = {
      'themeMode': themeMode,
      'fontSize': fontSize,
      'chatBackground': chatBackground,
      'bubbleStyle': bubbleStyle,
      'savedAt': DateTime.now().toIso8601String(),
    };

    final p = await prefs;
    await p.setString(_keyAppearanceSettings, jsonEncode(data));

    prefsLog('Appearance settings saved');
  }

  /// 获取外观设置
  Future<Map<String, String?>?> getAppearanceSettings() async {
    try {
      final p = await prefs;
      final data = p.getString(_keyAppearanceSettings);
      if (data == null) return null;

      final json = jsonDecode(data) as Map<String, dynamic>;
      return {
        'themeMode': json['themeMode'] as String?,
        'fontSize': json['fontSize'] as String?,
        'chatBackground': json['chatBackground'] as String?,
        'bubbleStyle': json['bubbleStyle'] as String?,
      };
    } catch (e) {
      prefsLog('Failed to read appearance settings - $e');
      return null;
    }
  }

  /// 保存主题模式
  Future<void> saveThemeMode(String themeMode) async {
    final current = await getAppearanceSettings();
    await saveAppearanceSettings(
      themeMode: themeMode,
      fontSize: current?['fontSize'] ?? 'medium',
      chatBackground: current?['chatBackground'],
      bubbleStyle: current?['bubbleStyle'] ?? 'wechat',
    );
  }

  /// 获取主题模式
  Future<String?> getThemeMode() async {
    final settings = await getAppearanceSettings();
    return settings?['themeMode'];
  }

  Future<void> saveAppearanceSettingsModel(AppearanceSettings settings) async {
    await saveAppearanceSettings(
      themeMode: _themeModeToStorage(settings.themeMode),
      fontSize: settings.fontSize.name,
      chatBackground: settings.chatBackground,
      bubbleStyle: settings.bubbleStyle.name,
    );
  }

  Future<AppearanceSettings> getAppearanceSettingsModel() async {
    final raw = await getAppearanceSettings();
    if (raw == null) {
      return const AppearanceSettings();
    }

    return AppearanceSettings(
      themeMode: _parseThemeMode(raw['themeMode']),
      fontSize: _parseFontSize(raw['fontSize']),
      chatBackground: raw['chatBackground'],
      bubbleStyle: _parseBubbleStyle(raw['bubbleStyle']),
    );
  }

  // ============================================
  // 通知设置
  // ============================================

  Future<void> saveNotificationSettingsModel(
    NotificationSettings settings,
  ) async {
    final p = await prefs;
    await p.setString(
      _keyNotificationSettings,
      jsonEncode({
        'enabled': settings.enabled,
        'showPreview': settings.showPreview,
        'playSound': settings.playSound,
        'vibrate': settings.vibrate,
        'doNotDisturb': settings.doNotDisturb,
        'doNotDisturbStart': settings.doNotDisturbStart,
        'doNotDisturbEnd': settings.doNotDisturbEnd,
        'privacyMode': settings.privacyMode.name,
        'savedAt': DateTime.now().toIso8601String(),
      }),
    );
    prefsLog('Notification settings saved');
  }

  Future<NotificationSettings> getNotificationSettingsModel() async {
    try {
      final p = await prefs;
      final data = p.getString(_keyNotificationSettings);
      if (data == null) {
        return const NotificationSettings();
      }

      final json = jsonDecode(data) as Map<String, dynamic>;
      return NotificationSettings(
        enabled: json['enabled'] as bool? ?? true,
        showPreview: json['showPreview'] as bool? ?? true,
        playSound: json['playSound'] as bool? ?? true,
        vibrate: json['vibrate'] as bool? ?? true,
        doNotDisturb: json['doNotDisturb'] as bool? ?? false,
        doNotDisturbStart: json['doNotDisturbStart'] as String?,
        doNotDisturbEnd: json['doNotDisturbEnd'] as String?,
        privacyMode: NotificationPrivacyMode.values.firstWhere(
          (mode) => mode.name == json['privacyMode'],
          orElse: () => NotificationPrivacyMode.full,
        ),
      );
    } catch (e) {
      prefsLog('Failed to read notification settings - $e');
      return const NotificationSettings();
    }
  }

  ThemeMode _parseThemeMode(String? rawValue) {
    switch (rawValue?.trim().toLowerCase()) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  FontSize _parseFontSize(String? rawValue) {
    switch (rawValue?.trim().toLowerCase()) {
      case 'small':
        return FontSize.small;
      case 'large':
        return FontSize.large;
      case 'extralarge':
      case 'extra_large':
      case 'extra-large':
        return FontSize.extraLarge;
      case 'medium':
      default:
        return FontSize.medium;
    }
  }

  BubbleStyle _parseBubbleStyle(String? rawValue) {
    switch (rawValue?.trim().toLowerCase()) {
      case 'modern':
        return BubbleStyle.modern;
      case 'classic':
        return BubbleStyle.classic;
      case 'wechat':
      default:
        return BubbleStyle.wechat;
    }
  }

  String _themeModeToStorage(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  // ============================================
  // 联系人备注
  // ============================================

  /// 获取所有联系人备注
  Future<Map<String, String>> getContactRemarks() async {
    try {
      final p = await prefs;
      final data = p.getString(_keyContactRemarks);
      if (data == null) return {};

      final json = jsonDecode(data) as Map<String, dynamic>;
      return json.map((key, value) => MapEntry(key, value.toString()));
    } catch (e) {
      prefsLog('Failed to read contact remarks - $e');
      return {};
    }
  }

  /// 设置联系人备注
  ///
  /// 同时更新独立 key（快速单条读取）和批量 JSON（批量读取兼容）。
  Future<void> setContactRemark(String userId, String? remark) async {
    final p = await prefs;

    // 独立 key（供 getContactRemark 快速读取）
    final key = 'n42_chat_remark_$userId';
    if (remark == null || remark.isEmpty) {
      await p.remove(key);
    } else {
      await p.setString(key, remark);
    }

    // 批量 JSON（供 getContactRemarks 批量读取）
    final remarks = await getContactRemarks();
    if (remark == null || remark.isEmpty) {
      remarks.remove(userId);
    } else {
      remarks[userId] = remark;
    }
    await p.setString(_keyContactRemarks, jsonEncode(remarks));

    prefsLog('Contact remark set for $userId');
  }

  /// 获取联系人备注（独立 key，O(1) 读取）
  Future<String?> getContactRemark(String userId) async {
    final p = await prefs;
    return p.getString('n42_chat_remark_$userId');
  }

  /// 删除联系人备注
  Future<void> removeContactRemark(String userId) async {
    await setContactRemark(userId, null);
  }

  // ============================================
  // 强提醒设置
  // ============================================

  /// 获取所有强提醒设置
  Future<Map<String, bool>> getStrongReminders() async {
    try {
      final p = await prefs;
      final data = p.getString(_keyStrongReminders);
      if (data == null) return {};

      final json = jsonDecode(data) as Map<String, dynamic>;
      return json.map(
        (key, value) => MapEntry(key, value == true || value == 'true'),
      );
    } catch (e) {
      prefsLog('Failed to read strong reminders - $e');
      return {};
    }
  }

  /// 设置强提醒
  ///
  /// 同时更新独立 key（快速单条读取）和批量 JSON（批量读取兼容）。
  Future<void> setStrongReminder(String roomId, bool enabled) async {
    final p = await prefs;

    // 独立 key（供 getStrongReminderStatus 快速读取）
    final key = 'n42_chat_strong_reminder_$roomId';
    if (!enabled) {
      await p.remove(key);
    } else {
      await p.setBool(key, true);
    }

    // 批量 JSON（供 getStrongReminders 批量读取）
    final reminders = await getStrongReminders();
    if (!enabled) {
      reminders.remove(roomId);
    } else {
      reminders[roomId] = true;
    }
    await p.setString(_keyStrongReminders, jsonEncode(reminders));

    prefsLog('Strong reminder set for $roomId: $enabled');
  }

  /// 获取强提醒状态（独立 key，O(1) 读取）
  Future<bool> getStrongReminderStatus(String roomId) async {
    final p = await prefs;
    return p.getBool('n42_chat_strong_reminder_$roomId') ?? false;
  }

  // ============================================
  // 设置存储
  // ============================================

  /// 保存设置项
  Future<void> saveSetting(String key, String value) async {
    final settings = await _getSettings();
    settings[key] = value;
    final p = await prefs;
    await p.setString(_keySettings, jsonEncode(settings));
  }

  /// 获取设置项
  Future<String?> getSetting(String key) async {
    final settings = await _getSettings();
    return settings[key];
  }

  /// 删除设置项
  Future<void> removeSetting(String key) async {
    final settings = await _getSettings();
    settings.remove(key);
    final p = await prefs;
    await p.setString(_keySettings, jsonEncode(settings));
  }

  Future<Map<String, String>> _getSettings() async {
    try {
      final p = await prefs;
      final data = p.getString(_keySettings);
      if (data == null) return {};

      final json = jsonDecode(data) as Map<String, dynamic>;
      return json.map((key, value) => MapEntry(key, value.toString()));
    } catch (e) {
      return {};
    }
  }

  // ============================================
  // 本地删除消息管理
  // ============================================

  /// 获取房间的本地删除消息ID列表
  Future<Set<String>> getLocallyDeletedMessageIds(String roomId) async {
    try {
      final p = await prefs;
      final data = p.getString(_keyLocallyDeletedMessages);
      if (data == null) return {};

      final json = jsonDecode(data) as Map<String, dynamic>;
      final roomData = json[roomId] as List<dynamic>?;
      if (roomData == null) return {};

      return roomData.cast<String>().toSet();
    } catch (e) {
      prefsLog('Failed to read locally deleted messages - $e');
      return {};
    }
  }

  /// 标记消息为本地删除
  Future<void> markMessagesAsLocallyDeleted(
    String roomId,
    List<String> messageIds,
  ) async {
    try {
      final p = await prefs;
      final data = p.getString(_keyLocallyDeletedMessages);
      Map<String, dynamic> allData = {};

      if (data != null) {
        allData = jsonDecode(data) as Map<String, dynamic>;
      }

      // 获取当前房间的已删除消息列表
      final currentIds =
          (allData[roomId] as List<dynamic>?)?.cast<String>().toSet() ??
          <String>{};
      currentIds.addAll(messageIds);

      // 限制每个房间最多保存 1000 个删除记录
      final limitedIds = currentIds.toList();
      if (limitedIds.length > 1000) {
        limitedIds.removeRange(0, limitedIds.length - 1000);
      }

      allData[roomId] = limitedIds;

      await p.setString(_keyLocallyDeletedMessages, jsonEncode(allData));

      prefsLog(
        'Marked ${messageIds.length} messages as locally deleted in $roomId',
      );
    } catch (e) {
      prefsLog('Failed to mark messages as locally deleted - $e');
    }
  }

  /// 清除房间的本地删除消息记录
  Future<void> clearLocallyDeletedMessages(String roomId) async {
    try {
      final p = await prefs;
      final data = p.getString(_keyLocallyDeletedMessages);
      if (data == null) return;

      final allData = jsonDecode(data) as Map<String, dynamic>;
      allData.remove(roomId);

      if (allData.isEmpty) {
        await p.remove(_keyLocallyDeletedMessages);
      } else {
        await p.setString(_keyLocallyDeletedMessages, jsonEncode(allData));
      }

      prefsLog('Cleared locally deleted messages for $roomId');
    } catch (e) {
      prefsLog('Failed to clear locally deleted messages - $e');
    }
  }

  // ============================================
  // 阅后即焚消息销毁时间管理
  // ============================================

  /// 设置消息的销毁时间
  Future<void> setMessageDestroyedAt(
    String roomId,
    String messageId,
    DateTime destroyedAt,
  ) async {
    try {
      final p = await prefs;
      final data = p.getString(_keyMessageDestructionTimes);
      Map<String, dynamic> allData = {};

      if (data != null) {
        allData = jsonDecode(data) as Map<String, dynamic>;
      }

      // 获取当前房间的销毁时间记录
      final roomData = (allData[roomId] as Map<String, dynamic>?) ?? {};
      roomData[messageId] = destroyedAt.toIso8601String();
      allData[roomId] = roomData;

      await p.setString(_keyMessageDestructionTimes, jsonEncode(allData));

      prefsLog('Set destruction time for message $messageId in $roomId');
    } catch (e) {
      prefsLog('Failed to set message destruction time - $e');
    }
  }

  /// 获取房间所有消息的销毁时间
  Future<Map<String, DateTime>> getMessageDestructionTimes(
    String roomId,
  ) async {
    try {
      final p = await prefs;
      final data = p.getString(_keyMessageDestructionTimes);
      if (data == null) return {};

      final allData = jsonDecode(data) as Map<String, dynamic>;
      final roomData = allData[roomId] as Map<String, dynamic>?;
      if (roomData == null) return {};

      return roomData.map((key, value) {
        return MapEntry(key, DateTime.parse(value as String));
      });
    } catch (e) {
      prefsLog('Failed to read message destruction times - $e');
      return {};
    }
  }

  /// 获取单条消息的销毁时间
  Future<DateTime?> getMessageDestroyedAt(
    String roomId,
    String messageId,
  ) async {
    final times = await getMessageDestructionTimes(roomId);
    return times[messageId];
  }

  /// 清除指定消息的销毁时间记录
  Future<void> clearMessageDestructionTimes(
    String roomId,
    List<String> messageIds,
  ) async {
    try {
      final p = await prefs;
      final data = p.getString(_keyMessageDestructionTimes);
      if (data == null) return;

      final allData = jsonDecode(data) as Map<String, dynamic>;
      final roomData = allData[roomId] as Map<String, dynamic>?;
      if (roomData == null) return;

      for (final messageId in messageIds) {
        roomData.remove(messageId);
      }

      if (roomData.isEmpty) {
        allData.remove(roomId);
      } else {
        allData[roomId] = roomData;
      }

      if (allData.isEmpty) {
        await p.remove(_keyMessageDestructionTimes);
      } else {
        await p.setString(_keyMessageDestructionTimes, jsonEncode(allData));
      }

      prefsLog(
        'Cleared ${messageIds.length} destruction time records in $roomId',
      );
    } catch (e) {
      prefsLog('Failed to clear message destruction times - $e');
    }
  }

  /// 清除房间所有消息的销毁时间记录
  Future<void> clearAllMessageDestructionTimes(String roomId) async {
    try {
      final p = await prefs;
      final data = p.getString(_keyMessageDestructionTimes);
      if (data == null) return;

      final allData = jsonDecode(data) as Map<String, dynamic>;
      allData.remove(roomId);

      if (allData.isEmpty) {
        await p.remove(_keyMessageDestructionTimes);
      } else {
        await p.setString(_keyMessageDestructionTimes, jsonEncode(allData));
      }

      prefsLog('Cleared all destruction time records in $roomId');
    } catch (e) {
      prefsLog('Failed to clear all destruction times - $e');
    }
  }

  // ============================================
  // 隐私设置
  // ============================================

  /// 保存隐私设置
  ///
  /// [avatarVisibility] 头像可见性 (everyone, contacts, nobody)
  /// [statusVisibility] 状态可见性 (everyone, contacts, nobody)
  /// [lastSeenVisibility] 最后上线时间可见性 (everyone, contacts, nobody)
  /// [allowStrangerMessage] 是否允许陌生人私聊
  /// [showReadReceipts] 是否显示已读回执
  /// [showTypingIndicator] 是否显示输入状态
  Future<void> savePrivacySettings({
    String avatarVisibility = 'everyone',
    String statusVisibility = 'everyone',
    String lastSeenVisibility = 'everyone',
    bool allowStrangerMessage = true,
    bool showReadReceipts = true,
    bool showTypingIndicator = true,
    bool hidePhoneNumber = false,
    bool showLinkPreviews = true,
    bool defaultEncryptNewChats = true,
    bool privateChatMode = false,
    bool protectIpAddress = false,
    bool proxyEnabled = false,
    String? proxyUrl,
    bool useTor = false,
    int? defaultSelfDestructSeconds,
  }) async {
    final data = {
      'avatarVisibility': avatarVisibility,
      'statusVisibility': statusVisibility,
      'lastSeenVisibility': lastSeenVisibility,
      'allowStrangerMessage': allowStrangerMessage,
      'showReadReceipts': showReadReceipts,
      'showTypingIndicator': showTypingIndicator,
      'hidePhoneNumber': hidePhoneNumber,
      'showLinkPreviews': showLinkPreviews,
      'defaultEncryptNewChats': defaultEncryptNewChats,
      'privateChatMode': privateChatMode,
      'protectIpAddress': protectIpAddress,
      'proxyEnabled': proxyEnabled,
      'proxyUrl': proxyUrl?.trim(),
      'useTor': useTor,
      'defaultSelfDestructSeconds': defaultSelfDestructSeconds,
      'savedAt': DateTime.now().toIso8601String(),
    };

    final p = await prefs;
    await p.setString(_keyPrivacySettings, jsonEncode(data));

    prefsLog('Privacy settings saved');
  }

  /// 获取隐私设置
  Future<Map<String, dynamic>?> getPrivacySettings() async {
    try {
      final p = await prefs;
      final data = p.getString(_keyPrivacySettings);
      if (data == null) return null;

      return jsonDecode(data) as Map<String, dynamic>;
    } catch (e) {
      prefsLog('Failed to read privacy settings - $e');
      return null;
    }
  }

  /// 获取强类型隐私设置模型
  Future<PrivacySettings> getPrivacySettingsModel() async {
    final settings = await getPrivacySettings();
    if (settings == null) {
      return const PrivacySettings();
    }

    return PrivacySettings(
      avatarVisibility: _parseVisibilityLevel(
        settings['avatarVisibility']?.toString(),
      ),
      statusVisibility: _parseVisibilityLevel(
        settings['statusVisibility']?.toString(),
      ),
      lastSeenVisibility: _parseVisibilityLevel(
        settings['lastSeenVisibility']?.toString(),
      ),
      allowStrangerMessage: (settings['allowStrangerMessage'] as bool?) ?? true,
      showReadReceipts: (settings['showReadReceipts'] as bool?) ?? true,
      showTypingIndicator: (settings['showTypingIndicator'] as bool?) ?? true,
      hidePhoneNumber: (settings['hidePhoneNumber'] as bool?) ?? false,
      showLinkPreviews: (settings['showLinkPreviews'] as bool?) ?? true,
      defaultEncryptNewChats:
          (settings['defaultEncryptNewChats'] as bool?) ?? true,
      privateChatMode: (settings['privateChatMode'] as bool?) ?? false,
      protectIpAddress: (settings['protectIpAddress'] as bool?) ?? false,
      proxyEnabled: (settings['proxyEnabled'] as bool?) ?? false,
      proxyUrl: settings['proxyUrl']?.toString(),
      useTor: (settings['useTor'] as bool?) ?? false,
      defaultSelfDestructSeconds: _readOptionalInt(
        settings['defaultSelfDestructSeconds'],
      ),
    );
  }

  /// 保存强类型隐私设置模型
  Future<void> savePrivacySettingsModel(PrivacySettings settings) {
    return savePrivacySettings(
      avatarVisibility: settings.avatarVisibility.name,
      statusVisibility: settings.statusVisibility.name,
      lastSeenVisibility: settings.lastSeenVisibility.name,
      allowStrangerMessage: settings.allowStrangerMessage,
      showReadReceipts: settings.showReadReceipts,
      showTypingIndicator: settings.showTypingIndicator,
      hidePhoneNumber: settings.hidePhoneNumber,
      showLinkPreviews: settings.showLinkPreviews,
      defaultEncryptNewChats: settings.defaultEncryptNewChats,
      privateChatMode: settings.privateChatMode,
      protectIpAddress: settings.protectIpAddress,
      proxyEnabled: settings.proxyEnabled,
      proxyUrl: settings.proxyUrl,
      useTor: settings.useTor,
      defaultSelfDestructSeconds: settings.defaultSelfDestructSeconds,
    );
  }

  /// 检查是否应该显示已读回执
  Future<bool> shouldShowReadReceipts() async {
    final settings = await getPrivacySettings();
    return (settings?['showReadReceipts'] as bool?) ?? true;
  }

  /// 检查是否应该显示输入状态
  Future<bool> shouldShowTypingIndicator() async {
    final settings = await getPrivacySettings();
    return (settings?['showTypingIndicator'] as bool?) ?? true;
  }

  /// 新聊天是否默认开启端到端加密
  Future<bool> shouldDefaultEncryptNewChats() async {
    final settings = await getPrivacySettings();
    return (settings?['defaultEncryptNewChats'] as bool?) ?? true;
  }

  /// 是否启用私密聊天模式
  Future<bool> isPrivateChatModeEnabled() async {
    final settings = await getPrivacySettings();
    return (settings?['privateChatMode'] as bool?) ?? false;
  }

  /// 是否启用 IP 地址保护
  Future<bool> shouldProtectIpAddress() async {
    final settings = await getPrivacySettings();
    return (settings?['protectIpAddress'] as bool?) ?? false;
  }

  /// 默认阅后即焚时长（秒）
  Future<int?> getDefaultSelfDestructSeconds() async {
    final settings = await getPrivacySettings();
    return _readOptionalInt(settings?['defaultSelfDestructSeconds']);
  }

  /// 更新单个隐私设置项
  Future<void> updatePrivacySetting(String key, dynamic value) async {
    final current = await getPrivacySettings() ?? {};
    current[key] = value;
    current['savedAt'] = DateTime.now().toIso8601String();

    final p = await prefs;
    await p.setString(_keyPrivacySettings, jsonEncode(current));

    prefsLog('Privacy setting updated - $key: $value');
  }

  // ============================================
  // 定时消息管理
  // ============================================

  /// 保存定时消息
  ///
  /// [roomId] 房间ID
  /// [messageId] 本地临时消息ID
  /// [text] 消息内容
  /// [scheduledAt] 预定发送时间
  /// [selfDestructAfter] 阅后即焚秒数（可选）
  /// [mentionedUserIds] 提及的用户ID列表（可选）
  /// [mentionsRoom] 是否 @全体成员
  Future<void> saveScheduledMessage({
    required String roomId,
    required String messageId,
    required String text,
    MessageType type = MessageType.text,
    Map<String, dynamic>? payload,
    required DateTime scheduledAt,
    int? selfDestructAfter,
    List<String>? mentionedUserIds,
    bool mentionsRoom = false,
  }) async {
    try {
      final p = await prefs;
      final data = p.getString(_keyScheduledMessages);
      Map<String, dynamic> allData = {};

      if (data != null) {
        allData = jsonDecode(data) as Map<String, dynamic>;
      }

      // 获取当前房间的定时消息列表
      final roomMessages =
          (allData[roomId] as List<dynamic>?)?.cast<Map<String, dynamic>>() ??
          [];

      // 添加新的定时消息
      roomMessages.add(
        ScheduledMessageDraft(
          messageId: messageId,
          text: text,
          type: type,
          scheduledAt: scheduledAt,
          createdAt: DateTime.now(),
          selfDestructAfter: selfDestructAfter,
          mentionedUserIds: mentionedUserIds ?? const [],
          mentionsRoom: mentionsRoom,
          payload: payload ?? const {},
        ).toJson(),
      );

      allData[roomId] = roomMessages;

      await p.setString(_keyScheduledMessages, jsonEncode(allData));

      prefsLog('Scheduled message saved - $messageId for $scheduledAt');
    } catch (e) {
      prefsLog('Failed to save scheduled message - $e');
    }
  }

  /// 获取房间的所有定时消息
  Future<List<ScheduledMessageDraft>> getScheduledMessages(String roomId) async {
    try {
      final p = await prefs;
      final data = p.getString(_keyScheduledMessages);
      if (data == null) return [];

      final allData = jsonDecode(data) as Map<String, dynamic>;
      final roomMessages = allData[roomId] as List<dynamic>?;
      if (roomMessages == null) return [];

      return roomMessages
          .whereType<Map<dynamic, dynamic>>()
          .map((item) => ScheduledMessageDraft.fromJson(
            Map<String, dynamic>.from(item),
          ))
          .toList(growable: false);
    } catch (e) {
      prefsLog('Failed to read scheduled messages - $e');
      return [];
    }
  }

  /// 获取所有房间的到期定时消息
  Future<List<ScheduledMessageDraft>> getDueScheduledMessages() async {
    try {
      final p = await prefs;
      final data = p.getString(_keyScheduledMessages);
      if (data == null) return [];

      final allData = jsonDecode(data) as Map<String, dynamic>;
      final now = DateTime.now();
      final dueMessages = <ScheduledMessageDraft>[];

      for (final entry in allData.entries) {
        final roomId = entry.key;
        final messages = (entry.value as List<dynamic>)
            .whereType<Map<dynamic, dynamic>>()
            .map((item) => ScheduledMessageDraft.fromJson(
              Map<String, dynamic>.from(item),
            ));

        for (final msg in messages) {
          final scheduledAt = msg.scheduledAt;
          if (now.isAfter(scheduledAt) || now.isAtSameMomentAs(scheduledAt)) {
            dueMessages.add(msg.copyWith(roomId: roomId));
          }
        }
      }

      return dueMessages;
    } catch (e) {
      prefsLog('Failed to get due scheduled messages - $e');
      return [];
    }
  }

  /// 删除定时消息
  Future<void> removeScheduledMessage(String roomId, String messageId) async {
    try {
      final p = await prefs;
      final data = p.getString(_keyScheduledMessages);
      if (data == null) return;

      final allData = jsonDecode(data) as Map<String, dynamic>;
      final roomMessages = (allData[roomId] as List<dynamic>?)
          ?.cast<Map<String, dynamic>>();
      if (roomMessages == null) return;

      roomMessages.removeWhere((msg) => msg['messageId'] == messageId);

      if (roomMessages.isEmpty) {
        allData.remove(roomId);
      } else {
        allData[roomId] = roomMessages;
      }

      if (allData.isEmpty) {
        await p.remove(_keyScheduledMessages);
      } else {
        await p.setString(_keyScheduledMessages, jsonEncode(allData));
      }

      prefsLog('Scheduled message removed - $messageId');
    } catch (e) {
      prefsLog('Failed to remove scheduled message - $e');
    }
  }

  /// 清除房间所有定时消息
  Future<void> clearScheduledMessages(String roomId) async {
    try {
      final p = await prefs;
      final data = p.getString(_keyScheduledMessages);
      if (data == null) return;

      final allData = jsonDecode(data) as Map<String, dynamic>;
      allData.remove(roomId);

      if (allData.isEmpty) {
        await p.remove(_keyScheduledMessages);
      } else {
        await p.setString(_keyScheduledMessages, jsonEncode(allData));
      }

      prefsLog('Cleared all scheduled messages for $roomId');
    } catch (e) {
      prefsLog('Failed to clear scheduled messages - $e');
    }
  }

  // ============================================
  // 朋友圈设置
  // ============================================

  /// 保存朋友圈设置
  Future<void> saveMomentSettings({
    bool allowStrangers = false,
    int visibleDays = 0,
  }) async {
    final data = {'allowStrangers': allowStrangers, 'visibleDays': visibleDays};
    final p = await prefs;
    await p.setString(_keyMomentSettings, jsonEncode(data));
  }

  /// 获取朋友圈设置
  Future<Map<String, dynamic>?> getMomentSettings() async {
    try {
      final p = await prefs;
      final data = p.getString(_keyMomentSettings);
      if (data == null) return null;
      return jsonDecode(data) as Map<String, dynamic>;
    } catch (e) {
      prefsLog('Failed to read moment settings - $e');
      return null;
    }
  }

  /// 保存不看谁的朋友圈列表
  Future<void> saveHiddenMomentUsers(List<String> userIds) async {
    final p = await prefs;
    await p.setString(_keyHiddenMomentUsers, jsonEncode(userIds));
  }

  /// 获取不看谁的朋友圈列表
  Future<List<String>?> getHiddenMomentUsers() async {
    try {
      final p = await prefs;
      final data = p.getString(_keyHiddenMomentUsers);
      if (data == null) return null;
      return (jsonDecode(data) as List).cast<String>();
    } catch (e) {
      prefsLog('Failed to read hidden moment users - $e');
      return null;
    }
  }

  /// 保存不让谁看我的朋友圈列表
  Future<void> saveBlockedMomentUsers(List<String> userIds) async {
    final p = await prefs;
    await p.setString(_keyBlockedMomentUsers, jsonEncode(userIds));
  }

  /// 获取不让谁看我的朋友圈列表
  Future<List<String>?> getBlockedMomentUsers() async {
    try {
      final p = await prefs;
      final data = p.getString(_keyBlockedMomentUsers);
      if (data == null) return null;
      return (jsonDecode(data) as List).cast<String>();
    } catch (e) {
      prefsLog('Failed to read blocked moment users - $e');
      return null;
    }
  }

  /// 保存朋友圈最后阅读时间
  Future<void> saveMomentLastReadTime(DateTime time) async {
    final p = await prefs;
    await p.setString(_keyMomentLastReadTime, time.toIso8601String());
  }

  /// 获取朋友圈最后阅读时间
  Future<DateTime?> getMomentLastReadTime() async {
    try {
      final p = await prefs;
      final data = p.getString(_keyMomentLastReadTime);
      if (data == null) return null;
      return DateTime.parse(data);
    } catch (e) {
      prefsLog('Failed to read moment last read time - $e');
      return null;
    }
  }

  // ============================================
  // 隐藏聊天管理
  // ============================================

  /// 获取隐藏的聊天 ID 集合
  Future<Set<String>> getHiddenChatIds() async {
    try {
      final p = await prefs;
      final data = p.getString(_keyHiddenChats);
      if (data == null) return {};
      return (jsonDecode(data) as List).cast<String>().toSet();
    } catch (e) {
      prefsLog('Failed to read hidden chats - $e');
      return {};
    }
  }

  /// 隐藏聊天
  Future<void> hideChat(String roomId) async {
    try {
      final ids = await getHiddenChatIds();
      ids.add(roomId);
      final p = await prefs;
      await p.setString(_keyHiddenChats, jsonEncode(ids.toList()));
      prefsLog('Chat hidden - $roomId');
    } catch (e) {
      prefsLog('Failed to hide chat - $e');
    }
  }

  /// 取消隐藏聊天
  Future<void> unhideChat(String roomId) async {
    try {
      final ids = await getHiddenChatIds();
      ids.remove(roomId);
      final p = await prefs;
      await p.setString(_keyHiddenChats, jsonEncode(ids.toList()));
      prefsLog('Chat unhidden - $roomId');
    } catch (e) {
      prefsLog('Failed to unhide chat - $e');
    }
  }

  /// 检查聊天是否被隐藏
  Future<bool> isChatHidden(String roomId) async {
    final ids = await getHiddenChatIds();
    return ids.contains(roomId);
  }

  // ============================================
  // 快捷回复模板管理
  // ============================================

  /// 获取快捷回复模板列表
  Future<List<Map<String, dynamic>>> getQuickReplies() async {
    try {
      final p = await prefs;
      final data = p.getString(_keyQuickReplies);
      if (data == null) {
        // 返回默认模板
        return _getDefaultQuickReplies();
      }
      return (jsonDecode(data) as List).cast<Map<String, dynamic>>();
    } catch (e) {
      prefsLog('Failed to read quick replies - $e');
      return _getDefaultQuickReplies();
    }
  }

  List<Map<String, dynamic>> _getDefaultQuickReplies() {
    const defaults = ['好的', '收到', '稍等', '在忙，稍后回复', '谢谢', '没问题'];
    return defaults
        .asMap()
        .entries
        .map(
          (e) => {
            'id': 'default_${e.key}',
            'content': e.value,
            'order': e.key,
            'isSystem': true,
          },
        )
        .toList();
  }

  /// 保存快捷回复模板列表
  Future<void> saveQuickReplies(List<Map<String, dynamic>> replies) async {
    try {
      final p = await prefs;
      await p.setString(_keyQuickReplies, jsonEncode(replies));
      prefsLog('Quick replies saved');
    } catch (e) {
      prefsLog('Failed to save quick replies - $e');
    }
  }

  /// 添加快捷回复模板
  Future<void> addQuickReply(String content) async {
    try {
      final replies = await getQuickReplies();
      final newReply = {
        'id': 'custom_${DateTime.now().millisecondsSinceEpoch}',
        'content': content,
        'order': replies.length,
        'isSystem': false,
      };
      replies.add(newReply);
      await saveQuickReplies(replies);
    } catch (e) {
      prefsLog('Failed to add quick reply - $e');
    }
  }

  /// 删除快捷回复模板
  Future<void> removeQuickReply(String id) async {
    try {
      final replies = await getQuickReplies();
      replies.removeWhere((r) => r['id'] == id);
      await saveQuickReplies(replies);
    } catch (e) {
      prefsLog('Failed to remove quick reply - $e');
    }
  }

  /// 更新快捷回复使用时间
  Future<void> updateQuickReplyLastUsed(String id) async {
    try {
      final replies = await getQuickReplies();
      final index = replies.indexWhere((r) => r['id'] == id);
      if (index != -1) {
        replies[index]['lastUsed'] = DateTime.now().toIso8601String();
        await saveQuickReplies(replies);
      }
    } catch (e) {
      prefsLog('Failed to update quick reply last used - $e');
    }
  }

  // ============================================
  // 翻译缓存管理
  // ============================================

  /// 保存翻译缓存
  Future<void> saveTranslationCache(
    String messageId,
    String targetLanguage,
    String translation,
  ) async {
    try {
      final p = await prefs;
      final data = p.getString(_keyTranslationCache);
      Map<String, dynamic> cache = {};
      if (data != null) {
        cache = jsonDecode(data) as Map<String, dynamic>;
      }

      final key = '${messageId}_$targetLanguage';
      cache[key] = translation;

      // 限制缓存大小，最多保存 500 条
      if (cache.length > 500) {
        final keys = cache.keys.toList();
        for (var i = 0; i < 100; i++) {
          cache.remove(keys[i]);
        }
      }

      await p.setString(_keyTranslationCache, jsonEncode(cache));
    } catch (e) {
      prefsLog('Failed to save translation cache - $e');
    }
  }

  /// 获取翻译缓存
  Future<String?> getTranslationCache(
    String messageId,
    String targetLanguage,
  ) async {
    try {
      final p = await prefs;
      final data = p.getString(_keyTranslationCache);
      if (data == null) return null;

      final cache = jsonDecode(data) as Map<String, dynamic>;
      final key = '${messageId}_$targetLanguage';
      return cache[key] as String?;
    } catch (e) {
      prefsLog('Failed to read translation cache - $e');
      return null;
    }
  }

  /// 获取翻译设置
  Future<Map<String, dynamic>?> getTranslationSettings() async {
    try {
      final p = await prefs;
      final data = p.getString(_keyTranslationSettings);
      if (data == null) return null;
      return jsonDecode(data) as Map<String, dynamic>;
    } catch (e) {
      prefsLog('Failed to read translation settings - $e');
      return null;
    }
  }

  /// 保存翻译设置
  Future<void> saveTranslationSettings({
    String? defaultTargetLanguage,
    bool? autoTranslate,
    bool? smartReplyTranslate,
  }) async {
    try {
      final current = await getTranslationSettings() ?? {};
      if (defaultTargetLanguage != null) {
        current['defaultTargetLanguage'] = defaultTargetLanguage;
      }
      if (autoTranslate != null) {
        current['autoTranslate'] = autoTranslate;
      }
      if (smartReplyTranslate != null) {
        current['smartReplyTranslate'] = smartReplyTranslate;
      }
      current['updatedAt'] = DateTime.now().toIso8601String();

      final p = await prefs;
      await p.setString(_keyTranslationSettings, jsonEncode(current));
    } catch (e) {
      prefsLog('Failed to save translation settings - $e');
    }
  }

  // ============================================
  // 聊天背景
  // ============================================

  /// 设置聊天背景
  Future<void> setChatBackground(String roomId, String backgroundPath) async {
    final p = await prefs;
    await p.setString('n42_chat_background_$roomId', backgroundPath);
  }

  /// 获取聊天背景
  Future<String?> getChatBackground(String roomId) async {
    final p = await prefs;
    return p.getString('n42_chat_background_$roomId');
  }

  /// 设置默认聊天背景
  Future<void> setDefaultChatBackground(String backgroundPath) async {
    final p = await prefs;
    await p.setString('n42_chat_default_background', backgroundPath);
  }

  /// 获取默认聊天背景
  Future<String?> getDefaultChatBackground() async {
    final p = await prefs;
    return p.getString('n42_chat_default_background');
  }

  // ============================================
  // 字体大小
  // ============================================

  /// 设置消息字体大小
  Future<void> setMessageFontSize(double size) async {
    final p = await prefs;
    await p.setString('n42_chat_message_font_size', size.toString());
  }

  /// 获取消息字体大小
  Future<double> getMessageFontSize() async {
    final p = await prefs;
    final value = p.getString('n42_chat_message_font_size');
    return double.tryParse(value ?? '') ?? 16.0;
  }

  // ============================================
  // 自动下载设置
  // ============================================

  /// 保存自动下载设置
  Future<void> saveAutoDownloadSettings(Map<String, dynamic> settings) async {
    final p = await prefs;
    await p.setString('n42_chat_auto_download_settings', jsonEncode(settings));
  }

  /// 获取自动下载设置
  Future<Map<String, dynamic>> getAutoDownloadSettings() async {
    final p = await prefs;
    final value = p.getString('n42_chat_auto_download_settings');
    if (value == null || value.isEmpty) {
      return Map<String, dynamic>.from(defaultAutoDownloadSettings);
    }

    try {
      final decoded = jsonDecode(value) as Map<String, dynamic>;
      return {...defaultAutoDownloadSettings, ...decoded};
    } catch (e) {
      // 兼容旧的 key=value 格式
      final map = <String, dynamic>{...defaultAutoDownloadSettings};
      for (final pair in value.split(',')) {
        final parts = pair.split('=');
        if (parts.length == 2) {
          map[parts[0]] = parts[1] == 'true'
              ? true
              : (parts[1] == 'false' ? false : parts[1]);
        }
      }
      return map;
    }
  }

  // ============================================
  // 收藏消息持久化
  // ============================================

  /// 保存收藏消息列表（JSON）
  Future<void> saveFavoriteMessages(String json) async {
    final p = await prefs;
    await p.setString(_keyFavoriteMessages, json);
  }

  /// 获取收藏消息列表（JSON）
  Future<String?> getFavoriteMessages() async {
    final p = await prefs;
    return p.getString(_keyFavoriteMessages);
  }

  /// 保存收藏元数据（标签+备注）
  Future<void> saveFavoriteMeta(String json) async {
    final p = await prefs;
    await p.setString(_keyFavoriteMeta, json);
  }

  /// 获取收藏元数据
  Future<String?> getFavoriteMeta() async {
    final p = await prefs;
    return p.getString(_keyFavoriteMeta);
  }

  /// 待办提醒列表存储 key
  static const String _keyReminders = 'n42_chat_reminders';

  /// 保存待办提醒列表（JSON）
  Future<void> saveReminders(String json) async {
    final p = await prefs;
    await p.setString(_keyReminders, json);
  }

  /// 获取待办提醒列表（JSON）
  Future<String?> getReminders() async {
    final p = await prefs;
    return p.getString(_keyReminders);
  }

  /// 订阅计划列表存储 key
  static const String _keySubscriptionPlans = 'n42_chat_subscription_plans';

  /// 用户订阅记录存储 key
  static const String _keyUserSubscriptions = 'n42_chat_user_subscriptions';

  Future<void> saveSubscriptionPlans(String json) async {
    final p = await prefs;
    await p.setString(_keySubscriptionPlans, json);
  }

  Future<String?> getSubscriptionPlans() async {
    final p = await prefs;
    return p.getString(_keySubscriptionPlans);
  }

  Future<void> saveUserSubscriptions(String json) async {
    final p = await prefs;
    await p.setString(_keyUserSubscriptions, json);
  }

  Future<String?> getUserSubscriptions() async {
    final p = await prefs;
    return p.getString(_keyUserSubscriptions);
  }

  // ============================================
  // 草稿持久化
  // ============================================

  /// 保存房间草稿（独立 key 存储，避免 N+1 读写）
  Future<void> saveDraft(String roomId, String text) async {
    try {
      final p = await prefs;
      final key = 'n42_chat_draft_$roomId';

      if (text.isEmpty) {
        await p.remove(key);
      } else {
        await p.setString(key, text);
      }
    } catch (e) {
      prefsLog('Failed to save draft - $e');
    }
  }

  /// 获取房间草稿（独立 key 存储，O(1) 读取）
  Future<String?> getDraft(String roomId) async {
    try {
      final p = await prefs;
      return p.getString('n42_chat_draft_$roomId');
    } catch (e) {
      prefsLog('Failed to read draft - $e');
      return null;
    }
  }

  // ============================================
  // 通用键值存储（供扩展模块使用）
  // ============================================

  /// 通用读取
  Future<String?> read(String key) async {
    try {
      final p = await prefs;
      return p.getString(key);
    } catch (e) {
      prefsLog('Read failed for key $key: $e');
      return null;
    }
  }

  /// 通用写入
  Future<void> write(String key, String value) async {
    final p = await prefs;
    await p.setString(key, value);
  }

  /// 通用删除
  Future<void> delete(String key) async {
    final p = await prefs;
    await p.remove(key);
  }

  // ============================================
  // 聊天文件夹管理
  // ============================================

  /// 保存聊天文件夹列表
  Future<void> saveChatFolders(List<Map<String, dynamic>> folders) async {
    final p = await prefs;
    await p.setString(_keyChatFolders, jsonEncode(folders));
  }

  /// 获取聊天文件夹列表
  Future<List<Map<String, dynamic>>> getChatFolders() async {
    try {
      final p = await prefs;
      final data = p.getString(_keyChatFolders);
      if (data == null) return [];
      final list = jsonDecode(data) as List<dynamic>;
      return list.cast<Map<String, dynamic>>();
    } catch (e) {
      prefsLog('Failed to load chat folders: $e');
      return [];
    }
  }
}

VisibilityLevel _parseVisibilityLevel(String? value) {
  return VisibilityLevel.values.firstWhere(
    (level) => level.name == value,
    orElse: () => VisibilityLevel.everyone,
  );
}

int? _readOptionalInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value > 0 ? value : null;
  if (value is num) return value > 0 ? value.toInt() : null;
  if (value is String) {
    final parsed = int.tryParse(value);
    if (parsed != null && parsed > 0) {
      return parsed;
    }
  }
  return null;
}
