import 'package:equatable/equatable.dart';

import '../../core/utils/event_message_data.dart';

final _whitespaceRegExp = RegExp(r'\s+');

/// 消息类型
enum MessageType {
  /// 文本消息
  text,

  /// 图片消息
  image,

  /// 语音消息
  voice,

  /// 音频消息（别名）
  audio,

  /// 视频消息
  video,

  /// 文件消息
  file,

  /// 位置消息
  location,

  /// 贴纸/表情
  sticker,

  /// 代码块（带语言标注 + 行号 + 复制）
  codeBlock,

  /// 打赏（渐变气泡，经钱包桥转账）
  tip,

  /// 系统消息
  system,

  /// 通知消息（入群、退群等）
  notice,

  /// 已加密（无法解密）
  encrypted,

  /// 已撤回
  redacted,

  /// 转账消息
  transfer,

  /// 收款请求
  paymentRequest,

  /// 红包
  redPacket,

  /// 投票
  poll,

  /// 音乐分享
  music,

  /// 语音通话
  voiceCall,

  /// 视频通话
  videoCall,

  /// 联系人名片
  contactCard,

  /// 日程 / 事件消息（可加入日历）
  event,

  /// 未知类型
  unknown,
}

/// 消息状态
enum MessageStatus {
  /// 发送中
  sending,

  /// 已发送
  sent,

  /// 已送达
  delivered,

  /// 已读
  read,

  /// 发送失败
  failed,
}

/// 消息实体
///
/// 表示聊天中的一条消息
class MessageEntity extends Equatable {
  /// Matrix事件ID
  final String id;

  /// 房间ID
  final String roomId;

  /// 发送者用户ID
  final String senderId;

  /// 发送者显示名称
  final String senderName;

  /// 发送者头像URL
  final String? senderAvatarUrl;

  /// 消息内容
  final String content;

  /// 格式化后的内容（如HTML）
  final String? formattedContent;

  /// 消息类型
  final MessageType type;

  /// 发送时间
  final DateTime timestamp;

  /// 消息状态
  final MessageStatus status;

  /// 是否是当前用户发送
  final bool isFromMe;

  /// 别名：isMe
  bool get isMe => isFromMe;

  /// 回复的消息ID
  final String? replyToId;

  /// 回复的消息内容预览
  final String? replyToContent;

  /// 回复的消息发送者
  final String? replyToSender;

  /// 是否已编辑
  final bool isEdited;

  /// 编辑时间
  final DateTime? editedAt;

  /// 附加数据（图片URL、文件信息等）
  final MessageMetadata? metadata;

  /// 反应（emoji reactions）
  final List<MessageReaction> reactions;

  /// 已读回执用户列表
  final List<String> readBy;

  /// 提及的用户ID列表
  final List<String> mentionedUserIds;

  /// 是否 @全体成员
  final bool mentionsRoom;

  /// 阅后即焚：消息被阅读后多少秒自毁（null 表示不自毁）
  final int? selfDestructAfter;

  /// 阅后即焚：消息实际销毁时间（已设置则表示倒计时已开始）
  final DateTime? destroyedAt;

  /// 定时发送：消息的预定发送时间（null 表示立即发送）
  final DateTime? scheduledAt;

  // ============================================
  // 消息线程 (MSC3440)
  // ============================================

  /// 所属线程根消息 ID（非 null 表示该消息是线程内的回复）
  final String? threadRootId;

  /// 线程回复数（仅线程根消息有值）
  final int? threadReplyCount;

  /// 最新回复内容预览
  final String? threadLatestReply;

  /// 最新回复者
  final String? threadLatestReplySender;

  /// 最新回复时间
  final DateTime? threadLatestReplyTimestamp;

  /// 是否是线程根消息（有人在此消息上创建了线程）
  bool get isThreadRoot => threadReplyCount != null && threadReplyCount! > 0;

  /// 是否在线程内（是某个线程的回复消息）
  bool get isInThread => threadRootId != null;

  /// 是否是 Bot 消息
  final bool isBotMessage;

  /// 线程未读消息数
  final int? threadUnreadCount;

