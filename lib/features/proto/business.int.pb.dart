// This is a generated file - do not edit.
//
// Generated from business.int.proto.

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

import 'business.ext.pb.dart' as $0;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class AuthReq extends $pb.GeneratedMessage {
  factory AuthReq({
    $fixnum.Int64? userId,
    $fixnum.Int64? deviceId,
    $core.String? token,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (deviceId != null) result.deviceId = deviceId;
    if (token != null) result.token = token;
    return result;
  }

  AuthReq._();

  factory AuthReq.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AuthReq.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AuthReq',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'userId')
    ..aInt64(2, _omitFieldNames ? '' : 'deviceId')
    ..aOS(3, _omitFieldNames ? '' : 'token')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AuthReq clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AuthReq copyWith(void Function(AuthReq) updates) =>
      super.copyWith((message) => updates(message as AuthReq)) as AuthReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AuthReq create() => AuthReq._();
  @$core.override
  AuthReq createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AuthReq getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AuthReq>(create);
  static AuthReq? _defaultInstance;

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
  $core.String get token => $_getSZ(2);
  @$pb.TagNumber(3)
  set token($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasToken() => $_has(2);
  @$pb.TagNumber(3)
  void clearToken() => $_clearField(3);
}

class GetUsersReq extends $pb.GeneratedMessage {
  factory GetUsersReq({
    $core.Iterable<$core.MapEntry<$fixnum.Int64, $core.int>>? userIds,
  }) {
    final result = create();
    if (userIds != null) result.userIds.addEntries(userIds);
    return result;
  }

  GetUsersReq._();

  factory GetUsersReq.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetUsersReq.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetUsersReq',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'),
      createEmptyInstance: create)
    ..m<$fixnum.Int64, $core.int>(1, _omitFieldNames ? '' : 'userIds',
        entryClassName: 'GetUsersReq.UserIdsEntry',
        keyFieldType: $pb.PbFieldType.O6,
        valueFieldType: $pb.PbFieldType.O3,
        packageName: const $pb.PackageName('pb'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetUsersReq clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetUsersReq copyWith(void Function(GetUsersReq) updates) =>
      super.copyWith((message) => updates(message as GetUsersReq))
          as GetUsersReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetUsersReq create() => GetUsersReq._();
  @$core.override
  GetUsersReq createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetUsersReq getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetUsersReq>(create);
  static GetUsersReq? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbMap<$fixnum.Int64, $core.int> get userIds => $_getMap(0);
}

class GetUsersResp extends $pb.GeneratedMessage {
  factory GetUsersResp({
    $core.Iterable<$core.MapEntry<$fixnum.Int64, $0.User>>? users,
  }) {
    final result = create();
    if (users != null) result.users.addEntries(users);
    return result;
  }

  GetUsersResp._();

  factory GetUsersResp.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetUsersResp.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetUsersResp',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'),
      createEmptyInstance: create)
    ..m<$fixnum.Int64, $0.User>(1, _omitFieldNames ? '' : 'users',
        entryClassName: 'GetUsersResp.UsersEntry',
        keyFieldType: $pb.PbFieldType.O6,
        valueFieldType: $pb.PbFieldType.OM,
        valueCreator: $0.User.create,
        valueDefaultOrMaker: $0.User.getDefault,
        packageName: const $pb.PackageName('pb'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetUsersResp clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetUsersResp copyWith(void Function(GetUsersResp) updates) =>
      super.copyWith((message) => updates(message as GetUsersResp))
          as GetUsersResp;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetUsersResp create() => GetUsersResp._();
  @$core.override
  GetUsersResp createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetUsersResp getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetUsersResp>(create);
  static GetUsersResp? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbMap<$fixnum.Int64, $0.User> get users => $_getMap(0);
}

class BusinessIntApi {
  final $pb.RpcClient _client;

  BusinessIntApi(this._client);

  /// 权限校验
  $async.Future<$1.Empty> auth($pb.ClientContext? ctx, AuthReq request) =>
      _client.invoke<$1.Empty>(ctx, 'BusinessInt', 'Auth', request, $1.Empty());

  /// 批量获取用户信息
  $async.Future<$0.GetUserResp> getUser(
          $pb.ClientContext? ctx, $0.GetUserReq request) =>
      _client.invoke<$0.GetUserResp>(
          ctx, 'BusinessInt', 'GetUser', request, $0.GetUserResp());

  /// 批量获取用户信息
  $async.Future<GetUsersResp> getUsers(
          $pb.ClientContext? ctx, GetUsersReq request) =>
      _client.invoke<GetUsersResp>(
          ctx, 'BusinessInt', 'GetUsers', request, GetUsersResp());
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
