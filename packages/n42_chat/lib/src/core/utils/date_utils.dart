import 'package:intl/intl.dart';

/// 本地化日期字符串
class DateLocaleStrings {
  final String yesterday;
  final String justNow;
  final String Function(int) minutesAgo;
  final String Function(int) hoursAgo;
  final String Function(int) daysAgo;
  final String online;
  final String offline;
  final String Function(int) minutesAgoOnline;
  final String Function(int) hoursAgoOnline;
  final String Function(int) daysAgoOnline;
  final List<String>? weekdays;
  final String? localeCode;
  final String Function(int month, int day) monthDay;
  final String Function(int year, int month, int day) yearMonthDay;

  const DateLocaleStrings({
    this.yesterday = 'Yesterday',
    this.justNow = 'Just now',
    this.minutesAgo = _defaultMinutesAgo,
    this.hoursAgo = _defaultHoursAgo,
    this.daysAgo = _defaultDaysAgo,
    this.online = 'Online',
    this.offline = 'Offline',
    this.minutesAgoOnline = _defaultMinutesAgoOnline,
    this.hoursAgoOnline = _defaultHoursAgoOnline,
    this.daysAgoOnline = _defaultDaysAgoOnline,
    this.weekdays,
    this.localeCode = 'en',
    this.monthDay = _defaultMonthDay,
    this.yearMonthDay = _defaultYearMonthDay,
  });

  /// 获取本地化的星期几短名
  String getWeekday(DateTime dateTime) {
    // 优先使用自定义weekdays数组
    if (weekdays != null && weekdays!.length > dateTime.weekday) {
      return weekdays![dateTime.weekday];
    }
    // 否则使用intl包的本地化
    return DateFormat.E(localeCode).format(dateTime);
  }

  static String _defaultMinutesAgo(int count) => '$count min ago';
  static String _defaultHoursAgo(int count) => '${count}h ago';
  static String _defaultDaysAgo(int count) => '${count}d ago';
  static String _defaultMinutesAgoOnline(int count) => '$count min ago';
  static String _defaultHoursAgoOnline(int count) => '${count}h ago';
  static String _defaultDaysAgoOnline(int count) => '${count}d ago';
  static String _defaultMonthDay(int month, int day) => '$month/$day';
  static String _defaultYearMonthDay(int year, int month, int day) =>
      '$year/$month/$day';

  /// Chinese locale strings（简体，默认 zh / zh_CN）
  static const DateLocaleStrings chinese = DateLocaleStrings(
    yesterday: '昨天',
    justNow: '刚刚',
    minutesAgo: _chineseMinutesAgo,
    hoursAgo: _chineseHoursAgo,
    daysAgo: _chineseDaysAgo,
    online: '在线',
    offline: '离线',
    minutesAgoOnline: _chineseMinutesAgoOnline,
    hoursAgoOnline: _chineseHoursAgoOnline,
    daysAgoOnline: _chineseDaysAgoOnline,
    weekdays: ['', '周一', '周二', '周三', '周四', '周五', '周六', '周日'],
    localeCode: 'zh',
    monthDay: _chineseMonthDay,
    yearMonthDay: _chineseYearMonthDay,
  );

  /// 繁体中文（zh_TW / zh_HK / zh_Hant）
  static const DateLocaleStrings chineseTraditional = DateLocaleStrings(
    yesterday: '昨天',
    justNow: '剛剛',
    minutesAgo: _chineseTradMinutesAgo,
    hoursAgo: _chineseTradHoursAgo,
    daysAgo: _chineseTradDaysAgo,
    online: '在線',
    offline: '離線',
    minutesAgoOnline: _chineseTradMinutesAgoOnline,
    hoursAgoOnline: _chineseTradHoursAgoOnline,
    daysAgoOnline: _chineseTradDaysAgoOnline,
    weekdays: ['', '週一', '週二', '週三', '週四', '週五', '週六', '週日'],
    localeCode: 'zh_TW',
    monthDay: _chineseMonthDay,
    yearMonthDay: _chineseYearMonthDay,
  );

  static String _chineseMinutesAgo(int count) => '$count分钟前';
  static String _chineseHoursAgo(int count) => '$count小时前';
  static String _chineseDaysAgo(int count) => '$count天前';
  static String _chineseMinutesAgoOnline(int count) => '$count分钟前在线';
  static String _chineseHoursAgoOnline(int count) => '$count小时前在线';
  static String _chineseDaysAgoOnline(int count) => '$count天前在线';
  static String _chineseMonthDay(int month, int day) => '$month月$day日';
  static String _chineseYearMonthDay(int year, int month, int day) =>
      '$year年$month月$day日';

  static String _chineseTradMinutesAgo(int count) => '$count分鐘前';
  static String _chineseTradHoursAgo(int count) => '$count小時前';
  static String _chineseTradDaysAgo(int count) => '$count天前';
  static String _chineseTradMinutesAgoOnline(int count) => '$count分鐘前在線';
  static String _chineseTradHoursAgoOnline(int count) => '$count小時前在線';
  static String _chineseTradDaysAgoOnline(int count) => '$count天前在線';

  /// 根据语言代码创建本地化字符串
  static DateLocaleStrings fromLocaleCode(String localeCode) {
    final lower = localeCode.toLowerCase().replaceAll('-', '_');
    if (lower.startsWith('zh')) {
      // 繁体：zh_TW / zh_HK / zh_MO / zh_Hant
      if (lower.contains('tw') ||
          lower.contains('hk') ||
          lower.contains('mo') ||
          lower.contains('hant')) {
        return chineseTraditional;
      }
      return chinese;
    }
    // 对于其他语言，使用intl包的本地化（不提供自定义weekdays）
    return DateLocaleStrings(localeCode: localeCode);
  }
}