  const MessageEntity({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.senderName,
    this.senderAvatarUrl,
    required this.content,
    this.formattedContent,
    required this.type,
    required this.timestamp,
    this.status = MessageStatus.sent,
    this.isFromMe = false,
    this.replyToId,
    this.replyToContent,
    this.replyToSender,
    this.isEdited = false,
    this.editedAt,
    this.metadata,
    this.reactions = const [],
    this.readBy = const [],
    this.mentionedUserIds = const [],
    this.mentionsRoom = false,
    this.selfDestructAfter,
    this.destroyedAt,
    this.scheduledAt,
    this.threadRootId,
    this.threadReplyCount,
    this.threadLatestReply,
    this.threadLatestReplySender,
    this.threadLatestReplyTimestamp,
    this.isBotMessage = false,
    this.threadUnreadCount,
  });

  /// 是否是文本消息
  bool get isText => type == MessageType.text;

  /// 是否是媒体消息
  bool get isMedia =>
      type == MessageType.image ||
      type == MessageType.voice ||
      type == MessageType.video;

  /// 是否是系统/通知消息
  bool get isSystemMessage =>
      type == MessageType.system || type == MessageType.notice;

  /// 是否有回复
  bool get hasReply => replyToId != null;

  /// 是否正在发送
  bool get isSending => status == MessageStatus.sending;

  /// 是否发送失败
  bool get isFailed => status == MessageStatus.failed;

  /// 是否是阅后即焚消息
  bool get isSelfDestructing => selfDestructAfter != null;

  /// 阅后即焚倒计时是否已开始
  bool get isDestructionStarted => destroyedAt != null;

  /// 获取剩余销毁时间（秒），null 表示尚未开始或不是阅后即焚消息
  int? get remainingDestructionSeconds {
    if (!isSelfDestructing || destroyedAt == null) return null;
    final remaining = destroyedAt!.difference(DateTime.now()).inSeconds;
    return remaining > 0 ? remaining : 0;
  }

  /// 消息是否已过期（应该被销毁）
  bool get isExpired {
    if (!isSelfDestructing || destroyedAt == null) return false;
    return DateTime.now().isAfter(destroyedAt!);
  }

  /// 是否是定时消息
  bool get isScheduled => scheduledAt != null;

  /// 定时消息是否已到发送时间
  bool get isScheduledTimeReached {
    if (scheduledAt == null) return false;
    return DateTime.now().isAfter(scheduledAt!) ||
        DateTime.now().isAtSameMomentAs(scheduledAt!);
  }

  /// 获取距离定时发送的剩余秒数
  int? get remainingScheduledSeconds {
    if (scheduledAt == null) return null;
    final remaining = scheduledAt!.difference(DateTime.now()).inSeconds;
    return remaining > 0 ? remaining : 0;
  }

  /// 是否提及了指定用户
  bool mentionsUser(String userId) => mentionedUserIds.contains(userId);

  /// 是否有任何提及（包括 @全体 或具体用户）
  bool get hasMentions => mentionsRoom || mentionedUserIds.isNotEmpty;

  /// 获取发送者首字母
  String get senderInitials {
    if (senderName.isEmpty) return '?';
    final words = senderName.trim().split(_whitespaceRegExp);
    if (words.length == 1) {
      return senderName
          .substring(0, senderName.length.clamp(0, 2))
          .toUpperCase();
    }
    return words
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();
  }

  @override
  List<Object?> get props => [
    id,
    roomId,
    senderId,
    senderName,
    senderAvatarUrl,
    content,
    formattedContent,
    type,
    timestamp,
    status,
    isFromMe,
    replyToId,
    replyToContent,
    replyToSender,
    isEdited,
    editedAt,
    metadata,
    reactions,
    readBy,
    mentionedUserIds,
    mentionsRoom,
    selfDestructAfter,
    destroyedAt,
    scheduledAt,
    threadRootId,
    threadReplyCount,
    threadLatestReply,
    threadLatestReplySender,
    threadLatestReplyTimestamp,
    isBotMessage,
    threadUnreadCount,
  ];

