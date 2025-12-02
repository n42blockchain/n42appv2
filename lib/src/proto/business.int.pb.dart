//
//  Generated code. Do not modify.
//  source: business.int.proto
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

import 'business.ext.pb.dart' as $0;
import 'google/protobuf/empty.pb.dart' as $1;

class AuthReq extends $pb.GeneratedMessage {
  factory AuthReq() => create();
  AuthReq._() : super();
  factory AuthReq.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AuthReq.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AuthReq', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'userId')
    ..aInt64(2, _omitFieldNames ? '' : 'deviceId')
    ..aOS(3, _omitFieldNames ? '' : 'token')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AuthReq clone() => AuthReq()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AuthReq copyWith(void Function(AuthReq) updates) => super.copyWith((message) => updates(message as AuthReq)) as AuthReq;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AuthReq create() => AuthReq._();
  AuthReq createEmptyInstance() => create();
  static $pb.PbList<AuthReq> createRepeated() => $pb.PbList<AuthReq>();
  @$core.pragma('dart2js:noInline')
  static AuthReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AuthReq>(create);
  static AuthReq? _defaultInstance;

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
  $core.String get token => $_getSZ(2);
  @$pb.TagNumber(3)
  set token($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasToken() => $_has(2);
  @$pb.TagNumber(3)
  void clearToken() => clearField(3);
}

class GetUsersReq extends $pb.GeneratedMessage {
  factory GetUsersReq() => create();
  GetUsersReq._() : super();
  factory GetUsersReq.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetUsersReq.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetUsersReq', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..m<$fixnum.Int64, $core.int>(1, _omitFieldNames ? '' : 'userIds', entryClassName: 'GetUsersReq.UserIdsEntry', keyFieldType: $pb.PbFieldType.O6, valueFieldType: $pb.PbFieldType.O3, packageName: const $pb.PackageName('pb'))
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetUsersReq clone() => GetUsersReq()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetUsersReq copyWith(void Function(GetUsersReq) updates) => super.copyWith((message) => updates(message as GetUsersReq)) as GetUsersReq;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetUsersReq create() => GetUsersReq._();
  GetUsersReq createEmptyInstance() => create();
  static $pb.PbList<GetUsersReq> createRepeated() => $pb.PbList<GetUsersReq>();
  @$core.pragma('dart2js:noInline')
  static GetUsersReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetUsersReq>(create);
  static GetUsersReq? _defaultInstance;

  @$pb.TagNumber(1)
  $core.Map<$fixnum.Int64, $core.int> get userIds => $_getMap(0);
}

class GetUsersResp extends $pb.GeneratedMessage {
  factory GetUsersResp() => create();
  GetUsersResp._() : super();
  factory GetUsersResp.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetUsersResp.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetUsersResp', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..m<$fixnum.Int64, $0.User>(1, _omitFieldNames ? '' : 'users', entryClassName: 'GetUsersResp.UsersEntry', keyFieldType: $pb.PbFieldType.O6, valueFieldType: $pb.PbFieldType.OM, valueCreator: $0.User.create, valueDefaultOrMaker: $0.User.getDefault, packageName: const $pb.PackageName('pb'))
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetUsersResp clone() => GetUsersResp()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetUsersResp copyWith(void Function(GetUsersResp) updates) => super.copyWith((message) => updates(message as GetUsersResp)) as GetUsersResp;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetUsersResp create() => GetUsersResp._();
  GetUsersResp createEmptyInstance() => create();
  static $pb.PbList<GetUsersResp> createRepeated() => $pb.PbList<GetUsersResp>();
  @$core.pragma('dart2js:noInline')
  static GetUsersResp getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetUsersResp>(create);
  static GetUsersResp? _defaultInstance;

  @$pb.TagNumber(1)
  $core.Map<$fixnum.Int64, $0.User> get users => $_getMap(0);
}

class BusinessIntApi {
  $pb.RpcClient _client;
  BusinessIntApi(this._client);

  $async.Future<$1.Empty> auth($pb.ClientContext? ctx, AuthReq request) =>
    _client.invoke<$1.Empty>(ctx, 'BusinessInt', 'Auth', request, $1.Empty())
  ;
  $async.Future<$0.GetUserResp> getUser($pb.ClientContext? ctx, $0.GetUserReq request) =>
    _client.invoke<$0.GetUserResp>(ctx, 'BusinessInt', 'GetUser', request, $0.GetUserResp())
  ;
  $async.Future<GetUsersResp> getUsers($pb.ClientContext? ctx, GetUsersReq request) =>
    _client.invoke<GetUsersResp>(ctx, 'BusinessInt', 'GetUsers', request, GetUsersResp())
  ;
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
