// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_metadata_database.dart';

// ignore_for_file: type=lint
class $MediaFilesTable extends MediaFiles
    with TableInfo<$MediaFilesTable, MediaFile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MediaFilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mxcUrlMeta = const VerificationMeta('mxcUrl');
  @override
  late final GeneratedColumn<String> mxcUrl = GeneratedColumn<String>(
    'mxc_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
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
  static const VerificationMeta _eventIdMeta = const VerificationMeta(
    'eventId',
  );
  @override
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
    'event_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fileCategoryMeta = const VerificationMeta(
    'fileCategory',
  );
  @override
  late final GeneratedColumn<String> fileCategory = GeneratedColumn<String>(
    'file_category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mimeTypeMeta = const VerificationMeta(
    'mimeType',
  );
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
    'mime_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fileSizeMeta = const VerificationMeta(
    'fileSize',
  );
  @override
  late final GeneratedColumn<int> fileSize = GeneratedColumn<int>(
    'file_size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isThumbnailMeta = const VerificationMeta(
    'isThumbnail',
  );
  @override
  late final GeneratedColumn<bool> isThumbnail = GeneratedColumn<bool>(
    'is_thumbnail',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_thumbnail" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _downloadedAtMeta = const VerificationMeta(
    'downloadedAt',
  );
  @override
  late final GeneratedColumn<DateTime> downloadedAt = GeneratedColumn<DateTime>(
    'downloaded_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastAccessedAtMeta = const VerificationMeta(
    'lastAccessedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastAccessedAt =
      GeneratedColumn<DateTime>(
        'last_accessed_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _isCleanedMeta = const VerificationMeta(
    'isCleaned',
  );
  @override
  late final GeneratedColumn<bool> isCleaned = GeneratedColumn<bool>(
    'is_cleaned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_cleaned" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _cleanedAtMeta = const VerificationMeta(
    'cleanedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cleanedAt = GeneratedColumn<DateTime>(
    'cleaned_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isPinnedMeta = const VerificationMeta(
    'isPinned',
  );
  @override
  late final GeneratedColumn<bool> isPinned = GeneratedColumn<bool>(
    'is_pinned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_pinned" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    filePath,
    mxcUrl,
    roomId,
    eventId,
    fileCategory,
    mimeType,
    fileSize,
    isThumbnail,
    downloadedAt,
    lastAccessedAt,
    isCleaned,
    cleanedAt,
    isPinned,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'media_files';
  @override
  VerificationContext validateIntegrity(
    Insertable<MediaFile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('mxc_url')) {
      context.handle(
        _mxcUrlMeta,
        mxcUrl.isAcceptableOrUnknown(data['mxc_url']!, _mxcUrlMeta),
      );
    }
    if (data.containsKey('room_id')) {
      context.handle(
        _roomIdMeta,
        roomId.isAcceptableOrUnknown(data['room_id']!, _roomIdMeta),
      );
    } else if (isInserting) {
      context.missing(_roomIdMeta);
    }
    if (data.containsKey('event_id')) {
      context.handle(
        _eventIdMeta,
        eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta),
      );
    }
    if (data.containsKey('file_category')) {
      context.handle(
        _fileCategoryMeta,
        fileCategory.isAcceptableOrUnknown(
          data['file_category']!,
          _fileCategoryMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fileCategoryMeta);
    }
    if (data.containsKey('mime_type')) {
      context.handle(
        _mimeTypeMeta,
        mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta),
      );
    }
    if (data.containsKey('file_size')) {
      context.handle(
        _fileSizeMeta,
        fileSize.isAcceptableOrUnknown(data['file_size']!, _fileSizeMeta),
      );
    }
    if (data.containsKey('is_thumbnail')) {
      context.handle(
        _isThumbnailMeta,
        isThumbnail.isAcceptableOrUnknown(
          data['is_thumbnail']!,
          _isThumbnailMeta,
        ),
      );
    }
    if (data.containsKey('downloaded_at')) {
      context.handle(
        _downloadedAtMeta,
        downloadedAt.isAcceptableOrUnknown(
          data['downloaded_at']!,
          _downloadedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_downloadedAtMeta);
    }
    if (data.containsKey('last_accessed_at')) {
      context.handle(
        _lastAccessedAtMeta,
        lastAccessedAt.isAcceptableOrUnknown(
          data['last_accessed_at']!,
          _lastAccessedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastAccessedAtMeta);
    }
    if (data.containsKey('is_cleaned')) {
      context.handle(
        _isCleanedMeta,
        isCleaned.isAcceptableOrUnknown(data['is_cleaned']!, _isCleanedMeta),
      );
    }
    if (data.containsKey('cleaned_at')) {
      context.handle(
        _cleanedAtMeta,
        cleanedAt.isAcceptableOrUnknown(data['cleaned_at']!, _cleanedAtMeta),
      );
    }
    if (data.containsKey('is_pinned')) {
      context.handle(
        _isPinnedMeta,
        isPinned.isAcceptableOrUnknown(data['is_pinned']!, _isPinnedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {filePath};
  @override
  MediaFile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MediaFile(
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      mxcUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mxc_url'],
      )!,
      roomId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}room_id'],
      )!,
      eventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_id'],
      ),
      fileCategory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_category'],
      )!,
      mimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime_type'],
      ),
      fileSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}file_size'],
      )!,
      isThumbnail: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_thumbnail'],
      )!,
      downloadedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}downloaded_at'],
      )!,
      lastAccessedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_accessed_at'],
      )!,
      isCleaned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_cleaned'],
      )!,
      cleanedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cleaned_at'],
      ),
      isPinned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_pinned'],
      )!,
    );
  }

  @override
  $MediaFilesTable createAlias(String alias) {
    return $MediaFilesTable(attachedDatabase, alias);
  }
}