  MessageEntity copyWith({
    String? id,
    String? roomId,
    String? senderId,
    String? senderName,
    String? senderAvatarUrl,
    String? content,
    String? formattedContent,
    MessageType? type,
    DateTime? timestamp,
    MessageStatus? status,
    bool? isFromMe,
    String? replyToId,
    String? replyToContent,
    String? replyToSender,
    bool? isEdited,
    DateTime? editedAt,
    MessageMetadata? metadata,
    List<MessageReaction>? reactions,
    List<String>? readBy,
    List<String>? mentionedUserIds,
    bool? mentionsRoom,
    int? selfDestructAfter,
    DateTime? destroyedAt,
    DateTime? scheduledAt,
    String? threadRootId,
    int? threadReplyCount,
    String? threadLatestReply,
    String? threadLatestReplySender,
    DateTime? threadLatestReplyTimestamp,
    bool? isBotMessage,
    int? threadUnreadCount,
  }) {
    return MessageEntity(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderAvatarUrl: senderAvatarUrl ?? this.senderAvatarUrl,
      content: content ?? this.content,
      formattedContent: formattedContent ?? this.formattedContent,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      isFromMe: isFromMe ?? this.isFromMe,
      replyToId: replyToId ?? this.replyToId,
      replyToContent: replyToContent ?? this.replyToContent,
      replyToSender: replyToSender ?? this.replyToSender,
      isEdited: isEdited ?? this.isEdited,
      editedAt: editedAt ?? this.editedAt,
      metadata: metadata ?? this.metadata,
      reactions: reactions ?? this.reactions,
      readBy: readBy ?? this.readBy,
      mentionedUserIds: mentionedUserIds ?? this.mentionedUserIds,
      mentionsRoom: mentionsRoom ?? this.mentionsRoom,
      selfDestructAfter: selfDestructAfter ?? this.selfDestructAfter,
      destroyedAt: destroyedAt ?? this.destroyedAt,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      threadRootId: threadRootId ?? this.threadRootId,
      threadReplyCount: threadReplyCount ?? this.threadReplyCount,
      threadLatestReply: threadLatestReply ?? this.threadLatestReply,
      threadLatestReplySender:
          threadLatestReplySender ?? this.threadLatestReplySender,
      threadLatestReplyTimestamp:
          threadLatestReplyTimestamp ?? this.threadLatestReplyTimestamp,
      isBotMessage: isBotMessage ?? this.isBotMessage,
      threadUnreadCount: threadUnreadCount ?? this.threadUnreadCount,
    );
  }

  /// 创建一个开始自毁倒计时的消息副本
  MessageEntity startDestruction() {
    if (!isSelfDestructing || isDestructionStarted) return this;
    return copyWith(
      destroyedAt: DateTime.now().add(Duration(seconds: selfDestructAfter!)),
    );
  }
}

/// 语音转文字状态
enum TranscriptionStatus {
  /// 尚未开始转录
  none,

  /// 正在转录中
  transcribing,

  /// 转录成功
  success,

  /// 转录失败
  failed,
}

/// 消息附加数据
class MessageMetadata extends Equatable {
  // ============================================
  // 媒体通用属性
  // ============================================

  /// 媒体URL (mxc://)
  final String? mediaUrl;

  /// HTTP URL (用于预览)
  final String? httpUrl;

  /// 缩略图URL
  final String? thumbnailUrl;

  /// MIME类型
  final String? mimeType;

  /// 文件大小（字节）
  final int? size;

  // ============================================
  // 图片/视频属性
  // ============================================

  /// 宽度
  final int? width;

  /// 高度
  final int? height;

  // ============================================
  // 音频/视频属性
  // ============================================

  /// 时长（毫秒）
  final int? duration;

  // ============================================
  // 文件属性
  // ============================================

  /// 文件名
  final String? fileName;

  // ============================================
  // 语音消息属性
  // ============================================

  /// 是否已播放
  final bool? isPlayed;

  /// 波形数据
  final List<int>? waveform;

  /// 语音转文字结果
  final String? transcription;

  /// 语音转文字状态
  final TranscriptionStatus? transcriptionStatus;

  // ============================================
  // 位置属性
  // ============================================

  /// 纬度
  final double? latitude;

  /// 经度
  final double? longitude;

  /// 位置名称
  final String? locationName;

