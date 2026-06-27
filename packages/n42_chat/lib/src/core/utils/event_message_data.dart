/// 日程 / 事件消息载荷（聊天内发送可加入日历的事件卡片）
///
/// 纯数据 + 编解码 + ICS 生成，无 IO，便于单测。
/// Matrix 自定义 msgtype `n42.event`，字段时间用毫秒时间戳。
class EventMessageData {
  /// msgtype 标识
  static const String msgType = 'n42.event';

  /// 事件标题
  final String title;

  /// 开始时间
  final DateTime startsAt;

  /// 结束时间（可空）
  final DateTime? endsAt;

  /// 地点（可空）
  final String? location;

  /// 描述（可空）
  final String? description;

  const EventMessageData({
    required this.title,
    required this.startsAt,
    this.endsAt,
    this.location,
    this.description,
  });

  /// 是否已结束（相对 [now]，默认现在由调用方传入以便测试）
  bool isPast(DateTime now) {
    final end = endsAt ?? startsAt;
    return now.isAfter(end);
  }

  /// 编码为 Matrix 自定义消息的 additionalData（不含 msgtype/body）
  Map<String, dynamic> toContent() => {
        'title': title,
        'starts_at': startsAt.millisecondsSinceEpoch,
        if (endsAt != null) 'ends_at': endsAt!.millisecondsSinceEpoch,
        if (location != null && location!.trim().isNotEmpty)
          'location': location!.trim(),
        if (description != null && description!.trim().isNotEmpty)
          'description': description!.trim(),
      };

  /// 从消息 content 解析；缺少 title / starts_at 返回 null。
  static EventMessageData? fromContent(Map<String, dynamic> content) {
    final title = (content['title'] as String?)?.trim();
    final startsMs = content['starts_at'];
    if (title == null || title.isEmpty || startsMs is! int) return null;

    final endsMs = content['ends_at'];
    return EventMessageData(
      title: title,
      startsAt: DateTime.fromMillisecondsSinceEpoch(startsMs),
      endsAt: endsMs is int ? DateTime.fromMillisecondsSinceEpoch(endsMs) : null,
      location: _nullIfEmpty(content['location'] as String?),
      description: _nullIfEmpty(content['description'] as String?),
    );
  }

  /// 兜底 body 文本（不支持的客户端看到纯文本）
  String get fallbackBody {
    final when = formatLocal(startsAt);
    return '📅 $title — $when';
  }

  /// 生成单事件 ICS（VEVENT）文本，可作为 .ics 文件分享导入系统日历。
  String toIcs() {
    final buf = StringBuffer()
      ..writeln('BEGIN:VCALENDAR')
      ..writeln('VERSION:2.0')
      ..writeln('PRODID:-//N42 Chat//Event//EN')
      ..writeln('BEGIN:VEVENT')
      ..writeln('UID:${startsAt.millisecondsSinceEpoch}@n42.chat')
      ..writeln('DTSTART:${_icsStamp(startsAt)}')
      ..writeln('DTEND:${_icsStamp(endsAt ?? startsAt)}')
      ..writeln('SUMMARY:${_icsEscape(title)}');
    if (location != null && location!.trim().isNotEmpty) {
      buf.writeln('LOCATION:${_icsEscape(location!.trim())}');
    }
    if (description != null && description!.trim().isNotEmpty) {
      buf.writeln('DESCRIPTION:${_icsEscape(description!.trim())}');
    }
    buf
      ..writeln('END:VEVENT')
      ..writeln('END:VCALENDAR');
    return buf.toString();
  }

  /// ICS UTC 时间戳 `yyyyMMddTHHmmssZ`
  static String _icsStamp(DateTime dt) {
    final u = dt.toUtc();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${u.year.toString().padLeft(4, '0')}${two(u.month)}${two(u.day)}'
        'T${two(u.hour)}${two(u.minute)}${two(u.second)}Z';
  }

  /// ICS 文本转义（逗号/分号/反斜杠/换行）
  static String _icsEscape(String s) => s
      .replaceAll('\\', '\\\\')
      .replaceAll(',', '\\,')
      .replaceAll(';', '\\;')
      .replaceAll('\n', '\\n');

  /// 本地可读时间 `yyyy-MM-dd HH:mm`
  static String formatLocal(DateTime dt) {
    final l = dt.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${l.year}-${two(l.month)}-${two(l.day)} ${two(l.hour)}:${two(l.minute)}';
  }

  /// 起止时间区间：同一天省略结束日期，仅显示结束 `HH:mm`
  static String formatRange(DateTime start, DateTime end) {
    final s = start.toLocal();
    final e = end.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    final sameDay = s.year == e.year && s.month == e.month && s.day == e.day;
    if (sameDay) {
      return '${formatLocal(start)} - ${two(e.hour)}:${two(e.minute)}';
    }
    return '${formatLocal(start)} - ${formatLocal(end)}';
  }

  static String? _nullIfEmpty(String? v) {
    final t = v?.trim();
    return (t == null || t.isEmpty) ? null : t;
  }

  @override
  bool operator ==(Object other) =>
      other is EventMessageData &&
      other.title == title &&
      other.startsAt == startsAt &&
      other.endsAt == endsAt &&
      other.location == location &&
      other.description == description;

  @override
  int get hashCode =>
      Object.hash(title, startsAt, endsAt, location, description);
}
