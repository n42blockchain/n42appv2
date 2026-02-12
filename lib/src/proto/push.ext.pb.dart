// This is a generated file - do not edit.
//
// Generated from push.ext.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'logic.ext.pb.dart' as $0;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'push.ext.pbenum.dart';

class Sender extends $pb.GeneratedMessage {
  factory Sender({
    $fixnum.Int64? userId,
    $fixnum.Int64? deviceId,
    $core.String? avatarUrl,
    $core.String? nickname,
    $core.String? extra,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (deviceId != null) result.deviceId = deviceId;
    if (avatarUrl != null) result.avatarUrl = avatarUrl;
    if (nickname != null) result.nickname = nickname;
    if (extra != null) result.extra = extra;
    return result;
  }

  Sender._();

  factory Sender.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Sender.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Sender',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'),
      createEmptyInstance: create)
    ..aInt64(2, _omitFieldNames ? '' : 'userId')
    ..aInt64(3, _omitFieldNames ? '' : 'deviceId')
    ..aOS(4, _omitFieldNames ? '' : 'avatarUrl')
    ..aOS(5, _omitFieldNames ? '' : 'nickname')
    ..aOS(6, _omitFieldNames ? '' : 'extra')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Sender clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Sender copyWith(void Function(Sender) updates) =>
      super.copyWith((message) => updates(message as Sender)) as Sender;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Sender create() => Sender._();
  @$core.override
  Sender createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Sender getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Sender>(create);
  static Sender? _defaultInstance;

  @$pb.TagNumber(2)
  $fixnum.Int64 get userId => $_getI64(0);
  @$pb.TagNumber(2)
  set userId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(2)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(2)
  void clearUserId() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get deviceId => $_getI64(1);
  @$pb.TagNumber(3)
  set deviceId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(3)
  $core.bool hasDeviceId() => $_has(1);
  @$pb.TagNumber(3)
  void clearDeviceId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get avatarUrl => $_getSZ(2);
  @$pb.TagNumber(4)
  set avatarUrl($core.String value) => $_setString(2, value);
  @$pb.TagNumber(4)
  $core.bool hasAvatarUrl() => $_has(2);
  @$pb.TagNumber(4)
  void clearAvatarUrl() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get nickname => $_getSZ(3);
  @$pb.TagNumber(5)
  set nickname($core.String value) => $_setString(3, value);
  @$pb.TagNumber(5)
  $core.bool hasNickname() => $_has(3);
  @$pb.TagNumber(5)
  void clearNickname() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get extra => $_getSZ(4);
  @$pb.TagNumber(6)
  set extra($core.String value) => $_setString(4, value);
  @$pb.TagNumber(6)
  $core.bool hasExtra() => $_has(4);
  @$pb.TagNumber(6)
  void clearExtra() => $_clearField(6);
}

/// 用户消息 MC_USER_MESSAGE = 100
class UserMessagePush extends $pb.GeneratedMessage {
  factory UserMessagePush({
    Sender? sender,
    $fixnum.Int64? receiverId,
    $core.List<$core.int>? content,
  }) {
    final result = create();
    if (sender != null) result.sender = sender;
    if (receiverId != null) result.receiverId = receiverId;
    if (content != null) result.content = content;
    return result;
  }

  UserMessagePush._();

