//
//  Generated code. Do not modify.
//  source: business.ext.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types
// ignore_for_file: constant_identifier_names
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'business.ext.pb.dart' as $1;
import 'business.ext.pbjson.dart';
import 'google/protobuf/empty.pb.dart' as $0;

export 'business.ext.pb.dart';

abstract class BusinessExtServiceBase extends $pb.GeneratedService {
  $async.Future<$1.SignInResp> signIn($pb.ServerContext ctx, $1.SignInReq request);
  $async.Future<$1.GetUserResp> getUser($pb.ServerContext ctx, $1.GetUserReq request);
  $async.Future<$0.Empty> updateUser($pb.ServerContext ctx, $1.UpdateUserReq request);
  $async.Future<$1.SearchUserResp> searchUser($pb.ServerContext ctx, $1.SearchUserReq request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'SignIn': return $1.SignInReq();
      case 'GetUser': return $1.GetUserReq();
      case 'UpdateUser': return $1.UpdateUserReq();
      case 'SearchUser': return $1.SearchUserReq();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'SignIn': return this.signIn(ctx, request as $1.SignInReq);
      case 'GetUser': return this.getUser(ctx, request as $1.GetUserReq);
      case 'UpdateUser': return this.updateUser(ctx, request as $1.UpdateUserReq);
      case 'SearchUser': return this.searchUser(ctx, request as $1.SearchUserReq);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => BusinessExtServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => BusinessExtServiceBase$messageJson;
}

