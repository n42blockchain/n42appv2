// This is a generated file - do not edit.
//
// Generated from business.ext.proto.

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

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class SignInReq extends $pb.GeneratedMessage {
  factory SignInReq({
    $core.String? phoneNumber,
    $core.String? code,
    $fixnum.Int64? deviceId,
  }) {
    final result = create();
    if (phoneNumber != null) result.phoneNumber = phoneNumber;
    if (code != null) result.code = code;
    if (deviceId != null) result.deviceId = deviceId;
    return result;
  }

  SignInReq._();

  factory SignInReq.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SignInReq.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SignInReq',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'phoneNumber')
    ..aOS(2, _omitFieldNames ? '' : 'code')
    ..aInt64(3, _omitFieldNames ? '' : 'deviceId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SignInReq clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SignInReq copyWith(void Function(SignInReq) updates) =>
      super.copyWith((message) => updates(message as SignInReq)) as SignInReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SignInReq create() => SignInReq._();
  @$core.override
  SignInReq createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SignInReq getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SignInReq>(create);
  static SignInReq? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get phoneNumber => $_getSZ(0);
  @$pb.TagNumber(1)
  set phoneNumber($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPhoneNumber() => $_has(0);
  @$pb.TagNumber(1)
  void clearPhoneNumber() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get code => $_getSZ(1);
  @$pb.TagNumber(2)
  set code($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCode() => $_has(1);
  @$pb.TagNumber(2)
  void clearCode() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get deviceId => $_getI64(2);
  @$pb.TagNumber(3)
  set deviceId($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDeviceId() => $_has(2);
  @$pb.TagNumber(3)
  void clearDeviceId() => $_clearField(3);
}

class SignInResp extends $pb.GeneratedMessage {
  factory SignInResp({
    $core.bool? isNew,
    $fixnum.Int64? userId,
    $core.String? token,
  }) {
    final result = create();
    if (isNew != null) result.isNew = isNew;
    if (userId != null) result.userId = userId;
    if (token != null) result.token = token;
    return result;
  }

  SignInResp._();

  factory SignInResp.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SignInResp.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SignInResp',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'isNew')
    ..aInt64(2, _omitFieldNames ? '' : 'userId')
    ..aOS(3, _omitFieldNames ? '' : 'token')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SignInResp clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SignInResp copyWith(void Function(SignInResp) updates) =>
      super.copyWith((message) => updates(message as SignInResp)) as SignInResp;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SignInResp create() => SignInResp._();
  @$core.override
  SignInResp createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SignInResp getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SignInResp>(create);
  static SignInResp? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get isNew => $_getBF(0);
  @$pb.TagNumber(1)
  set isNew($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasIsNew() => $_has(0);
  @$pb.TagNumber(1)
  void clearIsNew() => $_clearField(1);

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

class User extends $pb.GeneratedMessage {
  factory User({
    $fixnum.Int64? userId,
    $core.String? nickname,
    $core.int? sex,
    $core.String? avatarUrl,
    $core.String? extra,
    $fixnum.Int64? createTime,
    $fixnum.Int64? updateTime,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (nickname != null) result.nickname = nickname;
    if (sex != null) result.sex = sex;
    if (avatarUrl != null) result.avatarUrl = avatarUrl;
    if (extra != null) result.extra = extra;
    if (createTime != null) result.createTime = createTime;
    if (updateTime != null) result.updateTime = updateTime;
    return result;
  }

  User._();

  factory User.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory User.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'User',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'nickname')
    ..aI(3, _omitFieldNames ? '' : 'sex')
    ..aOS(4, _omitFieldNames ? '' : 'avatarUrl')
    ..aOS(5, _omitFieldNames ? '' : 'extra')
    ..aInt64(6, _omitFieldNames ? '' : 'createTime')
    ..aInt64(7, _omitFieldNames ? '' : 'updateTime')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  User clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  User copyWith(void Function(User) updates) =>
      super.copyWith((message) => updates(message as User)) as User;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static User create() => User._();
  @$core.override
  User createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static User getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<User>(create);
  static User? _defaultInstance;

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
  $core.String get extra => $_getSZ(4);
  @$pb.TagNumber(5)
  set extra($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasExtra() => $_has(4);
  @$pb.TagNumber(5)
  void clearExtra() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get createTime => $_getI64(5);
  @$pb.TagNumber(6)
  set createTime($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasCreateTime() => $_has(5);
  @$pb.TagNumber(6)
  void clearCreateTime() => $_clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get updateTime => $_getI64(6);
  @$pb.TagNumber(7)
  set updateTime($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasUpdateTime() => $_has(6);
  @$pb.TagNumber(7)
  void clearUpdateTime() => $_clearField(7);
}

class GetUserReq extends $pb.GeneratedMessage {
  factory GetUserReq({
    $fixnum.Int64? userId,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    return result;
  }

  GetUserReq._();

  factory GetUserReq.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetUserReq.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetUserReq',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'userId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetUserReq clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetUserReq copyWith(void Function(GetUserReq) updates) =>
      super.copyWith((message) => updates(message as GetUserReq)) as GetUserReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetUserReq create() => GetUserReq._();
  @$core.override
  GetUserReq createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetUserReq getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetUserReq>(create);
  static GetUserReq? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get userId => $_getI64(0);
  @$pb.TagNumber(1)
  set userId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);
}

class GetUserResp extends $pb.GeneratedMessage {
  factory GetUserResp({
    User? user,
  }) {
    final result = create();
    if (user != null) result.user = user;
    return result;
  }

  GetUserResp._();

  factory GetUserResp.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetUserResp.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetUserResp',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'),
      createEmptyInstance: create)
    ..aOM<User>(1, _omitFieldNames ? '' : 'user', subBuilder: User.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetUserResp clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetUserResp copyWith(void Function(GetUserResp) updates) =>
      super.copyWith((message) => updates(message as GetUserResp))
          as GetUserResp;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetUserResp create() => GetUserResp._();
  @$core.override
  GetUserResp createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetUserResp getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetUserResp>(create);
  static GetUserResp? _defaultInstance;

  @$pb.TagNumber(1)
  User get user => $_getN(0);
  @$pb.TagNumber(1)
  set user(User value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasUser() => $_has(0);
  @$pb.TagNumber(1)
  void clearUser() => $_clearField(1);
  @$pb.TagNumber(1)
  User ensureUser() => $_ensure(0);
}

class UpdateUserReq extends $pb.GeneratedMessage {
  factory UpdateUserReq({
    $core.String? nickname,
    $core.int? sex,
    $core.String? avatarUrl,
    $core.String? extra,
  }) {
    final result = create();
    if (nickname != null) result.nickname = nickname;
    if (sex != null) result.sex = sex;
    if (avatarUrl != null) result.avatarUrl = avatarUrl;
    if (extra != null) result.extra = extra;
    return result;
  }

  UpdateUserReq._();

  factory UpdateUserReq.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateUserReq.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateUserReq',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'nickname')
    ..aI(2, _omitFieldNames ? '' : 'sex')
    ..aOS(3, _omitFieldNames ? '' : 'avatarUrl')
    ..aOS(4, _omitFieldNames ? '' : 'extra')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateUserReq clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateUserReq copyWith(void Function(UpdateUserReq) updates) =>
      super.copyWith((message) => updates(message as UpdateUserReq))
          as UpdateUserReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateUserReq create() => UpdateUserReq._();
  @$core.override
  UpdateUserReq createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateUserReq getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateUserReq>(create);
  static UpdateUserReq? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get nickname => $_getSZ(0);
  @$pb.TagNumber(1)
  set nickname($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNickname() => $_has(0);
  @$pb.TagNumber(1)
  void clearNickname() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get sex => $_getIZ(1);
  @$pb.TagNumber(2)
  set sex($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSex() => $_has(1);
  @$pb.TagNumber(2)
  void clearSex() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get avatarUrl => $_getSZ(2);
  @$pb.TagNumber(3)
  set avatarUrl($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAvatarUrl() => $_has(2);
  @$pb.TagNumber(3)
  void clearAvatarUrl() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get extra => $_getSZ(3);
  @$pb.TagNumber(4)
  set extra($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasExtra() => $_has(3);
  @$pb.TagNumber(4)
  void clearExtra() => $_clearField(4);
}

class SearchUserReq extends $pb.GeneratedMessage {
  factory SearchUserReq({
    $core.String? key,
  }) {
    final result = create();
    if (key != null) result.key = key;
    return result;
  }

  SearchUserReq._();

  factory SearchUserReq.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SearchUserReq.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SearchUserReq',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'key')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SearchUserReq clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SearchUserReq copyWith(void Function(SearchUserReq) updates) =>
      super.copyWith((message) => updates(message as SearchUserReq))
          as SearchUserReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SearchUserReq create() => SearchUserReq._();
  @$core.override
  SearchUserReq createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SearchUserReq getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SearchUserReq>(create);
  static SearchUserReq? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get key => $_getSZ(0);
  @$pb.TagNumber(1)
  set key($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearKey() => $_clearField(1);
}

class SearchUserResp extends $pb.GeneratedMessage {
  factory SearchUserResp({
    $core.Iterable<User>? users,
  }) {
    final result = create();
    if (users != null) result.users.addAll(users);
    return result;
  }

  SearchUserResp._();

  factory SearchUserResp.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SearchUserResp.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SearchUserResp',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'),
      createEmptyInstance: create)
    ..pPM<User>(1, _omitFieldNames ? '' : 'users', subBuilder: User.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SearchUserResp clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SearchUserResp copyWith(void Function(SearchUserResp) updates) =>
      super.copyWith((message) => updates(message as SearchUserResp))
          as SearchUserResp;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SearchUserResp create() => SearchUserResp._();
  @$core.override
  SearchUserResp createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SearchUserResp getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SearchUserResp>(create);
  static SearchUserResp? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<User> get users => $_getList(0);
}

class BusinessExtApi {
  final $pb.RpcClient _client;

  BusinessExtApi(this._client);

  /// 登录
  $async.Future<SignInResp> signIn($pb.ClientContext? ctx, SignInReq request) =>
      _client.invoke<SignInResp>(
          ctx, 'BusinessExt', 'SignIn', request, SignInResp());

  /// 获取用户信息
  $async.Future<GetUserResp> getUser(
          $pb.ClientContext? ctx, GetUserReq request) =>
      _client.invoke<GetUserResp>(
          ctx, 'BusinessExt', 'GetUser', request, GetUserResp());

  /// 更新用户信息
  $async.Future<$0.Empty> updateUser(
          $pb.ClientContext? ctx, UpdateUserReq request) =>
      _client.invoke<$0.Empty>(
          ctx, 'BusinessExt', 'UpdateUser', request, $0.Empty());

  /// 搜索用户(这里简单数据库实现，生产环境建议使用ES)
  $async.Future<SearchUserResp> searchUser(
          $pb.ClientContext? ctx, SearchUserReq request) =>
      _client.invoke<SearchUserResp>(
          ctx, 'BusinessExt', 'SearchUser', request, SearchUserResp());
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