  factory UserMessagePush.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UserMessagePush.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UserMessagePush',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'),
      createEmptyInstance: create)
    ..aOM<Sender>(1, _omitFieldNames ? '' : 'sender', subBuilder: Sender.create)
    ..aInt64(2, _omitFieldNames ? '' : 'receiverId')
    ..a<$core.List<$core.int>>(
        3, _omitFieldNames ? '' : 'content', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UserMessagePush clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UserMessagePush copyWith(void Function(UserMessagePush) updates) =>
      super.copyWith((message) => updates(message as UserMessagePush))
          as UserMessagePush;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UserMessagePush create() => UserMessagePush._();
  @$core.override
  UserMessagePush createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UserMessagePush getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UserMessagePush>(create);
  static UserMessagePush? _defaultInstance;

  @$pb.TagNumber(1)
  Sender get sender => $_getN(0);
  @$pb.TagNumber(1)
  set sender(Sender value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSender() => $_has(0);
  @$pb.TagNumber(1)
  void clearSender() => $_clearField(1);
  @$pb.TagNumber(1)
  Sender ensureSender() => $_ensure(0);

  @$pb.TagNumber(2)
  $fixnum.Int64 get receiverId => $_getI64(1);
  @$pb.TagNumber(2)
  set receiverId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasReceiverId() => $_has(1);
  @$pb.TagNumber(2)
  void clearReceiverId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get content => $_getN(2);
  @$pb.TagNumber(3)
  set content($core.List<$core.int> value) => $_setBytes(2, value);
  @$pb.TagNumber(3)
  $core.bool hasContent() => $_has(2);
  @$pb.TagNumber(3)
  void clearContent() => $_clearField(3);
}

/// 添加好友 PC_ADD_FRIEND = 110
class AddFriendPush extends $pb.GeneratedMessage {
  factory AddFriendPush({
    $core.String? friendId,
    $core.String? nickname,
    $core.String? avatarUrl,
    $core.String? description,
  }) {
    final result = create();
    if (friendId != null) result.friendId = friendId;
    if (nickname != null) result.nickname = nickname;
    if (avatarUrl != null) result.avatarUrl = avatarUrl;
    if (description != null) result.description = description;
    return result;
  }

  AddFriendPush._();

  factory AddFriendPush.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AddFriendPush.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AddFriendPush',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'friendId')
    ..aOS(2, _omitFieldNames ? '' : 'nickname')
    ..aOS(3, _omitFieldNames ? '' : 'avatarUrl')
    ..aOS(4, _omitFieldNames ? '' : 'description')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddFriendPush clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddFriendPush copyWith(void Function(AddFriendPush) updates) =>
      super.copyWith((message) => updates(message as AddFriendPush))
          as AddFriendPush;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddFriendPush create() => AddFriendPush._();
  @$core.override
  AddFriendPush createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AddFriendPush getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AddFriendPush>(create);
  static AddFriendPush? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get friendId => $_getSZ(0);
  @$pb.TagNumber(1)
  set friendId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFriendId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFriendId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get nickname => $_getSZ(1);
  @$pb.TagNumber(2)
  set nickname($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNickname() => $_has(1);
  @$pb.TagNumber(2)
  void clearNickname() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get avatarUrl => $_getSZ(2);
  @$pb.TagNumber(3)
  set avatarUrl($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAvatarUrl() => $_has(2);
  @$pb.TagNumber(3)
  void clearAvatarUrl() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get description => $_getSZ(3);
  @$pb.TagNumber(4)
  set description($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDescription() => $_has(3);
  @$pb.TagNumber(4)
  void clearDescription() => $_clearField(4);
}

/// 同意 添加好友 PC_AGREE_ADD_FRIEND = 111
class AgreeAddFriendPush extends $pb.GeneratedMessage {
  factory AgreeAddFriendPush({
    $core.String? friendId,
    $core.String? nickname,
    $core.String? avatarUrl,
  }) {
    final result = create();
    if (friendId != null) result.friendId = friendId;
    if (nickname != null) result.nickname = nickname;
    if (avatarUrl != null) result.avatarUrl = avatarUrl;
    return result;
  }

  AgreeAddFriendPush._();

  factory AgreeAddFriendPush.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AgreeAddFriendPush.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AgreeAddFriendPush',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'friendId')
    ..aOS(2, _omitFieldNames ? '' : 'nickname')
    ..aOS(3, _omitFieldNames ? '' : 'avatarUrl')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AgreeAddFriendPush clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AgreeAddFriendPush copyWith(void Function(AgreeAddFriendPush) updates) =>
      super.copyWith((message) => updates(message as AgreeAddFriendPush))
          as AgreeAddFriendPush;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AgreeAddFriendPush create() => AgreeAddFriendPush._();
  @$core.override
  AgreeAddFriendPush createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AgreeAddFriendPush getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AgreeAddFriendPush>(create);
  static AgreeAddFriendPush? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get friendId => $_getSZ(0);
  @$pb.TagNumber(1)
  set friendId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFriendId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFriendId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get nickname => $_getSZ(1);
  @$pb.TagNumber(2)
  set nickname($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNickname() => $_has(1);
  @$pb.TagNumber(2)
  void clearNickname() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get avatarUrl => $_getSZ(2);
  @$pb.TagNumber(3)
  set avatarUrl($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAvatarUrl() => $_has(2);
  @$pb.TagNumber(3)
  void clearAvatarUrl() => $_clearField(3);
}

/// 更新群组 PC_UPDATE_GROUP = 120
class UpdateGroupPush extends $pb.GeneratedMessage {
  factory UpdateGroupPush({
    $fixnum.Int64? optId,
    $core.String? optName,
    $core.String? name,
    $core.String? avatarUrl,
    $core.String? introduction,
    $core.String? extra,
  }) {
    final result = create();
    if (optId != null) result.optId = optId;
    if (optName != null) result.optName = optName;
    if (name != null) result.name = name;
    if (avatarUrl != null) result.avatarUrl = avatarUrl;
    if (introduction != null) result.introduction = introduction;
    if (extra != null) result.extra = extra;
    return result;
  }

  UpdateGroupPush._();

  factory UpdateGroupPush.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateGroupPush.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateGroupPush',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'optId')
    ..aOS(2, _omitFieldNames ? '' : 'optName')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aOS(4, _omitFieldNames ? '' : 'avatarUrl')
    ..aOS(5, _omitFieldNames ? '' : 'introduction')
    ..aOS(6, _omitFieldNames ? '' : 'extra')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateGroupPush clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateGroupPush copyWith(void Function(UpdateGroupPush) updates) =>
      super.copyWith((message) => updates(message as UpdateGroupPush))
          as UpdateGroupPush;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateGroupPush create() => UpdateGroupPush._();
  @$core.override
  UpdateGroupPush createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateGroupPush getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateGroupPush>(create);
  static UpdateGroupPush? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get optId => $_getI64(0);
  @$pb.TagNumber(1)
  set optId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasOptId() => $_has(0);
  @$pb.TagNumber(1)
  void clearOptId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get optName => $_getSZ(1);
  @$pb.TagNumber(2)
  set optName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasOptName() => $_has(1);
  @$pb.TagNumber(2)
  void clearOptName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get avatarUrl => $_getSZ(3);
  @$pb.TagNumber(4)
  set avatarUrl($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAvatarUrl() => $_has(3);
  @$pb.TagNumber(4)
  void clearAvatarUrl() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get introduction => $_getSZ(4);
  @$pb.TagNumber(5)
  set introduction($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasIntroduction() => $_has(4);
  @$pb.TagNumber(5)
  void clearIntroduction() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get extra => $_getSZ(5);
  @$pb.TagNumber(6)
  set extra($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasExtra() => $_has(5);
  @$pb.TagNumber(6)
  void clearExtra() => $_clearField(6);
}

/// 添加群组成员 PC_AGREE_ADD_GROUPS = 121
class AddGroupMembersPush extends $pb.GeneratedMessage {
  factory AddGroupMembersPush({
    $fixnum.Int64? optId,
    $core.String? optName,
    $core.Iterable<$0.GroupMember>? members,
  }) {
    final result = create();
    if (optId != null) result.optId = optId;
    if (optName != null) result.optName = optName;
    if (members != null) result.members.addAll(members);
    return result;
  }

  AddGroupMembersPush._();

  factory AddGroupMembersPush.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AddGroupMembersPush.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AddGroupMembersPush',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'optId')
    ..aOS(2, _omitFieldNames ? '' : 'optName')
    ..pPM<$0.GroupMember>(3, _omitFieldNames ? '' : 'members',
        subBuilder: $0.GroupMember.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddGroupMembersPush clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddGroupMembersPush copyWith(void Function(AddGroupMembersPush) updates) =>
      super.copyWith((message) => updates(message as AddGroupMembersPush))
          as AddGroupMembersPush;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddGroupMembersPush create() => AddGroupMembersPush._();
  @$core.override
  AddGroupMembersPush createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AddGroupMembersPush getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AddGroupMembersPush>(create);
  static AddGroupMembersPush? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get optId => $_getI64(0);
  @$pb.TagNumber(1)
  set optId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasOptId() => $_has(0);
  @$pb.TagNumber(1)
  void clearOptId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get optName => $_getSZ(1);
  @$pb.TagNumber(2)
  set optName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasOptName() => $_has(1);
  @$pb.TagNumber(2)
  void clearOptName() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<$0.GroupMember> get members => $_getList(2);
}

/// 删除群组成员 PC_REMOVE_GROUP_MEMBER = 122
class RemoveGroupMemberPush extends $pb.GeneratedMessage {
  factory RemoveGroupMemberPush({
    $fixnum.Int64? optId,
    $core.String? optName,
    $fixnum.Int64? deletedUserId,
  }) {
    final result = create();
    if (optId != null) result.optId = optId;
    if (optName != null) result.optName = optName;
    if (deletedUserId != null) result.deletedUserId = deletedUserId;
    return result;
  }

  RemoveGroupMemberPush._();

  factory RemoveGroupMemberPush.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RemoveGroupMemberPush.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RemoveGroupMemberPush',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'optId')
    ..aOS(2, _omitFieldNames ? '' : 'optName')
    ..aInt64(3, _omitFieldNames ? '' : 'deletedUserId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveGroupMemberPush clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveGroupMemberPush copyWith(
          void Function(RemoveGroupMemberPush) updates) =>
      super.copyWith((message) => updates(message as RemoveGroupMemberPush))
          as RemoveGroupMemberPush;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RemoveGroupMemberPush create() => RemoveGroupMemberPush._();
  @$core.override
  RemoveGroupMemberPush createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RemoveGroupMemberPush getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RemoveGroupMemberPush>(create);
  static RemoveGroupMemberPush? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get optId => $_getI64(0);
  @$pb.TagNumber(1)
  set optId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasOptId() => $_has(0);
  @$pb.TagNumber(1)
  void clearOptId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get optName => $_getSZ(1);
  @$pb.TagNumber(2)
  set optName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasOptName() => $_has(1);
  @$pb.TagNumber(2)
  void clearOptName() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get deletedUserId => $_getI64(2);
  @$pb.TagNumber(3)
  set deletedUserId($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDeletedUserId() => $_has(2);
  @$pb.TagNumber(3)
  void clearDeletedUserId() => $_clearField(3);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
