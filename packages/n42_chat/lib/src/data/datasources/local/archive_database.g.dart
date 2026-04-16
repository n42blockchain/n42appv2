// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'archive_database.dart';

// ignore_for_file: type=lint
class $ArchivedMessagesTable extends ArchivedMessages
    with TableInfo<$ArchivedMessagesTable, ArchivedMessage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ArchivedMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _eventIdMeta = const VerificationMeta(
    'eventId',
  );
  @override
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
    'event_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roomIdMeta = const VerificationMeta('roomId');
  @override
  late final GeneratedColumn<String> roomId = GeneratedColumn<String>(
    'room_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _senderIdMeta = const VerificationMeta(
    'senderId',
  );
  @override
  late final GeneratedColumn<String> senderId = GeneratedColumn<String>(
    'sender_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originServerTsMeta = const VerificationMeta(
    'originServerTs',
  );
  @override
  late final GeneratedColumn<int> originServerTs = GeneratedColumn<int>(
    'origin_server_ts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _formattedBodyMeta = const VerificationMeta(
    'formattedBody',
  );
  @override
  late final GeneratedColumn<String> formattedBody = GeneratedColumn<String>(
    'formatted_body',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _msgtypeMeta = const VerificationMeta(
    'msgtype',
  );
  @override
  late final GeneratedColumn<String> msgtype = GeneratedColumn<String>(
    'msgtype',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _relatesToMeta = const VerificationMeta(
    'relatesTo',
  );
  @override
  late final GeneratedColumn<String> relatesTo = GeneratedColumn<String>(
    'relates_to',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mediaInfoMeta = const VerificationMeta(
    'mediaInfo',
  );
  @override
  late final GeneratedColumn<String> mediaInfo = GeneratedColumn<String>(
    'media_info',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isEncryptedMeta = const VerificationMeta(
    'isEncrypted',
  );
  @override
  late final GeneratedColumn<bool> isEncrypted = GeneratedColumn<bool>(
    'is_encrypted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_encrypted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _decryptedBodyMeta = const VerificationMeta(
    'decryptedBody',
  );
  @override
  late final GeneratedColumn<String> decryptedBody = GeneratedColumn<String>(
    'decrypted_body',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _quarterMeta = const VerificationMeta(
    'quarter',
  );
  @override
  late final GeneratedColumn<int> quarter = GeneratedColumn<int>(
    'quarter',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _archivedAtMeta = const VerificationMeta(
    'archivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> archivedAt = GeneratedColumn<DateTime>(
    'archived_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    eventId,
    roomId,
    senderId,
    originServerTs,
    type,
    body,
    formattedBody,
    msgtype,
    relatesTo,
    mediaInfo,
    isEncrypted,
    decryptedBody,
    quarter,
    archivedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'archived_messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<ArchivedMessage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('event_id')) {
      context.handle(
        _eventIdMeta,
        eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta),
      );
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    if (data.containsKey('room_id')) {
      context.handle(
        _roomIdMeta,
        roomId.isAcceptableOrUnknown(data['room_id']!, _roomIdMeta),
      );
    } else if (isInserting) {
      context.missing(_roomIdMeta);
    }
    if (data.containsKey('sender_id')) {
      context.handle(
        _senderIdMeta,
        senderId.isAcceptableOrUnknown(data['sender_id']!, _senderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_senderIdMeta);
    }
    if (data.containsKey('origin_server_ts')) {
      context.handle(
        _originServerTsMeta,
        originServerTs.isAcceptableOrUnknown(
          data['origin_server_ts']!,
          _originServerTsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originServerTsMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    }
    if (data.containsKey('formatted_body')) {
      context.handle(
        _formattedBodyMeta,
        formattedBody.isAcceptableOrUnknown(
          data['formatted_body']!,
          _formattedBodyMeta,
        ),
      );
    }
    if (data.containsKey('msgtype')) {
      context.handle(
        _msgtypeMeta,
        msgtype.isAcceptableOrUnknown(data['msgtype']!, _msgtypeMeta),
      );
    }
    if (data.containsKey('relates_to')) {
      context.handle(
        _relatesToMeta,
        relatesTo.isAcceptableOrUnknown(data['relates_to']!, _relatesToMeta),
      );
    }
    if (data.containsKey('media_info')) {
      context.handle(
        _mediaInfoMeta,
        mediaInfo.isAcceptableOrUnknown(data['media_info']!, _mediaInfoMeta),
      );
    }
    if (data.containsKey('is_encrypted')) {
      context.handle(
        _isEncryptedMeta,
        isEncrypted.isAcceptableOrUnknown(
          data['is_encrypted']!,
          _isEncryptedMeta,
        ),
      );
    }
    if (data.containsKey('decrypted_body')) {
      context.handle(
        _decryptedBodyMeta,
        decryptedBody.isAcceptableOrUnknown(
          data['decrypted_body']!,
          _decryptedBodyMeta,
        ),
      );
    }
    if (data.containsKey('quarter')) {
      context.handle(
        _quarterMeta,
        quarter.isAcceptableOrUnknown(data['quarter']!, _quarterMeta),
      );
    } else if (isInserting) {
      context.missing(_quarterMeta);
    }
    if (data.containsKey('archived_at')) {
      context.handle(
        _archivedAtMeta,
        archivedAt.isAcceptableOrUnknown(data['archived_at']!, _archivedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_archivedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {eventId};
  @override
  ArchivedMessage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ArchivedMessage(
      eventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_id'],
      )!,
      roomId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}room_id'],
      )!,
      senderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender_id'],
      )!,
      originServerTs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}origin_server_ts'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      ),
      formattedBody: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}formatted_body'],
      ),
      msgtype: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}msgtype'],
      ),
      relatesTo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relates_to'],
      ),
      mediaInfo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_info'],
      ),
      isEncrypted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_encrypted'],
      )!,
      decryptedBody: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}decrypted_body'],
      ),
      quarter: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quarter'],
      )!,
      archivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}archived_at'],
      )!,
    );
  }

  @override
  $ArchivedMessagesTable createAlias(String alias) {
    return $ArchivedMessagesTable(attachedDatabase, alias);
  }
}

