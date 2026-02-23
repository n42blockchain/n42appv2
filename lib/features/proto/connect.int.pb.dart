// This is a generated file - do not edit.
//
// Generated from connect.int.proto.

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

import 'message.ext.pb.dart' as $0;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class DeliverMessageReq extends $pb.GeneratedMessage {
  factory DeliverMessageReq({
    $fixnum.Int64? deviceId,
    $0.Message? message,
  }) {
    final result = create();
    if (deviceId != null) result.deviceId = deviceId;
    if (message != null) result.message = message;
    return result;
  }

  DeliverMessageReq._();

  factory DeliverMessageReq.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeliverMessageReq.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeliverMessageReq',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'deviceId')
    ..aOM<$0.Message>(2, _omitFieldNames ? '' : 'message',
        subBuilder: $0.Message.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeliverMessageReq clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeliverMessageReq copyWith(void Function(DeliverMessageReq) updates) =>
      super.copyWith((message) => updates(message as DeliverMessageReq))
          as DeliverMessageReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeliverMessageReq create() => DeliverMessageReq._();
  @$core.override
  DeliverMessageReq createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeliverMessageReq getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeliverMessageReq>(create);
  static DeliverMessageReq? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get deviceId => $_getI64(0);
  @$pb.TagNumber(1)
  set deviceId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDeviceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearDeviceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $0.Message get message => $_getN(1);
  @$pb.TagNumber(2)
  set message($0.Message value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.Message ensureMessage() => $_ensure(1);
}

/// 房间推送
class PushRoomMsg extends $pb.GeneratedMessage {
  factory PushRoomMsg({
    $fixnum.Int64? roomId,
    $0.Message? message,
  }) {
    final result = create();
    if (roomId != null) result.roomId = roomId;
    if (message != null) result.message = message;
    return result;
  }

  PushRoomMsg._();

  factory PushRoomMsg.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PushRoomMsg.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PushRoomMsg',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'roomId')
    ..aOM<$0.Message>(2, _omitFieldNames ? '' : 'message',
        subBuilder: $0.Message.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PushRoomMsg clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PushRoomMsg copyWith(void Function(PushRoomMsg) updates) =>
      super.copyWith((message) => updates(message as PushRoomMsg))
          as PushRoomMsg;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PushRoomMsg create() => PushRoomMsg._();
  @$core.override
  PushRoomMsg createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PushRoomMsg getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PushRoomMsg>(create);
  static PushRoomMsg? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get roomId => $_getI64(0);
  @$pb.TagNumber(1)
  set roomId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRoomId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRoomId() => $_clearField(1);

  @$pb.TagNumber(2)
  $0.Message get message => $_getN(1);
  @$pb.TagNumber(2)
  set message($0.Message value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.Message ensureMessage() => $_ensure(1);
}

/// 房间推送
class PushAllMsg extends $pb.GeneratedMessage {
  factory PushAllMsg({
    $0.Message? message,
  }) {
    final result = create();
    if (message != null) result.message = message;
    return result;
  }

  PushAllMsg._();

  factory PushAllMsg.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PushAllMsg.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PushAllMsg',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'),
      createEmptyInstance: create)
    ..aOM<$0.Message>(2, _omitFieldNames ? '' : 'message',
        subBuilder: $0.Message.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PushAllMsg clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PushAllMsg copyWith(void Function(PushAllMsg) updates) =>
      super.copyWith((message) => updates(message as PushAllMsg)) as PushAllMsg;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PushAllMsg create() => PushAllMsg._();
  @$core.override
  PushAllMsg createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PushAllMsg getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PushAllMsg>(create);
  static PushAllMsg? _defaultInstance;

  @$pb.TagNumber(2)
  $0.Message get message => $_getN(0);
  @$pb.TagNumber(2)
  set message($0.Message value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(0);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.Message ensureMessage() => $_ensure(0);
}

class ConnectIntApi {
  final $pb.RpcClient _client;

  ConnectIntApi(this._client);

  /// 消息投递
  $async.Future<$1.Empty> deliverMessage(
          $pb.ClientContext? ctx, DeliverMessageReq request) =>
      _client.invoke<$1.Empty>(
          ctx, 'ConnectInt', 'DeliverMessage', request, $1.Empty());
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
