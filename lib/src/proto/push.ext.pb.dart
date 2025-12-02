//
//  Generated code. Do not modify.
//  source: push.ext.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'logic.ext.pb.dart' as $0;

export 'push.ext.pbenum.dart';

class Sender extends $pb.GeneratedMessage {
  factory Sender() => create();
  Sender._() : super();
  factory Sender.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Sender.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Sender', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..aInt64(2, _omitFieldNames ? '' : 'userId')
    ..aInt64(3, _omitFieldNames ? '' : 'deviceId')
    ..aOS(4, _omitFieldNames ? '' : 'avatarUrl')
    ..aOS(5, _omitFieldNames ? '' : 'nickname')
    ..aOS(6, _omitFieldNames ? '' : 'extra')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Sender clone() => Sender()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Sender copyWith(void Function(Sender) updates) => super.copyWith((message) => updates(message as Sender)) as Sender;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Sender create() => Sender._();
  Sender createEmptyInstance() => create();
  static $pb.PbList<Sender> createRepeated() => $pb.PbList<Sender>();
  @$core.pragma('dart2js:noInline')
  static Sender getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Sender>(create);
  static Sender? _defaultInstance;

  @$pb.TagNumber(2)
  $fixnum.Int64 get userId => $_getI64(0);
  @$pb.TagNumber(2)
  set userId($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(2)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(2)
  void clearUserId() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get deviceId => $_getI64(1);
  @$pb.TagNumber(3)
  set deviceId($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(3)
  $core.bool hasDeviceId() => $_has(1);
  @$pb.TagNumber(3)
  void clearDeviceId() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get avatarUrl => $_getSZ(2);
  @$pb.TagNumber(4)
  set avatarUrl($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(4)
  $core.bool hasAvatarUrl() => $_has(2);
  @$pb.TagNumber(4)
  void clearAvatarUrl() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get nickname => $_getSZ(3);
  @$pb.TagNumber(5)
  set nickname($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(5)
  $core.bool hasNickname() => $_has(3);
  @$pb.TagNumber(5)
  void clearNickname() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get extra => $_getSZ(4);
  @$pb.TagNumber(6)
  set extra($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(6)
  $core.bool hasExtra() => $_has(4);
  @$pb.TagNumber(6)
  void clearExtra() => clearField(6);
}

class UserMessagePush extends $pb.GeneratedMessage {
  factory UserMessagePush() => create();
  UserMessagePush._() : super();
  factory UserMessagePush.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UserMessagePush.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UserMessagePush', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..aOM<Sender>(1, _omitFieldNames ? '' : 'sender', subBuilder: Sender.create)
    ..aInt64(2, _omitFieldNames ? '' : 'receiverId')
    ..a<$core.List<$core.int>>(3, _omitFieldNames ? '' : 'content', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UserMessagePush clone() => UserMessagePush()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UserMessagePush copyWith(void Function(UserMessagePush) updates) => super.copyWith((message) => updates(message as UserMessagePush)) as UserMessagePush;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UserMessagePush create() => UserMessagePush._();
  UserMessagePush createEmptyInstance() => create();
  static $pb.PbList<UserMessagePush> createRepeated() => $pb.PbList<UserMessagePush>();
  @$core.pragma('dart2js:noInline')
  static UserMessagePush getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UserMessagePush>(create);
  static UserMessagePush? _defaultInstance;

  @$pb.TagNumber(1)
  Sender get sender => $_getN(0);
  @$pb.TagNumber(1)
  set sender(Sender v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasSender() => $_has(0);
  @$pb.TagNumber(1)
  void clearSender() => clearField(1);
  @$pb.TagNumber(1)
  Sender ensureSender() => $_ensure(0);

  @$pb.TagNumber(2)
  $fixnum.Int64 get receiverId => $_getI64(1);
  @$pb.TagNumber(2)
  set receiverId($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasReceiverId() => $_has(1);
  @$pb.TagNumber(2)
  void clearReceiverId() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get content => $_getN(2);
  @$pb.TagNumber(3)
  set content($core.List<$core.int> v) { $_setBytes(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasContent() => $_has(2);
  @$pb.TagNumber(3)
  void clearContent() => clearField(3);
}

class AddFriendPush extends $pb.GeneratedMessage {
  factory AddFriendPush() => create();
  AddFriendPush._() : super();
  factory AddFriendPush.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AddFriendPush.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AddFriendPush', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'friendId')
    ..aOS(2, _omitFieldNames ? '' : 'nickname')
    ..aOS(3, _omitFieldNames ? '' : 'avatarUrl')
    ..aOS(4, _omitFieldNames ? '' : 'description')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AddFriendPush clone() => AddFriendPush()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AddFriendPush copyWith(void Function(AddFriendPush) updates) => super.copyWith((message) => updates(message as AddFriendPush)) as AddFriendPush;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddFriendPush create() => AddFriendPush._();
  AddFriendPush createEmptyInstance() => create();
  static $pb.PbList<AddFriendPush> createRepeated() => $pb.PbList<AddFriendPush>();
  @$core.pragma('dart2js:noInline')
  static AddFriendPush getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AddFriendPush>(create);
  static AddFriendPush? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get friendId => $_getSZ(0);
  @$pb.TagNumber(1)
  set friendId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasFriendId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFriendId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get nickname => $_getSZ(1);
  @$pb.TagNumber(2)
  set nickname($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasNickname() => $_has(1);
  @$pb.TagNumber(2)
  void clearNickname() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get avatarUrl => $_getSZ(2);
  @$pb.TagNumber(3)
  set avatarUrl($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasAvatarUrl() => $_has(2);
  @$pb.TagNumber(3)
  void clearAvatarUrl() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get description => $_getSZ(3);
  @$pb.TagNumber(4)
  set description($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasDescription() => $_has(3);
  @$pb.TagNumber(4)
  void clearDescription() => clearField(4);
}

class AgreeAddFriendPush extends $pb.GeneratedMessage {
  factory AgreeAddFriendPush() => create();
  AgreeAddFriendPush._() : super();
  factory AgreeAddFriendPush.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AgreeAddFriendPush.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AgreeAddFriendPush', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'friendId')
    ..aOS(2, _omitFieldNames ? '' : 'nickname')
    ..aOS(3, _omitFieldNames ? '' : 'avatarUrl')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AgreeAddFriendPush clone() => AgreeAddFriendPush()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AgreeAddFriendPush copyWith(void Function(AgreeAddFriendPush) updates) => super.copyWith((message) => updates(message as AgreeAddFriendPush)) as AgreeAddFriendPush;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AgreeAddFriendPush create() => AgreeAddFriendPush._();
  AgreeAddFriendPush createEmptyInstance() => create();
  static $pb.PbList<AgreeAddFriendPush> createRepeated() => $pb.PbList<AgreeAddFriendPush>();
  @$core.pragma('dart2js:noInline')
  static AgreeAddFriendPush getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AgreeAddFriendPush>(create);
  static AgreeAddFriendPush? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get friendId => $_getSZ(0);
  @$pb.TagNumber(1)
  set friendId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasFriendId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFriendId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get nickname => $_getSZ(1);
  @$pb.TagNumber(2)
  set nickname($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasNickname() => $_has(1);
  @$pb.TagNumber(2)
  void clearNickname() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get avatarUrl => $_getSZ(2);
  @$pb.TagNumber(3)
  set avatarUrl($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasAvatarUrl() => $_has(2);
  @$pb.TagNumber(3)
  void clearAvatarUrl() => clearField(3);
}

class UpdateGroupPush extends $pb.GeneratedMessage {
  factory UpdateGroupPush() => create();
  UpdateGroupPush._() : super();
  factory UpdateGroupPush.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UpdateGroupPush.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UpdateGroupPush', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'optId')
    ..aOS(2, _omitFieldNames ? '' : 'optName')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aOS(4, _omitFieldNames ? '' : 'avatarUrl')
    ..aOS(5, _omitFieldNames ? '' : 'introduction')
    ..aOS(6, _omitFieldNames ? '' : 'extra')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UpdateGroupPush clone() => UpdateGroupPush()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UpdateGroupPush copyWith(void Function(UpdateGroupPush) updates) => super.copyWith((message) => updates(message as UpdateGroupPush)) as UpdateGroupPush;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateGroupPush create() => UpdateGroupPush._();
  UpdateGroupPush createEmptyInstance() => create();
  static $pb.PbList<UpdateGroupPush> createRepeated() => $pb.PbList<UpdateGroupPush>();
  @$core.pragma('dart2js:noInline')
  static UpdateGroupPush getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UpdateGroupPush>(create);
  static UpdateGroupPush? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get optId => $_getI64(0);
  @$pb.TagNumber(1)
  set optId($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasOptId() => $_has(0);
  @$pb.TagNumber(1)
  void clearOptId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get optName => $_getSZ(1);
  @$pb.TagNumber(2)
  set optName($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasOptName() => $_has(1);
  @$pb.TagNumber(2)
  void clearOptName() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get avatarUrl => $_getSZ(3);
  @$pb.TagNumber(4)
  set avatarUrl($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasAvatarUrl() => $_has(3);
  @$pb.TagNumber(4)
  void clearAvatarUrl() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get introduction => $_getSZ(4);
  @$pb.TagNumber(5)
  set introduction($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasIntroduction() => $_has(4);
  @$pb.TagNumber(5)
  void clearIntroduction() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get extra => $_getSZ(5);
  @$pb.TagNumber(6)
  set extra($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasExtra() => $_has(5);
  @$pb.TagNumber(6)
  void clearExtra() => clearField(6);
}

class AddGroupMembersPush extends $pb.GeneratedMessage {
  factory AddGroupMembersPush() => create();
  AddGroupMembersPush._() : super();
  factory AddGroupMembersPush.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AddGroupMembersPush.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AddGroupMembersPush', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'optId')
    ..aOS(2, _omitFieldNames ? '' : 'optName')
    ..pc<$0.GroupMember>(3, _omitFieldNames ? '' : 'members', $pb.PbFieldType.PM, subBuilder: $0.GroupMember.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AddGroupMembersPush clone() => AddGroupMembersPush()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AddGroupMembersPush copyWith(void Function(AddGroupMembersPush) updates) => super.copyWith((message) => updates(message as AddGroupMembersPush)) as AddGroupMembersPush;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddGroupMembersPush create() => AddGroupMembersPush._();
  AddGroupMembersPush createEmptyInstance() => create();
  static $pb.PbList<AddGroupMembersPush> createRepeated() => $pb.PbList<AddGroupMembersPush>();
  @$core.pragma('dart2js:noInline')
  static AddGroupMembersPush getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AddGroupMembersPush>(create);
  static AddGroupMembersPush? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get optId => $_getI64(0);
  @$pb.TagNumber(1)
  set optId($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasOptId() => $_has(0);
  @$pb.TagNumber(1)
  void clearOptId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get optName => $_getSZ(1);
  @$pb.TagNumber(2)
  set optName($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasOptName() => $_has(1);
  @$pb.TagNumber(2)
  void clearOptName() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<$0.GroupMember> get members => $_getList(2);
}

class RemoveGroupMemberPush extends $pb.GeneratedMessage {
  factory RemoveGroupMemberPush() => create();
  RemoveGroupMemberPush._() : super();
  factory RemoveGroupMemberPush.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory RemoveGroupMemberPush.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RemoveGroupMemberPush', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'optId')
    ..aOS(2, _omitFieldNames ? '' : 'optName')
    ..aInt64(3, _omitFieldNames ? '' : 'deletedUserId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  RemoveGroupMemberPush clone() => RemoveGroupMemberPush()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  RemoveGroupMemberPush copyWith(void Function(RemoveGroupMemberPush) updates) => super.copyWith((message) => updates(message as RemoveGroupMemberPush)) as RemoveGroupMemberPush;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RemoveGroupMemberPush create() => RemoveGroupMemberPush._();
  RemoveGroupMemberPush createEmptyInstance() => create();
  static $pb.PbList<RemoveGroupMemberPush> createRepeated() => $pb.PbList<RemoveGroupMemberPush>();
  @$core.pragma('dart2js:noInline')
  static RemoveGroupMemberPush getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RemoveGroupMemberPush>(create);
  static RemoveGroupMemberPush? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get optId => $_getI64(0);
  @$pb.TagNumber(1)
  set optId($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasOptId() => $_has(0);
  @$pb.TagNumber(1)
  void clearOptId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get optName => $_getSZ(1);
  @$pb.TagNumber(2)
  set optName($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasOptName() => $_has(1);
  @$pb.TagNumber(2)
  void clearOptName() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get deletedUserId => $_getI64(2);
  @$pb.TagNumber(3)
  set deletedUserId($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasDeletedUserId() => $_has(2);
  @$pb.TagNumber(3)
  void clearDeletedUserId() => clearField(3);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