class ArchivedMessage extends DataClass implements Insertable<ArchivedMessage> {
  /// Matrix event ID (PK)
  final String eventId;

  /// 所属房间 ID
  final String roomId;

  /// 发送者 Matrix user ID
  final String senderId;

  /// 服务端原始时间戳（毫秒）
  final int originServerTs;

  /// 事件类型：m.room.message, m.sticker 等
  final String type;

  /// 消息体明文
  final String? body;

  /// HTML 格式化内容
  final String? formattedBody;

  /// 消息子类型：m.text, m.image, m.file 等
  final String? msgtype;

  /// JSON: 回复/线程关系 (m.relates_to)
  final String? relatesTo;

  /// JSON: 媒体信息 (mxcUrl, size, mime, w, h, duration 等)
  final String? mediaInfo;

  /// 是否为 E2EE 加密消息
  final bool isEncrypted;

  /// 解密后的明文内容（仅本地存储，不外传）
  final String? decryptedBody;

  /// 所属季度标识：YYYYQQ，如 202501 = 2025年Q1
  final int quarter;

  /// 归档入库时间
  final DateTime archivedAt;
  const ArchivedMessage({
    required this.eventId,
    required this.roomId,
    required this.senderId,
    required this.originServerTs,
    required this.type,
    this.body,
    this.formattedBody,
    this.msgtype,
    this.relatesTo,
    this.mediaInfo,
    required this.isEncrypted,
    this.decryptedBody,
    required this.quarter,
    required this.archivedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['event_id'] = Variable<String>(eventId);
    map['room_id'] = Variable<String>(roomId);
    map['sender_id'] = Variable<String>(senderId);
    map['origin_server_ts'] = Variable<int>(originServerTs);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || body != null) {
      map['body'] = Variable<String>(body);
    }
    if (!nullToAbsent || formattedBody != null) {
      map['formatted_body'] = Variable<String>(formattedBody);
    }
    if (!nullToAbsent || msgtype != null) {
      map['msgtype'] = Variable<String>(msgtype);
    }
    if (!nullToAbsent || relatesTo != null) {
      map['relates_to'] = Variable<String>(relatesTo);
    }
    if (!nullToAbsent || mediaInfo != null) {
      map['media_info'] = Variable<String>(mediaInfo);
    }
    map['is_encrypted'] = Variable<bool>(isEncrypted);
    if (!nullToAbsent || decryptedBody != null) {
      map['decrypted_body'] = Variable<String>(decryptedBody);
    }
    map['quarter'] = Variable<int>(quarter);
    map['archived_at'] = Variable<DateTime>(archivedAt);
    return map;
  }

  ArchivedMessagesCompanion toCompanion(bool nullToAbsent) {
    return ArchivedMessagesCompanion(
      eventId: Value(eventId),
      roomId: Value(roomId),
      senderId: Value(senderId),
      originServerTs: Value(originServerTs),
      type: Value(type),
      body: body == null && nullToAbsent ? const Value.absent() : Value(body),
      formattedBody: formattedBody == null && nullToAbsent
          ? const Value.absent()
          : Value(formattedBody),
      msgtype: msgtype == null && nullToAbsent
          ? const Value.absent()
          : Value(msgtype),
      relatesTo: relatesTo == null && nullToAbsent
          ? const Value.absent()
          : Value(relatesTo),
      mediaInfo: mediaInfo == null && nullToAbsent
          ? const Value.absent()
          : Value(mediaInfo),
      isEncrypted: Value(isEncrypted),
      decryptedBody: decryptedBody == null && nullToAbsent
          ? const Value.absent()
          : Value(decryptedBody),
      quarter: Value(quarter),
      archivedAt: Value(archivedAt),
    );
  }

