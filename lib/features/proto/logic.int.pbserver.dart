// This is a generated file - do not edit.
//
// Generated from logic.int.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/empty.pb.dart' as $1;

import 'logic.ext.pb.dart' as $2;
import 'logic.int.pb.dart' as $3;
import 'logic.int.pbjson.dart';

export 'logic.int.pb.dart';

abstract class LogicIntServiceBase extends $pb.GeneratedService {
  $async.Future<$1.Empty> connSignIn(
      $pb.ServerContext ctx, $3.ConnSignInReq request);
  $async.Future<$3.SyncResp> sync($pb.ServerContext ctx, $3.SyncReq request);
  $async.Future<$1.Empty> messageACK(
      $pb.ServerContext ctx, $3.MessageACKReq request);
  $async.Future<$1.Empty> offline($pb.ServerContext ctx, $3.OfflineReq request);
  $async.Future<$1.Empty> subscribeRoom(
      $pb.ServerContext ctx, $3.SubscribeRoomReq request);
  $async.Future<$3.PushResp> push($pb.ServerContext ctx, $3.PushReq request);
  $async.Future<$1.Empty> pushRoom(
      $pb.ServerContext ctx, $2.PushRoomReq request);
  $async.Future<$1.Empty> pushAll($pb.ServerContext ctx, $3.PushAllReq request);
  $async.Future<$3.GetDeviceResp> getDevice(
      $pb.ServerContext ctx, $3.GetDeviceReq request);
  $async.Future<$1.Empty> serverStop(
      $pb.ServerContext ctx, $3.ServerStopReq request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'ConnSignIn':
        return $3.ConnSignInReq();
      case 'Sync':
        return $3.SyncReq();
      case 'MessageACK':
        return $3.MessageACKReq();
      case 'Offline':
        return $3.OfflineReq();
      case 'SubscribeRoom':
        return $3.SubscribeRoomReq();
      case 'Push':
        return $3.PushReq();
      case 'PushRoom':
        return $2.PushRoomReq();
      case 'PushAll':
        return $3.PushAllReq();
      case 'GetDevice':
        return $3.GetDeviceReq();
      case 'ServerStop':
        return $3.ServerStopReq();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx,
      $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'ConnSignIn':
        return connSignIn(ctx, request as $3.ConnSignInReq);
      case 'Sync':
        return sync(ctx, request as $3.SyncReq);
      case 'MessageACK':
        return messageACK(ctx, request as $3.MessageACKReq);
      case 'Offline':
        return offline(ctx, request as $3.OfflineReq);
      case 'SubscribeRoom':
        return subscribeRoom(ctx, request as $3.SubscribeRoomReq);
      case 'Push':
        return push(ctx, request as $3.PushReq);
      case 'PushRoom':
        return pushRoom(ctx, request as $2.PushRoomReq);
      case 'PushAll':
        return pushAll(ctx, request as $3.PushAllReq);
      case 'GetDevice':
        return getDevice(ctx, request as $3.GetDeviceReq);
      case 'ServerStop':
        return serverStop(ctx, request as $3.ServerStopReq);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => LogicIntServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
      get $messageJson => LogicIntServiceBase$messageJson;
}
