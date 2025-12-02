//
//  Generated code. Do not modify.
//  source: connect.int.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

import 'google/protobuf/empty.pbjson.dart' as $1;
import 'message.ext.pbjson.dart' as $0;

@$core.Deprecated('Use deliverMessageReqDescriptor instead')
const DeliverMessageReq$json = {
  '1': 'DeliverMessageReq',
  '2': [
    {'1': 'device_id', '3': 1, '4': 1, '5': 3, '10': 'deviceId'},
    {'1': 'message', '3': 2, '4': 1, '5': 11, '6': '.pb.Message', '10': 'message'},
  ],
};

/// Descriptor for `DeliverMessageReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deliverMessageReqDescriptor = $convert.base64Decode(
    'ChFEZWxpdmVyTWVzc2FnZVJlcRIbCglkZXZpY2VfaWQYASABKANSCGRldmljZUlkEiUKB21lc3'
    'NhZ2UYAiABKAsyCy5wYi5NZXNzYWdlUgdtZXNzYWdl');

@$core.Deprecated('Use pushRoomMsgDescriptor instead')
const PushRoomMsg$json = {
  '1': 'PushRoomMsg',
  '2': [
    {'1': 'room_id', '3': 1, '4': 1, '5': 3, '10': 'roomId'},
    {'1': 'message', '3': 2, '4': 1, '5': 11, '6': '.pb.Message', '10': 'message'},
  ],
};

/// Descriptor for `PushRoomMsg`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pushRoomMsgDescriptor = $convert.base64Decode(
    'CgtQdXNoUm9vbU1zZxIXCgdyb29tX2lkGAEgASgDUgZyb29tSWQSJQoHbWVzc2FnZRgCIAEoCz'
    'ILLnBiLk1lc3NhZ2VSB21lc3NhZ2U=');

@$core.Deprecated('Use pushAllMsgDescriptor instead')
const PushAllMsg$json = {
  '1': 'PushAllMsg',
  '2': [
    {'1': 'message', '3': 2, '4': 1, '5': 11, '6': '.pb.Message', '10': 'message'},
  ],
};

/// Descriptor for `PushAllMsg`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pushAllMsgDescriptor = $convert.base64Decode(
    'CgpQdXNoQWxsTXNnEiUKB21lc3NhZ2UYAiABKAsyCy5wYi5NZXNzYWdlUgdtZXNzYWdl');

const $core.Map<$core.String, $core.dynamic> ConnectIntServiceBase$json = {
  '1': 'ConnectInt',
  '2': [
    {'1': 'DeliverMessage', '2': '.pb.DeliverMessageReq', '3': '.google.protobuf.Empty'},
  ],
};

@$core.Deprecated('Use connectIntServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> ConnectIntServiceBase$messageJson = {
  '.pb.DeliverMessageReq': DeliverMessageReq$json,
  '.pb.Message': $0.Message$json,
  '.google.protobuf.Empty': $1.Empty$json,
};

/// Descriptor for `ConnectInt`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List connectIntServiceDescriptor = $convert.base64Decode(
    'CgpDb25uZWN0SW50Ej8KDkRlbGl2ZXJNZXNzYWdlEhUucGIuRGVsaXZlck1lc3NhZ2VSZXEaFi'
    '5nb29nbGUucHJvdG9idWYuRW1wdHk=');

