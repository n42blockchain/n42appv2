//
//  Generated code. Do not modify.
//  source: message.ext.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use messageStatusDescriptor instead')
const MessageStatus$json = {
  '1': 'MessageStatus',
  '2': [
    {'1': 'MS_NORMAL', '2': 0},
    {'1': 'MS_RECALL', '2': 1},
  ],
};

/// Descriptor for `MessageStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List messageStatusDescriptor = $convert.base64Decode(
    'Cg1NZXNzYWdlU3RhdHVzEg0KCU1TX05PUk1BTBAAEg0KCU1TX1JFQ0FMTBAB');

@$core.Deprecated('Use messageDescriptor instead')
const Message$json = {
  '1': 'Message',
  '2': [
    {'1': 'message_id', '3': 1, '4': 1, '5': 3, '10': 'messageId'},
    {'1': 'code', '3': 2, '4': 1, '5': 5, '10': 'code'},
    {'1': 'content', '3': 3, '4': 1, '5': 12, '10': 'content'},
    {'1': 'seq', '3': 4, '4': 1, '5': 3, '10': 'seq'},
    {'1': 'send_time', '3': 5, '4': 1, '5': 3, '10': 'sendTime'},
    {'1': 'status', '3': 6, '4': 1, '5': 14, '6': '.pb.MessageStatus', '10': 'status'},
  ],
};

/// Descriptor for `Message`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List messageDescriptor = $convert.base64Decode(
    'CgdNZXNzYWdlEh0KCm1lc3NhZ2VfaWQYASABKANSCW1lc3NhZ2VJZBISCgRjb2RlGAIgASgFUg'
    'Rjb2RlEhgKB2NvbnRlbnQYAyABKAxSB2NvbnRlbnQSEAoDc2VxGAQgASgDUgNzZXESGwoJc2Vu'
    'ZF90aW1lGAUgASgDUghzZW5kVGltZRIpCgZzdGF0dXMYBiABKA4yES5wYi5NZXNzYWdlU3RhdH'
    'VzUgZzdGF0dXM=');

