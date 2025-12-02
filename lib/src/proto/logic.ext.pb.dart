//
//  Generated code. Do not modify.
//  source: logic.ext.proto
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

import 'google/protobuf/empty.pb.dart' as $0;
import 'logic.ext.pbenum.dart';

export 'logic.ext.pbenum.dart';

class RegisterDeviceReq extends $pb.GeneratedMessage {
  factory RegisterDeviceReq() => create();
  RegisterDeviceReq._() : super();
  factory RegisterDeviceReq.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory RegisterDeviceReq.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RegisterDeviceReq', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'type', $pb.PbFieldType.O3)
    ..aOS(3, _omitFieldNames ? '' : 'brand')
    ..aOS(4, _omitFieldNames ? '' : 'model')
    ..aOS(5, _omitFieldNames ? '' : 'systemVersion')
    ..aOS(6, _omitFieldNames ? '' : 'sdkVersion')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  RegisterDeviceReq clone() => RegisterDeviceReq()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  RegisterDeviceReq copyWith(void Function(RegisterDeviceReq) updates) => super.copyWith((message) => updates(message as RegisterDeviceReq)) as RegisterDeviceReq;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RegisterDeviceReq create() => RegisterDeviceReq._();
  RegisterDeviceReq createEmptyInstance() => create();
  static $pb.PbList<RegisterDeviceReq> createRepeated() => $pb.PbList<RegisterDeviceReq>();
  @$core.pragma('dart2js:noInline')
  static RegisterDeviceReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RegisterDeviceReq>(create);
  static RegisterDeviceReq? _defaultInstance;

