//
//  Generated code. Do not modify.
//  source: push.ext.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use pushCodeDescriptor instead')
const PushCode$json = {
  '1': 'PushCode',
  '2': [
    {'1': 'PC_ADD_DEFAULT', '2': 0},
    {'1': 'PC_USER_MESSAGE', '2': 100},
    {'1': 'PC_GROUP_MESSAGE', '2': 101},
    {'1': 'PC_ADD_FRIEND', '2': 110},
    {'1': 'PC_AGREE_ADD_FRIEND', '2': 111},
    {'1': 'PC_UPDATE_GROUP', '2': 120},
    {'1': 'PC_ADD_GROUP_MEMBERS', '2': 121},
    {'1': 'PC_REMOVE_GROUP_MEMBER', '2': 122},
  ],
};

/// Descriptor for `PushCode`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List pushCodeDescriptor = $convert.base64Decode(
    'CghQdXNoQ29kZRISCg5QQ19BRERfREVGQVVMVBAAEhMKD1BDX1VTRVJfTUVTU0FHRRBkEhQKEF'
    'BDX0dST1VQX01FU1NBR0UQZRIRCg1QQ19BRERfRlJJRU5EEG4SFwoTUENfQUdSRUVfQUREX0ZS'
    'SUVORBBvEhMKD1BDX1VQREFURV9HUk9VUBB4EhgKFFBDX0FERF9HUk9VUF9NRU1CRVJTEHkSGg'
    'oWUENfUkVNT1ZFX0dST1VQX01FTUJFUhB6');

@$core.Deprecated('Use senderDescriptor instead')
const Sender$json = {
  '1': 'Sender',
  '2': [
    {'1': 'user_id', '3': 2, '4': 1, '5': 3, '10': 'userId'},
    {'1': 'device_id', '3': 3, '4': 1, '5': 3, '10': 'deviceId'},
    {'1': 'avatar_url', '3': 4, '4': 1, '5': 9, '10': 'avatarUrl'},
    {'1': 'nickname', '3': 5, '4': 1, '5': 9, '10': 'nickname'},
    {'1': 'extra', '3': 6, '4': 1, '5': 9, '10': 'extra'},
  ],
};

/// Descriptor for `Sender`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List senderDescriptor = $convert.base64Decode(
    'CgZTZW5kZXISFwoHdXNlcl9pZBgCIAEoA1IGdXNlcklkEhsKCWRldmljZV9pZBgDIAEoA1IIZG'
    'V2aWNlSWQSHQoKYXZhdGFyX3VybBgEIAEoCVIJYXZhdGFyVXJsEhoKCG5pY2tuYW1lGAUgASgJ'
    'UghuaWNrbmFtZRIUCgVleHRyYRgGIAEoCVIFZXh0cmE=');

@$core.Deprecated('Use userMessagePushDescriptor instead')
const UserMessagePush$json = {
  '1': 'UserMessagePush',
  '2': [
    {'1': 'sender', '3': 1, '4': 1, '5': 11, '6': '.pb.Sender', '10': 'sender'},
    {'1': 'receiver_id', '3': 2, '4': 1, '5': 3, '10': 'receiverId'},
    {'1': 'content', '3': 3, '4': 1, '5': 12, '10': 'content'},
  ],
};

/// Descriptor for `UserMessagePush`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userMessagePushDescriptor = $convert.base64Decode(
    'Cg9Vc2VyTWVzc2FnZVB1c2gSIgoGc2VuZGVyGAEgASgLMgoucGIuU2VuZGVyUgZzZW5kZXISHw'
    'oLcmVjZWl2ZXJfaWQYAiABKANSCnJlY2VpdmVySWQSGAoHY29udGVudBgDIAEoDFIHY29udGVu'
    'dA==');

@$core.Deprecated('Use addFriendPushDescriptor instead')
const AddFriendPush$json = {
  '1': 'AddFriendPush',
  '2': [
    {'1': 'friend_id', '3': 1, '4': 1, '5': 9, '10': 'friendId'},
    {'1': 'nickname', '3': 2, '4': 1, '5': 9, '10': 'nickname'},
    {'1': 'avatar_url', '3': 3, '4': 1, '5': 9, '10': 'avatarUrl'},
    {'1': 'description', '3': 4, '4': 1, '5': 9, '10': 'description'},
  ],
};

/// Descriptor for `AddFriendPush`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addFriendPushDescriptor = $convert.base64Decode(
    'Cg1BZGRGcmllbmRQdXNoEhsKCWZyaWVuZF9pZBgBIAEoCVIIZnJpZW5kSWQSGgoIbmlja25hbW'
    'UYAiABKAlSCG5pY2tuYW1lEh0KCmF2YXRhcl91cmwYAyABKAlSCWF2YXRhclVybBIgCgtkZXNj'
    'cmlwdGlvbhgEIAEoCVILZGVzY3JpcHRpb24=');