/// 日期时间工具类
///
/// 提供微信风格的时间格式化
abstract class N42DateUtils {
  N42DateUtils._();

  /// 默认本地化字符串（英文）
  static DateLocaleStrings _defaultLocale = const DateLocaleStrings();

  /// 设置默认语言
  static void setLocale(DateLocaleStrings locale) {
    _defaultLocale = locale;
  }

  /// 格式化会话列表时间
  ///
  /// - 今天: 显示时:分 (如 14:30)
  /// - 昨天: 显示"昨天"
  /// - 本周: 显示星期几
  /// - 今年: 显示月-日 (如 12-25)
  /// - 更早: 显示年-月-日 (如 2023-12-25)
  static String formatConversationTime(
    DateTime? dateTime, [
    DateLocaleStrings? locale,
  ]) {
    if (dateTime == null) return '';
    locale ??= _defaultLocale;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final targetDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (targetDate == today) {
      // 今天，显示时间
      return DateFormat('HH:mm').format(dateTime);
    } else if (targetDate == yesterday) {
      // 昨天
      return locale.yesterday;
    } else if (now.difference(dateTime).inDays < 7 &&
        dateTime.weekday < now.weekday) {
      // 本周（且在今天之前）
      return locale.getWeekday(dateTime);
    } else if (dateTime.year == now.year) {
      // 今年
      return locale.monthDay(dateTime.month, dateTime.day);
    } else {
      // 更早
      return locale.yearMonthDay(dateTime.year, dateTime.month, dateTime.day);
    }
  }

  /// 格式化消息时间（完整格式）
  ///
  /// 用于消息详情页的时间分隔线
  static String formatMessageTime(
    DateTime dateTime, [
    DateLocaleStrings? locale,
  ]) {
    locale ??= _defaultLocale;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final targetDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    String dateStr;
    if (targetDate == today) {
      dateStr = '';
    } else if (targetDate == yesterday) {
      dateStr = '${locale.yesterday} ';
    } else if (now.difference(dateTime).inDays < 7 &&
        dateTime.weekday < now.weekday) {
      dateStr = '${locale.getWeekday(dateTime)} ';
    } else if (dateTime.year == now.year) {
      dateStr = '${locale.monthDay(dateTime.month, dateTime.day)} ';
    } else {
      dateStr =
          '${locale.yearMonthDay(dateTime.year, dateTime.month, dateTime.day)} ';
    }

    return '$dateStr${DateFormat('HH:mm').format(dateTime)}';
  }

  /// 格式化消息详情时间（用于消息详情）
  static String formatMessageDetailTime(
    DateTime dateTime, [
    DateLocaleStrings? locale,
  ]) {
    locale ??= _defaultLocale;
    return '${locale.yearMonthDay(dateTime.year, dateTime.month, dateTime.day)} ${DateFormat('HH:mm').format(dateTime)}';
  }

  /// 格式化相对时间
  ///
  /// - 刚刚 (< 1分钟)
  /// - x分钟前 (< 1小时)
  /// - x小时前 (< 24小时)
  /// - 昨天
  /// - x天前 (< 7天)
  /// - 日期
  static String formatRelativeTime(
    DateTime dateTime, [
    DateLocaleStrings? locale,
  ]) {
    locale ??= _defaultLocale;
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return locale.justNow;
    } else if (difference.inMinutes < 60) {
      return locale.minutesAgo(difference.inMinutes);
    } else if (difference.inHours < 24) {
      return locale.hoursAgo(difference.inHours);
    } else if (difference.inDays == 1) {
      return locale.yesterday;
    } else if (difference.inDays < 7) {
      return locale.daysAgo(difference.inDays);
    } else {
      return formatConversationTime(dateTime, locale);
    }
  }

  /// 格式化语音消息时长
  ///
  /// 返回格式：x" 或 x'y"
  static String formatVoiceDuration(Duration duration) {
    final seconds = duration.inSeconds;
    if (seconds < 60) {
      return '$seconds"';
    } else {
      final minutes = seconds ~/ 60;
      final remainingSeconds = seconds % 60;
      if (remainingSeconds == 0) {
        return "$minutes'";
      }
      return "$minutes'$remainingSeconds\"";
    }
  }

  /// 格式化在线状态时间
  static String formatLastSeen(
    DateTime? lastSeen, [
    DateLocaleStrings? locale,
  ]) {
    locale ??= _defaultLocale;
    if (lastSeen == null) return locale.offline;

    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inMinutes < 5) {
      return locale.online;
    } else if (difference.inMinutes < 60) {
      return locale.minutesAgoOnline(difference.inMinutes);
    } else if (difference.inHours < 24) {
      return locale.hoursAgoOnline(difference.inHours);
    } else if (difference.inDays < 7) {
      return locale.daysAgoOnline(difference.inDays);
    } else {
      return locale.offline;
    }
  }

  /// 判断两条消息是否需要显示时间分隔
  ///
  /// 超过5分钟显示时间
  static bool shouldShowTimeSeparator(DateTime? prev, DateTime current) {
    if (prev == null) return true;
    return current.difference(prev).inMinutes >= 5;
  }

  /// 判断是否同一天
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