  @$pb.TagNumber(2)
  $core.int get type => $_getIZ(0);
  @$pb.TagNumber(2)
  set type($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(2)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(2)
  void clearType() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get brand => $_getSZ(1);
  @$pb.TagNumber(3)
  set brand($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(3)
  $core.bool hasBrand() => $_has(1);
  @$pb.TagNumber(3)
  void clearBrand() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get model => $_getSZ(2);
  @$pb.TagNumber(4)
  set model($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(4)
  $core.bool hasModel() => $_has(2);
  @$pb.TagNumber(4)
  void clearModel() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get systemVersion => $_getSZ(3);
  @$pb.TagNumber(5)
  set systemVersion($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(5)
  $core.bool hasSystemVersion() => $_has(3);
  @$pb.TagNumber(5)
  void clearSystemVersion() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get sdkVersion => $_getSZ(4);
  @$pb.TagNumber(6)
  set sdkVersion($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(6)
  $core.bool hasSdkVersion() => $_has(4);
  @$pb.TagNumber(6)
  void clearSdkVersion() => clearField(6);
}

class RegisterDeviceResp extends $pb.GeneratedMessage {
  factory RegisterDeviceResp() => create();
  RegisterDeviceResp._() : super();
  factory RegisterDeviceResp.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory RegisterDeviceResp.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RegisterDeviceResp', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'deviceId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  RegisterDeviceResp clone() => RegisterDeviceResp()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  RegisterDeviceResp copyWith(void Function(RegisterDeviceResp) updates) => super.copyWith((message) => updates(message as RegisterDeviceResp)) as RegisterDeviceResp;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RegisterDeviceResp create() => RegisterDeviceResp._();
  RegisterDeviceResp createEmptyInstance() => create();
  static $pb.PbList<RegisterDeviceResp> createRepeated() => $pb.PbList<RegisterDeviceResp>();
  @$core.pragma('dart2js:noInline')
  static RegisterDeviceResp getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RegisterDeviceResp>(create);
  static RegisterDeviceResp? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get deviceId => $_getI64(0);
  @$pb.TagNumber(1)
  set deviceId($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasDeviceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearDeviceId() => clearField(1);
}

class SendMessageReq extends $pb.GeneratedMessage {
  factory SendMessageReq() => create();
  SendMessageReq._() : super();
  factory SendMessageReq.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SendMessageReq.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SendMessageReq', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'receiverId')
    ..a<$core.List<$core.int>>(2, _omitFieldNames ? '' : 'content', $pb.PbFieldType.OY)
    ..aInt64(3, _omitFieldNames ? '' : 'sendTime')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SendMessageReq clone() => SendMessageReq()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SendMessageReq copyWith(void Function(SendMessageReq) updates) => super.copyWith((message) => updates(message as SendMessageReq)) as SendMessageReq;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SendMessageReq create() => SendMessageReq._();
  SendMessageReq createEmptyInstance() => create();
  static $pb.PbList<SendMessageReq> createRepeated() => $pb.PbList<SendMessageReq>();
  @$core.pragma('dart2js:noInline')
  static SendMessageReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SendMessageReq>(create);
  static SendMessageReq? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get receiverId => $_getI64(0);
  @$pb.TagNumber(1)
  set receiverId($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasReceiverId() => $_has(0);
  @$pb.TagNumber(1)
  void clearReceiverId() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get content => $_getN(1);
  @$pb.TagNumber(2)
  set content($core.List<$core.int> v) { $_setBytes(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasContent() => $_has(1);
  @$pb.TagNumber(2)
  void clearContent() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get sendTime => $_getI64(2);
  @$pb.TagNumber(3)
  set sendTime($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasSendTime() => $_has(2);
  @$pb.TagNumber(3)
  void clearSendTime() => clearField(3);
}

class SendMessageResp extends $pb.GeneratedMessage {
  factory SendMessageResp() => create();
  SendMessageResp._() : super();
  factory SendMessageResp.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SendMessageResp.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SendMessageResp', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'seq')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SendMessageResp clone() => SendMessageResp()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SendMessageResp copyWith(void Function(SendMessageResp) updates) => super.copyWith((message) => updates(message as SendMessageResp)) as SendMessageResp;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SendMessageResp create() => SendMessageResp._();
  SendMessageResp createEmptyInstance() => create();
  static $pb.PbList<SendMessageResp> createRepeated() => $pb.PbList<SendMessageResp>();
  @$core.pragma('dart2js:noInline')
  static SendMessageResp getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SendMessageResp>(create);
  static SendMessageResp? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get seq => $_getI64(0);
  @$pb.TagNumber(1)
  set seq($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSeq() => $_has(0);
  @$pb.TagNumber(1)
  void clearSeq() => clearField(1);
}

class PushRoomReq extends $pb.GeneratedMessage {
  factory PushRoomReq() => create();
  PushRoomReq._() : super();
  factory PushRoomReq.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PushRoomReq.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PushRoomReq', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'roomId')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'code', $pb.PbFieldType.O3)
    ..a<$core.List<$core.int>>(3, _omitFieldNames ? '' : 'content', $pb.PbFieldType.OY)
    ..aInt64(4, _omitFieldNames ? '' : 'sendTime')
    ..aOB(5, _omitFieldNames ? '' : 'isPersist')
    ..aOB(6, _omitFieldNames ? '' : 'isPriority')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PushRoomReq clone() => PushRoomReq()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PushRoomReq copyWith(void Function(PushRoomReq) updates) => super.copyWith((message) => updates(message as PushRoomReq)) as PushRoomReq;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PushRoomReq create() => PushRoomReq._();
  PushRoomReq createEmptyInstance() => create();
  static $pb.PbList<PushRoomReq> createRepeated() => $pb.PbList<PushRoomReq>();
  @$core.pragma('dart2js:noInline')
  static PushRoomReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PushRoomReq>(create);
  static PushRoomReq? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get roomId => $_getI64(0);
  @$pb.TagNumber(1)
  set roomId($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasRoomId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRoomId() => clearField(1);

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
  $fixnum.Int64 get sendTime => $_getI64(3);
  @$pb.TagNumber(4)
  set sendTime($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasSendTime() => $_has(3);
  @$pb.TagNumber(4)
  void clearSendTime() => clearField(4);

  @$pb.TagNumber(5)
  $core.bool get isPersist => $_getBF(4);
  @$pb.TagNumber(5)
  set isPersist($core.bool v) { $_setBool(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasIsPersist() => $_has(4);
  @$pb.TagNumber(5)
  void clearIsPersist() => clearField(5);

  @$pb.TagNumber(6)
  $core.bool get isPriority => $_getBF(5);
  @$pb.TagNumber(6)
  set isPriority($core.bool v) { $_setBool(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasIsPriority() => $_has(5);
  @$pb.TagNumber(6)
  void clearIsPriority() => clearField(6);
}

class AddFriendReq extends $pb.GeneratedMessage {
  factory AddFriendReq() => create();
  AddFriendReq._() : super();
  factory AddFriendReq.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AddFriendReq.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AddFriendReq', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'friendId')
    ..aOS(2, _omitFieldNames ? '' : 'remarks')
    ..aOS(3, _omitFieldNames ? '' : 'description')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AddFriendReq clone() => AddFriendReq()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AddFriendReq copyWith(void Function(AddFriendReq) updates) => super.copyWith((message) => updates(message as AddFriendReq)) as AddFriendReq;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddFriendReq create() => AddFriendReq._();
  AddFriendReq createEmptyInstance() => create();
  static $pb.PbList<AddFriendReq> createRepeated() => $pb.PbList<AddFriendReq>();
  @$core.pragma('dart2js:noInline')
  static AddFriendReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AddFriendReq>(create);
  static AddFriendReq? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get friendId => $_getI64(0);
  @$pb.TagNumber(1)
  set friendId($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasFriendId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFriendId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get remarks => $_getSZ(1);
  @$pb.TagNumber(2)
  set remarks($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasRemarks() => $_has(1);
  @$pb.TagNumber(2)
  void clearRemarks() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get description => $_getSZ(2);
  @$pb.TagNumber(3)
  set description($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasDescription() => $_has(2);
  @$pb.TagNumber(3)
  void clearDescription() => clearField(3);
}

class AgreeAddFriendReq extends $pb.GeneratedMessage {
  factory AgreeAddFriendReq() => create();
  AgreeAddFriendReq._() : super();
  factory AgreeAddFriendReq.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AgreeAddFriendReq.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AgreeAddFriendReq', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'remarks')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AgreeAddFriendReq clone() => AgreeAddFriendReq()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AgreeAddFriendReq copyWith(void Function(AgreeAddFriendReq) updates) => super.copyWith((message) => updates(message as AgreeAddFriendReq)) as AgreeAddFriendReq;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AgreeAddFriendReq create() => AgreeAddFriendReq._();
  AgreeAddFriendReq createEmptyInstance() => create();
  static $pb.PbList<AgreeAddFriendReq> createRepeated() => $pb.PbList<AgreeAddFriendReq>();
  @$core.pragma('dart2js:noInline')
  static AgreeAddFriendReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AgreeAddFriendReq>(create);
  static AgreeAddFriendReq? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get userId => $_getI64(0);
  @$pb.TagNumber(1)
  set userId($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get remarks => $_getSZ(1);
  @$pb.TagNumber(2)
  set remarks($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasRemarks() => $_has(1);
  @$pb.TagNumber(2)
  void clearRemarks() => clearField(2);
}

class SetFriendReq extends $pb.GeneratedMessage {
  factory SetFriendReq() => create();
  SetFriendReq._() : super();
  factory SetFriendReq.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SetFriendReq.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SetFriendReq', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'friendId')
    ..aOS(2, _omitFieldNames ? '' : 'remarks')
    ..aOS(8, _omitFieldNames ? '' : 'extra')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SetFriendReq clone() => SetFriendReq()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SetFriendReq copyWith(void Function(SetFriendReq) updates) => super.copyWith((message) => updates(message as SetFriendReq)) as SetFriendReq;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetFriendReq create() => SetFriendReq._();
  SetFriendReq createEmptyInstance() => create();
  static $pb.PbList<SetFriendReq> createRepeated() => $pb.PbList<SetFriendReq>();
  @$core.pragma('dart2js:noInline')
  static SetFriendReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SetFriendReq>(create);
  static SetFriendReq? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get friendId => $_getI64(0);
  @$pb.TagNumber(1)
  set friendId($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasFriendId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFriendId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get remarks => $_getSZ(1);
  @$pb.TagNumber(2)
  set remarks($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasRemarks() => $_has(1);
  @$pb.TagNumber(2)
  void clearRemarks() => clearField(2);

  @$pb.TagNumber(8)
  $core.String get extra => $_getSZ(2);
  @$pb.TagNumber(8)
  set extra($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(8)
  $core.bool hasExtra() => $_has(2);
  @$pb.TagNumber(8)
  void clearExtra() => clearField(8);
}

class SetFriendResp extends $pb.GeneratedMessage {
  factory SetFriendResp() => create();
  SetFriendResp._() : super();
  factory SetFriendResp.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SetFriendResp.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SetFriendResp', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'friendId')
    ..aOS(2, _omitFieldNames ? '' : 'remarks')
    ..aOS(8, _omitFieldNames ? '' : 'extra')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SetFriendResp clone() => SetFriendResp()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SetFriendResp copyWith(void Function(SetFriendResp) updates) => super.copyWith((message) => updates(message as SetFriendResp)) as SetFriendResp;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetFriendResp create() => SetFriendResp._();
  SetFriendResp createEmptyInstance() => create();
  static $pb.PbList<SetFriendResp> createRepeated() => $pb.PbList<SetFriendResp>();
  @$core.pragma('dart2js:noInline')
  static SetFriendResp getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SetFriendResp>(create);
  static SetFriendResp? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get friendId => $_getI64(0);
  @$pb.TagNumber(1)
  set friendId($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasFriendId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFriendId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get remarks => $_getSZ(1);
  @$pb.TagNumber(2)
  set remarks($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasRemarks() => $_has(1);
  @$pb.TagNumber(2)
  void clearRemarks() => clearField(2);

  @$pb.TagNumber(8)
  $core.String get extra => $_getSZ(2);
  @$pb.TagNumber(8)
  set extra($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(8)
  $core.bool hasExtra() => $_has(2);
  @$pb.TagNumber(8)
  void clearExtra() => clearField(8);
}

class Friend extends $pb.GeneratedMessage {
  factory Friend() => create();
  Friend._() : super();
  factory Friend.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Friend.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Friend', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'phoneNumber')
    ..aOS(3, _omitFieldNames ? '' : 'nickname')
    ..a<$core.int>(4, _omitFieldNames ? '' : 'sex', $pb.PbFieldType.O3)
    ..aOS(5, _omitFieldNames ? '' : 'avatarUrl')
    ..aOS(6, _omitFieldNames ? '' : 'userExtra')
    ..aOS(7, _omitFieldNames ? '' : 'remarks')
    ..aOS(8, _omitFieldNames ? '' : 'extra')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Friend clone() => Friend()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Friend copyWith(void Function(Friend) updates) => super.copyWith((message) => updates(message as Friend)) as Friend;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Friend create() => Friend._();
  Friend createEmptyInstance() => create();
  static $pb.PbList<Friend> createRepeated() => $pb.PbList<Friend>();
  @$core.pragma('dart2js:noInline')
  static Friend getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Friend>(create);
  static Friend? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get userId => $_getI64(0);
  @$pb.TagNumber(1)
  set userId($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get phoneNumber => $_getSZ(1);
  @$pb.TagNumber(2)
  set phoneNumber($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasPhoneNumber() => $_has(1);
  @$pb.TagNumber(2)
  void clearPhoneNumber() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get nickname => $_getSZ(2);
  @$pb.TagNumber(3)
  set nickname($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasNickname() => $_has(2);
  @$pb.TagNumber(3)
  void clearNickname() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get sex => $_getIZ(3);
  @$pb.TagNumber(4)
  set sex($core.int v) { $_setSignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasSex() => $_has(3);
  @$pb.TagNumber(4)
  void clearSex() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get avatarUrl => $_getSZ(4);
  @$pb.TagNumber(5)
  set avatarUrl($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasAvatarUrl() => $_has(4);
  @$pb.TagNumber(5)
  void clearAvatarUrl() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get userExtra => $_getSZ(5);
  @$pb.TagNumber(6)
  set userExtra($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasUserExtra() => $_has(5);
  @$pb.TagNumber(6)
  void clearUserExtra() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get remarks => $_getSZ(6);
  @$pb.TagNumber(7)
  set remarks($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasRemarks() => $_has(6);
  @$pb.TagNumber(7)
  void clearRemarks() => clearField(7);

  @$pb.TagNumber(8)
  $core.String get extra => $_getSZ(7);
  @$pb.TagNumber(8)
  set extra($core.String v) { $_setString(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasExtra() => $_has(7);
  @$pb.TagNumber(8)
  void clearExtra() => clearField(8);
}

class GetFriendsResp extends $pb.GeneratedMessage {
  factory GetFriendsResp() => create();
  GetFriendsResp._() : super();
  factory GetFriendsResp.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetFriendsResp.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetFriendsResp', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..pc<Friend>(1, _omitFieldNames ? '' : 'friends', $pb.PbFieldType.PM, subBuilder: Friend.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetFriendsResp clone() => GetFriendsResp()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetFriendsResp copyWith(void Function(GetFriendsResp) updates) => super.copyWith((message) => updates(message as GetFriendsResp)) as GetFriendsResp;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetFriendsResp create() => GetFriendsResp._();
  GetFriendsResp createEmptyInstance() => create();
  static $pb.PbList<GetFriendsResp> createRepeated() => $pb.PbList<GetFriendsResp>();
  @$core.pragma('dart2js:noInline')
  static GetFriendsResp getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetFriendsResp>(create);
  static GetFriendsResp? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<Friend> get friends => $_getList(0);
}

class CreateGroupReq extends $pb.GeneratedMessage {
  factory CreateGroupReq() => create();
  CreateGroupReq._() : super();
  factory CreateGroupReq.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateGroupReq.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateGroupReq', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOS(2, _omitFieldNames ? '' : 'avatarUrl')
    ..aOS(3, _omitFieldNames ? '' : 'introduction')
    ..aOS(4, _omitFieldNames ? '' : 'extra')
    ..p<$fixnum.Int64>(5, _omitFieldNames ? '' : 'memberIds', $pb.PbFieldType.K6)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateGroupReq clone() => CreateGroupReq()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateGroupReq copyWith(void Function(CreateGroupReq) updates) => super.copyWith((message) => updates(message as CreateGroupReq)) as CreateGroupReq;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateGroupReq create() => CreateGroupReq._();
  CreateGroupReq createEmptyInstance() => create();
  static $pb.PbList<CreateGroupReq> createRepeated() => $pb.PbList<CreateGroupReq>();
  @$core.pragma('dart2js:noInline')
  static CreateGroupReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateGroupReq>(create);
  static CreateGroupReq? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get avatarUrl => $_getSZ(1);
  @$pb.TagNumber(2)
  set avatarUrl($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasAvatarUrl() => $_has(1);
  @$pb.TagNumber(2)
  void clearAvatarUrl() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get introduction => $_getSZ(2);
  @$pb.TagNumber(3)
  set introduction($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasIntroduction() => $_has(2);
  @$pb.TagNumber(3)
  void clearIntroduction() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get extra => $_getSZ(3);
  @$pb.TagNumber(4)
  set extra($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasExtra() => $_has(3);
  @$pb.TagNumber(4)
  void clearExtra() => clearField(4);

  @$pb.TagNumber(5)
  $core.List<$fixnum.Int64> get memberIds => $_getList(4);
}

class CreateGroupResp extends $pb.GeneratedMessage {
  factory CreateGroupResp() => create();
  CreateGroupResp._() : super();
  factory CreateGroupResp.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateGroupResp.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateGroupResp', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'groupId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateGroupResp clone() => CreateGroupResp()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateGroupResp copyWith(void Function(CreateGroupResp) updates) => super.copyWith((message) => updates(message as CreateGroupResp)) as CreateGroupResp;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateGroupResp create() => CreateGroupResp._();
  CreateGroupResp createEmptyInstance() => create();
  static $pb.PbList<CreateGroupResp> createRepeated() => $pb.PbList<CreateGroupResp>();
  @$core.pragma('dart2js:noInline')
  static CreateGroupResp getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateGroupResp>(create);
  static CreateGroupResp? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get groupId => $_getI64(0);
  @$pb.TagNumber(1)
  set groupId($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasGroupId() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroupId() => clearField(1);
}

class UpdateGroupReq extends $pb.GeneratedMessage {
  factory UpdateGroupReq() => create();
  UpdateGroupReq._() : super();
  factory UpdateGroupReq.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UpdateGroupReq.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UpdateGroupReq', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'groupId')
    ..aOS(2, _omitFieldNames ? '' : 'avatarUrl')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aOS(4, _omitFieldNames ? '' : 'introduction')
    ..aOS(5, _omitFieldNames ? '' : 'extra')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UpdateGroupReq clone() => UpdateGroupReq()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UpdateGroupReq copyWith(void Function(UpdateGroupReq) updates) => super.copyWith((message) => updates(message as UpdateGroupReq)) as UpdateGroupReq;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateGroupReq create() => UpdateGroupReq._();
  UpdateGroupReq createEmptyInstance() => create();
  static $pb.PbList<UpdateGroupReq> createRepeated() => $pb.PbList<UpdateGroupReq>();
  @$core.pragma('dart2js:noInline')
  static UpdateGroupReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UpdateGroupReq>(create);
  static UpdateGroupReq? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get groupId => $_getI64(0);
  @$pb.TagNumber(1)
  set groupId($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasGroupId() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroupId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get avatarUrl => $_getSZ(1);
  @$pb.TagNumber(2)
  set avatarUrl($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasAvatarUrl() => $_has(1);
  @$pb.TagNumber(2)
  void clearAvatarUrl() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get introduction => $_getSZ(3);
  @$pb.TagNumber(4)
  set introduction($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasIntroduction() => $_has(3);
  @$pb.TagNumber(4)
  void clearIntroduction() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get extra => $_getSZ(4);
  @$pb.TagNumber(5)
  set extra($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasExtra() => $_has(4);
  @$pb.TagNumber(5)
  void clearExtra() => clearField(5);
}

class GetGroupReq extends $pb.GeneratedMessage {
  factory GetGroupReq() => create();
  GetGroupReq._() : super();
  factory GetGroupReq.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetGroupReq.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetGroupReq', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'groupId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetGroupReq clone() => GetGroupReq()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetGroupReq copyWith(void Function(GetGroupReq) updates) => super.copyWith((message) => updates(message as GetGroupReq)) as GetGroupReq;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetGroupReq create() => GetGroupReq._();
  GetGroupReq createEmptyInstance() => create();
  static $pb.PbList<GetGroupReq> createRepeated() => $pb.PbList<GetGroupReq>();
  @$core.pragma('dart2js:noInline')
  static GetGroupReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetGroupReq>(create);
  static GetGroupReq? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get groupId => $_getI64(0);
  @$pb.TagNumber(1)
  set groupId($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasGroupId() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroupId() => clearField(1);
}

class GetGroupResp extends $pb.GeneratedMessage {
  factory GetGroupResp() => create();
  GetGroupResp._() : super();
  factory GetGroupResp.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetGroupResp.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetGroupResp', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..aOM<Group>(1, _omitFieldNames ? '' : 'group', subBuilder: Group.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetGroupResp clone() => GetGroupResp()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetGroupResp copyWith(void Function(GetGroupResp) updates) => super.copyWith((message) => updates(message as GetGroupResp)) as GetGroupResp;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetGroupResp create() => GetGroupResp._();
  GetGroupResp createEmptyInstance() => create();
  static $pb.PbList<GetGroupResp> createRepeated() => $pb.PbList<GetGroupResp>();
  @$core.pragma('dart2js:noInline')
  static GetGroupResp getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetGroupResp>(create);
  static GetGroupResp? _defaultInstance;

  @$pb.TagNumber(1)
  Group get group => $_getN(0);
  @$pb.TagNumber(1)
  set group(Group v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasGroup() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroup() => clearField(1);
  @$pb.TagNumber(1)
  Group ensureGroup() => $_ensure(0);
}

class Group extends $pb.GeneratedMessage {
  factory Group() => create();
  Group._() : super();
  factory Group.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Group.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Group', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'groupId')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'avatarUrl')
    ..aOS(4, _omitFieldNames ? '' : 'introduction')
    ..a<$core.int>(5, _omitFieldNames ? '' : 'userMum', $pb.PbFieldType.O3)
    ..aOS(6, _omitFieldNames ? '' : 'extra')
    ..aInt64(7, _omitFieldNames ? '' : 'createTime')
    ..aInt64(8, _omitFieldNames ? '' : 'updateTime')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Group clone() => Group()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Group copyWith(void Function(Group) updates) => super.copyWith((message) => updates(message as Group)) as Group;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Group create() => Group._();
  Group createEmptyInstance() => create();
  static $pb.PbList<Group> createRepeated() => $pb.PbList<Group>();
  @$core.pragma('dart2js:noInline')
  static Group getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Group>(create);
  static Group? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get groupId => $_getI64(0);
  @$pb.TagNumber(1)
  set groupId($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasGroupId() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroupId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get avatarUrl => $_getSZ(2);
  @$pb.TagNumber(3)
  set avatarUrl($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasAvatarUrl() => $_has(2);
  @$pb.TagNumber(3)
  void clearAvatarUrl() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get introduction => $_getSZ(3);
  @$pb.TagNumber(4)
  set introduction($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasIntroduction() => $_has(3);
  @$pb.TagNumber(4)
  void clearIntroduction() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get userMum => $_getIZ(4);
  @$pb.TagNumber(5)
  set userMum($core.int v) { $_setSignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasUserMum() => $_has(4);
  @$pb.TagNumber(5)
  void clearUserMum() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get extra => $_getSZ(5);
  @$pb.TagNumber(6)
  set extra($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasExtra() => $_has(5);
  @$pb.TagNumber(6)
  void clearExtra() => clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get createTime => $_getI64(6);
  @$pb.TagNumber(7)
  set createTime($fixnum.Int64 v) { $_setInt64(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasCreateTime() => $_has(6);
  @$pb.TagNumber(7)
  void clearCreateTime() => clearField(7);

  @$pb.TagNumber(8)
  $fixnum.Int64 get updateTime => $_getI64(7);
  @$pb.TagNumber(8)
  set updateTime($fixnum.Int64 v) { $_setInt64(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasUpdateTime() => $_has(7);
  @$pb.TagNumber(8)
  void clearUpdateTime() => clearField(8);
}

class GetGroupsResp extends $pb.GeneratedMessage {
  factory GetGroupsResp() => create();
  GetGroupsResp._() : super();
  factory GetGroupsResp.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetGroupsResp.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetGroupsResp', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..pc<Group>(1, _omitFieldNames ? '' : 'groups', $pb.PbFieldType.PM, subBuilder: Group.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetGroupsResp clone() => GetGroupsResp()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetGroupsResp copyWith(void Function(GetGroupsResp) updates) => super.copyWith((message) => updates(message as GetGroupsResp)) as GetGroupsResp;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetGroupsResp create() => GetGroupsResp._();
  GetGroupsResp createEmptyInstance() => create();
  static $pb.PbList<GetGroupsResp> createRepeated() => $pb.PbList<GetGroupsResp>();
  @$core.pragma('dart2js:noInline')
  static GetGroupsResp getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetGroupsResp>(create);
  static GetGroupsResp? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<Group> get groups => $_getList(0);
}

class AddGroupMembersReq extends $pb.GeneratedMessage {
  factory AddGroupMembersReq() => create();
  AddGroupMembersReq._() : super();
  factory AddGroupMembersReq.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AddGroupMembersReq.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AddGroupMembersReq', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'groupId')
    ..p<$fixnum.Int64>(2, _omitFieldNames ? '' : 'userIds', $pb.PbFieldType.K6)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AddGroupMembersReq clone() => AddGroupMembersReq()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AddGroupMembersReq copyWith(void Function(AddGroupMembersReq) updates) => super.copyWith((message) => updates(message as AddGroupMembersReq)) as AddGroupMembersReq;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddGroupMembersReq create() => AddGroupMembersReq._();
  AddGroupMembersReq createEmptyInstance() => create();
  static $pb.PbList<AddGroupMembersReq> createRepeated() => $pb.PbList<AddGroupMembersReq>();
  @$core.pragma('dart2js:noInline')
  static AddGroupMembersReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AddGroupMembersReq>(create);
  static AddGroupMembersReq? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get groupId => $_getI64(0);
  @$pb.TagNumber(1)
  set groupId($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasGroupId() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroupId() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$fixnum.Int64> get userIds => $_getList(1);
}

class AddGroupMembersResp extends $pb.GeneratedMessage {
  factory AddGroupMembersResp() => create();
  AddGroupMembersResp._() : super();
  factory AddGroupMembersResp.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AddGroupMembersResp.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AddGroupMembersResp', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..p<$fixnum.Int64>(1, _omitFieldNames ? '' : 'userIds', $pb.PbFieldType.K6)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AddGroupMembersResp clone() => AddGroupMembersResp()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AddGroupMembersResp copyWith(void Function(AddGroupMembersResp) updates) => super.copyWith((message) => updates(message as AddGroupMembersResp)) as AddGroupMembersResp;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddGroupMembersResp create() => AddGroupMembersResp._();
  AddGroupMembersResp createEmptyInstance() => create();
  static $pb.PbList<AddGroupMembersResp> createRepeated() => $pb.PbList<AddGroupMembersResp>();
  @$core.pragma('dart2js:noInline')
  static AddGroupMembersResp getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AddGroupMembersResp>(create);
  static AddGroupMembersResp? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$fixnum.Int64> get userIds => $_getList(0);
}

class UpdateGroupMemberReq extends $pb.GeneratedMessage {
  factory UpdateGroupMemberReq() => create();
  UpdateGroupMemberReq._() : super();
  factory UpdateGroupMemberReq.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UpdateGroupMemberReq.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UpdateGroupMemberReq', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'groupId')
    ..aInt64(2, _omitFieldNames ? '' : 'userId')
    ..e<MemberType>(3, _omitFieldNames ? '' : 'memberType', $pb.PbFieldType.OE, defaultOrMaker: MemberType.GMT_UNKNOWN, valueOf: MemberType.valueOf, enumValues: MemberType.values)
    ..aOS(4, _omitFieldNames ? '' : 'remarks')
    ..aOS(5, _omitFieldNames ? '' : 'extra')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UpdateGroupMemberReq clone() => UpdateGroupMemberReq()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UpdateGroupMemberReq copyWith(void Function(UpdateGroupMemberReq) updates) => super.copyWith((message) => updates(message as UpdateGroupMemberReq)) as UpdateGroupMemberReq;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateGroupMemberReq create() => UpdateGroupMemberReq._();
  UpdateGroupMemberReq createEmptyInstance() => create();
  static $pb.PbList<UpdateGroupMemberReq> createRepeated() => $pb.PbList<UpdateGroupMemberReq>();
  @$core.pragma('dart2js:noInline')
  static UpdateGroupMemberReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UpdateGroupMemberReq>(create);
  static UpdateGroupMemberReq? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get groupId => $_getI64(0);
  @$pb.TagNumber(1)
  set groupId($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasGroupId() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroupId() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get userId => $_getI64(1);
  @$pb.TagNumber(2)
  set userId($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserId() => clearField(2);

  @$pb.TagNumber(3)
  MemberType get memberType => $_getN(2);
  @$pb.TagNumber(3)
  set memberType(MemberType v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasMemberType() => $_has(2);
  @$pb.TagNumber(3)
  void clearMemberType() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get remarks => $_getSZ(3);
  @$pb.TagNumber(4)
  set remarks($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasRemarks() => $_has(3);
  @$pb.TagNumber(4)
  void clearRemarks() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get extra => $_getSZ(4);
  @$pb.TagNumber(5)
  set extra($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasExtra() => $_has(4);
  @$pb.TagNumber(5)
  void clearExtra() => clearField(5);
}

class DeleteGroupMemberReq extends $pb.GeneratedMessage {
  factory DeleteGroupMemberReq() => create();
  DeleteGroupMemberReq._() : super();
  factory DeleteGroupMemberReq.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DeleteGroupMemberReq.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DeleteGroupMemberReq', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'groupId')
    ..aInt64(2, _omitFieldNames ? '' : 'userId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DeleteGroupMemberReq clone() => DeleteGroupMemberReq()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DeleteGroupMemberReq copyWith(void Function(DeleteGroupMemberReq) updates) => super.copyWith((message) => updates(message as DeleteGroupMemberReq)) as DeleteGroupMemberReq;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteGroupMemberReq create() => DeleteGroupMemberReq._();
  DeleteGroupMemberReq createEmptyInstance() => create();
  static $pb.PbList<DeleteGroupMemberReq> createRepeated() => $pb.PbList<DeleteGroupMemberReq>();
  @$core.pragma('dart2js:noInline')
  static DeleteGroupMemberReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DeleteGroupMemberReq>(create);
  static DeleteGroupMemberReq? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get groupId => $_getI64(0);
  @$pb.TagNumber(1)
  set groupId($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasGroupId() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroupId() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get userId => $_getI64(1);
  @$pb.TagNumber(2)
  set userId($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserId() => clearField(2);
}

class GetGroupMembersReq extends $pb.GeneratedMessage {
  factory GetGroupMembersReq() => create();
  GetGroupMembersReq._() : super();
  factory GetGroupMembersReq.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetGroupMembersReq.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetGroupMembersReq', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'groupId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetGroupMembersReq clone() => GetGroupMembersReq()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetGroupMembersReq copyWith(void Function(GetGroupMembersReq) updates) => super.copyWith((message) => updates(message as GetGroupMembersReq)) as GetGroupMembersReq;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetGroupMembersReq create() => GetGroupMembersReq._();
  GetGroupMembersReq createEmptyInstance() => create();
  static $pb.PbList<GetGroupMembersReq> createRepeated() => $pb.PbList<GetGroupMembersReq>();
  @$core.pragma('dart2js:noInline')
  static GetGroupMembersReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetGroupMembersReq>(create);
  static GetGroupMembersReq? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get groupId => $_getI64(0);
  @$pb.TagNumber(1)
  set groupId($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasGroupId() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroupId() => clearField(1);
}

class GetGroupMembersResp extends $pb.GeneratedMessage {
  factory GetGroupMembersResp() => create();
  GetGroupMembersResp._() : super();
  factory GetGroupMembersResp.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetGroupMembersResp.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetGroupMembersResp', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..pc<GroupMember>(1, _omitFieldNames ? '' : 'members', $pb.PbFieldType.PM, subBuilder: GroupMember.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetGroupMembersResp clone() => GetGroupMembersResp()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetGroupMembersResp copyWith(void Function(GetGroupMembersResp) updates) => super.copyWith((message) => updates(message as GetGroupMembersResp)) as GetGroupMembersResp;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetGroupMembersResp create() => GetGroupMembersResp._();
  GetGroupMembersResp createEmptyInstance() => create();
  static $pb.PbList<GetGroupMembersResp> createRepeated() => $pb.PbList<GetGroupMembersResp>();
  @$core.pragma('dart2js:noInline')
  static GetGroupMembersResp getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetGroupMembersResp>(create);
  static GetGroupMembersResp? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<GroupMember> get members => $_getList(0);
}

class GroupMember extends $pb.GeneratedMessage {
  factory GroupMember() => create();
  GroupMember._() : super();
  factory GroupMember.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GroupMember.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GroupMember', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'nickname')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'sex', $pb.PbFieldType.O3)
    ..aOS(4, _omitFieldNames ? '' : 'avatarUrl')
    ..aOS(5, _omitFieldNames ? '' : 'userExtra')
    ..e<MemberType>(6, _omitFieldNames ? '' : 'memberType', $pb.PbFieldType.OE, defaultOrMaker: MemberType.GMT_UNKNOWN, valueOf: MemberType.valueOf, enumValues: MemberType.values)
    ..aOS(7, _omitFieldNames ? '' : 'remarks')
    ..aOS(8, _omitFieldNames ? '' : 'extra')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GroupMember clone() => GroupMember()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GroupMember copyWith(void Function(GroupMember) updates) => super.copyWith((message) => updates(message as GroupMember)) as GroupMember;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GroupMember create() => GroupMember._();
  GroupMember createEmptyInstance() => create();
  static $pb.PbList<GroupMember> createRepeated() => $pb.PbList<GroupMember>();
  @$core.pragma('dart2js:noInline')
  static GroupMember getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GroupMember>(create);
  static GroupMember? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get userId => $_getI64(0);
  @$pb.TagNumber(1)
  set userId($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get nickname => $_getSZ(1);
  @$pb.TagNumber(2)
  set nickname($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasNickname() => $_has(1);
  @$pb.TagNumber(2)
  void clearNickname() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get sex => $_getIZ(2);
  @$pb.TagNumber(3)
  set sex($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasSex() => $_has(2);
  @$pb.TagNumber(3)
  void clearSex() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get avatarUrl => $_getSZ(3);
  @$pb.TagNumber(4)
  set avatarUrl($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasAvatarUrl() => $_has(3);
  @$pb.TagNumber(4)
  void clearAvatarUrl() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get userExtra => $_getSZ(4);
  @$pb.TagNumber(5)
  set userExtra($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasUserExtra() => $_has(4);
  @$pb.TagNumber(5)
  void clearUserExtra() => clearField(5);

  @$pb.TagNumber(6)
  MemberType get memberType => $_getN(5);
  @$pb.TagNumber(6)
  set memberType(MemberType v) { setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasMemberType() => $_has(5);
  @$pb.TagNumber(6)
  void clearMemberType() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get remarks => $_getSZ(6);
  @$pb.TagNumber(7)
  set remarks($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasRemarks() => $_has(6);
  @$pb.TagNumber(7)
  void clearRemarks() => clearField(7);

  @$pb.TagNumber(8)
  $core.String get extra => $_getSZ(7);
  @$pb.TagNumber(8)
  set extra($core.String v) { $_setString(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasExtra() => $_has(7);
  @$pb.TagNumber(8)
  void clearExtra() => clearField(8);
}

class LogicExtApi {
  $pb.RpcClient _client;
  LogicExtApi(this._client);

  $async.Future<RegisterDeviceResp> registerDevice($pb.ClientContext? ctx, RegisterDeviceReq request) =>
    _client.invoke<RegisterDeviceResp>(ctx, 'LogicExt', 'RegisterDevice', request, RegisterDeviceResp())
  ;
  $async.Future<$0.Empty> pushRoom($pb.ClientContext? ctx, PushRoomReq request) =>
    _client.invoke<$0.Empty>(ctx, 'LogicExt', 'PushRoom', request, $0.Empty())
  ;
  $async.Future<SendMessageResp> sendMessageToFriend($pb.ClientContext? ctx, SendMessageReq request) =>
    _client.invoke<SendMessageResp>(ctx, 'LogicExt', 'SendMessageToFriend', request, SendMessageResp())
  ;
  $async.Future<$0.Empty> addFriend($pb.ClientContext? ctx, AddFriendReq request) =>
    _client.invoke<$0.Empty>(ctx, 'LogicExt', 'AddFriend', request, $0.Empty())
  ;
  $async.Future<$0.Empty> agreeAddFriend($pb.ClientContext? ctx, AgreeAddFriendReq request) =>
    _client.invoke<$0.Empty>(ctx, 'LogicExt', 'AgreeAddFriend', request, $0.Empty())
  ;
  $async.Future<SetFriendResp> setFriend($pb.ClientContext? ctx, SetFriendReq request) =>
    _client.invoke<SetFriendResp>(ctx, 'LogicExt', 'SetFriend', request, SetFriendResp())
  ;
  $async.Future<GetFriendsResp> getFriends($pb.ClientContext? ctx, $0.Empty request) =>
    _client.invoke<GetFriendsResp>(ctx, 'LogicExt', 'GetFriends', request, GetFriendsResp())
  ;
  $async.Future<SendMessageResp> sendMessageToGroup($pb.ClientContext? ctx, SendMessageReq request) =>
    _client.invoke<SendMessageResp>(ctx, 'LogicExt', 'SendMessageToGroup', request, SendMessageResp())
  ;
  $async.Future<CreateGroupResp> createGroup($pb.ClientContext? ctx, CreateGroupReq request) =>
    _client.invoke<CreateGroupResp>(ctx, 'LogicExt', 'CreateGroup', request, CreateGroupResp())
  ;
  $async.Future<$0.Empty> updateGroup($pb.ClientContext? ctx, UpdateGroupReq request) =>
    _client.invoke<$0.Empty>(ctx, 'LogicExt', 'UpdateGroup', request, $0.Empty())
  ;
  $async.Future<GetGroupResp> getGroup($pb.ClientContext? ctx, GetGroupReq request) =>
    _client.invoke<GetGroupResp>(ctx, 'LogicExt', 'GetGroup', request, GetGroupResp())
  ;
  $async.Future<GetGroupsResp> getGroups($pb.ClientContext? ctx, $0.Empty request) =>
    _client.invoke<GetGroupsResp>(ctx, 'LogicExt', 'GetGroups', request, GetGroupsResp())
  ;
  $async.Future<AddGroupMembersResp> addGroupMembers($pb.ClientContext? ctx, AddGroupMembersReq request) =>
    _client.invoke<AddGroupMembersResp>(ctx, 'LogicExt', 'AddGroupMembers', request, AddGroupMembersResp())
  ;
  $async.Future<$0.Empty> updateGroupMember($pb.ClientContext? ctx, UpdateGroupMemberReq request) =>
    _client.invoke<$0.Empty>(ctx, 'LogicExt', 'UpdateGroupMember', request, $0.Empty())
  ;
  $async.Future<$0.Empty> deleteGroupMember($pb.ClientContext? ctx, DeleteGroupMemberReq request) =>
    _client.invoke<$0.Empty>(ctx, 'LogicExt', 'DeleteGroupMember', request, $0.Empty())
  ;
  $async.Future<GetGroupMembersResp> getGroupMembers($pb.ClientContext? ctx, GetGroupMembersReq request) =>
    _client.invoke<GetGroupMembersResp>(ctx, 'LogicExt', 'GetGroupMembers', request, GetGroupMembersResp())
  ;
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