  // ============================================
  // 转账属性
  // ============================================

  /// 转账金额
  final String? amount;

  /// 代币符号
  final String? token;

  /// 转账状态
  final String? transferStatus;

  /// 交易哈希
  final String? txHash;

  /// 收款请求 ID
  final String? paymentRequestId;

  /// 收款地址
  final String? paymentReceiverAddress;

  /// 收款请求过期时间
  final DateTime? paymentRequestExpiresAt;

  /// 红包 ID（用于领取和查询真实红包状态）
  final String? redPacketId;

  // ============================================
  // 投票属性
  // ============================================

  /// 投票问题
  final String? pollQuestion;

  /// 投票选项
  final List<String>? pollOptions;

  /// 投票选项ID列表
  final List<String>? pollOptionIds;

  /// 已投票的选项ID（用户自己的选择）
  final List<String>? myVotes;

  /// 每个选项的投票数 {optionId: count}
  final Map<String, int>? voteCounts;

  /// 总投票人数
  final int? totalVoters;

  /// 最大可选数量（1=单选，0=不限）
  final int? maxSelections;

  /// 是否已结束
  final bool? pollEnded;

  /// 是否匿名投票
  final bool? isAnonymousPoll;

  /// Quiz 正确选项序号（null = 普通投票，非 null = Quiz 答题）
  final int? quizCorrectIndex;

  /// Quiz 答案解析（可空）
  final String? quizExplanation;

  // ============================================
  // E2EE 加密媒体属性（file 字段中的 key 材料）
  // ============================================

  /// AES-CTR 密钥（base64url，来自 file.key.k）
  final String? encryptKey;

  /// AES-CTR IV（base64，来自 file.iv）
  final String? encryptIv;

  /// SHA-256 校验（base64，来自 file.hashes.sha256）
  final String? encryptSha256;

  // ============================================
  // 音乐属性
  // ============================================

  /// 歌曲名称
  final String? musicTitle;

  /// 歌手/艺术家
  final String? musicArtist;

  /// 音乐链接
  final String? musicUrl;

  /// 专辑封面
  final String? musicCover;

  // ============================================
  // 通话属性
  // ============================================

  /// 通话时长（秒）
  final int? callDuration;

  /// 通话是否已结束
  final bool? callEnded;

  /// 是否是未接来电
  final bool? isMissedCall;

  /// 通话结束原因
  final String? callEndReason;

  /// 通话房间 ID（用于回拨）
  final String? callRoomId;

  /// 通话对方 ID
  final String? callPeerId;

  // ============================================
  // 日程 / 事件属性
  // ============================================

  /// 日程/事件载荷（标题、起止时间、地点、描述）
  final EventMessageData? event;

  const MessageMetadata({
    this.mediaUrl,
    this.httpUrl,
    this.thumbnailUrl,
    this.mimeType,
    this.size,
    this.width,
    this.height,
    this.duration,
    this.fileName,
    this.isPlayed,
    this.waveform,
    this.transcription,
    this.transcriptionStatus,
    this.latitude,
    this.longitude,
    this.locationName,
    this.amount,
    this.token,
    this.transferStatus,
    this.txHash,
    this.paymentRequestId,
    this.paymentReceiverAddress,
    this.paymentRequestExpiresAt,
    this.redPacketId,
    this.pollQuestion,
    this.pollOptions,
    this.pollOptionIds,
    this.myVotes,
    this.voteCounts,
    this.totalVoters,
    this.maxSelections,
    this.pollEnded,
    this.isAnonymousPoll,
    this.quizCorrectIndex,
    this.quizExplanation,
    this.encryptKey,
    this.encryptIv,
    this.encryptSha256,
    this.musicTitle,
    this.musicArtist,
    this.musicUrl,
    this.musicCover,
    this.callDuration,
    this.callEnded,
    this.isMissedCall,
    this.callEndReason,
    this.callRoomId,
    this.callPeerId,
    this.event,
  });

