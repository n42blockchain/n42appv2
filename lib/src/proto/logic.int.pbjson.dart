//
//  Generated code. Do not modify.
//  source: logic.int.proto
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
import 'logic.ext.pbjson.dart' as $2;
import 'message.ext.pbjson.dart' as $0;

@$core.Deprecated('Use connSignInReqDescriptor instead')
const ConnSignInReq$json = {
  '1': 'ConnSignInReq',
  '2': [
    {'1': 'device_id', '3': 1, '4': 1, '5': 3, '10': 'deviceId'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 3, '10': 'userId'},
    {'1': 'token', '3': 3, '4': 1, '5': 9, '10': 'token'},
    {'1': 'conn_addr', '3': 4, '4': 1, '5': 9, '10': 'connAddr'},
    {'1': 'client_addr', '3': 5, '4': 1, '5': 9, '10': 'clientAddr'},
  ],
};

/// Descriptor for `ConnSignInReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List connSignInReqDescriptor = $convert.base64Decode(
    'Cg1Db25uU2lnbkluUmVxEhsKCWRldmljZV9pZBgBIAEoA1IIZGV2aWNlSWQSFwoHdXNlcl9pZB'
    'gCIAEoA1IGdXNlcklkEhQKBXRva2VuGAMgASgJUgV0b2tlbhIbCgljb25uX2FkZHIYBCABKAlS'
    'CGNvbm5BZGRyEh8KC2NsaWVudF9hZGRyGAUgASgJUgpjbGllbnRBZGRy');

@$core.Deprecated('Use syncReqDescriptor instead')
const SyncReq$json = {
  '1': 'SyncReq',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 3, '10': 'userId'},
    {'1': 'device_id', '3': 2, '4': 1, '5': 3, '10': 'deviceId'},
    {'1': 'seq', '3': 3, '4': 1, '5': 3, '10': 'seq'},
  ],
};

/// Descriptor for `SyncReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List syncReqDescriptor = $convert.base64Decode(
    'CgdTeW5jUmVxEhcKB3VzZXJfaWQYASABKANSBnVzZXJJZBIbCglkZXZpY2VfaWQYAiABKANSCG'
    'RldmljZUlkEhAKA3NlcRgDIAEoA1IDc2Vx');

@$core.Deprecated('Use syncRespDescriptor instead')
const SyncResp$json = {
  '1': 'SyncResp',
  '2': [
    {'1': 'messages', '3': 1, '4': 3, '5': 11, '6': '.pb.Message', '10': 'messages'},
    {'1': 'has_more', '3': 2, '4': 1, '5': 8, '10': 'hasMore'},
  ],
};

/// Descriptor for `SyncResp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List syncRespDescriptor = $convert.base64Decode(
    'CghTeW5jUmVzcBInCghtZXNzYWdlcxgBIAMoCzILLnBiLk1lc3NhZ2VSCG1lc3NhZ2VzEhkKCG'
    'hhc19tb3JlGAIgASgIUgdoYXNNb3Jl');

@$core.Deprecated('Use messageACKReqDescriptor instead')
const MessageACKReq$json = {
  '1': 'MessageACKReq',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 3, '10': 'userId'},
    {'1': 'device_id', '3': 2, '4': 1, '5': 3, '10': 'deviceId'},
    {'1': 'device_ack', '3': 3, '4': 1, '5': 3, '10': 'deviceAck'},
    {'1': 'receive_time', '3': 4, '4': 1, '5': 3, '10': 'receiveTime'},
  ],
};

/// Descriptor for `MessageACKReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List messageACKReqDescriptor = $convert.base64Decode(
    'Cg1NZXNzYWdlQUNLUmVxEhcKB3VzZXJfaWQYASABKANSBnVzZXJJZBIbCglkZXZpY2VfaWQYAi'
    'ABKANSCGRldmljZUlkEh0KCmRldmljZV9hY2sYAyABKANSCWRldmljZUFjaxIhCgxyZWNlaXZl'
    'X3RpbWUYBCABKANSC3JlY2VpdmVUaW1l');

