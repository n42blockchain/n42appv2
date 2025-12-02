//
//  Generated code. Do not modify.
//  source: business.int.proto
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

import 'business.ext.pb.dart' as $0;
import 'business.int.pb.dart' as $2;
import 'business.int.pbjson.dart';
import 'google/protobuf/empty.pb.dart' as $1;

export 'business.int.pb.dart';

abstract class BusinessIntServiceBase extends $pb.GeneratedService {
  $async.Future<$1.Empty> auth($pb.ServerContext ctx, $2.AuthReq request);
  $async.Future<$0.GetUserResp> getUser($pb.ServerContext ctx, $0.GetUserReq request);
  $async.Future<$2.GetUsersResp> getUsers($pb.ServerContext ctx, $2.GetUsersReq request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'Auth': return $2.AuthReq();
      case 'GetUser': return $0.GetUserReq();
      case 'GetUsers': return $2.GetUsersReq();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'Auth': return this.auth(ctx, request as $2.AuthReq);
      case 'GetUser': return this.getUser(ctx, request as $0.GetUserReq);
      case 'GetUsers': return this.getUsers(ctx, request as $2.GetUsersReq);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => BusinessIntServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => BusinessIntServiceBase$messageJson;
}

