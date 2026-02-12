// This is a generated file - do not edit.
//
// Generated from connect.ext.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'connect.ext.pbenum.dart';
import 'message.ext.pb.dart' as $0;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'connect.ext.pbenum.dart';

/// 上行数据
class Input extends $pb.GeneratedMessage {
  factory Input({
    PackageType? type,
    $fixnum.Int64? requestId,
    $core.List<$core.int>? data,
  }) {
    final result = create();
    if (type != null) result.type = type;
    if (requestId != null) result.requestId = requestId;
    if (data != null) result.data = data;
    return result;
  }

  Input._();

  factory Input.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Input.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Input',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'),
      createEmptyInstance: create)
    ..aE<PackageType>(1, _omitFieldNames ? '' : 'type',
        enumValues: PackageType.values)
    ..aInt64(2, _omitFieldNames ? '' : 'requestId')
    ..a<$core.List<$core.int>>(
        3, _omitFieldNames ? '' : 'data', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Input clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Input copyWith(void Function(Input) updates) =>
      super.copyWith((message) => updates(message as Input)) as Input;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Input create() => Input._();
  @$core.override
  Input createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Input getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Input>(create);
  static Input? _defaultInstance;

  @$pb.TagNumber(1)
  PackageType get type => $_getN(0);
  @$pb.TagNumber(1)
  set type(PackageType value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get requestId => $_getI64(1);
  @$pb.TagNumber(2)
  set requestId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRequestId() => $_has(1);
  @$pb.TagNumber(2)
  void clearRequestId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get data => $_getN(2);
  @$pb.TagNumber(3)
  set data($core.List<$core.int> value) => $_setBytes(2, value);
  @$pb.TagNumber(3)
  $core.bool hasData() => $_has(2);
  @$pb.TagNumber(3)
  void clearData() => $_clearField(3);
}

/// 下行数据
class Output extends $pb.GeneratedMessage {
  factory Output({
    PackageType? type,
    $fixnum.Int64? requestId,
    $core.int? code,
    $core.String? message,
    $core.List<$core.int>? data,
  }) {
    final result = create();
    if (type != null) result.type = type;
    if (requestId != null) result.requestId = requestId;
    if (code != null) result.code = code;
    if (message != null) result.message = message;
    if (data != null) result.data = data;
    return result;
  }

  Output._();

  factory Output.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Output.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Output',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'),
      createEmptyInstance: create)
    ..aE<PackageType>(1, _omitFieldNames ? '' : 'type',
        enumValues: PackageType.values)
    ..aInt64(2, _omitFieldNames ? '' : 'requestId')
    ..aI(3, _omitFieldNames ? '' : 'code')
    ..aOS(4, _omitFieldNames ? '' : 'message')
    ..a<$core.List<$core.int>>(
        5, _omitFieldNames ? '' : 'data', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Output clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Output copyWith(void Function(Output) updates) =>
      super.copyWith((message) => updates(message as Output)) as Output;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Output create() => Output._();
  @$core.override
  Output createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Output getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Output>(create);
  static Output? _defaultInstance;

  @$pb.TagNumber(1)
  PackageType get type => $_getN(0);
  @$pb.TagNumber(1)
  set type(PackageType value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get requestId => $_getI64(1);
  @$pb.TagNumber(2)
  set requestId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRequestId() => $_has(1);
  @$pb.TagNumber(2)
  void clearRequestId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get code => $_getIZ(2);
  @$pb.TagNumber(3)
  set code($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCode() => $_has(2);
  @$pb.TagNumber(3)
  void clearCode() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get message => $_getSZ(3);
  @$pb.TagNumber(4)
  set message($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMessage() => $_has(3);
  @$pb.TagNumber(4)
  void clearMessage() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.List<$core.int> get data => $_getN(4);
  @$pb.TagNumber(5)
  set data($core.List<$core.int> value) => $_setBytes(4, value);
  @$pb.TagNumber(5)
  $core.bool hasData() => $_has(4);
  @$pb.TagNumber(5)
  void clearData() => $_clearField(5);
}

/// 设备登录,package_type:1
class SignInInput extends $pb.GeneratedMessage {
  factory SignInInput({
    $fixnum.Int64? deviceId,
    $fixnum.Int64? userId,
    $core.String? token,
  }) {
    final result = create();
    if (deviceId != null) result.deviceId = deviceId;
    if (userId != null) result.userId = userId;
    if (token != null) result.token = token;
    return result;
  }

  SignInInput._();

  factory SignInInput.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SignInInput.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SignInInput',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'deviceId')
    ..aInt64(2, _omitFieldNames ? '' : 'userId')
    ..aOS(3, _omitFieldNames ? '' : 'token')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SignInInput clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SignInInput copyWith(void Function(SignInInput) updates) =>
      super.copyWith((message) => updates(message as SignInInput))
          as SignInInput;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SignInInput create() => SignInInput._();
  @$core.override
  SignInInput createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SignInInput getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SignInInput>(create);
  static SignInInput? _defaultInstance;

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
}

/// 消息同步请求,package_type:2
class SyncInput extends $pb.GeneratedMessage {
  factory SyncInput({
    $fixnum.Int64? seq,
  }) {
    final result = create();
    if (seq != null) result.seq = seq;
    return result;
  }

  SyncInput._();

  factory SyncInput.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SyncInput.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SyncInput',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'seq')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SyncInput clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SyncInput copyWith(void Function(SyncInput) updates) =>
      super.copyWith((message) => updates(message as SyncInput)) as SyncInput;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SyncInput create() => SyncInput._();
  @$core.override
  SyncInput createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SyncInput getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SyncInput>(create);
  static SyncInput? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get seq => $_getI64(0);
  @$pb.TagNumber(1)
  set seq($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSeq() => $_has(0);
  @$pb.TagNumber(1)
  void clearSeq() => $_clearField(1);
}

/// 消息同步响应,package_type:2
class SyncOutput extends $pb.GeneratedMessage {
  factory SyncOutput({
    $core.Iterable<$0.Message>? messages,
    $core.bool? hasMore,
  }) {
    final result = create();
    if (messages != null) result.messages.addAll(messages);
    if (hasMore != null) result.hasMore = hasMore;
    return result;
  }

  SyncOutput._();

  factory SyncOutput.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SyncOutput.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SyncOutput',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'),
      createEmptyInstance: create)
    ..pPM<$0.Message>(1, _omitFieldNames ? '' : 'messages',
        subBuilder: $0.Message.create)
    ..aOB(2, _omitFieldNames ? '' : 'hasMore')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SyncOutput clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SyncOutput copyWith(void Function(SyncOutput) updates) =>
      super.copyWith((message) => updates(message as SyncOutput)) as SyncOutput;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SyncOutput create() => SyncOutput._();
  @$core.override
  SyncOutput createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SyncOutput getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SyncOutput>(create);
  static SyncOutput? _defaultInstance;

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

/// 订阅房间请求
class SubscribeRoomInput extends $pb.GeneratedMessage {
  factory SubscribeRoomInput({
    $fixnum.Int64? roomId,
    $fixnum.Int64? seq,
  }) {
    final result = create();
    if (roomId != null) result.roomId = roomId;
    if (seq != null) result.seq = seq;
    return result;
  }

  SubscribeRoomInput._();

  factory SubscribeRoomInput.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SubscribeRoomInput.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SubscribeRoomInput',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'roomId')
    ..aInt64(2, _omitFieldNames ? '' : 'seq')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubscribeRoomInput clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubscribeRoomInput copyWith(void Function(SubscribeRoomInput) updates) =>
      super.copyWith((message) => updates(message as SubscribeRoomInput))
          as SubscribeRoomInput;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SubscribeRoomInput create() => SubscribeRoomInput._();
  @$core.override
  SubscribeRoomInput createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SubscribeRoomInput getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SubscribeRoomInput>(create);
  static SubscribeRoomInput? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get roomId => $_getI64(0);
  @$pb.TagNumber(1)
  set roomId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRoomId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRoomId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get seq => $_getI64(1);
  @$pb.TagNumber(2)
  set seq($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSeq() => $_has(1);
  @$pb.TagNumber(2)
  void clearSeq() => $_clearField(2);
}

/// 投递消息回执,package_type:4
class MessageACK extends $pb.GeneratedMessage {
  factory MessageACK({
    $fixnum.Int64? deviceAck,
    $core.String? target,
    $fixnum.Int64? receiveTime,
  }) {
    final result = create();
    if (deviceAck != null) result.deviceAck = deviceAck;
    if (target != null) result.target = target;
    if (receiveTime != null) result.receiveTime = receiveTime;
    return result;
  }

  MessageACK._();

  factory MessageACK.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MessageACK.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MessageACK',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'),
      createEmptyInstance: create)
    ..aInt64(2, _omitFieldNames ? '' : 'deviceAck')
    ..aOS(3, _omitFieldNames ? '' : 'target')
    ..aInt64(4, _omitFieldNames ? '' : 'receiveTime')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MessageACK clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MessageACK copyWith(void Function(MessageACK) updates) =>
      super.copyWith((message) => updates(message as MessageACK)) as MessageACK;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MessageACK create() => MessageACK._();
  @$core.override
  MessageACK createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MessageACK getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MessageACK>(create);
  static MessageACK? _defaultInstance;

  @$pb.TagNumber(2)
  $fixnum.Int64 get deviceAck => $_getI64(0);
  @$pb.TagNumber(2)
  set deviceAck($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(2)
  $core.bool hasDeviceAck() => $_has(0);
  @$pb.TagNumber(2)
  void clearDeviceAck() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get target => $_getSZ(1);
  @$pb.TagNumber(3)
  set target($core.String value) => $_setString(1, value);
  @$pb.TagNumber(3)
  $core.bool hasTarget() => $_has(1);
  @$pb.TagNumber(3)
  void clearTarget() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get receiveTime => $_getI64(2);
  @$pb.TagNumber(4)
  set receiveTime($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(4)
  $core.bool hasReceiveTime() => $_has(2);
  @$pb.TagNumber(4)
  void clearReceiveTime() => $_clearField(4);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