@$core.Deprecated('Use agreeAddFriendPushDescriptor instead')
const AgreeAddFriendPush$json = {
  '1': 'AgreeAddFriendPush',
  '2': [
    {'1': 'friend_id', '3': 1, '4': 1, '5': 9, '10': 'friendId'},
    {'1': 'nickname', '3': 2, '4': 1, '5': 9, '10': 'nickname'},
    {'1': 'avatar_url', '3': 3, '4': 1, '5': 9, '10': 'avatarUrl'},
  ],
};

/// Descriptor for `AgreeAddFriendPush`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List agreeAddFriendPushDescriptor = $convert.base64Decode(
    'ChJBZ3JlZUFkZEZyaWVuZFB1c2gSGwoJZnJpZW5kX2lkGAEgASgJUghmcmllbmRJZBIaCghuaW'
    'NrbmFtZRgCIAEoCVIIbmlja25hbWUSHQoKYXZhdGFyX3VybBgDIAEoCVIJYXZhdGFyVXJs');

@$core.Deprecated('Use updateGroupPushDescriptor instead')
const UpdateGroupPush$json = {
  '1': 'UpdateGroupPush',
  '2': [
    {'1': 'opt_id', '3': 1, '4': 1, '5': 3, '10': 'optId'},
    {'1': 'opt_name', '3': 2, '4': 1, '5': 9, '10': 'optName'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
    {'1': 'avatar_url', '3': 4, '4': 1, '5': 9, '10': 'avatarUrl'},
    {'1': 'introduction', '3': 5, '4': 1, '5': 9, '10': 'introduction'},
    {'1': 'extra', '3': 6, '4': 1, '5': 9, '10': 'extra'},
  ],
};

/// Descriptor for `UpdateGroupPush`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateGroupPushDescriptor = $convert.base64Decode(
    'Cg9VcGRhdGVHcm91cFB1c2gSFQoGb3B0X2lkGAEgASgDUgVvcHRJZBIZCghvcHRfbmFtZRgCIA'
    'EoCVIHb3B0TmFtZRISCgRuYW1lGAMgASgJUgRuYW1lEh0KCmF2YXRhcl91cmwYBCABKAlSCWF2'
    'YXRhclVybBIiCgxpbnRyb2R1Y3Rpb24YBSABKAlSDGludHJvZHVjdGlvbhIUCgVleHRyYRgGIA'
    'EoCVIFZXh0cmE=');

@$core.Deprecated('Use addGroupMembersPushDescriptor instead')
const AddGroupMembersPush$json = {
  '1': 'AddGroupMembersPush',
  '2': [
    {'1': 'opt_id', '3': 1, '4': 1, '5': 3, '10': 'optId'},
    {'1': 'opt_name', '3': 2, '4': 1, '5': 9, '10': 'optName'},
    {'1': 'members', '3': 3, '4': 3, '5': 11, '6': '.pb.GroupMember', '10': 'members'},
  ],
};

/// Descriptor for `AddGroupMembersPush`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addGroupMembersPushDescriptor = $convert.base64Decode(
    'ChNBZGRHcm91cE1lbWJlcnNQdXNoEhUKBm9wdF9pZBgBIAEoA1IFb3B0SWQSGQoIb3B0X25hbW'
    'UYAiABKAlSB29wdE5hbWUSKQoHbWVtYmVycxgDIAMoCzIPLnBiLkdyb3VwTWVtYmVyUgdtZW1i'
    'ZXJz');

@$core.Deprecated('Use removeGroupMemberPushDescriptor instead')
const RemoveGroupMemberPush$json = {
  '1': 'RemoveGroupMemberPush',
  '2': [
    {'1': 'opt_id', '3': 1, '4': 1, '5': 3, '10': 'optId'},
    {'1': 'opt_name', '3': 2, '4': 1, '5': 9, '10': 'optName'},
    {'1': 'deleted_user_id', '3': 3, '4': 1, '5': 3, '10': 'deletedUserId'},
  ],
};

/// Descriptor for `RemoveGroupMemberPush`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List removeGroupMemberPushDescriptor = $convert.base64Decode(
    'ChVSZW1vdmVHcm91cE1lbWJlclB1c2gSFQoGb3B0X2lkGAEgASgDUgVvcHRJZBIZCghvcHRfbm'
    'FtZRgCIAEoCVIHb3B0TmFtZRImCg9kZWxldGVkX3VzZXJfaWQYAyABKANSDWRlbGV0ZWRVc2Vy'
    'SWQ=');

