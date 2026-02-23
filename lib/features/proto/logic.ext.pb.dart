// This is a generated file - do not edit.
//
// Generated from logic.ext.proto.

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
import 'package:protobuf/well_known_types/google/protobuf/empty.pb.dart' as $0;

import 'logic.ext.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'logic.ext.pbenum.dart';

class RegisterDeviceReq extends $pb.GeneratedMessage {
  factory RegisterDeviceReq({
    $core.int? type,
    $core.String? brand,
    $core.String? model,
    $core.String? systemVersion,
    $core.String? sdkVersion,
  }) {
    final result = create();
    if (type != null) result.type = type;
    if (brand != null) result.brand = brand;
    if (model != null) result.model = model;
    if (systemVersion != null) result.systemVersion = systemVersion;
    if (sdkVersion != null) result.sdkVersion = sdkVersion;
    return result;
  }

  RegisterDeviceReq._();

  factory RegisterDeviceReq.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RegisterDeviceReq.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RegisterDeviceReq',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'),
      createEmptyInstance: create)
    ..aI(2, _omitFieldNames ? '' : 'type')
    ..aOS(3, _omitFieldNames ? '' : 'brand')
    ..aOS(4, _omitFieldNames ? '' : 'model')
    ..aOS(5, _omitFieldNames ? '' : 'systemVersion')
    ..aOS(6, _omitFieldNames ? '' : 'sdkVersion')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RegisterDeviceReq clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RegisterDeviceReq copyWith(void Function(RegisterDeviceReq) updates) =>
      super.copyWith((message) => updates(message as RegisterDeviceReq))
          as RegisterDeviceReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RegisterDeviceReq create() => RegisterDeviceReq._();
  @$core.override
  RegisterDeviceReq createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RegisterDeviceReq getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RegisterDeviceReq>(create);
  static RegisterDeviceReq? _defaultInstance;

  @$pb.TagNumber(2)
  $core.int get type => $_getIZ(0);
  @$pb.TagNumber(2)
  set type($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(2)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(2)
  void clearType() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get brand => $_getSZ(1);
  @$pb.TagNumber(3)
  set brand($core.String value) => $_setString(1, value);
  @$pb.TagNumber(3)
  $core.bool hasBrand() => $_has(1);
  @$pb.TagNumber(3)
  void clearBrand() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get model => $_getSZ(2);
  @$pb.TagNumber(4)
  set model($core.String value) => $_setString(2, value);
  @$pb.TagNumber(4)
  $core.bool hasModel() => $_has(2);
  @$pb.TagNumber(4)
  void clearModel() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get systemVersion => $_getSZ(3);
  @$pb.TagNumber(5)
  set systemVersion($core.String value) => $_setString(3, value);
  @$pb.TagNumber(5)
  $core.bool hasSystemVersion() => $_has(3);
  @$pb.TagNumber(5)
  void clearSystemVersion() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get sdkVersion => $_getSZ(4);
  @$pb.TagNumber(6)
  set sdkVersion($core.String value) => $_setString(4, value);
  @$pb.TagNumber(6)
  $core.bool hasSdkVersion() => $_has(4);
  @$pb.TagNumber(6)
  void clearSdkVersion() => $_clearField(6);
}

class RegisterDeviceResp extends $pb.GeneratedMessage {
  factory RegisterDeviceResp({
    $fixnum.Int64? deviceId,
  }) {
    final result = create();
    if (deviceId != null) result.deviceId = deviceId;
    return result;
  }

  RegisterDeviceResp._();

  factory RegisterDeviceResp.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RegisterDeviceResp.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RegisterDeviceResp',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'deviceId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RegisterDeviceResp clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RegisterDeviceResp copyWith(void Function(RegisterDeviceResp) updates) =>
      super.copyWith((message) => updates(message as RegisterDeviceResp))
          as RegisterDeviceResp;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RegisterDeviceResp create() => RegisterDeviceResp._();
  @$core.override
  RegisterDeviceResp createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RegisterDeviceResp getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RegisterDeviceResp>(create);
  static RegisterDeviceResp? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get deviceId => $_getI64(0);
  @$pb.TagNumber(1)
  set deviceId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDeviceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearDeviceId() => $_clearField(1);
}

class SendMessageReq extends $pb.GeneratedMessage {
  factory SendMessageReq({
    $fixnum.Int64? receiverId,
    $core.List<$core.int>? content,
    $fixnum.Int64? sendTime,
  }) {
    final result = create();
    if (receiverId != null) result.receiverId = receiverId;
    if (content != null) result.content = content;
    if (sendTime != null) result.sendTime = sendTime;
    return result;
  }

  SendMessageReq._();

