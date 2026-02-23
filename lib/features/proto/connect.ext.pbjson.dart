// This is a generated file - do not edit.
//
// Generated from connect.ext.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use packageTypeDescriptor instead')
const PackageType$json = {
  '1': 'PackageType',
  '2': [
    {'1': 'PT_UNKNOWN', '2': 0},
    {'1': 'PT_SIGN_IN', '2': 1},
    {'1': 'PT_SYNC', '2': 2},
    {'1': 'PT_HEARTBEAT', '2': 3},
    {'1': 'PT_MESSAGE', '2': 4},
    {'1': 'PT_SUBSCRIBE_ROOM', '2': 5},
  ],
};

/// Descriptor for `PackageType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List packageTypeDescriptor = $convert.base64Decode(
    'CgtQYWNrYWdlVHlwZRIOCgpQVF9VTktOT1dOEAASDgoKUFRfU0lHTl9JThABEgsKB1BUX1NZTk'
    'MQAhIQCgxQVF9IRUFSVEJFQVQQAxIOCgpQVF9NRVNTQUdFEAQSFQoRUFRfU1VCU0NSSUJFX1JP'
    'T00QBQ==');

@$core.Deprecated('Use inputDescriptor instead')
const Input$json = {
  '1': 'Input',
  '2': [
    {
      '1': 'type',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.pb.PackageType',
      '10': 'type'
    },
    {'1': 'request_id', '3': 2, '4': 1, '5': 3, '10': 'requestId'},
    {'1': 'data', '3': 3, '4': 1, '5': 12, '10': 'data'},
  ],
};

/// Descriptor for `Input`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List inputDescriptor = $convert.base64Decode(
    'CgVJbnB1dBIjCgR0eXBlGAEgASgOMg8ucGIuUGFja2FnZVR5cGVSBHR5cGUSHQoKcmVxdWVzdF'
    '9pZBgCIAEoA1IJcmVxdWVzdElkEhIKBGRhdGEYAyABKAxSBGRhdGE=');

@$core.Deprecated('Use outputDescriptor instead')
const Output$json = {
  '1': 'Output',
  '2': [
    {
      '1': 'type',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.pb.PackageType',
      '10': 'type'
    },
    {'1': 'request_id', '3': 2, '4': 1, '5': 3, '10': 'requestId'},
    {'1': 'code', '3': 3, '4': 1, '5': 5, '10': 'code'},
    {'1': 'message', '3': 4, '4': 1, '5': 9, '10': 'message'},
    {'1': 'data', '3': 5, '4': 1, '5': 12, '10': 'data'},
  ],
};

/// Descriptor for `Output`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List outputDescriptor = $convert.base64Decode(
    'CgZPdXRwdXQSIwoEdHlwZRgBIAEoDjIPLnBiLlBhY2thZ2VUeXBlUgR0eXBlEh0KCnJlcXVlc3'
    'RfaWQYAiABKANSCXJlcXVlc3RJZBISCgRjb2RlGAMgASgFUgRjb2RlEhgKB21lc3NhZ2UYBCAB'
    'KAlSB21lc3NhZ2USEgoEZGF0YRgFIAEoDFIEZGF0YQ==');

@$core.Deprecated('Use signInInputDescriptor instead')
const SignInInput$json = {
  '1': 'SignInInput',
  '2': [
    {'1': 'device_id', '3': 1, '4': 1, '5': 3, '10': 'deviceId'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 3, '10': 'userId'},
    {'1': 'token', '3': 3, '4': 1, '5': 9, '10': 'token'},
  ],
};

/// Descriptor for `SignInInput`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List signInInputDescriptor = $convert.base64Decode(
    'CgtTaWduSW5JbnB1dBIbCglkZXZpY2VfaWQYASABKANSCGRldmljZUlkEhcKB3VzZXJfaWQYAi'
    'ABKANSBnVzZXJJZBIUCgV0b2tlbhgDIAEoCVIFdG9rZW4=');

@$core.Deprecated('Use syncInputDescriptor instead')
const SyncInput$json = {
  '1': 'SyncInput',
  '2': [
    {'1': 'seq', '3': 1, '4': 1, '5': 3, '10': 'seq'},
  ],
};

/// Descriptor for `SyncInput`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List syncInputDescriptor =
    $convert.base64Decode('CglTeW5jSW5wdXQSEAoDc2VxGAEgASgDUgNzZXE=');

@$core.Deprecated('Use syncOutputDescriptor instead')
const SyncOutput$json = {
  '1': 'SyncOutput',
  '2': [
    {
      '1': 'messages',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.pb.Message',
      '10': 'messages'
    },
    {'1': 'has_more', '3': 2, '4': 1, '5': 8, '10': 'hasMore'},
  ],
};

/// Descriptor for `SyncOutput`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List syncOutputDescriptor = $convert.base64Decode(
    'CgpTeW5jT3V0cHV0EicKCG1lc3NhZ2VzGAEgAygLMgsucGIuTWVzc2FnZVIIbWVzc2FnZXMSGQ'
    'oIaGFzX21vcmUYAiABKAhSB2hhc01vcmU=');

@$core.Deprecated('Use subscribeRoomInputDescriptor instead')
const SubscribeRoomInput$json = {
  '1': 'SubscribeRoomInput',
  '2': [
    {'1': 'room_id', '3': 1, '4': 1, '5': 3, '10': 'roomId'},
    {'1': 'seq', '3': 2, '4': 1, '5': 3, '10': 'seq'},
  ],
};

/// Descriptor for `SubscribeRoomInput`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List subscribeRoomInputDescriptor = $convert.base64Decode(
    'ChJTdWJzY3JpYmVSb29tSW5wdXQSFwoHcm9vbV9pZBgBIAEoA1IGcm9vbUlkEhAKA3NlcRgCIA'
    'EoA1IDc2Vx');

@$core.Deprecated('Use messageACKDescriptor instead')
const MessageACK$json = {
  '1': 'MessageACK',
  '2': [
    {'1': 'device_ack', '3': 2, '4': 1, '5': 3, '10': 'deviceAck'},
    {'1': 'target', '3': 3, '4': 1, '5': 9, '10': 'target'},
    {'1': 'receive_time', '3': 4, '4': 1, '5': 3, '10': 'receiveTime'},
  ],
};

/// Descriptor for `MessageACK`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List messageACKDescriptor = $convert.base64Decode(
    'CgpNZXNzYWdlQUNLEh0KCmRldmljZV9hY2sYAiABKANSCWRldmljZUFjaxIWCgZ0YXJnZXQYAy'
    'ABKAlSBnRhcmdldBIhCgxyZWNlaXZlX3RpbWUYBCABKANSC3JlY2VpdmVUaW1l');
