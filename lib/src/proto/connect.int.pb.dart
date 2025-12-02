//
//  Generated code. Do not modify.
//  source: connect.int.proto
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
import 'message.ext.pb.dart' as $0;

class DeliverMessageReq extends $pb.GeneratedMessage {
  factory DeliverMessageReq() => create();
  DeliverMessageReq._() : super();
  factory DeliverMessageReq.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DeliverMessageReq.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DeliverMessageReq', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'deviceId')
    ..aOM<$0.Message>(2, _omitFieldNames ? '' : 'message', subBuilder: $0.Message.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DeliverMessageReq clone() => DeliverMessageReq()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DeliverMessageReq copyWith(void Function(DeliverMessageReq) updates) => super.copyWith((message) => updates(message as DeliverMessageReq)) as DeliverMessageReq;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeliverMessageReq create() => DeliverMessageReq._();
  DeliverMessageReq createEmptyInstance() => create();
  static $pb.PbList<DeliverMessageReq> createRepeated() => $pb.PbList<DeliverMessageReq>();
  @$core.pragma('dart2js:noInline')
  static DeliverMessageReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DeliverMessageReq>(create);
  static DeliverMessageReq? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get deviceId => $_getI64(0);
  @$pb.TagNumber(1)
  set deviceId($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasDeviceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearDeviceId() => clearField(1);

  @$pb.TagNumber(2)
  $0.Message get message => $_getN(1);
  @$pb.TagNumber(2)
  set message($0.Message v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => clearField(2);
  @$pb.TagNumber(2)
  $0.Message ensureMessage() => $_ensure(1);
}

class PushRoomMsg extends $pb.GeneratedMessage {
  factory PushRoomMsg() => create();
  PushRoomMsg._() : super();
  factory PushRoomMsg.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PushRoomMsg.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PushRoomMsg', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'roomId')
    ..aOM<$0.Message>(2, _omitFieldNames ? '' : 'message', subBuilder: $0.Message.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PushRoomMsg clone() => PushRoomMsg()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PushRoomMsg copyWith(void Function(PushRoomMsg) updates) => super.copyWith((message) => updates(message as PushRoomMsg)) as PushRoomMsg;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PushRoomMsg create() => PushRoomMsg._();
  PushRoomMsg createEmptyInstance() => create();
  static $pb.PbList<PushRoomMsg> createRepeated() => $pb.PbList<PushRoomMsg>();
  @$core.pragma('dart2js:noInline')
  static PushRoomMsg getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PushRoomMsg>(create);
  static PushRoomMsg? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get roomId => $_getI64(0);
  @$pb.TagNumber(1)
  set roomId($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasRoomId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRoomId() => clearField(1);

  @$pb.TagNumber(2)
  $0.Message get message => $_getN(1);
  @$pb.TagNumber(2)
  set message($0.Message v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => clearField(2);
  @$pb.TagNumber(2)
  $0.Message ensureMessage() => $_ensure(1);
}

class PushAllMsg extends $pb.GeneratedMessage {
  factory PushAllMsg() => create();
  PushAllMsg._() : super();
  factory PushAllMsg.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PushAllMsg.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PushAllMsg', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..aOM<$0.Message>(2, _omitFieldNames ? '' : 'message', subBuilder: $0.Message.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PushAllMsg clone() => PushAllMsg()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PushAllMsg copyWith(void Function(PushAllMsg) updates) => super.copyWith((message) => updates(message as PushAllMsg)) as PushAllMsg;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PushAllMsg create() => PushAllMsg._();
  PushAllMsg createEmptyInstance() => create();
  static $pb.PbList<PushAllMsg> createRepeated() => $pb.PbList<PushAllMsg>();
  @$core.pragma('dart2js:noInline')
  static PushAllMsg getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PushAllMsg>(create);
  static PushAllMsg? _defaultInstance;

  @$pb.TagNumber(2)
  $0.Message get message => $_getN(0);
  @$pb.TagNumber(2)
  set message($0.Message v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(0);
  @$pb.TagNumber(2)
  void clearMessage() => clearField(2);
  @$pb.TagNumber(2)
  $0.Message ensureMessage() => $_ensure(0);
}

class ConnectIntApi {
  $pb.RpcClient _client;
  ConnectIntApi(this._client);

  $async.Future<$1.Empty> deliverMessage($pb.ClientContext? ctx, DeliverMessageReq request) =>
    _client.invoke<$1.Empty>(ctx, 'ConnectInt', 'DeliverMessage', request, $1.Empty())
  ;
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