  factory SendMessageReq.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SendMessageReq.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SendMessageReq',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'receiverId')
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'content', $pb.PbFieldType.OY)
    ..aInt64(3, _omitFieldNames ? '' : 'sendTime')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendMessageReq clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendMessageReq copyWith(void Function(SendMessageReq) updates) =>
      super.copyWith((message) => updates(message as SendMessageReq))
          as SendMessageReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SendMessageReq create() => SendMessageReq._();
  @$core.override
  SendMessageReq createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SendMessageReq getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SendMessageReq>(create);
  static SendMessageReq? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get receiverId => $_getI64(0);
  @$pb.TagNumber(1)
  set receiverId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasReceiverId() => $_has(0);
  @$pb.TagNumber(1)
  void clearReceiverId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get content => $_getN(1);
  @$pb.TagNumber(2)
  set content($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasContent() => $_has(1);
  @$pb.TagNumber(2)
  void clearContent() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get sendTime => $_getI64(2);
  @$pb.TagNumber(3)
  set sendTime($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSendTime() => $_has(2);
  @$pb.TagNumber(3)
  void clearSendTime() => $_clearField(3);
}

class SendMessageResp extends $pb.GeneratedMessage {
  factory SendMessageResp({
    $fixnum.Int64? seq,
  }) {
    final result = create();
    if (seq != null) result.seq = seq;
    return result;
  }

  SendMessageResp._();

  factory SendMessageResp.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SendMessageResp.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SendMessageResp',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'seq')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendMessageResp clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendMessageResp copyWith(void Function(SendMessageResp) updates) =>
      super.copyWith((message) => updates(message as SendMessageResp))
          as SendMessageResp;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SendMessageResp create() => SendMessageResp._();
  @$core.override
  SendMessageResp createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SendMessageResp getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SendMessageResp>(create);
  static SendMessageResp? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get seq => $_getI64(0);
  @$pb.TagNumber(1)
  set seq($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSeq() => $_has(0);
  @$pb.TagNumber(1)
  void clearSeq() => $_clearField(1);
}

class PushRoomReq extends $pb.GeneratedMessage {
  factory PushRoomReq({
    $fixnum.Int64? roomId,
    $core.int? code,
    $core.List<$core.int>? content,
    $fixnum.Int64? sendTime,
    $core.bool? isPersist,
    $core.bool? isPriority,
  }) {
    final result = create();
    if (roomId != null) result.roomId = roomId;
    if (code != null) result.code = code;
    if (content != null) result.content = content;
    if (sendTime != null) result.sendTime = sendTime;
    if (isPersist != null) result.isPersist = isPersist;
    if (isPriority != null) result.isPriority = isPriority;
    return result;
  }

  PushRoomReq._();

  factory PushRoomReq.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PushRoomReq.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PushRoomReq',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'roomId')
    ..aI(2, _omitFieldNames ? '' : 'code')
    ..a<$core.List<$core.int>>(
        3, _omitFieldNames ? '' : 'content', $pb.PbFieldType.OY)
    ..aInt64(4, _omitFieldNames ? '' : 'sendTime')
    ..aOB(5, _omitFieldNames ? '' : 'isPersist')
    ..aOB(6, _omitFieldNames ? '' : 'isPriority')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PushRoomReq clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PushRoomReq copyWith(void Function(PushRoomReq) updates) =>
      super.copyWith((message) => updates(message as PushRoomReq))
          as PushRoomReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PushRoomReq create() => PushRoomReq._();
  @$core.override
  PushRoomReq createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PushRoomReq getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PushRoomReq>(create);
  static PushRoomReq? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get roomId => $_getI64(0);
  @$pb.TagNumber(1)
  set roomId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRoomId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRoomId() => $_clearField(1);

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
  $fixnum.Int64 get sendTime => $_getI64(3);
  @$pb.TagNumber(4)
  set sendTime($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSendTime() => $_has(3);
  @$pb.TagNumber(4)
  void clearSendTime() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get isPersist => $_getBF(4);
  @$pb.TagNumber(5)
  set isPersist($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasIsPersist() => $_has(4);
  @$pb.TagNumber(5)
  void clearIsPersist() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get isPriority => $_getBF(5);
  @$pb.TagNumber(6)
  set isPriority($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasIsPriority() => $_has(5);
  @$pb.TagNumber(6)
  void clearIsPriority() => $_clearField(6);
}

class AddFriendReq extends $pb.GeneratedMessage {
  factory AddFriendReq({
    $fixnum.Int64? friendId,
    $core.String? remarks,
    $core.String? description,
  }) {
    final result = create();
    if (friendId != null) result.friendId = friendId;
    if (remarks != null) result.remarks = remarks;
    if (description != null) result.description = description;
    return result;
  }

  AddFriendReq._();

  factory AddFriendReq.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AddFriendReq.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AddFriendReq',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'friendId')
    ..aOS(2, _omitFieldNames ? '' : 'remarks')
    ..aOS(3, _omitFieldNames ? '' : 'description')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddFriendReq clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddFriendReq copyWith(void Function(AddFriendReq) updates) =>
      super.copyWith((message) => updates(message as AddFriendReq))
          as AddFriendReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddFriendReq create() => AddFriendReq._();
  @$core.override
  AddFriendReq createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AddFriendReq getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AddFriendReq>(create);
  static AddFriendReq? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get friendId => $_getI64(0);
  @$pb.TagNumber(1)
  set friendId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFriendId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFriendId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get remarks => $_getSZ(1);
  @$pb.TagNumber(2)
  set remarks($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRemarks() => $_has(1);
  @$pb.TagNumber(2)
  void clearRemarks() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get description => $_getSZ(2);
  @$pb.TagNumber(3)
  set description($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDescription() => $_has(2);
  @$pb.TagNumber(3)
  void clearDescription() => $_clearField(3);
}

class AgreeAddFriendReq extends $pb.GeneratedMessage {
  factory AgreeAddFriendReq({
    $fixnum.Int64? userId,
    $core.String? remarks,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (remarks != null) result.remarks = remarks;
    return result;
  }

  AgreeAddFriendReq._();

  factory AgreeAddFriendReq.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AgreeAddFriendReq.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AgreeAddFriendReq',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'remarks')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AgreeAddFriendReq clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AgreeAddFriendReq copyWith(void Function(AgreeAddFriendReq) updates) =>
      super.copyWith((message) => updates(message as AgreeAddFriendReq))
          as AgreeAddFriendReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AgreeAddFriendReq create() => AgreeAddFriendReq._();
  @$core.override
  AgreeAddFriendReq createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AgreeAddFriendReq getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AgreeAddFriendReq>(create);
  static AgreeAddFriendReq? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get userId => $_getI64(0);
  @$pb.TagNumber(1)
  set userId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get remarks => $_getSZ(1);
  @$pb.TagNumber(2)
  set remarks($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRemarks() => $_has(1);
  @$pb.TagNumber(2)
  void clearRemarks() => $_clearField(2);
}

class SetFriendReq extends $pb.GeneratedMessage {
  factory SetFriendReq({
    $fixnum.Int64? friendId,
    $core.String? remarks,
    $core.String? extra,
  }) {
    final result = create();
    if (friendId != null) result.friendId = friendId;
    if (remarks != null) result.remarks = remarks;
    if (extra != null) result.extra = extra;
    return result;
  }

  SetFriendReq._();

  factory SetFriendReq.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetFriendReq.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetFriendReq',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'friendId')
    ..aOS(2, _omitFieldNames ? '' : 'remarks')
    ..aOS(8, _omitFieldNames ? '' : 'extra')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetFriendReq clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetFriendReq copyWith(void Function(SetFriendReq) updates) =>
      super.copyWith((message) => updates(message as SetFriendReq))
          as SetFriendReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetFriendReq create() => SetFriendReq._();
  @$core.override
  SetFriendReq createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetFriendReq getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetFriendReq>(create);
  static SetFriendReq? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get friendId => $_getI64(0);
  @$pb.TagNumber(1)
  set friendId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFriendId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFriendId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get remarks => $_getSZ(1);
  @$pb.TagNumber(2)
  set remarks($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRemarks() => $_has(1);
  @$pb.TagNumber(2)
  void clearRemarks() => $_clearField(2);

  @$pb.TagNumber(8)
  $core.String get extra => $_getSZ(2);
  @$pb.TagNumber(8)
  set extra($core.String value) => $_setString(2, value);
  @$pb.TagNumber(8)
  $core.bool hasExtra() => $_has(2);
  @$pb.TagNumber(8)
  void clearExtra() => $_clearField(8);
}

class SetFriendResp extends $pb.GeneratedMessage {
  factory SetFriendResp({
    $fixnum.Int64? friendId,
    $core.String? remarks,
    $core.String? extra,
  }) {
    final result = create();
    if (friendId != null) result.friendId = friendId;
    if (remarks != null) result.remarks = remarks;
    if (extra != null) result.extra = extra;
    return result;
  }

  SetFriendResp._();

  factory SetFriendResp.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetFriendResp.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetFriendResp',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'friendId')
    ..aOS(2, _omitFieldNames ? '' : 'remarks')
    ..aOS(8, _omitFieldNames ? '' : 'extra')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetFriendResp clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetFriendResp copyWith(void Function(SetFriendResp) updates) =>
      super.copyWith((message) => updates(message as SetFriendResp))
          as SetFriendResp;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetFriendResp create() => SetFriendResp._();
  @$core.override
  SetFriendResp createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetFriendResp getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetFriendResp>(create);
  static SetFriendResp? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get friendId => $_getI64(0);
  @$pb.TagNumber(1)
  set friendId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFriendId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFriendId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get remarks => $_getSZ(1);
  @$pb.TagNumber(2)
  set remarks($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRemarks() => $_has(1);
  @$pb.TagNumber(2)
  void clearRemarks() => $_clearField(2);

  @$pb.TagNumber(8)
  $core.String get extra => $_getSZ(2);
  @$pb.TagNumber(8)
  set extra($core.String value) => $_setString(2, value);
  @$pb.TagNumber(8)
  $core.bool hasExtra() => $_has(2);
  @$pb.TagNumber(8)
  void clearExtra() => $_clearField(8);
}

class Friend extends $pb.GeneratedMessage {
  factory Friend({
    $fixnum.Int64? userId,
    $core.String? phoneNumber,
    $core.String? nickname,
    $core.int? sex,
    $core.String? avatarUrl,
    $core.String? userExtra,
    $core.String? remarks,
    $core.String? extra,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (phoneNumber != null) result.phoneNumber = phoneNumber;
    if (nickname != null) result.nickname = nickname;
    if (sex != null) result.sex = sex;
    if (avatarUrl != null) result.avatarUrl = avatarUrl;
    if (userExtra != null) result.userExtra = userExtra;
    if (remarks != null) result.remarks = remarks;
    if (extra != null) result.extra = extra;
    return result;
  }

  Friend._();

  factory Friend.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Friend.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Friend',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'phoneNumber')
    ..aOS(3, _omitFieldNames ? '' : 'nickname')
    ..aI(4, _omitFieldNames ? '' : 'sex')
    ..aOS(5, _omitFieldNames ? '' : 'avatarUrl')
    ..aOS(6, _omitFieldNames ? '' : 'userExtra')
    ..aOS(7, _omitFieldNames ? '' : 'remarks')
    ..aOS(8, _omitFieldNames ? '' : 'extra')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Friend clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Friend copyWith(void Function(Friend) updates) =>
      super.copyWith((message) => updates(message as Friend)) as Friend;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Friend create() => Friend._();
  @$core.override
  Friend createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Friend getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Friend>(create);
  static Friend? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get userId => $_getI64(0);
  @$pb.TagNumber(1)
  set userId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get phoneNumber => $_getSZ(1);
  @$pb.TagNumber(2)
  set phoneNumber($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPhoneNumber() => $_has(1);
  @$pb.TagNumber(2)
  void clearPhoneNumber() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get nickname => $_getSZ(2);
  @$pb.TagNumber(3)
  set nickname($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasNickname() => $_has(2);
  @$pb.TagNumber(3)
  void clearNickname() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get sex => $_getIZ(3);
  @$pb.TagNumber(4)
  set sex($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSex() => $_has(3);
  @$pb.TagNumber(4)
  void clearSex() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get avatarUrl => $_getSZ(4);
  @$pb.TagNumber(5)
  set avatarUrl($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasAvatarUrl() => $_has(4);
  @$pb.TagNumber(5)
  void clearAvatarUrl() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get userExtra => $_getSZ(5);
  @$pb.TagNumber(6)
  set userExtra($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasUserExtra() => $_has(5);
  @$pb.TagNumber(6)
  void clearUserExtra() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get remarks => $_getSZ(6);
  @$pb.TagNumber(7)
  set remarks($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasRemarks() => $_has(6);
  @$pb.TagNumber(7)
  void clearRemarks() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get extra => $_getSZ(7);
  @$pb.TagNumber(8)
  set extra($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasExtra() => $_has(7);
  @$pb.TagNumber(8)
  void clearExtra() => $_clearField(8);
}

class GetFriendsResp extends $pb.GeneratedMessage {
  factory GetFriendsResp({
    $core.Iterable<Friend>? friends,
  }) {
    final result = create();
    if (friends != null) result.friends.addAll(friends);
    return result;
  }

  GetFriendsResp._();

  factory GetFriendsResp.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetFriendsResp.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetFriendsResp',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'),
      createEmptyInstance: create)
    ..pPM<Friend>(1, _omitFieldNames ? '' : 'friends',
        subBuilder: Friend.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFriendsResp clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFriendsResp copyWith(void Function(GetFriendsResp) updates) =>
      super.copyWith((message) => updates(message as GetFriendsResp))
          as GetFriendsResp;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetFriendsResp create() => GetFriendsResp._();
  @$core.override
  GetFriendsResp createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetFriendsResp getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetFriendsResp>(create);
  static GetFriendsResp? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Friend> get friends => $_getList(0);
}

class CreateGroupReq extends $pb.GeneratedMessage {
  factory CreateGroupReq({
    $core.String? name,
    $core.String? avatarUrl,
    $core.String? introduction,
    $core.String? extra,
    $core.Iterable<$fixnum.Int64>? memberIds,
  }) {
    final result = create();
    if (name != null) result.name = name;
    if (avatarUrl != null) result.avatarUrl = avatarUrl;
    if (introduction != null) result.introduction = introduction;
    if (extra != null) result.extra = extra;
    if (memberIds != null) result.memberIds.addAll(memberIds);
    return result;
  }

  CreateGroupReq._();

  factory CreateGroupReq.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateGroupReq.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateGroupReq',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOS(2, _omitFieldNames ? '' : 'avatarUrl')
    ..aOS(3, _omitFieldNames ? '' : 'introduction')
    ..aOS(4, _omitFieldNames ? '' : 'extra')
    ..p<$fixnum.Int64>(
        5, _omitFieldNames ? '' : 'memberIds', $pb.PbFieldType.K6)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateGroupReq clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateGroupReq copyWith(void Function(CreateGroupReq) updates) =>
      super.copyWith((message) => updates(message as CreateGroupReq))
          as CreateGroupReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateGroupReq create() => CreateGroupReq._();
  @$core.override
  CreateGroupReq createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateGroupReq getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateGroupReq>(create);
  static CreateGroupReq? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get avatarUrl => $_getSZ(1);
  @$pb.TagNumber(2)
  set avatarUrl($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAvatarUrl() => $_has(1);
  @$pb.TagNumber(2)
  void clearAvatarUrl() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get introduction => $_getSZ(2);
  @$pb.TagNumber(3)
  set introduction($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasIntroduction() => $_has(2);
  @$pb.TagNumber(3)
  void clearIntroduction() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get extra => $_getSZ(3);
  @$pb.TagNumber(4)
  set extra($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasExtra() => $_has(3);
  @$pb.TagNumber(4)
  void clearExtra() => $_clearField(4);

  @$pb.TagNumber(5)
  $pb.PbList<$fixnum.Int64> get memberIds => $_getList(4);
}

class CreateGroupResp extends $pb.GeneratedMessage {
  factory CreateGroupResp({
    $fixnum.Int64? groupId,
  }) {
    final result = create();
    if (groupId != null) result.groupId = groupId;
    return result;
  }

  CreateGroupResp._();

  factory CreateGroupResp.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateGroupResp.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateGroupResp',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'groupId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateGroupResp clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateGroupResp copyWith(void Function(CreateGroupResp) updates) =>
      super.copyWith((message) => updates(message as CreateGroupResp))
          as CreateGroupResp;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateGroupResp create() => CreateGroupResp._();
  @$core.override
  CreateGroupResp createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateGroupResp getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateGroupResp>(create);
  static CreateGroupResp? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get groupId => $_getI64(0);
  @$pb.TagNumber(1)
  set groupId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasGroupId() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroupId() => $_clearField(1);
}

class UpdateGroupReq extends $pb.GeneratedMessage {
  factory UpdateGroupReq({
    $fixnum.Int64? groupId,
    $core.String? avatarUrl,
    $core.String? name,
    $core.String? introduction,
    $core.String? extra,
  }) {
    final result = create();
    if (groupId != null) result.groupId = groupId;
    if (avatarUrl != null) result.avatarUrl = avatarUrl;
    if (name != null) result.name = name;
    if (introduction != null) result.introduction = introduction;
    if (extra != null) result.extra = extra;
    return result;
  }

  UpdateGroupReq._();

  factory UpdateGroupReq.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateGroupReq.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateGroupReq',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'groupId')
    ..aOS(2, _omitFieldNames ? '' : 'avatarUrl')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aOS(4, _omitFieldNames ? '' : 'introduction')
    ..aOS(5, _omitFieldNames ? '' : 'extra')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateGroupReq clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateGroupReq copyWith(void Function(UpdateGroupReq) updates) =>
      super.copyWith((message) => updates(message as UpdateGroupReq))
          as UpdateGroupReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateGroupReq create() => UpdateGroupReq._();
  @$core.override
  UpdateGroupReq createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateGroupReq getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateGroupReq>(create);
  static UpdateGroupReq? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get groupId => $_getI64(0);
  @$pb.TagNumber(1)
  set groupId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasGroupId() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroupId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get avatarUrl => $_getSZ(1);
  @$pb.TagNumber(2)
  set avatarUrl($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAvatarUrl() => $_has(1);
  @$pb.TagNumber(2)
  void clearAvatarUrl() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get introduction => $_getSZ(3);
  @$pb.TagNumber(4)
  set introduction($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasIntroduction() => $_has(3);
  @$pb.TagNumber(4)
  void clearIntroduction() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get extra => $_getSZ(4);
  @$pb.TagNumber(5)
  set extra($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasExtra() => $_has(4);
  @$pb.TagNumber(5)
  void clearExtra() => $_clearField(5);
}

class GetGroupReq extends $pb.GeneratedMessage {
  factory GetGroupReq({
    $fixnum.Int64? groupId,
  }) {
    final result = create();
    if (groupId != null) result.groupId = groupId;
    return result;
  }

  GetGroupReq._();

  factory GetGroupReq.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetGroupReq.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetGroupReq',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'groupId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetGroupReq clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetGroupReq copyWith(void Function(GetGroupReq) updates) =>
      super.copyWith((message) => updates(message as GetGroupReq))
          as GetGroupReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetGroupReq create() => GetGroupReq._();
  @$core.override
  GetGroupReq createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetGroupReq getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetGroupReq>(create);
  static GetGroupReq? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get groupId => $_getI64(0);
  @$pb.TagNumber(1)
  set groupId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasGroupId() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroupId() => $_clearField(1);
}

class GetGroupResp extends $pb.GeneratedMessage {
  factory GetGroupResp({
    Group? group,
  }) {
    final result = create();
    if (group != null) result.group = group;
    return result;
  }

  GetGroupResp._();

  factory GetGroupResp.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetGroupResp.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetGroupResp',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'),
      createEmptyInstance: create)
    ..aOM<Group>(1, _omitFieldNames ? '' : 'group', subBuilder: Group.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetGroupResp clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetGroupResp copyWith(void Function(GetGroupResp) updates) =>
      super.copyWith((message) => updates(message as GetGroupResp))
          as GetGroupResp;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetGroupResp create() => GetGroupResp._();
  @$core.override
  GetGroupResp createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetGroupResp getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetGroupResp>(create);
  static GetGroupResp? _defaultInstance;

  @$pb.TagNumber(1)
  Group get group => $_getN(0);
  @$pb.TagNumber(1)
  set group(Group value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasGroup() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroup() => $_clearField(1);
  @$pb.TagNumber(1)
  Group ensureGroup() => $_ensure(0);
}

class Group extends $pb.GeneratedMessage {
  factory Group({
    $fixnum.Int64? groupId,
    $core.String? name,
    $core.String? avatarUrl,
    $core.String? introduction,
    $core.int? userMum,
    $core.String? extra,
    $fixnum.Int64? createTime,
    $fixnum.Int64? updateTime,
  }) {
    final result = create();
    if (groupId != null) result.groupId = groupId;
    if (name != null) result.name = name;
    if (avatarUrl != null) result.avatarUrl = avatarUrl;
    if (introduction != null) result.introduction = introduction;
    if (userMum != null) result.userMum = userMum;
    if (extra != null) result.extra = extra;
    if (createTime != null) result.createTime = createTime;
    if (updateTime != null) result.updateTime = updateTime;
    return result;
  }

  Group._();

  factory Group.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Group.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Group',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'groupId')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'avatarUrl')
    ..aOS(4, _omitFieldNames ? '' : 'introduction')
    ..aI(5, _omitFieldNames ? '' : 'userMum')
    ..aOS(6, _omitFieldNames ? '' : 'extra')
    ..aInt64(7, _omitFieldNames ? '' : 'createTime')
    ..aInt64(8, _omitFieldNames ? '' : 'updateTime')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Group clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Group copyWith(void Function(Group) updates) =>
      super.copyWith((message) => updates(message as Group)) as Group;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Group create() => Group._();
  @$core.override
  Group createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Group getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Group>(create);
  static Group? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get groupId => $_getI64(0);
  @$pb.TagNumber(1)
  set groupId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasGroupId() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroupId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get avatarUrl => $_getSZ(2);
  @$pb.TagNumber(3)
  set avatarUrl($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAvatarUrl() => $_has(2);
  @$pb.TagNumber(3)
  void clearAvatarUrl() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get introduction => $_getSZ(3);
  @$pb.TagNumber(4)
  set introduction($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasIntroduction() => $_has(3);
  @$pb.TagNumber(4)
  void clearIntroduction() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get userMum => $_getIZ(4);
  @$pb.TagNumber(5)
  set userMum($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasUserMum() => $_has(4);
  @$pb.TagNumber(5)
  void clearUserMum() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get extra => $_getSZ(5);
  @$pb.TagNumber(6)
  set extra($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasExtra() => $_has(5);
  @$pb.TagNumber(6)
  void clearExtra() => $_clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get createTime => $_getI64(6);
  @$pb.TagNumber(7)
  set createTime($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasCreateTime() => $_has(6);
  @$pb.TagNumber(7)
  void clearCreateTime() => $_clearField(7);

  @$pb.TagNumber(8)
  $fixnum.Int64 get updateTime => $_getI64(7);
  @$pb.TagNumber(8)
  set updateTime($fixnum.Int64 value) => $_setInt64(7, value);
  @$pb.TagNumber(8)
  $core.bool hasUpdateTime() => $_has(7);
  @$pb.TagNumber(8)
  void clearUpdateTime() => $_clearField(8);
}

class GetGroupsResp extends $pb.GeneratedMessage {
  factory GetGroupsResp({
    $core.Iterable<Group>? groups,
  }) {
    final result = create();
    if (groups != null) result.groups.addAll(groups);
    return result;
  }

  GetGroupsResp._();

  factory GetGroupsResp.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetGroupsResp.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetGroupsResp',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'),
      createEmptyInstance: create)
    ..pPM<Group>(1, _omitFieldNames ? '' : 'groups', subBuilder: Group.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetGroupsResp clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetGroupsResp copyWith(void Function(GetGroupsResp) updates) =>
      super.copyWith((message) => updates(message as GetGroupsResp))
          as GetGroupsResp;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetGroupsResp create() => GetGroupsResp._();
  @$core.override
  GetGroupsResp createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetGroupsResp getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetGroupsResp>(create);
  static GetGroupsResp? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Group> get groups => $_getList(0);
}

class AddGroupMembersReq extends $pb.GeneratedMessage {
  factory AddGroupMembersReq({
    $fixnum.Int64? groupId,
    $core.Iterable<$fixnum.Int64>? userIds,
  }) {
    final result = create();
    if (groupId != null) result.groupId = groupId;
    if (userIds != null) result.userIds.addAll(userIds);
    return result;
  }

  AddGroupMembersReq._();

  factory AddGroupMembersReq.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AddGroupMembersReq.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AddGroupMembersReq',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'groupId')
    ..p<$fixnum.Int64>(2, _omitFieldNames ? '' : 'userIds', $pb.PbFieldType.K6)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddGroupMembersReq clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddGroupMembersReq copyWith(void Function(AddGroupMembersReq) updates) =>
      super.copyWith((message) => updates(message as AddGroupMembersReq))
          as AddGroupMembersReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddGroupMembersReq create() => AddGroupMembersReq._();
  @$core.override
  AddGroupMembersReq createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AddGroupMembersReq getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AddGroupMembersReq>(create);
  static AddGroupMembersReq? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get groupId => $_getI64(0);
  @$pb.TagNumber(1)
  set groupId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasGroupId() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroupId() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<$fixnum.Int64> get userIds => $_getList(1);
}

class AddGroupMembersResp extends $pb.GeneratedMessage {
  factory AddGroupMembersResp({
    $core.Iterable<$fixnum.Int64>? userIds,
  }) {
    final result = create();
    if (userIds != null) result.userIds.addAll(userIds);
    return result;
  }

  AddGroupMembersResp._();

  factory AddGroupMembersResp.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AddGroupMembersResp.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AddGroupMembersResp',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'),
      createEmptyInstance: create)
    ..p<$fixnum.Int64>(1, _omitFieldNames ? '' : 'userIds', $pb.PbFieldType.K6)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddGroupMembersResp clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddGroupMembersResp copyWith(void Function(AddGroupMembersResp) updates) =>
      super.copyWith((message) => updates(message as AddGroupMembersResp))
          as AddGroupMembersResp;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddGroupMembersResp create() => AddGroupMembersResp._();
  @$core.override
  AddGroupMembersResp createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AddGroupMembersResp getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AddGroupMembersResp>(create);
  static AddGroupMembersResp? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$fixnum.Int64> get userIds => $_getList(0);
}

class UpdateGroupMemberReq extends $pb.GeneratedMessage {
  factory UpdateGroupMemberReq({
    $fixnum.Int64? groupId,
    $fixnum.Int64? userId,
    MemberType? memberType,
    $core.String? remarks,
    $core.String? extra,
  }) {
    final result = create();
    if (groupId != null) result.groupId = groupId;
    if (userId != null) result.userId = userId;
    if (memberType != null) result.memberType = memberType;
    if (remarks != null) result.remarks = remarks;
    if (extra != null) result.extra = extra;
    return result;
  }

  UpdateGroupMemberReq._();

  factory UpdateGroupMemberReq.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateGroupMemberReq.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateGroupMemberReq',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'groupId')
    ..aInt64(2, _omitFieldNames ? '' : 'userId')
    ..aE<MemberType>(3, _omitFieldNames ? '' : 'memberType',
        enumValues: MemberType.values)
    ..aOS(4, _omitFieldNames ? '' : 'remarks')
    ..aOS(5, _omitFieldNames ? '' : 'extra')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateGroupMemberReq clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateGroupMemberReq copyWith(void Function(UpdateGroupMemberReq) updates) =>
      super.copyWith((message) => updates(message as UpdateGroupMemberReq))
          as UpdateGroupMemberReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateGroupMemberReq create() => UpdateGroupMemberReq._();
  @$core.override
  UpdateGroupMemberReq createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateGroupMemberReq getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateGroupMemberReq>(create);
  static UpdateGroupMemberReq? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get groupId => $_getI64(0);
  @$pb.TagNumber(1)
  set groupId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasGroupId() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroupId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get userId => $_getI64(1);
  @$pb.TagNumber(2)
  set userId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserId() => $_clearField(2);

  @$pb.TagNumber(3)
  MemberType get memberType => $_getN(2);
  @$pb.TagNumber(3)
  set memberType(MemberType value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasMemberType() => $_has(2);
  @$pb.TagNumber(3)
  void clearMemberType() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get remarks => $_getSZ(3);
  @$pb.TagNumber(4)
  set remarks($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasRemarks() => $_has(3);
  @$pb.TagNumber(4)
  void clearRemarks() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get extra => $_getSZ(4);
  @$pb.TagNumber(5)
  set extra($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasExtra() => $_has(4);
  @$pb.TagNumber(5)
  void clearExtra() => $_clearField(5);
}

class DeleteGroupMemberReq extends $pb.GeneratedMessage {
  factory DeleteGroupMemberReq({
    $fixnum.Int64? groupId,
    $fixnum.Int64? userId,
  }) {
    final result = create();
    if (groupId != null) result.groupId = groupId;
    if (userId != null) result.userId = userId;
    return result;
  }

  DeleteGroupMemberReq._();

  factory DeleteGroupMemberReq.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteGroupMemberReq.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteGroupMemberReq',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'groupId')
    ..aInt64(2, _omitFieldNames ? '' : 'userId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteGroupMemberReq clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteGroupMemberReq copyWith(void Function(DeleteGroupMemberReq) updates) =>
      super.copyWith((message) => updates(message as DeleteGroupMemberReq))
          as DeleteGroupMemberReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteGroupMemberReq create() => DeleteGroupMemberReq._();
  @$core.override
  DeleteGroupMemberReq createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteGroupMemberReq getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteGroupMemberReq>(create);
  static DeleteGroupMemberReq? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get groupId => $_getI64(0);
  @$pb.TagNumber(1)
  set groupId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasGroupId() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroupId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get userId => $_getI64(1);
  @$pb.TagNumber(2)
  set userId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserId() => $_clearField(2);
}

class GetGroupMembersReq extends $pb.GeneratedMessage {
  factory GetGroupMembersReq({
    $fixnum.Int64? groupId,
  }) {
    final result = create();
    if (groupId != null) result.groupId = groupId;
    return result;
  }

  GetGroupMembersReq._();

  factory GetGroupMembersReq.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetGroupMembersReq.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetGroupMembersReq',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'groupId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetGroupMembersReq clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetGroupMembersReq copyWith(void Function(GetGroupMembersReq) updates) =>
      super.copyWith((message) => updates(message as GetGroupMembersReq))
          as GetGroupMembersReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetGroupMembersReq create() => GetGroupMembersReq._();
  @$core.override
  GetGroupMembersReq createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetGroupMembersReq getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetGroupMembersReq>(create);
  static GetGroupMembersReq? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get groupId => $_getI64(0);
  @$pb.TagNumber(1)
  set groupId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasGroupId() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroupId() => $_clearField(1);
}

class GetGroupMembersResp extends $pb.GeneratedMessage {
  factory GetGroupMembersResp({
    $core.Iterable<GroupMember>? members,
  }) {
    final result = create();
    if (members != null) result.members.addAll(members);
    return result;
  }

  GetGroupMembersResp._();

  factory GetGroupMembersResp.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetGroupMembersResp.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetGroupMembersResp',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'),
      createEmptyInstance: create)
    ..pPM<GroupMember>(1, _omitFieldNames ? '' : 'members',
        subBuilder: GroupMember.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetGroupMembersResp clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetGroupMembersResp copyWith(void Function(GetGroupMembersResp) updates) =>
      super.copyWith((message) => updates(message as GetGroupMembersResp))
          as GetGroupMembersResp;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetGroupMembersResp create() => GetGroupMembersResp._();
  @$core.override
  GetGroupMembersResp createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetGroupMembersResp getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetGroupMembersResp>(create);
  static GetGroupMembersResp? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<GroupMember> get members => $_getList(0);
}

class GroupMember extends $pb.GeneratedMessage {
  factory GroupMember({
    $fixnum.Int64? userId,
    $core.String? nickname,
    $core.int? sex,
    $core.String? avatarUrl,
    $core.String? userExtra,
    MemberType? memberType,
    $core.String? remarks,
    $core.String? extra,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (nickname != null) result.nickname = nickname;
    if (sex != null) result.sex = sex;
    if (avatarUrl != null) result.avatarUrl = avatarUrl;
    if (userExtra != null) result.userExtra = userExtra;
    if (memberType != null) result.memberType = memberType;
    if (remarks != null) result.remarks = remarks;
    if (extra != null) result.extra = extra;
    return result;
  }

  GroupMember._();

  factory GroupMember.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GroupMember.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GroupMember',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'nickname')
    ..aI(3, _omitFieldNames ? '' : 'sex')
    ..aOS(4, _omitFieldNames ? '' : 'avatarUrl')
    ..aOS(5, _omitFieldNames ? '' : 'userExtra')
    ..aE<MemberType>(6, _omitFieldNames ? '' : 'memberType',
        enumValues: MemberType.values)
    ..aOS(7, _omitFieldNames ? '' : 'remarks')
    ..aOS(8, _omitFieldNames ? '' : 'extra')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GroupMember clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GroupMember copyWith(void Function(GroupMember) updates) =>
      super.copyWith((message) => updates(message as GroupMember))
          as GroupMember;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GroupMember create() => GroupMember._();
  @$core.override
  GroupMember createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GroupMember getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GroupMember>(create);
  static GroupMember? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get userId => $_getI64(0);
  @$pb.TagNumber(1)
  set userId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get nickname => $_getSZ(1);
  @$pb.TagNumber(2)
  set nickname($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNickname() => $_has(1);
  @$pb.TagNumber(2)
  void clearNickname() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get sex => $_getIZ(2);
  @$pb.TagNumber(3)
  set sex($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSex() => $_has(2);
  @$pb.TagNumber(3)
  void clearSex() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get avatarUrl => $_getSZ(3);
  @$pb.TagNumber(4)
  set avatarUrl($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAvatarUrl() => $_has(3);
  @$pb.TagNumber(4)
  void clearAvatarUrl() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get userExtra => $_getSZ(4);
  @$pb.TagNumber(5)
  set userExtra($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasUserExtra() => $_has(4);
  @$pb.TagNumber(5)
  void clearUserExtra() => $_clearField(5);

  @$pb.TagNumber(6)
  MemberType get memberType => $_getN(5);
  @$pb.TagNumber(6)
  set memberType(MemberType value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasMemberType() => $_has(5);
  @$pb.TagNumber(6)
  void clearMemberType() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get remarks => $_getSZ(6);
  @$pb.TagNumber(7)
  set remarks($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasRemarks() => $_has(6);
  @$pb.TagNumber(7)
  void clearRemarks() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get extra => $_getSZ(7);
  @$pb.TagNumber(8)
  set extra($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasExtra() => $_has(7);
  @$pb.TagNumber(8)
  void clearExtra() => $_clearField(8);
}

class LogicExtApi {
  final $pb.RpcClient _client;

  LogicExtApi(this._client);

  /// 注册设备
  $async.Future<RegisterDeviceResp> registerDevice(
          $pb.ClientContext? ctx, RegisterDeviceReq request) =>
      _client.invoke<RegisterDeviceResp>(
          ctx, 'LogicExt', 'RegisterDevice', request, RegisterDeviceResp());

  /// 推送消息到房间
  $async.Future<$0.Empty> pushRoom(
          $pb.ClientContext? ctx, PushRoomReq request) =>
      _client.invoke<$0.Empty>(
          ctx, 'LogicExt', 'PushRoom', request, $0.Empty());

  /// 发送好友消息
  $async.Future<SendMessageResp> sendMessageToFriend(
          $pb.ClientContext? ctx, SendMessageReq request) =>
      _client.invoke<SendMessageResp>(
          ctx, 'LogicExt', 'SendMessageToFriend', request, SendMessageResp());

  /// 添加好友
  $async.Future<$0.Empty> addFriend(
          $pb.ClientContext? ctx, AddFriendReq request) =>
      _client.invoke<$0.Empty>(
          ctx, 'LogicExt', 'AddFriend', request, $0.Empty());

  /// 同意添加好友
  $async.Future<$0.Empty> agreeAddFriend(
          $pb.ClientContext? ctx, AgreeAddFriendReq request) =>
      _client.invoke<$0.Empty>(
          ctx, 'LogicExt', 'AgreeAddFriend', request, $0.Empty());

  /// 设置好友信息
  $async.Future<SetFriendResp> setFriend(
          $pb.ClientContext? ctx, SetFriendReq request) =>
      _client.invoke<SetFriendResp>(
          ctx, 'LogicExt', 'SetFriend', request, SetFriendResp());

  /// 获取好友列表
  $async.Future<GetFriendsResp> getFriends(
          $pb.ClientContext? ctx, $0.Empty request) =>
      _client.invoke<GetFriendsResp>(
          ctx, 'LogicExt', 'GetFriends', request, GetFriendsResp());

  /// 发送群组消息
  $async.Future<SendMessageResp> sendMessageToGroup(
          $pb.ClientContext? ctx, SendMessageReq request) =>
      _client.invoke<SendMessageResp>(
          ctx, 'LogicExt', 'SendMessageToGroup', request, SendMessageResp());

  /// 创建群组
  $async.Future<CreateGroupResp> createGroup(
          $pb.ClientContext? ctx, CreateGroupReq request) =>
      _client.invoke<CreateGroupResp>(
          ctx, 'LogicExt', 'CreateGroup', request, CreateGroupResp());

  /// 更新群组
  $async.Future<$0.Empty> updateGroup(
          $pb.ClientContext? ctx, UpdateGroupReq request) =>
      _client.invoke<$0.Empty>(
          ctx, 'LogicExt', 'UpdateGroup', request, $0.Empty());

  /// 获取群组信息
  $async.Future<GetGroupResp> getGroup(
          $pb.ClientContext? ctx, GetGroupReq request) =>
      _client.invoke<GetGroupResp>(
          ctx, 'LogicExt', 'GetGroup', request, GetGroupResp());

  /// 获取用户加入的所有群组
  $async.Future<GetGroupsResp> getGroups(
          $pb.ClientContext? ctx, $0.Empty request) =>
      _client.invoke<GetGroupsResp>(
          ctx, 'LogicExt', 'GetGroups', request, GetGroupsResp());

  /// 添加群组成员
  $async.Future<AddGroupMembersResp> addGroupMembers(
          $pb.ClientContext? ctx, AddGroupMembersReq request) =>
      _client.invoke<AddGroupMembersResp>(
          ctx, 'LogicExt', 'AddGroupMembers', request, AddGroupMembersResp());

  /// 更新群组成员信息
  $async.Future<$0.Empty> updateGroupMember(
          $pb.ClientContext? ctx, UpdateGroupMemberReq request) =>
      _client.invoke<$0.Empty>(
          ctx, 'LogicExt', 'UpdateGroupMember', request, $0.Empty());

  /// 添加群组成员
  $async.Future<$0.Empty> deleteGroupMember(
          $pb.ClientContext? ctx, DeleteGroupMemberReq request) =>
      _client.invoke<$0.Empty>(
          ctx, 'LogicExt', 'DeleteGroupMember', request, $0.Empty());

  /// 获取群组成员
  $async.Future<GetGroupMembersResp> getGroupMembers(
          $pb.ClientContext? ctx, GetGroupMembersReq request) =>
      _client.invoke<GetGroupMembersResp>(
          ctx, 'LogicExt', 'GetGroupMembers', request, GetGroupMembersResp());
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