class MediaFile extends DataClass implements Insertable<MediaFile> {
  /// 本地绝对路径 (PK)
  final String filePath;

  /// Matrix mxc:// URL（重下载用）
  final String mxcUrl;

  /// 所属房间 ID
  final String roomId;

  /// 关联事件 ID
  final String? eventId;

  /// 文件分类: image/video/audio/document/other
  final String fileCategory;

  /// MIME 类型
  final String? mimeType;

  /// 文件大小（字节）
  final int fileSize;

  /// 是否为缩略图（永不自动清理）
  final bool isThumbnail;

  /// 下载时间
  final DateTime downloadedAt;

  /// 最后访问时间
  final DateTime lastAccessedAt;

  /// 是否已清理（保留记录支持重下载）
  final bool isCleaned;

  /// 清理时间
  final DateTime? cleanedAt;

  /// 用户标记保留（永不自动清理）
  final bool isPinned;
  const MediaFile({
    required this.filePath,
    required this.mxcUrl,
    required this.roomId,
    this.eventId,
    required this.fileCategory,
    this.mimeType,
    required this.fileSize,
    required this.isThumbnail,
    required this.downloadedAt,
    required this.lastAccessedAt,
    required this.isCleaned,
    this.cleanedAt,
    required this.isPinned,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['file_path'] = Variable<String>(filePath);
    map['mxc_url'] = Variable<String>(mxcUrl);
    map['room_id'] = Variable<String>(roomId);
    if (!nullToAbsent || eventId != null) {
      map['event_id'] = Variable<String>(eventId);
    }
    map['file_category'] = Variable<String>(fileCategory);
    if (!nullToAbsent || mimeType != null) {
      map['mime_type'] = Variable<String>(mimeType);
    }
    map['file_size'] = Variable<int>(fileSize);
    map['is_thumbnail'] = Variable<bool>(isThumbnail);
    map['downloaded_at'] = Variable<DateTime>(downloadedAt);
    map['last_accessed_at'] = Variable<DateTime>(lastAccessedAt);
    map['is_cleaned'] = Variable<bool>(isCleaned);
    if (!nullToAbsent || cleanedAt != null) {
      map['cleaned_at'] = Variable<DateTime>(cleanedAt);
    }
    map['is_pinned'] = Variable<bool>(isPinned);
    return map;
  }

  MediaFilesCompanion toCompanion(bool nullToAbsent) {
    return MediaFilesCompanion(
      filePath: Value(filePath),
      mxcUrl: Value(mxcUrl),
      roomId: Value(roomId),
      eventId: eventId == null && nullToAbsent
          ? const Value.absent()
          : Value(eventId),
      fileCategory: Value(fileCategory),
      mimeType: mimeType == null && nullToAbsent
          ? const Value.absent()
          : Value(mimeType),
      fileSize: Value(fileSize),
      isThumbnail: Value(isThumbnail),
      downloadedAt: Value(downloadedAt),
      lastAccessedAt: Value(lastAccessedAt),
      isCleaned: Value(isCleaned),
      cleanedAt: cleanedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(cleanedAt),
      isPinned: Value(isPinned),
    );
  }

  factory MediaFile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MediaFile(
      filePath: serializer.fromJson<String>(json['filePath']),
      mxcUrl: serializer.fromJson<String>(json['mxcUrl']),
      roomId: serializer.fromJson<String>(json['roomId']),
      eventId: serializer.fromJson<String?>(json['eventId']),
      fileCategory: serializer.fromJson<String>(json['fileCategory']),
      mimeType: serializer.fromJson<String?>(json['mimeType']),
      fileSize: serializer.fromJson<int>(json['fileSize']),
      isThumbnail: serializer.fromJson<bool>(json['isThumbnail']),
      downloadedAt: serializer.fromJson<DateTime>(json['downloadedAt']),
      lastAccessedAt: serializer.fromJson<DateTime>(json['lastAccessedAt']),
      isCleaned: serializer.fromJson<bool>(json['isCleaned']),
      cleanedAt: serializer.fromJson<DateTime?>(json['cleanedAt']),
      isPinned: serializer.fromJson<bool>(json['isPinned']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'filePath': serializer.toJson<String>(filePath),
      'mxcUrl': serializer.toJson<String>(mxcUrl),
      'roomId': serializer.toJson<String>(roomId),
      'eventId': serializer.toJson<String?>(eventId),
      'fileCategory': serializer.toJson<String>(fileCategory),
      'mimeType': serializer.toJson<String?>(mimeType),
      'fileSize': serializer.toJson<int>(fileSize),
      'isThumbnail': serializer.toJson<bool>(isThumbnail),
      'downloadedAt': serializer.toJson<DateTime>(downloadedAt),
      'lastAccessedAt': serializer.toJson<DateTime>(lastAccessedAt),
      'isCleaned': serializer.toJson<bool>(isCleaned),
      'cleanedAt': serializer.toJson<DateTime?>(cleanedAt),
      'isPinned': serializer.toJson<bool>(isPinned),
    };
  }

  MediaFile copyWith({
    String? filePath,
    String? mxcUrl,
    String? roomId,
    Value<String?> eventId = const Value.absent(),
    String? fileCategory,
    Value<String?> mimeType = const Value.absent(),
    int? fileSize,
    bool? isThumbnail,
    DateTime? downloadedAt,
    DateTime? lastAccessedAt,
    bool? isCleaned,
    Value<DateTime?> cleanedAt = const Value.absent(),
    bool? isPinned,
  }) => MediaFile(
    filePath: filePath ?? this.filePath,
    mxcUrl: mxcUrl ?? this.mxcUrl,
    roomId: roomId ?? this.roomId,
    eventId: eventId.present ? eventId.value : this.eventId,
    fileCategory: fileCategory ?? this.fileCategory,
    mimeType: mimeType.present ? mimeType.value : this.mimeType,
    fileSize: fileSize ?? this.fileSize,
    isThumbnail: isThumbnail ?? this.isThumbnail,
    downloadedAt: downloadedAt ?? this.downloadedAt,
    lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
    isCleaned: isCleaned ?? this.isCleaned,
    cleanedAt: cleanedAt.present ? cleanedAt.value : this.cleanedAt,
    isPinned: isPinned ?? this.isPinned,
  );
  MediaFile copyWithCompanion(MediaFilesCompanion data) {
    return MediaFile(
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      mxcUrl: data.mxcUrl.present ? data.mxcUrl.value : this.mxcUrl,
      roomId: data.roomId.present ? data.roomId.value : this.roomId,
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      fileCategory: data.fileCategory.present
          ? data.fileCategory.value
          : this.fileCategory,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      fileSize: data.fileSize.present ? data.fileSize.value : this.fileSize,
      isThumbnail: data.isThumbnail.present
          ? data.isThumbnail.value
          : this.isThumbnail,
      downloadedAt: data.downloadedAt.present
          ? data.downloadedAt.value
          : this.downloadedAt,
      lastAccessedAt: data.lastAccessedAt.present
          ? data.lastAccessedAt.value
          : this.lastAccessedAt,
      isCleaned: data.isCleaned.present ? data.isCleaned.value : this.isCleaned,
      cleanedAt: data.cleanedAt.present ? data.cleanedAt.value : this.cleanedAt,
      isPinned: data.isPinned.present ? data.isPinned.value : this.isPinned,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MediaFile(')
          ..write('filePath: $filePath, ')
          ..write('mxcUrl: $mxcUrl, ')
          ..write('roomId: $roomId, ')
          ..write('eventId: $eventId, ')
          ..write('fileCategory: $fileCategory, ')
          ..write('mimeType: $mimeType, ')
          ..write('fileSize: $fileSize, ')
          ..write('isThumbnail: $isThumbnail, ')
          ..write('downloadedAt: $downloadedAt, ')
          ..write('lastAccessedAt: $lastAccessedAt, ')
          ..write('isCleaned: $isCleaned, ')
          ..write('cleanedAt: $cleanedAt, ')
          ..write('isPinned: $isPinned')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    filePath,
    mxcUrl,
    roomId,
    eventId,
    fileCategory,
    mimeType,
    fileSize,
    isThumbnail,
    downloadedAt,
    lastAccessedAt,
    isCleaned,
    cleanedAt,
    isPinned,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MediaFile &&
          other.filePath == this.filePath &&
          other.mxcUrl == this.mxcUrl &&
          other.roomId == this.roomId &&
          other.eventId == this.eventId &&
          other.fileCategory == this.fileCategory &&
          other.mimeType == this.mimeType &&
          other.fileSize == this.fileSize &&
          other.isThumbnail == this.isThumbnail &&
          other.downloadedAt == this.downloadedAt &&
          other.lastAccessedAt == this.lastAccessedAt &&
          other.isCleaned == this.isCleaned &&
          other.cleanedAt == this.cleanedAt &&
          other.isPinned == this.isPinned);
}

class MediaFilesCompanion extends UpdateCompanion<MediaFile> {
  final Value<String> filePath;
  final Value<String> mxcUrl;
  final Value<String> roomId;
  final Value<String?> eventId;
  final Value<String> fileCategory;
  final Value<String?> mimeType;
  final Value<int> fileSize;
  final Value<bool> isThumbnail;
  final Value<DateTime> downloadedAt;
  final Value<DateTime> lastAccessedAt;
  final Value<bool> isCleaned;
  final Value<DateTime?> cleanedAt;
  final Value<bool> isPinned;
  final Value<int> rowid;
  const MediaFilesCompanion({
    this.filePath = const Value.absent(),
    this.mxcUrl = const Value.absent(),
    this.roomId = const Value.absent(),
    this.eventId = const Value.absent(),
    this.fileCategory = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.fileSize = const Value.absent(),
    this.isThumbnail = const Value.absent(),
    this.downloadedAt = const Value.absent(),
    this.lastAccessedAt = const Value.absent(),
    this.isCleaned = const Value.absent(),
    this.cleanedAt = const Value.absent(),
    this.isPinned = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MediaFilesCompanion.insert({
    required String filePath,
    this.mxcUrl = const Value.absent(),
    required String roomId,
    this.eventId = const Value.absent(),
    required String fileCategory,
    this.mimeType = const Value.absent(),
    this.fileSize = const Value.absent(),
    this.isThumbnail = const Value.absent(),
    required DateTime downloadedAt,
    required DateTime lastAccessedAt,
    this.isCleaned = const Value.absent(),
    this.cleanedAt = const Value.absent(),
    this.isPinned = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : filePath = Value(filePath),
       roomId = Value(roomId),
       fileCategory = Value(fileCategory),
       downloadedAt = Value(downloadedAt),
       lastAccessedAt = Value(lastAccessedAt);
  static Insertable<MediaFile> custom({
    Expression<String>? filePath,
    Expression<String>? mxcUrl,
    Expression<String>? roomId,
    Expression<String>? eventId,
    Expression<String>? fileCategory,
    Expression<String>? mimeType,
    Expression<int>? fileSize,
    Expression<bool>? isThumbnail,
    Expression<DateTime>? downloadedAt,
    Expression<DateTime>? lastAccessedAt,
    Expression<bool>? isCleaned,
    Expression<DateTime>? cleanedAt,
    Expression<bool>? isPinned,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (filePath != null) 'file_path': filePath,
      if (mxcUrl != null) 'mxc_url': mxcUrl,
      if (roomId != null) 'room_id': roomId,
      if (eventId != null) 'event_id': eventId,
      if (fileCategory != null) 'file_category': fileCategory,
      if (mimeType != null) 'mime_type': mimeType,
      if (fileSize != null) 'file_size': fileSize,
      if (isThumbnail != null) 'is_thumbnail': isThumbnail,
      if (downloadedAt != null) 'downloaded_at': downloadedAt,
      if (lastAccessedAt != null) 'last_accessed_at': lastAccessedAt,
      if (isCleaned != null) 'is_cleaned': isCleaned,
      if (cleanedAt != null) 'cleaned_at': cleanedAt,
      if (isPinned != null) 'is_pinned': isPinned,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MediaFilesCompanion copyWith({
    Value<String>? filePath,
    Value<String>? mxcUrl,
    Value<String>? roomId,
    Value<String?>? eventId,
    Value<String>? fileCategory,
    Value<String?>? mimeType,
    Value<int>? fileSize,
    Value<bool>? isThumbnail,
    Value<DateTime>? downloadedAt,
    Value<DateTime>? lastAccessedAt,
    Value<bool>? isCleaned,
    Value<DateTime?>? cleanedAt,
    Value<bool>? isPinned,
    Value<int>? rowid,
  }) {
    return MediaFilesCompanion(
      filePath: filePath ?? this.filePath,
      mxcUrl: mxcUrl ?? this.mxcUrl,
      roomId: roomId ?? this.roomId,
      eventId: eventId ?? this.eventId,
      fileCategory: fileCategory ?? this.fileCategory,
      mimeType: mimeType ?? this.mimeType,
      fileSize: fileSize ?? this.fileSize,
      isThumbnail: isThumbnail ?? this.isThumbnail,
      downloadedAt: downloadedAt ?? this.downloadedAt,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      isCleaned: isCleaned ?? this.isCleaned,
      cleanedAt: cleanedAt ?? this.cleanedAt,
      isPinned: isPinned ?? this.isPinned,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (mxcUrl.present) {
      map['mxc_url'] = Variable<String>(mxcUrl.value);
    }
    if (roomId.present) {
      map['room_id'] = Variable<String>(roomId.value);
    }
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
    }
    if (fileCategory.present) {
      map['file_category'] = Variable<String>(fileCategory.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (fileSize.present) {
      map['file_size'] = Variable<int>(fileSize.value);
    }
    if (isThumbnail.present) {
      map['is_thumbnail'] = Variable<bool>(isThumbnail.value);
    }
    if (downloadedAt.present) {
      map['downloaded_at'] = Variable<DateTime>(downloadedAt.value);
    }
    if (lastAccessedAt.present) {
      map['last_accessed_at'] = Variable<DateTime>(lastAccessedAt.value);
    }
    if (isCleaned.present) {
      map['is_cleaned'] = Variable<bool>(isCleaned.value);
    }
    if (cleanedAt.present) {
      map['cleaned_at'] = Variable<DateTime>(cleanedAt.value);
    }
    if (isPinned.present) {
      map['is_pinned'] = Variable<bool>(isPinned.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MediaFilesCompanion(')
          ..write('filePath: $filePath, ')
          ..write('mxcUrl: $mxcUrl, ')
          ..write('roomId: $roomId, ')
          ..write('eventId: $eventId, ')
          ..write('fileCategory: $fileCategory, ')
          ..write('mimeType: $mimeType, ')
          ..write('fileSize: $fileSize, ')
          ..write('isThumbnail: $isThumbnail, ')
          ..write('downloadedAt: $downloadedAt, ')
          ..write('lastAccessedAt: $lastAccessedAt, ')
          ..write('isCleaned: $isCleaned, ')
          ..write('cleanedAt: $cleanedAt, ')
          ..write('isPinned: $isPinned, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$MediaMetadataDatabase extends GeneratedDatabase {
  _$MediaMetadataDatabase(QueryExecutor e) : super(e);
  $MediaMetadataDatabaseManager get managers =>
      $MediaMetadataDatabaseManager(this);
  late final $MediaFilesTable mediaFiles = $MediaFilesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [mediaFiles];
}

typedef $$MediaFilesTableCreateCompanionBuilder =
    MediaFilesCompanion Function({
      required String filePath,
      Value<String> mxcUrl,
      required String roomId,
      Value<String?> eventId,
      required String fileCategory,
      Value<String?> mimeType,
      Value<int> fileSize,
      Value<bool> isThumbnail,
      required DateTime downloadedAt,
      required DateTime lastAccessedAt,
      Value<bool> isCleaned,
      Value<DateTime?> cleanedAt,
      Value<bool> isPinned,
      Value<int> rowid,
    });
typedef $$MediaFilesTableUpdateCompanionBuilder =
    MediaFilesCompanion Function({
      Value<String> filePath,
      Value<String> mxcUrl,
      Value<String> roomId,
      Value<String?> eventId,
      Value<String> fileCategory,
      Value<String?> mimeType,
      Value<int> fileSize,
      Value<bool> isThumbnail,
      Value<DateTime> downloadedAt,
      Value<DateTime> lastAccessedAt,
      Value<bool> isCleaned,
      Value<DateTime?> cleanedAt,
      Value<bool> isPinned,
      Value<int> rowid,
    });

class $$MediaFilesTableFilterComposer
    extends Composer<_$MediaMetadataDatabase, $MediaFilesTable> {
  $$MediaFilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mxcUrl => $composableBuilder(
    column: $table.mxcUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get roomId => $composableBuilder(
    column: $table.roomId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileCategory => $composableBuilder(
    column: $table.fileCategory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isThumbnail => $composableBuilder(
    column: $table.isThumbnail,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastAccessedAt => $composableBuilder(
    column: $table.lastAccessedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCleaned => $composableBuilder(
    column: $table.isCleaned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cleanedAt => $composableBuilder(
    column: $table.cleanedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPinned => $composableBuilder(
    column: $table.isPinned,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MediaFilesTableOrderingComposer
    extends Composer<_$MediaMetadataDatabase, $MediaFilesTable> {
  $$MediaFilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mxcUrl => $composableBuilder(
    column: $table.mxcUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get roomId => $composableBuilder(
    column: $table.roomId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileCategory => $composableBuilder(
    column: $table.fileCategory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isThumbnail => $composableBuilder(
    column: $table.isThumbnail,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastAccessedAt => $composableBuilder(
    column: $table.lastAccessedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCleaned => $composableBuilder(
    column: $table.isCleaned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cleanedAt => $composableBuilder(
    column: $table.cleanedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPinned => $composableBuilder(
    column: $table.isPinned,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MediaFilesTableAnnotationComposer
    extends Composer<_$MediaMetadataDatabase, $MediaFilesTable> {
  $$MediaFilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<String> get mxcUrl =>
      $composableBuilder(column: $table.mxcUrl, builder: (column) => column);

  GeneratedColumn<String> get roomId =>
      $composableBuilder(column: $table.roomId, builder: (column) => column);

  GeneratedColumn<String> get eventId =>
      $composableBuilder(column: $table.eventId, builder: (column) => column);

  GeneratedColumn<String> get fileCategory => $composableBuilder(
    column: $table.fileCategory,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<int> get fileSize =>
      $composableBuilder(column: $table.fileSize, builder: (column) => column);

  GeneratedColumn<bool> get isThumbnail => $composableBuilder(
    column: $table.isThumbnail,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastAccessedAt => $composableBuilder(
    column: $table.lastAccessedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCleaned =>
      $composableBuilder(column: $table.isCleaned, builder: (column) => column);

  GeneratedColumn<DateTime> get cleanedAt =>
      $composableBuilder(column: $table.cleanedAt, builder: (column) => column);

  GeneratedColumn<bool> get isPinned =>
      $composableBuilder(column: $table.isPinned, builder: (column) => column);
}

class $$MediaFilesTableTableManager
    extends
        RootTableManager<
          _$MediaMetadataDatabase,
          $MediaFilesTable,
          MediaFile,
          $$MediaFilesTableFilterComposer,
          $$MediaFilesTableOrderingComposer,
          $$MediaFilesTableAnnotationComposer,
          $$MediaFilesTableCreateCompanionBuilder,
          $$MediaFilesTableUpdateCompanionBuilder,
          (
            MediaFile,
            BaseReferences<
              _$MediaMetadataDatabase,
              $MediaFilesTable,
              MediaFile
            >,
          ),
          MediaFile,
          PrefetchHooks Function()
        > {
  $$MediaFilesTableTableManager(
    _$MediaMetadataDatabase db,
    $MediaFilesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MediaFilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MediaFilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MediaFilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> filePath = const Value.absent(),
                Value<String> mxcUrl = const Value.absent(),
                Value<String> roomId = const Value.absent(),
                Value<String?> eventId = const Value.absent(),
                Value<String> fileCategory = const Value.absent(),
                Value<String?> mimeType = const Value.absent(),
                Value<int> fileSize = const Value.absent(),
                Value<bool> isThumbnail = const Value.absent(),
                Value<DateTime> downloadedAt = const Value.absent(),
                Value<DateTime> lastAccessedAt = const Value.absent(),
                Value<bool> isCleaned = const Value.absent(),
                Value<DateTime?> cleanedAt = const Value.absent(),
                Value<bool> isPinned = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MediaFilesCompanion(
                filePath: filePath,
                mxcUrl: mxcUrl,
                roomId: roomId,
                eventId: eventId,
                fileCategory: fileCategory,
                mimeType: mimeType,
                fileSize: fileSize,
                isThumbnail: isThumbnail,
                downloadedAt: downloadedAt,
                lastAccessedAt: lastAccessedAt,
                isCleaned: isCleaned,
                cleanedAt: cleanedAt,
                isPinned: isPinned,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String filePath,
                Value<String> mxcUrl = const Value.absent(),
                required String roomId,
                Value<String?> eventId = const Value.absent(),
                required String fileCategory,
                Value<String?> mimeType = const Value.absent(),
                Value<int> fileSize = const Value.absent(),
                Value<bool> isThumbnail = const Value.absent(),
                required DateTime downloadedAt,
                required DateTime lastAccessedAt,
                Value<bool> isCleaned = const Value.absent(),
                Value<DateTime?> cleanedAt = const Value.absent(),
                Value<bool> isPinned = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MediaFilesCompanion.insert(
                filePath: filePath,
                mxcUrl: mxcUrl,
                roomId: roomId,
                eventId: eventId,
                fileCategory: fileCategory,
                mimeType: mimeType,
                fileSize: fileSize,
                isThumbnail: isThumbnail,
                downloadedAt: downloadedAt,
                lastAccessedAt: lastAccessedAt,
                isCleaned: isCleaned,
                cleanedAt: cleanedAt,
                isPinned: isPinned,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MediaFilesTableProcessedTableManager =
    ProcessedTableManager<
      _$MediaMetadataDatabase,
      $MediaFilesTable,
      MediaFile,
      $$MediaFilesTableFilterComposer,
      $$MediaFilesTableOrderingComposer,
      $$MediaFilesTableAnnotationComposer,
      $$MediaFilesTableCreateCompanionBuilder,
      $$MediaFilesTableUpdateCompanionBuilder,
      (
        MediaFile,
        BaseReferences<_$MediaMetadataDatabase, $MediaFilesTable, MediaFile>,
      ),
      MediaFile,
      PrefetchHooks Function()
    >;

class $MediaMetadataDatabaseManager {
  final _$MediaMetadataDatabase _db;
  $MediaMetadataDatabaseManager(this._db);
  $$MediaFilesTableTableManager get mediaFiles =>
      $$MediaFilesTableTableManager(_db, _db.mediaFiles);
}