  /// 格式化文件大小
  String get formattedSize {
    if (size == null) return '';
    if (size! < 1024) return '$size B';
    if (size! < 1024 * 1024) return '${(size! / 1024).toStringAsFixed(1)} KB';
    if (size! < 1024 * 1024 * 1024) {
      return '${(size! / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(size! / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// 格式化时长
  String get formattedDuration {
    if (duration == null) return '';
    final seconds = (duration! / 1000).round();
    if (seconds < 60) return '$seconds"';
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    if (remainingSeconds == 0) return "$minutes'";
    return "$minutes'$remainingSeconds\"";
  }

  @override
  List<Object?> get props => [
    mediaUrl,
    httpUrl,
    thumbnailUrl,
    mimeType,
    size,
    width,
    height,
    duration,
    fileName,
    isPlayed,
    waveform,
    transcription,
    transcriptionStatus,
    latitude,
    longitude,
    locationName,
    amount,
    token,
    transferStatus,
    txHash,
    paymentRequestId,
    paymentReceiverAddress,
    paymentRequestExpiresAt,
    redPacketId,
    pollQuestion,
    pollOptions,
    pollOptionIds,
    myVotes,
    voteCounts,
    totalVoters,
    maxSelections,
    pollEnded,
    isAnonymousPoll,
    quizCorrectIndex,
    quizExplanation,
    encryptKey,
    encryptIv,
    encryptSha256,
    musicTitle,
    musicArtist,
    musicUrl,
    musicCover,
    callDuration,
    callEnded,
    isMissedCall,
    callEndReason,
    callRoomId,
    callPeerId,
    event,
  ];

  /// Create a copy with updated poll fields
  MessageMetadata copyWithPoll({
    bool? pollEnded,
    Map<String, int>? voteCounts,
    int? totalVoters,
    List<String>? myVotes,
    bool? isAnonymousPoll,
  }) => MessageMetadata(
    pollQuestion: pollQuestion,
    pollOptions: pollOptions,
    pollOptionIds: pollOptionIds,
    maxSelections: maxSelections,
    pollEnded: pollEnded ?? this.pollEnded,
    isAnonymousPoll: isAnonymousPoll ?? this.isAnonymousPoll,
    voteCounts: voteCounts ?? this.voteCounts,
    totalVoters: totalVoters ?? this.totalVoters,
    myVotes: myVotes ?? this.myVotes,
    quizCorrectIndex: quizCorrectIndex,
    quizExplanation: quizExplanation,
    mediaUrl: mediaUrl,
    httpUrl: httpUrl,
    thumbnailUrl: thumbnailUrl,
    mimeType: mimeType,
    size: size,
    width: width,
    height: height,
    duration: duration,
    fileName: fileName,
    isPlayed: isPlayed,
    waveform: waveform,
    transcription: transcription,
    transcriptionStatus: transcriptionStatus,
    latitude: latitude,
    longitude: longitude,
    locationName: locationName,
    amount: amount,
    token: token,
    transferStatus: transferStatus,
    txHash: txHash,
    paymentRequestId: paymentRequestId,
    paymentReceiverAddress: paymentReceiverAddress,
    paymentRequestExpiresAt: paymentRequestExpiresAt,
    redPacketId: redPacketId,
    musicTitle: musicTitle,
    musicArtist: musicArtist,
    musicUrl: musicUrl,
    musicCover: musicCover,
    callDuration: callDuration,
    callEnded: callEnded,
    isMissedCall: isMissedCall,
    callEndReason: callEndReason,
    callRoomId: callRoomId,
    callPeerId: callPeerId,
  );

  /// Create a copy with updated transcription fields
  MessageMetadata copyWithTranscription({
    String? transcription,
    TranscriptionStatus? transcriptionStatus,
  }) => MessageMetadata(
    mediaUrl: mediaUrl,
    httpUrl: httpUrl,
    thumbnailUrl: thumbnailUrl,
    mimeType: mimeType,
    size: size,
    width: width,
    height: height,
    duration: duration,
    fileName: fileName,
    isPlayed: isPlayed,
    waveform: waveform,
    transcription: transcription ?? this.transcription,
    transcriptionStatus: transcriptionStatus ?? this.transcriptionStatus,
    latitude: latitude,
    longitude: longitude,
    locationName: locationName,
    amount: amount,
    token: token,
    transferStatus: transferStatus,
    txHash: txHash,
    paymentRequestId: paymentRequestId,
    paymentReceiverAddress: paymentReceiverAddress,
    paymentRequestExpiresAt: paymentRequestExpiresAt,
    redPacketId: redPacketId,
    pollQuestion: pollQuestion,
    pollOptions: pollOptions,
    pollOptionIds: pollOptionIds,
    maxSelections: maxSelections,
    pollEnded: pollEnded,
    isAnonymousPoll: isAnonymousPoll,
    voteCounts: voteCounts,
    totalVoters: totalVoters,
    myVotes: myVotes,
    musicTitle: musicTitle,
    musicArtist: musicArtist,
    musicUrl: musicUrl,
    musicCover: musicCover,
    callDuration: callDuration,
    callEnded: callEnded,
    isMissedCall: isMissedCall,
    callEndReason: callEndReason,
    callRoomId: callRoomId,
    callPeerId: callPeerId,
  );

  /// Create a copy with updated transfer/payment fields
  MessageMetadata copyWithTransfer({
    String? amount,
    String? token,
    String? transferStatus,
    String? txHash,
    String? paymentRequestId,
    String? paymentReceiverAddress,
    DateTime? paymentRequestExpiresAt,
    String? redPacketId,
  }) => MessageMetadata(
    mediaUrl: mediaUrl,
    httpUrl: httpUrl,
    thumbnailUrl: thumbnailUrl,
    mimeType: mimeType,
    size: size,
    width: width,
    height: height,
    duration: duration,
    fileName: fileName,
    isPlayed: isPlayed,
    waveform: waveform,
    transcription: transcription,
    transcriptionStatus: transcriptionStatus,
    latitude: latitude,
    longitude: longitude,
    locationName: locationName,
    amount: amount ?? this.amount,
    token: token ?? this.token,
    transferStatus: transferStatus ?? this.transferStatus,
    txHash: txHash ?? this.txHash,
    paymentRequestId: paymentRequestId ?? this.paymentRequestId,
    paymentReceiverAddress:
        paymentReceiverAddress ?? this.paymentReceiverAddress,
    paymentRequestExpiresAt:
        paymentRequestExpiresAt ?? this.paymentRequestExpiresAt,
    redPacketId: redPacketId ?? this.redPacketId,
    pollQuestion: pollQuestion,
    pollOptions: pollOptions,
    pollOptionIds: pollOptionIds,
    myVotes: myVotes,
    voteCounts: voteCounts,
    totalVoters: totalVoters,
    maxSelections: maxSelections,
    pollEnded: pollEnded,
    isAnonymousPoll: isAnonymousPoll,
    musicTitle: musicTitle,
    musicArtist: musicArtist,
    musicUrl: musicUrl,
    musicCover: musicCover,
    callDuration: callDuration,
    callEnded: callEnded,
    isMissedCall: isMissedCall,
    callEndReason: callEndReason,
    callRoomId: callRoomId,
    callPeerId: callPeerId,
  );

  /// 是否是匿名投票
  bool get isAnonymous => isAnonymousPoll == true;

  /// 是否有转录文本
  bool get hasTranscription =>
      transcription != null && transcription!.isNotEmpty;

  /// 是否正在转录中
  bool get isTranscribing =>
      transcriptionStatus == TranscriptionStatus.transcribing;
}

/// 消息反应（Reaction）
class MessageReaction extends Equatable {
  /// 反应内容（emoji）
  final String key;

  /// 反应的用户ID列表（Matrix `m.annotation` chunk 不携带具体用户，
  /// 此时为空列表，[count] 由聚合 `count` 提供）
  final List<String> userIds;

  /// 当前用户是否已反应
  final bool isMe;

  /// 服务端聚合数量；优先于 `userIds.length`。
  /// 仅 Matrix 聚合事件（无 user 列表，仅给 count）会传入；本地操作仍走 userIds。
  final int? aggregateCount;

  const MessageReaction({
    required this.key,
    required this.userIds,
    this.isMe = false,
    this.aggregateCount,
  });

  /// 反应数量
  int get count => aggregateCount ?? userIds.length;

  @override
  List<Object?> get props => [key, userIds, isMe, aggregateCount];
}
