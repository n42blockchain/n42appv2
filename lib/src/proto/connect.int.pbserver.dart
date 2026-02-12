// This is a generated file - do not edit.
//
// Generated from connect.int.proto.

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

import 'connect.int.pb.dart' as $2;
import 'connect.int.pbjson.dart';

export 'connect.int.pb.dart';

abstract class ConnectIntServiceBase extends $pb.GeneratedService {
  $async.Future<$1.Empty> deliverMessage(
      $pb.ServerContext ctx, $2.DeliverMessageReq request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'DeliverMessage':
        return $2.DeliverMessageReq();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx,
      $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'DeliverMessage':
        return deliverMessage(ctx, request as $2.DeliverMessageReq);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json =>
      ConnectIntServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
      get $messageJson => ConnectIntServiceBase$messageJson;
}
