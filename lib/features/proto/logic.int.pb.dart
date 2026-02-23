// This is a generated file - do not edit.
//
// Generated from logic.int.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/empty.pb.dart' as $1;

import 'logic.ext.pb.dart' as $2;
import 'message.ext.pb.dart' as $0;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class ConnSignInReq extends $pb.GeneratedMessage {
  factory ConnSignInReq({
    $fixnum.Int64? deviceId,
    $fixnum.Int64? userId,
    $core.String? token,
    $core.String? connAddr,
    $core.String? clientAddr,
  }) {
    final result = create();
    if (deviceId != null) result.deviceId = deviceId;
    if (userId != null) result.userId = userId;
    if (token != null) result.token = token;
    if (connAddr != null) result.connAddr = connAddr;
    if (clientAddr != null) result.clientAddr = clientAddr;
    return result;
  }

  ConnSignInReq._();

  factory ConnSignInReq.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ConnSignInReq.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ConnSignInReq',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'deviceId')
    ..aInt64(2, _omitFieldNames ? '' : 'userId')
    ..aOS(3, _omitFieldNames ? '' : 'token')
    ..aOS(4, _omitFieldNames ? '' : 'connAddr')
    ..aOS(5, _omitFieldNames ? '' : 'clientAddr')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConnSignInReq clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConnSignInReq copyWith(void Function(ConnSignInReq) updates) =>
      super.copyWith((message) => updates(message as ConnSignInReq))
          as ConnSignInReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConnSignInReq create() => ConnSignInReq._();
  @$core.override
  ConnSignInReq createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ConnSignInReq getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ConnSignInReq>(create);
  static ConnSignInReq? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get deviceId => $_getI64(0);
  @$pb.TagNumber(1)
  set deviceId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDeviceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearDeviceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get userId => $_getI64(1);
  @$pb.TagNumber(2)
  set userId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get token => $_getSZ(2);
  @$pb.TagNumber(3)
  set token($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasToken() => $_has(2);
  @$pb.TagNumber(3)
  void clearToken() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get connAddr => $_getSZ(3);
  @$pb.TagNumber(4)
  set connAddr($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasConnAddr() => $_has(3);
  @$pb.TagNumber(4)
  void clearConnAddr() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get clientAddr => $_getSZ(4);
  @$pb.TagNumber(5)
  set clientAddr($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasClientAddr() => $_has(4);
  @$pb.TagNumber(5)
  void clearClientAddr() => $_clearField(5);
}

class SyncReq extends $pb.GeneratedMessage {
  factory SyncReq({
    $fixnum.Int64? userId,
    $fixnum.Int64? deviceId,
    $fixnum.Int64? seq,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (deviceId != null) result.deviceId = deviceId;
    if (seq != null) result.seq = seq;
    return result;
  }

  SyncReq._();

  factory SyncReq.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SyncReq.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SyncReq',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'userId')
    ..aInt64(2, _omitFieldNames ? '' : 'deviceId')
    ..aInt64(3, _omitFieldNames ? '' : 'seq')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SyncReq clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SyncReq copyWith(void Function(SyncReq) updates) =>
      super.copyWith((message) => updates(message as SyncReq)) as SyncReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SyncReq create() => SyncReq._();
  @$core.override
  SyncReq createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SyncReq getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SyncReq>(create);
  static SyncReq? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get userId => $_getI64(0);
  @$pb.TagNumber(1)
  set userId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get deviceId => $_getI64(1);
  @$pb.TagNumber(2)
  set deviceId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDeviceId() => $_has(1);
  @$pb.TagNumber(2)
  void clearDeviceId() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get seq => $_getI64(2);
  @$pb.TagNumber(3)
  set seq($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSeq() => $_has(2);
  @$pb.TagNumber(3)
  void clearSeq() => $_clearField(3);
}

class SyncResp extends $pb.GeneratedMessage {
  factory SyncResp({
    $core.Iterable<$0.Message>? messages,
    $core.bool? hasMore,
  }) {
    final result = create();
    if (messages != null) result.messages.addAll(messages);
    if (hasMore != null) result.hasMore = hasMore;
    return result;
  }

  SyncResp._();

  factory SyncResp.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SyncResp.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SyncResp',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'),
      createEmptyInstance: create)
    ..pPM<$0.Message>(1, _omitFieldNames ? '' : 'messages',
        subBuilder: $0.Message.create)
    ..aOB(2, _omitFieldNames ? '' : 'hasMore')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SyncResp clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SyncResp copyWith(void Function(SyncResp) updates) =>
      super.copyWith((message) => updates(message as SyncResp)) as SyncResp;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SyncResp create() => SyncResp._();
  @$core.override
  SyncResp createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SyncResp getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SyncResp>(create);
  static SyncResp? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$0.Message> get messages => $_getList(0);

  @$pb.TagNumber(2)
  $core.bool get hasMore => $_getBF(1);
  @$pb.TagNumber(2)
  set hasMore($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasHasMore() => $_has(1);
  @$pb.TagNumber(2)
  void clearHasMore() => $_clearField(2);
}

class MessageACKReq extends $pb.GeneratedMessage {
  factory MessageACKReq({
    $fixnum.Int64? userId,
    $fixnum.Int64? deviceId,
    $fixnum.Int64? deviceAck,
    $fixnum.Int64? receiveTime,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (deviceId != null) result.deviceId = deviceId;
    if (deviceAck != null) result.deviceAck = deviceAck;
    if (receiveTime != null) result.receiveTime = receiveTime;
    return result;
  }

  MessageACKReq._();

  factory MessageACKReq.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MessageACKReq.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MessageACKReq',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'userId')
    ..aInt64(2, _omitFieldNames ? '' : 'deviceId')
    ..aInt64(3, _omitFieldNames ? '' : 'deviceAck')
    ..aInt64(4, _omitFieldNames ? '' : 'receiveTime')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MessageACKReq clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MessageACKReq copyWith(void Function(MessageACKReq) updates) =>
      super.copyWith((message) => updates(message as MessageACKReq))
          as MessageACKReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MessageACKReq create() => MessageACKReq._();
  @$core.override
  MessageACKReq createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MessageACKReq getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MessageACKReq>(create);
  static MessageACKReq? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get userId => $_getI64(0);
  @$pb.TagNumber(1)
  set userId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get deviceId => $_getI64(1);
  @$pb.TagNumber(2)
  set deviceId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDeviceId() => $_has(1);
  @$pb.TagNumber(2)
  void clearDeviceId() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get deviceAck => $_getI64(2);
  @$pb.TagNumber(3)
  set deviceAck($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDeviceAck() => $_has(2);
  @$pb.TagNumber(3)
  void clearDeviceAck() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get receiveTime => $_getI64(3);
  @$pb.TagNumber(4)
  set receiveTime($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasReceiveTime() => $_has(3);
  @$pb.TagNumber(4)
  void clearReceiveTime() => $_clearField(4);
}

class OfflineReq extends $pb.GeneratedMessage {
  factory OfflineReq({
    $fixnum.Int64? userId,
    $fixnum.Int64? deviceId,
    $core.String? clientAddr,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (deviceId != null) result.deviceId = deviceId;
    if (clientAddr != null) result.clientAddr = clientAddr;
    return result;
  }

  OfflineReq._();

  factory OfflineReq.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory OfflineReq.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'OfflineReq',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'userId')
    ..aInt64(2, _omitFieldNames ? '' : 'deviceId')
    ..aOS(3, _omitFieldNames ? '' : 'clientAddr')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OfflineReq clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OfflineReq copyWith(void Function(OfflineReq) updates) =>
      super.copyWith((message) => updates(message as OfflineReq)) as OfflineReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static OfflineReq create() => OfflineReq._();
  @$core.override
  OfflineReq createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static OfflineReq getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<OfflineReq>(create);
  static OfflineReq? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get userId => $_getI64(0);
  @$pb.TagNumber(1)
  set userId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get deviceId => $_getI64(1);
  @$pb.TagNumber(2)
  set deviceId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDeviceId() => $_has(1);
  @$pb.TagNumber(2)
  void clearDeviceId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get clientAddr => $_getSZ(2);
  @$pb.TagNumber(3)
  set clientAddr($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasClientAddr() => $_has(2);
  @$pb.TagNumber(3)
  void clearClientAddr() => $_clearField(3);
}

class SubscribeRoomReq extends $pb.GeneratedMessage {
  factory SubscribeRoomReq({
    $fixnum.Int64? userId,
    $fixnum.Int64? deviceId,
    $fixnum.Int64? roomId,
    $fixnum.Int64? seq,
    $core.String? connAddr,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (deviceId != null) result.deviceId = deviceId;
    if (roomId != null) result.roomId = roomId;
    if (seq != null) result.seq = seq;
    if (connAddr != null) result.connAddr = connAddr;
    return result;
  }

  SubscribeRoomReq._();

  factory SubscribeRoomReq.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SubscribeRoomReq.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SubscribeRoomReq',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'userId')
    ..aInt64(2, _omitFieldNames ? '' : 'deviceId')
    ..aInt64(3, _omitFieldNames ? '' : 'roomId')
    ..aInt64(4, _omitFieldNames ? '' : 'seq')
    ..aOS(5, _omitFieldNames ? '' : 'connAddr')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubscribeRoomReq clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubscribeRoomReq copyWith(void Function(SubscribeRoomReq) updates) =>
      super.copyWith((message) => updates(message as SubscribeRoomReq))
          as SubscribeRoomReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SubscribeRoomReq create() => SubscribeRoomReq._();
  @$core.override
  SubscribeRoomReq createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SubscribeRoomReq getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SubscribeRoomReq>(create);
  static SubscribeRoomReq? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get userId => $_getI64(0);
  @$pb.TagNumber(1)
  set userId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get deviceId => $_getI64(1);
  @$pb.TagNumber(2)
  set deviceId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDeviceId() => $_has(1);
  @$pb.TagNumber(2)
  void clearDeviceId() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get roomId => $_getI64(2);
  @$pb.TagNumber(3)
  set roomId($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRoomId() => $_has(2);
  @$pb.TagNumber(3)
  void clearRoomId() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get seq => $_getI64(3);
  @$pb.TagNumber(4)
  set seq($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSeq() => $_has(3);
  @$pb.TagNumber(4)
  void clearSeq() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get connAddr => $_getSZ(4);
  @$pb.TagNumber(5)
  set connAddr($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasConnAddr() => $_has(4);
  @$pb.TagNumber(5)
  void clearConnAddr() => $_clearField(5);
}

class PushReq extends $pb.GeneratedMessage {
  factory PushReq({
    $fixnum.Int64? userId,
    $core.int? code,
    $core.List<$core.int>? content,
    $core.bool? isPersist,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (code != null) result.code = code;
    if (content != null) result.content = content;
    if (isPersist != null) result.isPersist = isPersist;
    return result;
  }

  PushReq._();

  factory PushReq.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PushReq.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PushReq',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'userId')
    ..aI(2, _omitFieldNames ? '' : 'code')
    ..a<$core.List<$core.int>>(
        3, _omitFieldNames ? '' : 'content', $pb.PbFieldType.OY)
    ..aOB(4, _omitFieldNames ? '' : 'isPersist')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PushReq clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PushReq copyWith(void Function(PushReq) updates) =>
      super.copyWith((message) => updates(message as PushReq)) as PushReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PushReq create() => PushReq._();
  @$core.override
  PushReq createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PushReq getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PushReq>(create);
  static PushReq? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get userId => $_getI64(0);
  @$pb.TagNumber(1)
  set userId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get code => $_getIZ(1);
  @$pb.TagNumber(2)
  set code($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCode() => $_has(1);
  @$pb.TagNumber(2)
  void clearCode() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get content => $_getN(2);
  @$pb.TagNumber(3)
  set content($core.List<$core.int> value) => $_setBytes(2, value);
  @$pb.TagNumber(3)
  $core.bool hasContent() => $_has(2);
  @$pb.TagNumber(3)
  void clearContent() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get isPersist => $_getBF(3);
  @$pb.TagNumber(4)
  set isPersist($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasIsPersist() => $_has(3);
  @$pb.TagNumber(4)
  void clearIsPersist() => $_clearField(4);
}

class PushResp extends $pb.GeneratedMessage {
  factory PushResp({
    $fixnum.Int64? seq,
  }) {
    final result = create();
    if (seq != null) result.seq = seq;
    return result;
  }

  PushResp._();

  factory PushResp.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PushResp.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PushResp',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'seq')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PushResp clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PushResp copyWith(void Function(PushResp) updates) =>
      super.copyWith((message) => updates(message as PushResp)) as PushResp;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PushResp create() => PushResp._();
  @$core.override
  PushResp createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PushResp getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PushResp>(create);
  static PushResp? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get seq => $_getI64(0);
  @$pb.TagNumber(1)
  set seq($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSeq() => $_has(0);
  @$pb.TagNumber(1)
  void clearSeq() => $_clearField(1);
}

class PushAllReq extends $pb.GeneratedMessage {
  factory PushAllReq({
    $core.int? code,
    $core.List<$core.int>? content,
  }) {
    final result = create();
    if (code != null) result.code = code;
    if (content != null) result.content = content;
    return result;
  }

  PushAllReq._();

  factory PushAllReq.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PushAllReq.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PushAllReq',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'code')
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'content', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PushAllReq clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PushAllReq copyWith(void Function(PushAllReq) updates) =>
      super.copyWith((message) => updates(message as PushAllReq)) as PushAllReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PushAllReq create() => PushAllReq._();
  @$core.override
  PushAllReq createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PushAllReq getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PushAllReq>(create);
  static PushAllReq? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get code => $_getIZ(0);
  @$pb.TagNumber(1)
  set code($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get content => $_getN(1);
  @$pb.TagNumber(2)
  set content($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasContent() => $_has(1);
  @$pb.TagNumber(2)
  void clearContent() => $_clearField(2);
}

class GetDeviceReq extends $pb.GeneratedMessage {
  factory GetDeviceReq({
    $fixnum.Int64? deviceId,
  }) {
    final result = create();
    if (deviceId != null) result.deviceId = deviceId;
    return result;
  }

  GetDeviceReq._();

  factory GetDeviceReq.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetDeviceReq.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetDeviceReq',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'deviceId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDeviceReq clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDeviceReq copyWith(void Function(GetDeviceReq) updates) =>
      super.copyWith((message) => updates(message as GetDeviceReq))
          as GetDeviceReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetDeviceReq create() => GetDeviceReq._();
  @$core.override
  GetDeviceReq createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetDeviceReq getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetDeviceReq>(create);
  static GetDeviceReq? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get deviceId => $_getI64(0);
  @$pb.TagNumber(1)
  set deviceId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDeviceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearDeviceId() => $_clearField(1);
}

class GetDeviceResp extends $pb.GeneratedMessage {
  factory GetDeviceResp({
    Device? device,
  }) {
    final result = create();
    if (device != null) result.device = device;
    return result;
  }

  GetDeviceResp._();

  factory GetDeviceResp.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetDeviceResp.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetDeviceResp',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'),
      createEmptyInstance: create)
    ..aOM<Device>(1, _omitFieldNames ? '' : 'device', subBuilder: Device.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDeviceResp clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDeviceResp copyWith(void Function(GetDeviceResp) updates) =>
      super.copyWith((message) => updates(message as GetDeviceResp))
          as GetDeviceResp;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetDeviceResp create() => GetDeviceResp._();
  @$core.override
  GetDeviceResp createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetDeviceResp getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetDeviceResp>(create);
  static GetDeviceResp? _defaultInstance;

  @$pb.TagNumber(1)
  Device get device => $_getN(0);
  @$pb.TagNumber(1)
  set device(Device value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasDevice() => $_has(0);
  @$pb.TagNumber(1)
  void clearDevice() => $_clearField(1);
  @$pb.TagNumber(1)
  Device ensureDevice() => $_ensure(0);
}

class Device extends $pb.GeneratedMessage {
  factory Device({
    $fixnum.Int64? deviceId,
    $fixnum.Int64? userId,
    $core.int? type,
    $core.String? brand,
    $core.String? model,
    $core.String? systemVersion,
    $core.String? sdkVersion,
    $core.int? status,
    $core.String? connAddr,
    $core.String? clientAddr,
    $fixnum.Int64? createTime,
    $fixnum.Int64? updateTime,
  }) {
    final result = create();
    if (deviceId != null) result.deviceId = deviceId;
    if (userId != null) result.userId = userId;
    if (type != null) result.type = type;
    if (brand != null) result.brand = brand;
    if (model != null) result.model = model;
    if (systemVersion != null) result.systemVersion = systemVersion;
    if (sdkVersion != null) result.sdkVersion = sdkVersion;
    if (status != null) result.status = status;
    if (connAddr != null) result.connAddr = connAddr;
    if (clientAddr != null) result.clientAddr = clientAddr;
    if (createTime != null) result.createTime = createTime;
    if (updateTime != null) result.updateTime = updateTime;
    return result;
  }

  Device._();

  factory Device.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Device.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Device',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'deviceId')
    ..aInt64(2, _omitFieldNames ? '' : 'userId')
    ..aI(3, _omitFieldNames ? '' : 'type')
    ..aOS(4, _omitFieldNames ? '' : 'brand')
    ..aOS(5, _omitFieldNames ? '' : 'model')
    ..aOS(6, _omitFieldNames ? '' : 'systemVersion')
    ..aOS(7, _omitFieldNames ? '' : 'sdkVersion')
    ..aI(8, _omitFieldNames ? '' : 'status')
    ..aOS(9, _omitFieldNames ? '' : 'connAddr')
    ..aOS(10, _omitFieldNames ? '' : 'clientAddr')
    ..aInt64(11, _omitFieldNames ? '' : 'createTime')
    ..aInt64(12, _omitFieldNames ? '' : 'updateTime')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Device clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Device copyWith(void Function(Device) updates) =>
      super.copyWith((message) => updates(message as Device)) as Device;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Device create() => Device._();
  @$core.override
  Device createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Device getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Device>(create);
  static Device? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get deviceId => $_getI64(0);
  @$pb.TagNumber(1)
  set deviceId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDeviceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearDeviceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get userId => $_getI64(1);
  @$pb.TagNumber(2)
  set userId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get type => $_getIZ(2);
  @$pb.TagNumber(3)
  set type($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasType() => $_has(2);
  @$pb.TagNumber(3)
  void clearType() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get brand => $_getSZ(3);
  @$pb.TagNumber(4)
  set brand($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasBrand() => $_has(3);
  @$pb.TagNumber(4)
  void clearBrand() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get model => $_getSZ(4);
  @$pb.TagNumber(5)
  set model($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasModel() => $_has(4);
  @$pb.TagNumber(5)
  void clearModel() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get systemVersion => $_getSZ(5);
  @$pb.TagNumber(6)
  set systemVersion($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasSystemVersion() => $_has(5);
  @$pb.TagNumber(6)
  void clearSystemVersion() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get sdkVersion => $_getSZ(6);
  @$pb.TagNumber(7)
  set sdkVersion($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasSdkVersion() => $_has(6);
  @$pb.TagNumber(7)
  void clearSdkVersion() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get status => $_getIZ(7);
  @$pb.TagNumber(8)
  set status($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasStatus() => $_has(7);
  @$pb.TagNumber(8)
  void clearStatus() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get connAddr => $_getSZ(8);
  @$pb.TagNumber(9)
  set connAddr($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasConnAddr() => $_has(8);
  @$pb.TagNumber(9)
  void clearConnAddr() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get clientAddr => $_getSZ(9);
  @$pb.TagNumber(10)
  set clientAddr($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasClientAddr() => $_has(9);
  @$pb.TagNumber(10)
  void clearClientAddr() => $_clearField(10);

  @$pb.TagNumber(11)
  $fixnum.Int64 get createTime => $_getI64(10);
  @$pb.TagNumber(11)
  set createTime($fixnum.Int64 value) => $_setInt64(10, value);
  @$pb.TagNumber(11)
  $core.bool hasCreateTime() => $_has(10);
  @$pb.TagNumber(11)
  void clearCreateTime() => $_clearField(11);

  @$pb.TagNumber(12)
  $fixnum.Int64 get updateTime => $_getI64(11);
  @$pb.TagNumber(12)
  set updateTime($fixnum.Int64 value) => $_setInt64(11, value);
  @$pb.TagNumber(12)
  $core.bool hasUpdateTime() => $_has(11);
  @$pb.TagNumber(12)
  void clearUpdateTime() => $_clearField(12);
}

class ServerStopReq extends $pb.GeneratedMessage {
  factory ServerStopReq({
    $core.String? connAddr,
  }) {
    final result = create();
    if (connAddr != null) result.connAddr = connAddr;
    return result;
  }

  ServerStopReq._();

  factory ServerStopReq.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ServerStopReq.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ServerStopReq',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'connAddr')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ServerStopReq clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ServerStopReq copyWith(void Function(ServerStopReq) updates) =>
      super.copyWith((message) => updates(message as ServerStopReq))
          as ServerStopReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ServerStopReq create() => ServerStopReq._();
  @$core.override
  ServerStopReq createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ServerStopReq getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ServerStopReq>(create);
  static ServerStopReq? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get connAddr => $_getSZ(0);
  @$pb.TagNumber(1)
  set connAddr($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConnAddr() => $_has(0);
  @$pb.TagNumber(1)
  void clearConnAddr() => $_clearField(1);
}

class LogicIntApi {
  final $pb.RpcClient _client;

  LogicIntApi(this._client);

  /// 登录
  $async.Future<$1.Empty> connSignIn(
          $pb.ClientContext? ctx, ConnSignInReq request) =>
      _client.invoke<$1.Empty>(
          ctx, 'LogicInt', 'ConnSignIn', request, $1.Empty());

  /// 消息同步
  $async.Future<SyncResp> sync($pb.ClientContext? ctx, SyncReq request) =>
      _client.invoke<SyncResp>(ctx, 'LogicInt', 'Sync', request, SyncResp());

  /// 设备收到消息回执
  $async.Future<$1.Empty> messageACK(
          $pb.ClientContext? ctx, MessageACKReq request) =>
      _client.invoke<$1.Empty>(
          ctx, 'LogicInt', 'MessageACK', request, $1.Empty());

  /// 设备离线
  $async.Future<$1.Empty> offline($pb.ClientContext? ctx, OfflineReq request) =>
      _client.invoke<$1.Empty>(ctx, 'LogicInt', 'Offline', request, $1.Empty());

  /// 订阅房间
  $async.Future<$1.Empty> subscribeRoom(
          $pb.ClientContext? ctx, SubscribeRoomReq request) =>
      _client.invoke<$1.Empty>(
          ctx, 'LogicInt', 'SubscribeRoom', request, $1.Empty());

  /// 推送
  $async.Future<PushResp> push($pb.ClientContext? ctx, PushReq request) =>
      _client.invoke<PushResp>(ctx, 'LogicInt', 'Push', request, PushResp());

  /// 推送消息到房间
  $async.Future<$1.Empty> pushRoom(
          $pb.ClientContext? ctx, $2.PushRoomReq request) =>
      _client.invoke<$1.Empty>(
          ctx, 'LogicInt', 'PushRoom', request, $1.Empty());

  /// 全服推送
  $async.Future<$1.Empty> pushAll($pb.ClientContext? ctx, PushAllReq request) =>
      _client.invoke<$1.Empty>(ctx, 'LogicInt', 'PushAll', request, $1.Empty());

  /// 获取设备信息
  $async.Future<GetDeviceResp> getDevice(
          $pb.ClientContext? ctx, GetDeviceReq request) =>
      _client.invoke<GetDeviceResp>(
          ctx, 'LogicInt', 'GetDevice', request, GetDeviceResp());

  /// 服务停止
  $async.Future<$1.Empty> serverStop(
          $pb.ClientContext? ctx, ServerStopReq request) =>
      _client.invoke<$1.Empty>(
          ctx, 'LogicInt', 'ServerStop', request, $1.Empty());
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