  factory ArchivedMessage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ArchivedMessage(
      eventId: serializer.fromJson<String>(json['eventId']),
      roomId: serializer.fromJson<String>(json['roomId']),
      senderId: serializer.fromJson<String>(json['senderId']),
      originServerTs: serializer.fromJson<int>(json['originServerTs']),
      type: serializer.fromJson<String>(json['type']),
      body: serializer.fromJson<String?>(json['body']),
      formattedBody: serializer.fromJson<String?>(json['formattedBody']),
      msgtype: serializer.fromJson<String?>(json['msgtype']),
      relatesTo: serializer.fromJson<String?>(json['relatesTo']),
      mediaInfo: serializer.fromJson<String?>(json['mediaInfo']),
      isEncrypted: serializer.fromJson<bool>(json['isEncrypted']),
      decryptedBody: serializer.fromJson<String?>(json['decryptedBody']),
      quarter: serializer.fromJson<int>(json['quarter']),
      archivedAt: serializer.fromJson<DateTime>(json['archivedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'eventId': serializer.toJson<String>(eventId),
      'roomId': serializer.toJson<String>(roomId),
      'senderId': serializer.toJson<String>(senderId),
      'originServerTs': serializer.toJson<int>(originServerTs),
      'type': serializer.toJson<String>(type),
      'body': serializer.toJson<String?>(body),
      'formattedBody': serializer.toJson<String?>(formattedBody),
      'msgtype': serializer.toJson<String?>(msgtype),
      'relatesTo': serializer.toJson<String?>(relatesTo),
      'mediaInfo': serializer.toJson<String?>(mediaInfo),
      'isEncrypted': serializer.toJson<bool>(isEncrypted),
      'decryptedBody': serializer.toJson<String?>(decryptedBody),
      'quarter': serializer.toJson<int>(quarter),
      'archivedAt': serializer.toJson<DateTime>(archivedAt),
    };
  }

  ArchivedMessage copyWith({
    String? eventId,
    String? roomId,
    String? senderId,
    int? originServerTs,
    String? type,
    Value<String?> body = const Value.absent(),
    Value<String?> formattedBody = const Value.absent(),
    Value<String?> msgtype = const Value.absent(),
    Value<String?> relatesTo = const Value.absent(),
    Value<String?> mediaInfo = const Value.absent(),
    bool? isEncrypted,
    Value<String?> decryptedBody = const Value.absent(),
    int? quarter,
    DateTime? archivedAt,
  }) => ArchivedMessage(
    eventId: eventId ?? this.eventId,
    roomId: roomId ?? this.roomId,
    senderId: senderId ?? this.senderId,
    originServerTs: originServerTs ?? this.originServerTs,
    type: type ?? this.type,
    body: body.present ? body.value : this.body,
    formattedBody: formattedBody.present
        ? formattedBody.value
        : this.formattedBody,
    msgtype: msgtype.present ? msgtype.value : this.msgtype,
    relatesTo: relatesTo.present ? relatesTo.value : this.relatesTo,
    mediaInfo: mediaInfo.present ? mediaInfo.value : this.mediaInfo,
    isEncrypted: isEncrypted ?? this.isEncrypted,
    decryptedBody: decryptedBody.present
        ? decryptedBody.value
        : this.decryptedBody,
    quarter: quarter ?? this.quarter,
    archivedAt: archivedAt ?? this.archivedAt,
  );
  ArchivedMessage copyWithCompanion(ArchivedMessagesCompanion data) {
    return ArchivedMessage(
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      roomId: data.roomId.present ? data.roomId.value : this.roomId,
      senderId: data.senderId.present ? data.senderId.value : this.senderId,
      originServerTs: data.originServerTs.present
          ? data.originServerTs.value
          : this.originServerTs,
      type: data.type.present ? data.type.value : this.type,
      body: data.body.present ? data.body.value : this.body,
      formattedBody: data.formattedBody.present
          ? data.formattedBody.value
          : this.formattedBody,
      msgtype: data.msgtype.present ? data.msgtype.value : this.msgtype,
      relatesTo: data.relatesTo.present ? data.relatesTo.value : this.relatesTo,
      mediaInfo: data.mediaInfo.present ? data.mediaInfo.value : this.mediaInfo,
      isEncrypted: data.isEncrypted.present
          ? data.isEncrypted.value
          : this.isEncrypted,
      decryptedBody: data.decryptedBody.present
          ? data.decryptedBody.value
          : this.decryptedBody,
      quarter: data.quarter.present ? data.quarter.value : this.quarter,
      archivedAt: data.archivedAt.present
          ? data.archivedAt.value
          : this.archivedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ArchivedMessage(')
          ..write('eventId: $eventId, ')
          ..write('roomId: $roomId, ')
          ..write('senderId: $senderId, ')
          ..write('originServerTs: $originServerTs, ')
          ..write('type: $type, ')
          ..write('body: $body, ')
          ..write('formattedBody: $formattedBody, ')
          ..write('msgtype: $msgtype, ')
          ..write('relatesTo: $relatesTo, ')
          ..write('mediaInfo: $mediaInfo, ')
          ..write('isEncrypted: $isEncrypted, ')
          ..write('decryptedBody: $decryptedBody, ')
          ..write('quarter: $quarter, ')
          ..write('archivedAt: $archivedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    eventId,
    roomId,
    senderId,
    originServerTs,
    type,
    body,
    formattedBody,
    msgtype,
    relatesTo,
    mediaInfo,
    isEncrypted,
    decryptedBody,
    quarter,
    archivedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ArchivedMessage &&
          other.eventId == this.eventId &&
          other.roomId == this.roomId &&
          other.senderId == this.senderId &&
          other.originServerTs == this.originServerTs &&
          other.type == this.type &&
          other.body == this.body &&
          other.formattedBody == this.formattedBody &&
          other.msgtype == this.msgtype &&
          other.relatesTo == this.relatesTo &&
          other.mediaInfo == this.mediaInfo &&
          other.isEncrypted == this.isEncrypted &&
          other.decryptedBody == this.decryptedBody &&
          other.quarter == this.quarter &&
          other.archivedAt == this.archivedAt);
}

class ArchivedMessagesCompanion extends UpdateCompanion<ArchivedMessage> {
  final Value<String> eventId;
  final Value<String> roomId;
  final Value<String> senderId;
  final Value<int> originServerTs;
  final Value<String> type;
  final Value<String?> body;
  final Value<String?> formattedBody;
  final Value<String?> msgtype;
  final Value<String?> relatesTo;
  final Value<String?> mediaInfo;
  final Value<bool> isEncrypted;
  final Value<String?> decryptedBody;
  final Value<int> quarter;
  final Value<DateTime> archivedAt;
  final Value<int> rowid;
  const ArchivedMessagesCompanion({
    this.eventId = const Value.absent(),
    this.roomId = const Value.absent(),
    this.senderId = const Value.absent(),
    this.originServerTs = const Value.absent(),
    this.type = const Value.absent(),
    this.body = const Value.absent(),
    this.formattedBody = const Value.absent(),
    this.msgtype = const Value.absent(),
    this.relatesTo = const Value.absent(),
    this.mediaInfo = const Value.absent(),
    this.isEncrypted = const Value.absent(),
    this.decryptedBody = const Value.absent(),
    this.quarter = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ArchivedMessagesCompanion.insert({
    required String eventId,
    required String roomId,
    required String senderId,
    required int originServerTs,
    required String type,
    this.body = const Value.absent(),
    this.formattedBody = const Value.absent(),
    this.msgtype = const Value.absent(),
    this.relatesTo = const Value.absent(),
    this.mediaInfo = const Value.absent(),
    this.isEncrypted = const Value.absent(),
    this.decryptedBody = const Value.absent(),
    required int quarter,
    required DateTime archivedAt,
    this.rowid = const Value.absent(),
  }) : eventId = Value(eventId),
       roomId = Value(roomId),
       senderId = Value(senderId),
       originServerTs = Value(originServerTs),
       type = Value(type),
       quarter = Value(quarter),
       archivedAt = Value(archivedAt);
  static Insertable<ArchivedMessage> custom({
    Expression<String>? eventId,
    Expression<String>? roomId,
    Expression<String>? senderId,
    Expression<int>? originServerTs,
    Expression<String>? type,
    Expression<String>? body,
    Expression<String>? formattedBody,
    Expression<String>? msgtype,
    Expression<String>? relatesTo,
    Expression<String>? mediaInfo,
    Expression<bool>? isEncrypted,
    Expression<String>? decryptedBody,
    Expression<int>? quarter,
    Expression<DateTime>? archivedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (eventId != null) 'event_id': eventId,
      if (roomId != null) 'room_id': roomId,
      if (senderId != null) 'sender_id': senderId,
      if (originServerTs != null) 'origin_server_ts': originServerTs,
      if (type != null) 'type': type,
      if (body != null) 'body': body,
      if (formattedBody != null) 'formatted_body': formattedBody,
      if (msgtype != null) 'msgtype': msgtype,
      if (relatesTo != null) 'relates_to': relatesTo,
      if (mediaInfo != null) 'media_info': mediaInfo,
      if (isEncrypted != null) 'is_encrypted': isEncrypted,
      if (decryptedBody != null) 'decrypted_body': decryptedBody,
      if (quarter != null) 'quarter': quarter,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ArchivedMessagesCompanion copyWith({
    Value<String>? eventId,
    Value<String>? roomId,
    Value<String>? senderId,
    Value<int>? originServerTs,
    Value<String>? type,
    Value<String?>? body,
    Value<String?>? formattedBody,
    Value<String?>? msgtype,
    Value<String?>? relatesTo,
    Value<String?>? mediaInfo,
    Value<bool>? isEncrypted,
    Value<String?>? decryptedBody,
    Value<int>? quarter,
    Value<DateTime>? archivedAt,
    Value<int>? rowid,
  }) {
    return ArchivedMessagesCompanion(
      eventId: eventId ?? this.eventId,
      roomId: roomId ?? this.roomId,
      senderId: senderId ?? this.senderId,
      originServerTs: originServerTs ?? this.originServerTs,
      type: type ?? this.type,
      body: body ?? this.body,
      formattedBody: formattedBody ?? this.formattedBody,
      msgtype: msgtype ?? this.msgtype,
      relatesTo: relatesTo ?? this.relatesTo,
      mediaInfo: mediaInfo ?? this.mediaInfo,
      isEncrypted: isEncrypted ?? this.isEncrypted,
      decryptedBody: decryptedBody ?? this.decryptedBody,
      quarter: quarter ?? this.quarter,
      archivedAt: archivedAt ?? this.archivedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
    }
    if (roomId.present) {
      map['room_id'] = Variable<String>(roomId.value);
    }
    if (senderId.present) {
      map['sender_id'] = Variable<String>(senderId.value);
    }
    if (originServerTs.present) {
      map['origin_server_ts'] = Variable<int>(originServerTs.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (formattedBody.present) {
      map['formatted_body'] = Variable<String>(formattedBody.value);
    }
    if (msgtype.present) {
      map['msgtype'] = Variable<String>(msgtype.value);
    }
    if (relatesTo.present) {
      map['relates_to'] = Variable<String>(relatesTo.value);
    }
    if (mediaInfo.present) {
      map['media_info'] = Variable<String>(mediaInfo.value);
    }
    if (isEncrypted.present) {
      map['is_encrypted'] = Variable<bool>(isEncrypted.value);
    }
    if (decryptedBody.present) {
      map['decrypted_body'] = Variable<String>(decryptedBody.value);
    }
    if (quarter.present) {
      map['quarter'] = Variable<int>(quarter.value);
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<DateTime>(archivedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ArchivedMessagesCompanion(')
          ..write('eventId: $eventId, ')
          ..write('roomId: $roomId, ')
          ..write('senderId: $senderId, ')
          ..write('originServerTs: $originServerTs, ')
          ..write('type: $type, ')
          ..write('body: $body, ')
          ..write('formattedBody: $formattedBody, ')
          ..write('msgtype: $msgtype, ')
          ..write('relatesTo: $relatesTo, ')
          ..write('mediaInfo: $mediaInfo, ')
          ..write('isEncrypted: $isEncrypted, ')
          ..write('decryptedBody: $decryptedBody, ')
          ..write('quarter: $quarter, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ArchiveMetadataTable extends ArchiveMetadata
    with TableInfo<$ArchiveMetadataTable, ArchiveMetadataData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ArchiveMetadataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _roomIdMeta = const VerificationMeta('roomId');
  @override
  late final GeneratedColumn<String> roomId = GeneratedColumn<String>(
    'room_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastArchivedEventIdMeta =
      const VerificationMeta('lastArchivedEventId');
  @override
  late final GeneratedColumn<String> lastArchivedEventId =
      GeneratedColumn<String>(
        'last_archived_event_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastArchivedTsMeta = const VerificationMeta(
    'lastArchivedTs',
  );
  @override
  late final GeneratedColumn<int> lastArchivedTs = GeneratedColumn<int>(
    'last_archived_ts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalArchivedMeta = const VerificationMeta(
    'totalArchived',
  );
  @override
  late final GeneratedColumn<int> totalArchived = GeneratedColumn<int>(
    'total_archived',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastArchiveTimeMeta = const VerificationMeta(
    'lastArchiveTime',
  );
  @override
  late final GeneratedColumn<DateTime> lastArchiveTime =
      GeneratedColumn<DateTime>(
        'last_archive_time',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    roomId,
    lastArchivedEventId,
    lastArchivedTs,
    totalArchived,
    lastArchiveTime,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'archive_metadata';
  @override
  VerificationContext validateIntegrity(
    Insertable<ArchiveMetadataData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('room_id')) {
      context.handle(
        _roomIdMeta,
        roomId.isAcceptableOrUnknown(data['room_id']!, _roomIdMeta),
      );
    } else if (isInserting) {
      context.missing(_roomIdMeta);
    }
    if (data.containsKey('last_archived_event_id')) {
      context.handle(
        _lastArchivedEventIdMeta,
        lastArchivedEventId.isAcceptableOrUnknown(
          data['last_archived_event_id']!,
          _lastArchivedEventIdMeta,
        ),
      );
    }
    if (data.containsKey('last_archived_ts')) {
      context.handle(
        _lastArchivedTsMeta,
        lastArchivedTs.isAcceptableOrUnknown(
          data['last_archived_ts']!,
          _lastArchivedTsMeta,
        ),
      );
    }
    if (data.containsKey('total_archived')) {
      context.handle(
        _totalArchivedMeta,
        totalArchived.isAcceptableOrUnknown(
          data['total_archived']!,
          _totalArchivedMeta,
        ),
      );
    }
    if (data.containsKey('last_archive_time')) {
      context.handle(
        _lastArchiveTimeMeta,
        lastArchiveTime.isAcceptableOrUnknown(
          data['last_archive_time']!,
          _lastArchiveTimeMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {roomId};
  @override
  ArchiveMetadataData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ArchiveMetadataData(
      roomId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}room_id'],
      )!,
      lastArchivedEventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_archived_event_id'],
      ),
      lastArchivedTs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_archived_ts'],
      )!,
      totalArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_archived'],
      )!,
      lastArchiveTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_archive_time'],
      ),
    );
  }

  @override
  $ArchiveMetadataTable createAlias(String alias) {
    return $ArchiveMetadataTable(attachedDatabase, alias);
  }
}

class ArchiveMetadataData extends DataClass
    implements Insertable<ArchiveMetadataData> {
  /// 房间 ID (PK)
  final String roomId;

  /// 最后归档的 event ID（断点续归）
  final String? lastArchivedEventId;

  /// 最后归档消息的服务端时间戳
  final int lastArchivedTs;

  /// 该房间归档消息总数
  final int totalArchived;

  /// 最后一次归档操作的时间
  final DateTime? lastArchiveTime;
  const ArchiveMetadataData({
    required this.roomId,
    this.lastArchivedEventId,
    required this.lastArchivedTs,
    required this.totalArchived,
    this.lastArchiveTime,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['room_id'] = Variable<String>(roomId);
    if (!nullToAbsent || lastArchivedEventId != null) {
      map['last_archived_event_id'] = Variable<String>(lastArchivedEventId);
    }
    map['last_archived_ts'] = Variable<int>(lastArchivedTs);
    map['total_archived'] = Variable<int>(totalArchived);
    if (!nullToAbsent || lastArchiveTime != null) {
      map['last_archive_time'] = Variable<DateTime>(lastArchiveTime);
    }
    return map;
  }

  ArchiveMetadataCompanion toCompanion(bool nullToAbsent) {
    return ArchiveMetadataCompanion(
      roomId: Value(roomId),
      lastArchivedEventId: lastArchivedEventId == null && nullToAbsent
          ? const Value.absent()
          : Value(lastArchivedEventId),
      lastArchivedTs: Value(lastArchivedTs),
      totalArchived: Value(totalArchived),
      lastArchiveTime: lastArchiveTime == null && nullToAbsent
          ? const Value.absent()
          : Value(lastArchiveTime),
    );
  }

  factory ArchiveMetadataData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ArchiveMetadataData(
      roomId: serializer.fromJson<String>(json['roomId']),
      lastArchivedEventId: serializer.fromJson<String?>(
        json['lastArchivedEventId'],
      ),
      lastArchivedTs: serializer.fromJson<int>(json['lastArchivedTs']),
      totalArchived: serializer.fromJson<int>(json['totalArchived']),
      lastArchiveTime: serializer.fromJson<DateTime?>(json['lastArchiveTime']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'roomId': serializer.toJson<String>(roomId),
      'lastArchivedEventId': serializer.toJson<String?>(lastArchivedEventId),
      'lastArchivedTs': serializer.toJson<int>(lastArchivedTs),
      'totalArchived': serializer.toJson<int>(totalArchived),
      'lastArchiveTime': serializer.toJson<DateTime?>(lastArchiveTime),
    };
  }

  ArchiveMetadataData copyWith({
    String? roomId,
    Value<String?> lastArchivedEventId = const Value.absent(),
    int? lastArchivedTs,
    int? totalArchived,
    Value<DateTime?> lastArchiveTime = const Value.absent(),
  }) => ArchiveMetadataData(
    roomId: roomId ?? this.roomId,
    lastArchivedEventId: lastArchivedEventId.present
        ? lastArchivedEventId.value
        : this.lastArchivedEventId,
    lastArchivedTs: lastArchivedTs ?? this.lastArchivedTs,
    totalArchived: totalArchived ?? this.totalArchived,
    lastArchiveTime: lastArchiveTime.present
        ? lastArchiveTime.value
        : this.lastArchiveTime,
  );
  ArchiveMetadataData copyWithCompanion(ArchiveMetadataCompanion data) {
    return ArchiveMetadataData(
      roomId: data.roomId.present ? data.roomId.value : this.roomId,
      lastArchivedEventId: data.lastArchivedEventId.present
          ? data.lastArchivedEventId.value
          : this.lastArchivedEventId,
      lastArchivedTs: data.lastArchivedTs.present
          ? data.lastArchivedTs.value
          : this.lastArchivedTs,
      totalArchived: data.totalArchived.present
          ? data.totalArchived.value
          : this.totalArchived,
      lastArchiveTime: data.lastArchiveTime.present
          ? data.lastArchiveTime.value
          : this.lastArchiveTime,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ArchiveMetadataData(')
          ..write('roomId: $roomId, ')
          ..write('lastArchivedEventId: $lastArchivedEventId, ')
          ..write('lastArchivedTs: $lastArchivedTs, ')
          ..write('totalArchived: $totalArchived, ')
          ..write('lastArchiveTime: $lastArchiveTime')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    roomId,
    lastArchivedEventId,
    lastArchivedTs,
    totalArchived,
    lastArchiveTime,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ArchiveMetadataData &&
          other.roomId == this.roomId &&
          other.lastArchivedEventId == this.lastArchivedEventId &&
          other.lastArchivedTs == this.lastArchivedTs &&
          other.totalArchived == this.totalArchived &&
          other.lastArchiveTime == this.lastArchiveTime);
}

class ArchiveMetadataCompanion extends UpdateCompanion<ArchiveMetadataData> {
  final Value<String> roomId;
  final Value<String?> lastArchivedEventId;
  final Value<int> lastArchivedTs;
  final Value<int> totalArchived;
  final Value<DateTime?> lastArchiveTime;
  final Value<int> rowid;
  const ArchiveMetadataCompanion({
    this.roomId = const Value.absent(),
    this.lastArchivedEventId = const Value.absent(),
    this.lastArchivedTs = const Value.absent(),
    this.totalArchived = const Value.absent(),
    this.lastArchiveTime = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ArchiveMetadataCompanion.insert({
    required String roomId,
    this.lastArchivedEventId = const Value.absent(),
    this.lastArchivedTs = const Value.absent(),
    this.totalArchived = const Value.absent(),
    this.lastArchiveTime = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : roomId = Value(roomId);
  static Insertable<ArchiveMetadataData> custom({
    Expression<String>? roomId,
    Expression<String>? lastArchivedEventId,
    Expression<int>? lastArchivedTs,
    Expression<int>? totalArchived,
    Expression<DateTime>? lastArchiveTime,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (roomId != null) 'room_id': roomId,
      if (lastArchivedEventId != null)
        'last_archived_event_id': lastArchivedEventId,
      if (lastArchivedTs != null) 'last_archived_ts': lastArchivedTs,
      if (totalArchived != null) 'total_archived': totalArchived,
      if (lastArchiveTime != null) 'last_archive_time': lastArchiveTime,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ArchiveMetadataCompanion copyWith({
    Value<String>? roomId,
    Value<String?>? lastArchivedEventId,
    Value<int>? lastArchivedTs,
    Value<int>? totalArchived,
    Value<DateTime?>? lastArchiveTime,
    Value<int>? rowid,
  }) {
    return ArchiveMetadataCompanion(
      roomId: roomId ?? this.roomId,
      lastArchivedEventId: lastArchivedEventId ?? this.lastArchivedEventId,
      lastArchivedTs: lastArchivedTs ?? this.lastArchivedTs,
      totalArchived: totalArchived ?? this.totalArchived,
      lastArchiveTime: lastArchiveTime ?? this.lastArchiveTime,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (roomId.present) {
      map['room_id'] = Variable<String>(roomId.value);
    }
    if (lastArchivedEventId.present) {
      map['last_archived_event_id'] = Variable<String>(
        lastArchivedEventId.value,
      );
    }
    if (lastArchivedTs.present) {
      map['last_archived_ts'] = Variable<int>(lastArchivedTs.value);
    }
    if (totalArchived.present) {
      map['total_archived'] = Variable<int>(totalArchived.value);
    }
    if (lastArchiveTime.present) {
      map['last_archive_time'] = Variable<DateTime>(lastArchiveTime.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ArchiveMetadataCompanion(')
          ..write('roomId: $roomId, ')
          ..write('lastArchivedEventId: $lastArchivedEventId, ')
          ..write('lastArchivedTs: $lastArchivedTs, ')
          ..write('totalArchived: $totalArchived, ')
          ..write('lastArchiveTime: $lastArchiveTime, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$ArchiveDatabase extends GeneratedDatabase {
  _$ArchiveDatabase(QueryExecutor e) : super(e);
  $ArchiveDatabaseManager get managers => $ArchiveDatabaseManager(this);
  late final $ArchivedMessagesTable archivedMessages = $ArchivedMessagesTable(
    this,
  );
  late final $ArchiveMetadataTable archiveMetadata = $ArchiveMetadataTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    archivedMessages,
    archiveMetadata,
  ];
}

typedef $$ArchivedMessagesTableCreateCompanionBuilder =
    ArchivedMessagesCompanion Function({
      required String eventId,
      required String roomId,
      required String senderId,
      required int originServerTs,
      required String type,
      Value<String?> body,
      Value<String?> formattedBody,
      Value<String?> msgtype,
      Value<String?> relatesTo,
      Value<String?> mediaInfo,
      Value<bool> isEncrypted,
      Value<String?> decryptedBody,
      required int quarter,
      required DateTime archivedAt,
      Value<int> rowid,
    });
typedef $$ArchivedMessagesTableUpdateCompanionBuilder =
    ArchivedMessagesCompanion Function({
      Value<String> eventId,
      Value<String> roomId,
      Value<String> senderId,
      Value<int> originServerTs,
      Value<String> type,
      Value<String?> body,
      Value<String?> formattedBody,
      Value<String?> msgtype,
      Value<String?> relatesTo,
      Value<String?> mediaInfo,
      Value<bool> isEncrypted,
      Value<String?> decryptedBody,
      Value<int> quarter,
      Value<DateTime> archivedAt,
      Value<int> rowid,
    });

class $$ArchivedMessagesTableFilterComposer
    extends Composer<_$ArchiveDatabase, $ArchivedMessagesTable> {
  $$ArchivedMessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get roomId => $composableBuilder(
    column: $table.roomId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get senderId => $composableBuilder(
    column: $table.senderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get originServerTs => $composableBuilder(
    column: $table.originServerTs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get formattedBody => $composableBuilder(
    column: $table.formattedBody,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get msgtype => $composableBuilder(
    column: $table.msgtype,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relatesTo => $composableBuilder(
    column: $table.relatesTo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mediaInfo => $composableBuilder(
    column: $table.mediaInfo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isEncrypted => $composableBuilder(
    column: $table.isEncrypted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get decryptedBody => $composableBuilder(
    column: $table.decryptedBody,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quarter => $composableBuilder(
    column: $table.quarter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ArchivedMessagesTableOrderingComposer
    extends Composer<_$ArchiveDatabase, $ArchivedMessagesTable> {
  $$ArchivedMessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get roomId => $composableBuilder(
    column: $table.roomId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get senderId => $composableBuilder(
    column: $table.senderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get originServerTs => $composableBuilder(
    column: $table.originServerTs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get formattedBody => $composableBuilder(
    column: $table.formattedBody,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get msgtype => $composableBuilder(
    column: $table.msgtype,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relatesTo => $composableBuilder(
    column: $table.relatesTo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mediaInfo => $composableBuilder(
    column: $table.mediaInfo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isEncrypted => $composableBuilder(
    column: $table.isEncrypted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get decryptedBody => $composableBuilder(
    column: $table.decryptedBody,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quarter => $composableBuilder(
    column: $table.quarter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ArchivedMessagesTableAnnotationComposer
    extends Composer<_$ArchiveDatabase, $ArchivedMessagesTable> {
  $$ArchivedMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get eventId =>
      $composableBuilder(column: $table.eventId, builder: (column) => column);

  GeneratedColumn<String> get roomId =>
      $composableBuilder(column: $table.roomId, builder: (column) => column);

  GeneratedColumn<String> get senderId =>
      $composableBuilder(column: $table.senderId, builder: (column) => column);

  GeneratedColumn<int> get originServerTs => $composableBuilder(
    column: $table.originServerTs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get formattedBody => $composableBuilder(
    column: $table.formattedBody,
    builder: (column) => column,
  );

  GeneratedColumn<String> get msgtype =>
      $composableBuilder(column: $table.msgtype, builder: (column) => column);

  GeneratedColumn<String> get relatesTo =>
      $composableBuilder(column: $table.relatesTo, builder: (column) => column);

  GeneratedColumn<String> get mediaInfo =>
      $composableBuilder(column: $table.mediaInfo, builder: (column) => column);

  GeneratedColumn<bool> get isEncrypted => $composableBuilder(
    column: $table.isEncrypted,
    builder: (column) => column,
  );

  GeneratedColumn<String> get decryptedBody => $composableBuilder(
    column: $table.decryptedBody,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quarter =>
      $composableBuilder(column: $table.quarter, builder: (column) => column);

  GeneratedColumn<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => column,
  );
}

class $$ArchivedMessagesTableTableManager
    extends
        RootTableManager<
          _$ArchiveDatabase,
          $ArchivedMessagesTable,
          ArchivedMessage,
          $$ArchivedMessagesTableFilterComposer,
          $$ArchivedMessagesTableOrderingComposer,
          $$ArchivedMessagesTableAnnotationComposer,
          $$ArchivedMessagesTableCreateCompanionBuilder,
          $$ArchivedMessagesTableUpdateCompanionBuilder,
          (
            ArchivedMessage,
            BaseReferences<
              _$ArchiveDatabase,
              $ArchivedMessagesTable,
              ArchivedMessage
            >,
          ),
          ArchivedMessage,
          PrefetchHooks Function()
        > {
  $$ArchivedMessagesTableTableManager(
    _$ArchiveDatabase db,
    $ArchivedMessagesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ArchivedMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ArchivedMessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ArchivedMessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> eventId = const Value.absent(),
                Value<String> roomId = const Value.absent(),
                Value<String> senderId = const Value.absent(),
                Value<int> originServerTs = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> body = const Value.absent(),
                Value<String?> formattedBody = const Value.absent(),
                Value<String?> msgtype = const Value.absent(),
                Value<String?> relatesTo = const Value.absent(),
                Value<String?> mediaInfo = const Value.absent(),
                Value<bool> isEncrypted = const Value.absent(),
                Value<String?> decryptedBody = const Value.absent(),
                Value<int> quarter = const Value.absent(),
                Value<DateTime> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ArchivedMessagesCompanion(
                eventId: eventId,
                roomId: roomId,
                senderId: senderId,
                originServerTs: originServerTs,
                type: type,
                body: body,
                formattedBody: formattedBody,
                msgtype: msgtype,
                relatesTo: relatesTo,
                mediaInfo: mediaInfo,
                isEncrypted: isEncrypted,
                decryptedBody: decryptedBody,
                quarter: quarter,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String eventId,
                required String roomId,
                required String senderId,
                required int originServerTs,
                required String type,
                Value<String?> body = const Value.absent(),
                Value<String?> formattedBody = const Value.absent(),
                Value<String?> msgtype = const Value.absent(),
                Value<String?> relatesTo = const Value.absent(),
                Value<String?> mediaInfo = const Value.absent(),
                Value<bool> isEncrypted = const Value.absent(),
                Value<String?> decryptedBody = const Value.absent(),
                required int quarter,
                required DateTime archivedAt,
                Value<int> rowid = const Value.absent(),
              }) => ArchivedMessagesCompanion.insert(
                eventId: eventId,
                roomId: roomId,
                senderId: senderId,
                originServerTs: originServerTs,
                type: type,
                body: body,
                formattedBody: formattedBody,
                msgtype: msgtype,
                relatesTo: relatesTo,
                mediaInfo: mediaInfo,
                isEncrypted: isEncrypted,
                decryptedBody: decryptedBody,
                quarter: quarter,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ArchivedMessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$ArchiveDatabase,
      $ArchivedMessagesTable,
      ArchivedMessage,
      $$ArchivedMessagesTableFilterComposer,
      $$ArchivedMessagesTableOrderingComposer,
      $$ArchivedMessagesTableAnnotationComposer,
      $$ArchivedMessagesTableCreateCompanionBuilder,
      $$ArchivedMessagesTableUpdateCompanionBuilder,
      (
        ArchivedMessage,
        BaseReferences<
          _$ArchiveDatabase,
          $ArchivedMessagesTable,
          ArchivedMessage
        >,
      ),
      ArchivedMessage,
      PrefetchHooks Function()
    >;
typedef $$ArchiveMetadataTableCreateCompanionBuilder =
    ArchiveMetadataCompanion Function({
      required String roomId,
      Value<String?> lastArchivedEventId,
      Value<int> lastArchivedTs,
      Value<int> totalArchived,
      Value<DateTime?> lastArchiveTime,
      Value<int> rowid,
    });
typedef $$ArchiveMetadataTableUpdateCompanionBuilder =
    ArchiveMetadataCompanion Function({
      Value<String> roomId,
      Value<String?> lastArchivedEventId,
      Value<int> lastArchivedTs,
      Value<int> totalArchived,
      Value<DateTime?> lastArchiveTime,
      Value<int> rowid,
    });

class $$ArchiveMetadataTableFilterComposer
    extends Composer<_$ArchiveDatabase, $ArchiveMetadataTable> {
  $$ArchiveMetadataTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get roomId => $composableBuilder(
    column: $table.roomId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastArchivedEventId => $composableBuilder(
    column: $table.lastArchivedEventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastArchivedTs => $composableBuilder(
    column: $table.lastArchivedTs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalArchived => $composableBuilder(
    column: $table.totalArchived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastArchiveTime => $composableBuilder(
    column: $table.lastArchiveTime,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ArchiveMetadataTableOrderingComposer
    extends Composer<_$ArchiveDatabase, $ArchiveMetadataTable> {
  $$ArchiveMetadataTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get roomId => $composableBuilder(
    column: $table.roomId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastArchivedEventId => $composableBuilder(
    column: $table.lastArchivedEventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastArchivedTs => $composableBuilder(
    column: $table.lastArchivedTs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalArchived => $composableBuilder(
    column: $table.totalArchived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastArchiveTime => $composableBuilder(
    column: $table.lastArchiveTime,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ArchiveMetadataTableAnnotationComposer
    extends Composer<_$ArchiveDatabase, $ArchiveMetadataTable> {
  $$ArchiveMetadataTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get roomId =>
      $composableBuilder(column: $table.roomId, builder: (column) => column);

  GeneratedColumn<String> get lastArchivedEventId => $composableBuilder(
    column: $table.lastArchivedEventId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastArchivedTs => $composableBuilder(
    column: $table.lastArchivedTs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalArchived => $composableBuilder(
    column: $table.totalArchived,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastArchiveTime => $composableBuilder(
    column: $table.lastArchiveTime,
    builder: (column) => column,
  );
}

class $$ArchiveMetadataTableTableManager
    extends
        RootTableManager<
          _$ArchiveDatabase,
          $ArchiveMetadataTable,
          ArchiveMetadataData,
          $$ArchiveMetadataTableFilterComposer,
          $$ArchiveMetadataTableOrderingComposer,
          $$ArchiveMetadataTableAnnotationComposer,
          $$ArchiveMetadataTableCreateCompanionBuilder,
          $$ArchiveMetadataTableUpdateCompanionBuilder,
          (
            ArchiveMetadataData,
            BaseReferences<
              _$ArchiveDatabase,
              $ArchiveMetadataTable,
              ArchiveMetadataData
            >,
          ),
          ArchiveMetadataData,
          PrefetchHooks Function()
        > {
  $$ArchiveMetadataTableTableManager(
    _$ArchiveDatabase db,
    $ArchiveMetadataTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ArchiveMetadataTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ArchiveMetadataTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ArchiveMetadataTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> roomId = const Value.absent(),
                Value<String?> lastArchivedEventId = const Value.absent(),
                Value<int> lastArchivedTs = const Value.absent(),
                Value<int> totalArchived = const Value.absent(),
                Value<DateTime?> lastArchiveTime = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ArchiveMetadataCompanion(
                roomId: roomId,
                lastArchivedEventId: lastArchivedEventId,
                lastArchivedTs: lastArchivedTs,
                totalArchived: totalArchived,
                lastArchiveTime: lastArchiveTime,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String roomId,
                Value<String?> lastArchivedEventId = const Value.absent(),
                Value<int> lastArchivedTs = const Value.absent(),
                Value<int> totalArchived = const Value.absent(),
                Value<DateTime?> lastArchiveTime = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ArchiveMetadataCompanion.insert(
                roomId: roomId,
                lastArchivedEventId: lastArchivedEventId,
                lastArchivedTs: lastArchivedTs,
                totalArchived: totalArchived,
                lastArchiveTime: lastArchiveTime,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ArchiveMetadataTableProcessedTableManager =
    ProcessedTableManager<
      _$ArchiveDatabase,
      $ArchiveMetadataTable,
      ArchiveMetadataData,
      $$ArchiveMetadataTableFilterComposer,
      $$ArchiveMetadataTableOrderingComposer,
      $$ArchiveMetadataTableAnnotationComposer,
      $$ArchiveMetadataTableCreateCompanionBuilder,
      $$ArchiveMetadataTableUpdateCompanionBuilder,
      (
        ArchiveMetadataData,
        BaseReferences<
          _$ArchiveDatabase,
          $ArchiveMetadataTable,
          ArchiveMetadataData
        >,
      ),
      ArchiveMetadataData,
      PrefetchHooks Function()
    >;

class $ArchiveDatabaseManager {
  final _$ArchiveDatabase _db;
  $ArchiveDatabaseManager(this._db);
  $$ArchivedMessagesTableTableManager get archivedMessages =>
      $$ArchivedMessagesTableTableManager(_db, _db.archivedMessages);
  $$ArchiveMetadataTableTableManager get archiveMetadata =>
      $$ArchiveMetadataTableTableManager(_db, _db.archiveMetadata);
}