@$core.Deprecated('Use offlineReqDescriptor instead')
const OfflineReq$json = {
  '1': 'OfflineReq',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 3, '10': 'userId'},
    {'1': 'device_id', '3': 2, '4': 1, '5': 3, '10': 'deviceId'},
    {'1': 'client_addr', '3': 3, '4': 1, '5': 9, '10': 'clientAddr'},
  ],
};

/// Descriptor for `OfflineReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List offlineReqDescriptor = $convert.base64Decode(
    'CgpPZmZsaW5lUmVxEhcKB3VzZXJfaWQYASABKANSBnVzZXJJZBIbCglkZXZpY2VfaWQYAiABKA'
    'NSCGRldmljZUlkEh8KC2NsaWVudF9hZGRyGAMgASgJUgpjbGllbnRBZGRy');

@$core.Deprecated('Use subscribeRoomReqDescriptor instead')
const SubscribeRoomReq$json = {
  '1': 'SubscribeRoomReq',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 3, '10': 'userId'},
    {'1': 'device_id', '3': 2, '4': 1, '5': 3, '10': 'deviceId'},
    {'1': 'room_id', '3': 3, '4': 1, '5': 3, '10': 'roomId'},
    {'1': 'seq', '3': 4, '4': 1, '5': 3, '10': 'seq'},
    {'1': 'conn_addr', '3': 5, '4': 1, '5': 9, '10': 'connAddr'},
  ],
};

/// Descriptor for `SubscribeRoomReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List subscribeRoomReqDescriptor = $convert.base64Decode(
    'ChBTdWJzY3JpYmVSb29tUmVxEhcKB3VzZXJfaWQYASABKANSBnVzZXJJZBIbCglkZXZpY2VfaW'
    'QYAiABKANSCGRldmljZUlkEhcKB3Jvb21faWQYAyABKANSBnJvb21JZBIQCgNzZXEYBCABKANS'
    'A3NlcRIbCgljb25uX2FkZHIYBSABKAlSCGNvbm5BZGRy');

@$core.Deprecated('Use pushReqDescriptor instead')
const PushReq$json = {
  '1': 'PushReq',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 3, '10': 'userId'},
    {'1': 'code', '3': 2, '4': 1, '5': 5, '10': 'code'},
    {'1': 'content', '3': 3, '4': 1, '5': 12, '10': 'content'},
    {'1': 'is_persist', '3': 4, '4': 1, '5': 8, '10': 'isPersist'},
  ],
};

/// Descriptor for `PushReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pushReqDescriptor = $convert.base64Decode(
    'CgdQdXNoUmVxEhcKB3VzZXJfaWQYASABKANSBnVzZXJJZBISCgRjb2RlGAIgASgFUgRjb2RlEh'
    'gKB2NvbnRlbnQYAyABKAxSB2NvbnRlbnQSHQoKaXNfcGVyc2lzdBgEIAEoCFIJaXNQZXJzaXN0');

@$core.Deprecated('Use pushRespDescriptor instead')
const PushResp$json = {
  '1': 'PushResp',
  '2': [
    {'1': 'seq', '3': 1, '4': 1, '5': 3, '10': 'seq'},
  ],
};

/// Descriptor for `PushResp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pushRespDescriptor = $convert.base64Decode(
    'CghQdXNoUmVzcBIQCgNzZXEYASABKANSA3NlcQ==');

@$core.Deprecated('Use pushAllReqDescriptor instead')
const PushAllReq$json = {
  '1': 'PushAllReq',
  '2': [
    {'1': 'code', '3': 1, '4': 1, '5': 5, '10': 'code'},
    {'1': 'content', '3': 2, '4': 1, '5': 12, '10': 'content'},
  ],
};

/// Descriptor for `PushAllReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pushAllReqDescriptor = $convert.base64Decode(
    'CgpQdXNoQWxsUmVxEhIKBGNvZGUYASABKAVSBGNvZGUSGAoHY29udGVudBgCIAEoDFIHY29udG'
    'VudA==');

@$core.Deprecated('Use getDeviceReqDescriptor instead')
const GetDeviceReq$json = {
  '1': 'GetDeviceReq',
  '2': [
    {'1': 'device_id', '3': 1, '4': 1, '5': 3, '10': 'deviceId'},
  ],
};

