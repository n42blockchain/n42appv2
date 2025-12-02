//
//  Generated code. Do not modify.
//  source: logic.int.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'google/protobuf/empty.pb.dart' as $1;
import 'logic.ext.pb.dart' as $2;
import 'message.ext.pb.dart' as $0;

class ConnSignInReq extends $pb.GeneratedMessage {
  factory ConnSignInReq() => create();
  ConnSignInReq._() : super();
  factory ConnSignInReq.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ConnSignInReq.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ConnSignInReq', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'deviceId')
    ..aInt64(2, _omitFieldNames ? '' : 'userId')
    ..aOS(3, _omitFieldNames ? '' : 'token')
    ..aOS(4, _omitFieldNames ? '' : 'connAddr')
    ..aOS(5, _omitFieldNames ? '' : 'clientAddr')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ConnSignInReq clone() => ConnSignInReq()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ConnSignInReq copyWith(void Function(ConnSignInReq) updates) => super.copyWith((message) => updates(message as ConnSignInReq)) as ConnSignInReq;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConnSignInReq create() => ConnSignInReq._();
  ConnSignInReq createEmptyInstance() => create();
  static $pb.PbList<ConnSignInReq> createRepeated() => $pb.PbList<ConnSignInReq>();
  @$core.pragma('dart2js:noInline')
  static ConnSignInReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ConnSignInReq>(create);
  static ConnSignInReq? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get deviceId => $_getI64(0);
  @$pb.TagNumber(1)
  set deviceId($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasDeviceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearDeviceId() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get userId => $_getI64(1);
  @$pb.TagNumber(2)
  set userId($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get token => $_getSZ(2);
  @$pb.TagNumber(3)
  set token($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasToken() => $_has(2);
  @$pb.TagNumber(3)
  void clearToken() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get connAddr => $_getSZ(3);
  @$pb.TagNumber(4)
  set connAddr($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasConnAddr() => $_has(3);
  @$pb.TagNumber(4)
  void clearConnAddr() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get clientAddr => $_getSZ(4);
  @$pb.TagNumber(5)
  set clientAddr($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasClientAddr() => $_has(4);
  @$pb.TagNumber(5)
  void clearClientAddr() => clearField(5);
}

class SyncReq extends $pb.GeneratedMessage {
  factory SyncReq() => create();
  SyncReq._() : super();
  factory SyncReq.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SyncReq.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SyncReq', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'userId')
    ..aInt64(2, _omitFieldNames ? '' : 'deviceId')
    ..aInt64(3, _omitFieldNames ? '' : 'seq')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SyncReq clone() => SyncReq()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SyncReq copyWith(void Function(SyncReq) updates) => super.copyWith((message) => updates(message as SyncReq)) as SyncReq;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SyncReq create() => SyncReq._();
  SyncReq createEmptyInstance() => create();
  static $pb.PbList<SyncReq> createRepeated() => $pb.PbList<SyncReq>();
  @$core.pragma('dart2js:noInline')
  static SyncReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SyncReq>(create);
  static SyncReq? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get userId => $_getI64(0);
  @$pb.TagNumber(1)
  set userId($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get deviceId => $_getI64(1);
  @$pb.TagNumber(2)
  set deviceId($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasDeviceId() => $_has(1);
  @$pb.TagNumber(2)
  void clearDeviceId() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get seq => $_getI64(2);
  @$pb.TagNumber(3)
  set seq($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasSeq() => $_has(2);
  @$pb.TagNumber(3)
  void clearSeq() => clearField(3);
}

class SyncResp extends $pb.GeneratedMessage {
  factory SyncResp() => create();
  SyncResp._() : super();
  factory SyncResp.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SyncResp.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SyncResp', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..pc<$0.Message>(1, _omitFieldNames ? '' : 'messages', $pb.PbFieldType.PM, subBuilder: $0.Message.create)
    ..aOB(2, _omitFieldNames ? '' : 'hasMore')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SyncResp clone() => SyncResp()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SyncResp copyWith(void Function(SyncResp) updates) => super.copyWith((message) => updates(message as SyncResp)) as SyncResp;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SyncResp create() => SyncResp._();
  SyncResp createEmptyInstance() => create();
  static $pb.PbList<SyncResp> createRepeated() => $pb.PbList<SyncResp>();
  @$core.pragma('dart2js:noInline')
  static SyncResp getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SyncResp>(create);
  static SyncResp? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$0.Message> get messages => $_getList(0);

  @$pb.TagNumber(2)
  $core.bool get hasMore => $_getBF(1);
  @$pb.TagNumber(2)
  set hasMore($core.bool v) { $_setBool(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasHasMore() => $_has(1);
  @$pb.TagNumber(2)
  void clearHasMore() => clearField(2);
}

class MessageACKReq extends $pb.GeneratedMessage {
  factory MessageACKReq() => create();
  MessageACKReq._() : super();
  factory MessageACKReq.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MessageACKReq.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MessageACKReq', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'userId')
    ..aInt64(2, _omitFieldNames ? '' : 'deviceId')
    ..aInt64(3, _omitFieldNames ? '' : 'deviceAck')
    ..aInt64(4, _omitFieldNames ? '' : 'receiveTime')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MessageACKReq clone() => MessageACKReq()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MessageACKReq copyWith(void Function(MessageACKReq) updates) => super.copyWith((message) => updates(message as MessageACKReq)) as MessageACKReq;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MessageACKReq create() => MessageACKReq._();
  MessageACKReq createEmptyInstance() => create();
  static $pb.PbList<MessageACKReq> createRepeated() => $pb.PbList<MessageACKReq>();
  @$core.pragma('dart2js:noInline')
  static MessageACKReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MessageACKReq>(create);
  static MessageACKReq? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get userId => $_getI64(0);
  @$pb.TagNumber(1)
  set userId($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get deviceId => $_getI64(1);
  @$pb.TagNumber(2)
  set deviceId($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasDeviceId() => $_has(1);
  @$pb.TagNumber(2)
  void clearDeviceId() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get deviceAck => $_getI64(2);
  @$pb.TagNumber(3)
  set deviceAck($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasDeviceAck() => $_has(2);
  @$pb.TagNumber(3)
  void clearDeviceAck() => clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get receiveTime => $_getI64(3);
  @$pb.TagNumber(4)
  set receiveTime($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasReceiveTime() => $_has(3);
  @$pb.TagNumber(4)
  void clearReceiveTime() => clearField(4);
}

class OfflineReq extends $pb.GeneratedMessage {
  factory OfflineReq() => create();
  OfflineReq._() : super();
  factory OfflineReq.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory OfflineReq.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'OfflineReq', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'userId')
    ..aInt64(2, _omitFieldNames ? '' : 'deviceId')
    ..aOS(3, _omitFieldNames ? '' : 'clientAddr')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  OfflineReq clone() => OfflineReq()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  OfflineReq copyWith(void Function(OfflineReq) updates) => super.copyWith((message) => updates(message as OfflineReq)) as OfflineReq;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static OfflineReq create() => OfflineReq._();
  OfflineReq createEmptyInstance() => create();
  static $pb.PbList<OfflineReq> createRepeated() => $pb.PbList<OfflineReq>();
  @$core.pragma('dart2js:noInline')
  static OfflineReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<OfflineReq>(create);
  static OfflineReq? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get userId => $_getI64(0);
  @$pb.TagNumber(1)
  set userId($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get deviceId => $_getI64(1);
  @$pb.TagNumber(2)
  set deviceId($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasDeviceId() => $_has(1);
  @$pb.TagNumber(2)
  void clearDeviceId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get clientAddr => $_getSZ(2);
  @$pb.TagNumber(3)
  set clientAddr($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasClientAddr() => $_has(2);
  @$pb.TagNumber(3)
  void clearClientAddr() => clearField(3);
}

class SubscribeRoomReq extends $pb.GeneratedMessage {
  factory SubscribeRoomReq() => create();
  SubscribeRoomReq._() : super();
  factory SubscribeRoomReq.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SubscribeRoomReq.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SubscribeRoomReq', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'userId')
    ..aInt64(2, _omitFieldNames ? '' : 'deviceId')
    ..aInt64(3, _omitFieldNames ? '' : 'roomId')
    ..aInt64(4, _omitFieldNames ? '' : 'seq')
    ..aOS(5, _omitFieldNames ? '' : 'connAddr')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SubscribeRoomReq clone() => SubscribeRoomReq()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SubscribeRoomReq copyWith(void Function(SubscribeRoomReq) updates) => super.copyWith((message) => updates(message as SubscribeRoomReq)) as SubscribeRoomReq;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SubscribeRoomReq create() => SubscribeRoomReq._();
  SubscribeRoomReq createEmptyInstance() => create();
  static $pb.PbList<SubscribeRoomReq> createRepeated() => $pb.PbList<SubscribeRoomReq>();
  @$core.pragma('dart2js:noInline')
  static SubscribeRoomReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SubscribeRoomReq>(create);
  static SubscribeRoomReq? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get userId => $_getI64(0);
  @$pb.TagNumber(1)
  set userId($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get deviceId => $_getI64(1);
  @$pb.TagNumber(2)
  set deviceId($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasDeviceId() => $_has(1);
  @$pb.TagNumber(2)
  void clearDeviceId() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get roomId => $_getI64(2);
  @$pb.TagNumber(3)
  set roomId($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasRoomId() => $_has(2);
  @$pb.TagNumber(3)
  void clearRoomId() => clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get seq => $_getI64(3);
  @$pb.TagNumber(4)
  set seq($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasSeq() => $_has(3);
  @$pb.TagNumber(4)
  void clearSeq() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get connAddr => $_getSZ(4);
  @$pb.TagNumber(5)
  set connAddr($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasConnAddr() => $_has(4);
  @$pb.TagNumber(5)
  void clearConnAddr() => clearField(5);
}

class PushReq extends $pb.GeneratedMessage {
  factory PushReq() => create();
  PushReq._() : super();
  factory PushReq.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PushReq.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PushReq', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'userId')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'code', $pb.PbFieldType.O3)
    ..a<$core.List<$core.int>>(3, _omitFieldNames ? '' : 'content', $pb.PbFieldType.OY)
    ..aOB(4, _omitFieldNames ? '' : 'isPersist')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PushReq clone() => PushReq()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PushReq copyWith(void Function(PushReq) updates) => super.copyWith((message) => updates(message as PushReq)) as PushReq;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PushReq create() => PushReq._();
  PushReq createEmptyInstance() => create();
  static $pb.PbList<PushReq> createRepeated() => $pb.PbList<PushReq>();
  @$core.pragma('dart2js:noInline')
  static PushReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PushReq>(create);
  static PushReq? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get userId => $_getI64(0);
  @$pb.TagNumber(1)
  set userId($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get code => $_getIZ(1);
  @$pb.TagNumber(2)
  set code($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasCode() => $_has(1);
  @$pb.TagNumber(2)
  void clearCode() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get content => $_getN(2);
  @$pb.TagNumber(3)
  set content($core.List<$core.int> v) { $_setBytes(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasContent() => $_has(2);
  @$pb.TagNumber(3)
  void clearContent() => clearField(3);

  @$pb.TagNumber(4)
  $core.bool get isPersist => $_getBF(3);
  @$pb.TagNumber(4)
  set isPersist($core.bool v) { $_setBool(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasIsPersist() => $_has(3);
  @$pb.TagNumber(4)
  void clearIsPersist() => clearField(4);
}

class PushResp extends $pb.GeneratedMessage {
  factory PushResp() => create();
  PushResp._() : super();
  factory PushResp.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PushResp.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PushResp', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'seq')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PushResp clone() => PushResp()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PushResp copyWith(void Function(PushResp) updates) => super.copyWith((message) => updates(message as PushResp)) as PushResp;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PushResp create() => PushResp._();
  PushResp createEmptyInstance() => create();
  static $pb.PbList<PushResp> createRepeated() => $pb.PbList<PushResp>();
  @$core.pragma('dart2js:noInline')
  static PushResp getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PushResp>(create);
  static PushResp? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get seq => $_getI64(0);
  @$pb.TagNumber(1)
  set seq($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSeq() => $_has(0);
  @$pb.TagNumber(1)
  void clearSeq() => clearField(1);
}

class PushAllReq extends $pb.GeneratedMessage {
  factory PushAllReq() => create();
  PushAllReq._() : super();
  factory PushAllReq.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PushAllReq.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PushAllReq', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'code', $pb.PbFieldType.O3)
    ..a<$core.List<$core.int>>(2, _omitFieldNames ? '' : 'content', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PushAllReq clone() => PushAllReq()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PushAllReq copyWith(void Function(PushAllReq) updates) => super.copyWith((message) => updates(message as PushAllReq)) as PushAllReq;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PushAllReq create() => PushAllReq._();
  PushAllReq createEmptyInstance() => create();
  static $pb.PbList<PushAllReq> createRepeated() => $pb.PbList<PushAllReq>();
  @$core.pragma('dart2js:noInline')
  static PushAllReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PushAllReq>(create);
  static PushAllReq? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get code => $_getIZ(0);
  @$pb.TagNumber(1)
  set code($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get content => $_getN(1);
  @$pb.TagNumber(2)
  set content($core.List<$core.int> v) { $_setBytes(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasContent() => $_has(1);
  @$pb.TagNumber(2)
  void clearContent() => clearField(2);
}

class GetDeviceReq extends $pb.GeneratedMessage {
  factory GetDeviceReq() => create();
  GetDeviceReq._() : super();
  factory GetDeviceReq.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetDeviceReq.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetDeviceReq', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'deviceId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetDeviceReq clone() => GetDeviceReq()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetDeviceReq copyWith(void Function(GetDeviceReq) updates) => super.copyWith((message) => updates(message as GetDeviceReq)) as GetDeviceReq;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetDeviceReq create() => GetDeviceReq._();
  GetDeviceReq createEmptyInstance() => create();
  static $pb.PbList<GetDeviceReq> createRepeated() => $pb.PbList<GetDeviceReq>();
  @$core.pragma('dart2js:noInline')
  static GetDeviceReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetDeviceReq>(create);
  static GetDeviceReq? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get deviceId => $_getI64(0);
  @$pb.TagNumber(1)
  set deviceId($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasDeviceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearDeviceId() => clearField(1);
}

class GetDeviceResp extends $pb.GeneratedMessage {
  factory GetDeviceResp() => create();
  GetDeviceResp._() : super();
  factory GetDeviceResp.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetDeviceResp.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetDeviceResp', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..aOM<Device>(1, _omitFieldNames ? '' : 'device', subBuilder: Device.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetDeviceResp clone() => GetDeviceResp()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetDeviceResp copyWith(void Function(GetDeviceResp) updates) => super.copyWith((message) => updates(message as GetDeviceResp)) as GetDeviceResp;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetDeviceResp create() => GetDeviceResp._();
  GetDeviceResp createEmptyInstance() => create();
  static $pb.PbList<GetDeviceResp> createRepeated() => $pb.PbList<GetDeviceResp>();
  @$core.pragma('dart2js:noInline')
  static GetDeviceResp getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetDeviceResp>(create);
  static GetDeviceResp? _defaultInstance;

  @$pb.TagNumber(1)
  Device get device => $_getN(0);
  @$pb.TagNumber(1)
  set device(Device v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasDevice() => $_has(0);
  @$pb.TagNumber(1)
  void clearDevice() => clearField(1);
  @$pb.TagNumber(1)
  Device ensureDevice() => $_ensure(0);
}

class Device extends $pb.GeneratedMessage {
  factory Device() => create();
  Device._() : super();
  factory Device.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Device.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Device', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'deviceId')
    ..aInt64(2, _omitFieldNames ? '' : 'userId')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'type', $pb.PbFieldType.O3)
    ..aOS(4, _omitFieldNames ? '' : 'brand')
    ..aOS(5, _omitFieldNames ? '' : 'model')
    ..aOS(6, _omitFieldNames ? '' : 'systemVersion')
    ..aOS(7, _omitFieldNames ? '' : 'sdkVersion')
    ..a<$core.int>(8, _omitFieldNames ? '' : 'status', $pb.PbFieldType.O3)
    ..aOS(9, _omitFieldNames ? '' : 'connAddr')
    ..aOS(10, _omitFieldNames ? '' : 'clientAddr')
    ..aInt64(11, _omitFieldNames ? '' : 'createTime')
    ..aInt64(12, _omitFieldNames ? '' : 'updateTime')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Device clone() => Device()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Device copyWith(void Function(Device) updates) => super.copyWith((message) => updates(message as Device)) as Device;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Device create() => Device._();
  Device createEmptyInstance() => create();
  static $pb.PbList<Device> createRepeated() => $pb.PbList<Device>();
  @$core.pragma('dart2js:noInline')
  static Device getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Device>(create);
  static Device? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get deviceId => $_getI64(0);
  @$pb.TagNumber(1)
  set deviceId($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasDeviceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearDeviceId() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get userId => $_getI64(1);
  @$pb.TagNumber(2)
  set userId($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserId() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get type => $_getIZ(2);
  @$pb.TagNumber(3)
  set type($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasType() => $_has(2);
  @$pb.TagNumber(3)
  void clearType() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get brand => $_getSZ(3);
  @$pb.TagNumber(4)
  set brand($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasBrand() => $_has(3);
  @$pb.TagNumber(4)
  void clearBrand() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get model => $_getSZ(4);
  @$pb.TagNumber(5)
  set model($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasModel() => $_has(4);
  @$pb.TagNumber(5)
  void clearModel() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get systemVersion => $_getSZ(5);
  @$pb.TagNumber(6)
  set systemVersion($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasSystemVersion() => $_has(5);
  @$pb.TagNumber(6)
  void clearSystemVersion() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get sdkVersion => $_getSZ(6);
  @$pb.TagNumber(7)
  set sdkVersion($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasSdkVersion() => $_has(6);
  @$pb.TagNumber(7)
  void clearSdkVersion() => clearField(7);

  @$pb.TagNumber(8)
  $core.int get status => $_getIZ(7);
  @$pb.TagNumber(8)
  set status($core.int v) { $_setSignedInt32(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasStatus() => $_has(7);
  @$pb.TagNumber(8)
  void clearStatus() => clearField(8);

  @$pb.TagNumber(9)
  $core.String get connAddr => $_getSZ(8);
  @$pb.TagNumber(9)
  set connAddr($core.String v) { $_setString(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasConnAddr() => $_has(8);
  @$pb.TagNumber(9)
  void clearConnAddr() => clearField(9);

  @$pb.TagNumber(10)
  $core.String get clientAddr => $_getSZ(9);
  @$pb.TagNumber(10)
  set clientAddr($core.String v) { $_setString(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasClientAddr() => $_has(9);
  @$pb.TagNumber(10)
  void clearClientAddr() => clearField(10);

  @$pb.TagNumber(11)
  $fixnum.Int64 get createTime => $_getI64(10);
  @$pb.TagNumber(11)
  set createTime($fixnum.Int64 v) { $_setInt64(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasCreateTime() => $_has(10);
  @$pb.TagNumber(11)
  void clearCreateTime() => clearField(11);

  @$pb.TagNumber(12)
  $fixnum.Int64 get updateTime => $_getI64(11);
  @$pb.TagNumber(12)
  set updateTime($fixnum.Int64 v) { $_setInt64(11, v); }
  @$pb.TagNumber(12)
  $core.bool hasUpdateTime() => $_has(11);
  @$pb.TagNumber(12)
  void clearUpdateTime() => clearField(12);
}

class ServerStopReq extends $pb.GeneratedMessage {
  factory ServerStopReq() => create();
  ServerStopReq._() : super();
  factory ServerStopReq.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ServerStopReq.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ServerStopReq', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'connAddr')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ServerStopReq clone() => ServerStopReq()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ServerStopReq copyWith(void Function(ServerStopReq) updates) => super.copyWith((message) => updates(message as ServerStopReq)) as ServerStopReq;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ServerStopReq create() => ServerStopReq._();
  ServerStopReq createEmptyInstance() => create();
  static $pb.PbList<ServerStopReq> createRepeated() => $pb.PbList<ServerStopReq>();
  @$core.pragma('dart2js:noInline')
  static ServerStopReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ServerStopReq>(create);
  static ServerStopReq? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get connAddr => $_getSZ(0);
  @$pb.TagNumber(1)
  set connAddr($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasConnAddr() => $_has(0);
  @$pb.TagNumber(1)
  void clearConnAddr() => clearField(1);
}

class LogicIntApi {
  $pb.RpcClient _client;
  LogicIntApi(this._client);

  $async.Future<$1.Empty> connSignIn($pb.ClientContext? ctx, ConnSignInReq request) =>
    _client.invoke<$1.Empty>(ctx, 'LogicInt', 'ConnSignIn', request, $1.Empty())
  ;
  $async.Future<SyncResp> sync($pb.ClientContext? ctx, SyncReq request) =>
    _client.invoke<SyncResp>(ctx, 'LogicInt', 'Sync', request, SyncResp())
  ;
  $async.Future<$1.Empty> messageACK($pb.ClientContext? ctx, MessageACKReq request) =>
    _client.invoke<$1.Empty>(ctx, 'LogicInt', 'MessageACK', request, $1.Empty())
  ;
  $async.Future<$1.Empty> offline($pb.ClientContext? ctx, OfflineReq request) =>
    _client.invoke<$1.Empty>(ctx, 'LogicInt', 'Offline', request, $1.Empty())
  ;
  $async.Future<$1.Empty> subscribeRoom($pb.ClientContext? ctx, SubscribeRoomReq request) =>
    _client.invoke<$1.Empty>(ctx, 'LogicInt', 'SubscribeRoom', request, $1.Empty())
  ;
  $async.Future<PushResp> push($pb.ClientContext? ctx, PushReq request) =>
    _client.invoke<PushResp>(ctx, 'LogicInt', 'Push', request, PushResp())
  ;
  $async.Future<$1.Empty> pushRoom($pb.ClientContext? ctx, $2.PushRoomReq request) =>
    _client.invoke<$1.Empty>(ctx, 'LogicInt', 'PushRoom', request, $1.Empty())
  ;
  $async.Future<$1.Empty> pushAll($pb.ClientContext? ctx, PushAllReq request) =>
    _client.invoke<$1.Empty>(ctx, 'LogicInt', 'PushAll', request, $1.Empty())
  ;
  $async.Future<GetDeviceResp> getDevice($pb.ClientContext? ctx, GetDeviceReq request) =>
    _client.invoke<GetDeviceResp>(ctx, 'LogicInt', 'GetDevice', request, GetDeviceResp())
  ;
  $async.Future<$1.Empty> serverStop($pb.ClientContext? ctx, ServerStopReq request) =>
    _client.invoke<$1.Empty>(ctx, 'LogicInt', 'ServerStop', request, $1.Empty())
  ;
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
