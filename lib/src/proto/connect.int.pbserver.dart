//
//  Generated code. Do not modify.
//  source: connect.int.proto
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

import 'connect.int.pb.dart' as $2;
import 'connect.int.pbjson.dart';
import 'google/protobuf/empty.pb.dart' as $1;

export 'connect.int.pb.dart';

abstract class ConnectIntServiceBase extends $pb.GeneratedService {
  $async.Future<$1.Empty> deliverMessage($pb.ServerContext ctx, $2.DeliverMessageReq request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'DeliverMessage': return $2.DeliverMessageReq();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'DeliverMessage': return this.deliverMessage(ctx, request as $2.DeliverMessageReq);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => ConnectIntServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => ConnectIntServiceBase$messageJson;
}