/// Descriptor for `GetDeviceReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getDeviceReqDescriptor = $convert.base64Decode(
    'CgxHZXREZXZpY2VSZXESGwoJZGV2aWNlX2lkGAEgASgDUghkZXZpY2VJZA==');

@$core.Deprecated('Use getDeviceRespDescriptor instead')
const GetDeviceResp$json = {
  '1': 'GetDeviceResp',
  '2': [
    {'1': 'device', '3': 1, '4': 1, '5': 11, '6': '.pb.Device', '10': 'device'},
  ],
};

/// Descriptor for `GetDeviceResp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getDeviceRespDescriptor = $convert.base64Decode(
    'Cg1HZXREZXZpY2VSZXNwEiIKBmRldmljZRgBIAEoCzIKLnBiLkRldmljZVIGZGV2aWNl');

@$core.Deprecated('Use deviceDescriptor instead')
const Device$json = {
  '1': 'Device',
  '2': [
    {'1': 'device_id', '3': 1, '4': 1, '5': 3, '10': 'deviceId'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 3, '10': 'userId'},
    {'1': 'type', '3': 3, '4': 1, '5': 5, '10': 'type'},
    {'1': 'brand', '3': 4, '4': 1, '5': 9, '10': 'brand'},
    {'1': 'model', '3': 5, '4': 1, '5': 9, '10': 'model'},
    {'1': 'system_version', '3': 6, '4': 1, '5': 9, '10': 'systemVersion'},
    {'1': 'sdk_version', '3': 7, '4': 1, '5': 9, '10': 'sdkVersion'},
    {'1': 'status', '3': 8, '4': 1, '5': 5, '10': 'status'},
    {'1': 'conn_addr', '3': 9, '4': 1, '5': 9, '10': 'connAddr'},
    {'1': 'client_addr', '3': 10, '4': 1, '5': 9, '10': 'clientAddr'},
    {'1': 'create_time', '3': 11, '4': 1, '5': 3, '10': 'createTime'},
    {'1': 'update_time', '3': 12, '4': 1, '5': 3, '10': 'updateTime'},
  ],
};

/// Descriptor for `Device`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deviceDescriptor = $convert.base64Decode(
    'CgZEZXZpY2USGwoJZGV2aWNlX2lkGAEgASgDUghkZXZpY2VJZBIXCgd1c2VyX2lkGAIgASgDUg'
    'Z1c2VySWQSEgoEdHlwZRgDIAEoBVIEdHlwZRIUCgVicmFuZBgEIAEoCVIFYnJhbmQSFAoFbW9k'
    'ZWwYBSABKAlSBW1vZGVsEiUKDnN5c3RlbV92ZXJzaW9uGAYgASgJUg1zeXN0ZW1WZXJzaW9uEh'
    '8KC3Nka192ZXJzaW9uGAcgASgJUgpzZGtWZXJzaW9uEhYKBnN0YXR1cxgIIAEoBVIGc3RhdHVz'
    'EhsKCWNvbm5fYWRkchgJIAEoCVIIY29ubkFkZHISHwoLY2xpZW50X2FkZHIYCiABKAlSCmNsaW'
    'VudEFkZHISHwoLY3JlYXRlX3RpbWUYCyABKANSCmNyZWF0ZVRpbWUSHwoLdXBkYXRlX3RpbWUY'
    'DCABKANSCnVwZGF0ZVRpbWU=');

@$core.Deprecated('Use serverStopReqDescriptor instead')
const ServerStopReq$json = {
  '1': 'ServerStopReq',
  '2': [
    {'1': 'conn_addr', '3': 1, '4': 1, '5': 9, '10': 'connAddr'},
  ],
};

/// Descriptor for `ServerStopReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List serverStopReqDescriptor = $convert.base64Decode(
    'Cg1TZXJ2ZXJTdG9wUmVxEhsKCWNvbm5fYWRkchgBIAEoCVIIY29ubkFkZHI=');

const $core.Map<$core.String, $core.dynamic> LogicIntServiceBase$json = {
  '1': 'LogicInt',
  '2': [
    {'1': 'ConnSignIn', '2': '.pb.ConnSignInReq', '3': '.google.protobuf.Empty'},
    {'1': 'Sync', '2': '.pb.SyncReq', '3': '.pb.SyncResp'},
    {'1': 'MessageACK', '2': '.pb.MessageACKReq', '3': '.google.protobuf.Empty'},
    {'1': 'Offline', '2': '.pb.OfflineReq', '3': '.google.protobuf.Empty'},
    {'1': 'SubscribeRoom', '2': '.pb.SubscribeRoomReq', '3': '.google.protobuf.Empty'},
    {'1': 'Push', '2': '.pb.PushReq', '3': '.pb.PushResp'},
    {'1': 'PushRoom', '2': '.pb.PushRoomReq', '3': '.google.protobuf.Empty'},
    {'1': 'PushAll', '2': '.pb.PushAllReq', '3': '.google.protobuf.Empty'},
    {'1': 'GetDevice', '2': '.pb.GetDeviceReq', '3': '.pb.GetDeviceResp'},
    {'1': 'ServerStop', '2': '.pb.ServerStopReq', '3': '.google.protobuf.Empty'},
  ],
};

@$core.Deprecated('Use logicIntServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> LogicIntServiceBase$messageJson = {
  '.pb.ConnSignInReq': ConnSignInReq$json,
  '.google.protobuf.Empty': $1.Empty$json,
  '.pb.SyncReq': SyncReq$json,
  '.pb.SyncResp': SyncResp$json,
  '.pb.Message': $0.Message$json,
  '.pb.MessageACKReq': MessageACKReq$json,
  '.pb.OfflineReq': OfflineReq$json,
  '.pb.SubscribeRoomReq': SubscribeRoomReq$json,
  '.pb.PushReq': PushReq$json,
  '.pb.PushResp': PushResp$json,
  '.pb.PushRoomReq': $2.PushRoomReq$json,
  '.pb.PushAllReq': PushAllReq$json,
  '.pb.GetDeviceReq': GetDeviceReq$json,
  '.pb.GetDeviceResp': GetDeviceResp$json,
  '.pb.Device': Device$json,
  '.pb.ServerStopReq': ServerStopReq$json,
};

/// Descriptor for `LogicInt`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List logicIntServiceDescriptor = $convert.base64Decode(
    'CghMb2dpY0ludBI3CgpDb25uU2lnbkluEhEucGIuQ29ublNpZ25JblJlcRoWLmdvb2dsZS5wcm'
    '90b2J1Zi5FbXB0eRIhCgRTeW5jEgsucGIuU3luY1JlcRoMLnBiLlN5bmNSZXNwEjcKCk1lc3Nh'
    'Z2VBQ0sSES5wYi5NZXNzYWdlQUNLUmVxGhYuZ29vZ2xlLnByb3RvYnVmLkVtcHR5EjEKB09mZm'
    'xpbmUSDi5wYi5PZmZsaW5lUmVxGhYuZ29vZ2xlLnByb3RvYnVmLkVtcHR5Ej0KDVN1YnNjcmli'
    'ZVJvb20SFC5wYi5TdWJzY3JpYmVSb29tUmVxGhYuZ29vZ2xlLnByb3RvYnVmLkVtcHR5EiEKBF'
    'B1c2gSCy5wYi5QdXNoUmVxGgwucGIuUHVzaFJlc3ASMwoIUHVzaFJvb20SDy5wYi5QdXNoUm9v'
    'bVJlcRoWLmdvb2dsZS5wcm90b2J1Zi5FbXB0eRIxCgdQdXNoQWxsEg4ucGIuUHVzaEFsbFJlcR'
    'oWLmdvb2dsZS5wcm90b2J1Zi5FbXB0eRIwCglHZXREZXZpY2USEC5wYi5HZXREZXZpY2VSZXEa'
    'ES5wYi5HZXREZXZpY2VSZXNwEjcKClNlcnZlclN0b3ASES5wYi5TZXJ2ZXJTdG9wUmVxGhYuZ2'
    '9vZ2xlLnByb3RvYnVmLkVtcHR5');

