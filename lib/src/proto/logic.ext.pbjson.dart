//
//  Generated code. Do not modify.
//  source: logic.ext.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

import 'google/protobuf/empty.pbjson.dart' as $0;

@$core.Deprecated('Use memberTypeDescriptor instead')
const MemberType$json = {
  '1': 'MemberType',
  '2': [
    {'1': 'GMT_UNKNOWN', '2': 0},
    {'1': 'GMT_ADMIN', '2': 1},
    {'1': 'GMT_MEMBER', '2': 2},
  ],
};

/// Descriptor for `MemberType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List memberTypeDescriptor = $convert.base64Decode(
    'CgpNZW1iZXJUeXBlEg8KC0dNVF9VTktOT1dOEAASDQoJR01UX0FETUlOEAESDgoKR01UX01FTU'
    'JFUhAC');

@$core.Deprecated('Use registerDeviceReqDescriptor instead')
const RegisterDeviceReq$json = {
  '1': 'RegisterDeviceReq',
  '2': [
    {'1': 'type', '3': 2, '4': 1, '5': 5, '10': 'type'},
    {'1': 'brand', '3': 3, '4': 1, '5': 9, '10': 'brand'},
    {'1': 'model', '3': 4, '4': 1, '5': 9, '10': 'model'},
    {'1': 'system_version', '3': 5, '4': 1, '5': 9, '10': 'systemVersion'},
    {'1': 'sdk_version', '3': 6, '4': 1, '5': 9, '10': 'sdkVersion'},
  ],
};

/// Descriptor for `RegisterDeviceReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List registerDeviceReqDescriptor = $convert.base64Decode(
    'ChFSZWdpc3RlckRldmljZVJlcRISCgR0eXBlGAIgASgFUgR0eXBlEhQKBWJyYW5kGAMgASgJUg'
    'VicmFuZBIUCgVtb2RlbBgEIAEoCVIFbW9kZWwSJQoOc3lzdGVtX3ZlcnNpb24YBSABKAlSDXN5'
    'c3RlbVZlcnNpb24SHwoLc2RrX3ZlcnNpb24YBiABKAlSCnNka1ZlcnNpb24=');

@$core.Deprecated('Use registerDeviceRespDescriptor instead')
const RegisterDeviceResp$json = {
  '1': 'RegisterDeviceResp',
  '2': [
    {'1': 'device_id', '3': 1, '4': 1, '5': 3, '10': 'deviceId'},
  ],
};

/// Descriptor for `RegisterDeviceResp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List registerDeviceRespDescriptor = $convert.base64Decode(
    'ChJSZWdpc3RlckRldmljZVJlc3ASGwoJZGV2aWNlX2lkGAEgASgDUghkZXZpY2VJZA==');

@$core.Deprecated('Use sendMessageReqDescriptor instead')
const SendMessageReq$json = {
  '1': 'SendMessageReq',
  '2': [
    {'1': 'receiver_id', '3': 1, '4': 1, '5': 3, '10': 'receiverId'},
    {'1': 'content', '3': 2, '4': 1, '5': 12, '10': 'content'},
    {'1': 'send_time', '3': 3, '4': 1, '5': 3, '10': 'sendTime'},
  ],
};

/// Descriptor for `SendMessageReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sendMessageReqDescriptor = $convert.base64Decode(
    'Cg5TZW5kTWVzc2FnZVJlcRIfCgtyZWNlaXZlcl9pZBgBIAEoA1IKcmVjZWl2ZXJJZBIYCgdjb2'
    '50ZW50GAIgASgMUgdjb250ZW50EhsKCXNlbmRfdGltZRgDIAEoA1IIc2VuZFRpbWU=');

@$core.Deprecated('Use sendMessageRespDescriptor instead')
const SendMessageResp$json = {
  '1': 'SendMessageResp',
  '2': [
    {'1': 'seq', '3': 1, '4': 1, '5': 3, '10': 'seq'},
  ],
};

/// Descriptor for `SendMessageResp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sendMessageRespDescriptor = $convert.base64Decode(
    'Cg9TZW5kTWVzc2FnZVJlc3ASEAoDc2VxGAEgASgDUgNzZXE=');

@$core.Deprecated('Use pushRoomReqDescriptor instead')
const PushRoomReq$json = {
  '1': 'PushRoomReq',
  '2': [
    {'1': 'room_id', '3': 1, '4': 1, '5': 3, '10': 'roomId'},
    {'1': 'code', '3': 2, '4': 1, '5': 5, '10': 'code'},
    {'1': 'content', '3': 3, '4': 1, '5': 12, '10': 'content'},
    {'1': 'send_time', '3': 4, '4': 1, '5': 3, '10': 'sendTime'},
    {'1': 'is_persist', '3': 5, '4': 1, '5': 8, '10': 'isPersist'},
    {'1': 'is_priority', '3': 6, '4': 1, '5': 8, '10': 'isPriority'},
  ],
};

/// Descriptor for `PushRoomReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pushRoomReqDescriptor = $convert.base64Decode(
    'CgtQdXNoUm9vbVJlcRIXCgdyb29tX2lkGAEgASgDUgZyb29tSWQSEgoEY29kZRgCIAEoBVIEY2'
    '9kZRIYCgdjb250ZW50GAMgASgMUgdjb250ZW50EhsKCXNlbmRfdGltZRgEIAEoA1IIc2VuZFRp'
    'bWUSHQoKaXNfcGVyc2lzdBgFIAEoCFIJaXNQZXJzaXN0Eh8KC2lzX3ByaW9yaXR5GAYgASgIUg'
    'ppc1ByaW9yaXR5');

@$core.Deprecated('Use addFriendReqDescriptor instead')
const AddFriendReq$json = {
  '1': 'AddFriendReq',
  '2': [
    {'1': 'friend_id', '3': 1, '4': 1, '5': 3, '10': 'friendId'},
    {'1': 'remarks', '3': 2, '4': 1, '5': 9, '10': 'remarks'},
    {'1': 'description', '3': 3, '4': 1, '5': 9, '10': 'description'},
  ],
};

/// Descriptor for `AddFriendReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addFriendReqDescriptor = $convert.base64Decode(
    'CgxBZGRGcmllbmRSZXESGwoJZnJpZW5kX2lkGAEgASgDUghmcmllbmRJZBIYCgdyZW1hcmtzGA'
    'IgASgJUgdyZW1hcmtzEiAKC2Rlc2NyaXB0aW9uGAMgASgJUgtkZXNjcmlwdGlvbg==');

@$core.Deprecated('Use agreeAddFriendReqDescriptor instead')
const AgreeAddFriendReq$json = {
  '1': 'AgreeAddFriendReq',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 3, '10': 'userId'},
    {'1': 'remarks', '3': 2, '4': 1, '5': 9, '10': 'remarks'},
  ],
};

/// Descriptor for `AgreeAddFriendReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List agreeAddFriendReqDescriptor = $convert.base64Decode(
    'ChFBZ3JlZUFkZEZyaWVuZFJlcRIXCgd1c2VyX2lkGAEgASgDUgZ1c2VySWQSGAoHcmVtYXJrcx'
    'gCIAEoCVIHcmVtYXJrcw==');

@$core.Deprecated('Use setFriendReqDescriptor instead')
const SetFriendReq$json = {
  '1': 'SetFriendReq',
  '2': [
    {'1': 'friend_id', '3': 1, '4': 1, '5': 3, '10': 'friendId'},
    {'1': 'remarks', '3': 2, '4': 1, '5': 9, '10': 'remarks'},
    {'1': 'extra', '3': 8, '4': 1, '5': 9, '10': 'extra'},
  ],
};

/// Descriptor for `SetFriendReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setFriendReqDescriptor = $convert.base64Decode(
    'CgxTZXRGcmllbmRSZXESGwoJZnJpZW5kX2lkGAEgASgDUghmcmllbmRJZBIYCgdyZW1hcmtzGA'
    'IgASgJUgdyZW1hcmtzEhQKBWV4dHJhGAggASgJUgVleHRyYQ==');

@$core.Deprecated('Use setFriendRespDescriptor instead')
const SetFriendResp$json = {
  '1': 'SetFriendResp',
  '2': [
    {'1': 'friend_id', '3': 1, '4': 1, '5': 3, '10': 'friendId'},
    {'1': 'remarks', '3': 2, '4': 1, '5': 9, '10': 'remarks'},
    {'1': 'extra', '3': 8, '4': 1, '5': 9, '10': 'extra'},
  ],
};

/// Descriptor for `SetFriendResp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setFriendRespDescriptor = $convert.base64Decode(
    'Cg1TZXRGcmllbmRSZXNwEhsKCWZyaWVuZF9pZBgBIAEoA1IIZnJpZW5kSWQSGAoHcmVtYXJrcx'
    'gCIAEoCVIHcmVtYXJrcxIUCgVleHRyYRgIIAEoCVIFZXh0cmE=');

@$core.Deprecated('Use friendDescriptor instead')
const Friend$json = {
  '1': 'Friend',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 3, '10': 'userId'},
    {'1': 'phone_number', '3': 2, '4': 1, '5': 9, '10': 'phoneNumber'},
    {'1': 'nickname', '3': 3, '4': 1, '5': 9, '10': 'nickname'},
    {'1': 'sex', '3': 4, '4': 1, '5': 5, '10': 'sex'},
    {'1': 'avatar_url', '3': 5, '4': 1, '5': 9, '10': 'avatarUrl'},
    {'1': 'user_extra', '3': 6, '4': 1, '5': 9, '10': 'userExtra'},
    {'1': 'remarks', '3': 7, '4': 1, '5': 9, '10': 'remarks'},
    {'1': 'extra', '3': 8, '4': 1, '5': 9, '10': 'extra'},
  ],
};

/// Descriptor for `Friend`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List friendDescriptor = $convert.base64Decode(
    'CgZGcmllbmQSFwoHdXNlcl9pZBgBIAEoA1IGdXNlcklkEiEKDHBob25lX251bWJlchgCIAEoCV'
    'ILcGhvbmVOdW1iZXISGgoIbmlja25hbWUYAyABKAlSCG5pY2tuYW1lEhAKA3NleBgEIAEoBVID'
    'c2V4Eh0KCmF2YXRhcl91cmwYBSABKAlSCWF2YXRhclVybBIdCgp1c2VyX2V4dHJhGAYgASgJUg'
    'l1c2VyRXh0cmESGAoHcmVtYXJrcxgHIAEoCVIHcmVtYXJrcxIUCgVleHRyYRgIIAEoCVIFZXh0'
    'cmE=');

@$core.Deprecated('Use getFriendsRespDescriptor instead')
const GetFriendsResp$json = {
  '1': 'GetFriendsResp',
  '2': [
    {'1': 'friends', '3': 1, '4': 3, '5': 11, '6': '.pb.Friend', '10': 'friends'},
  ],
};

/// Descriptor for `GetFriendsResp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getFriendsRespDescriptor = $convert.base64Decode(
    'Cg5HZXRGcmllbmRzUmVzcBIkCgdmcmllbmRzGAEgAygLMgoucGIuRnJpZW5kUgdmcmllbmRz');

@$core.Deprecated('Use createGroupReqDescriptor instead')
const CreateGroupReq$json = {
  '1': 'CreateGroupReq',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'avatar_url', '3': 2, '4': 1, '5': 9, '10': 'avatarUrl'},
    {'1': 'introduction', '3': 3, '4': 1, '5': 9, '10': 'introduction'},
    {'1': 'extra', '3': 4, '4': 1, '5': 9, '10': 'extra'},
    {'1': 'member_ids', '3': 5, '4': 3, '5': 3, '10': 'memberIds'},
  ],
};

/// Descriptor for `CreateGroupReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createGroupReqDescriptor = $convert.base64Decode(
    'Cg5DcmVhdGVHcm91cFJlcRISCgRuYW1lGAEgASgJUgRuYW1lEh0KCmF2YXRhcl91cmwYAiABKA'
    'lSCWF2YXRhclVybBIiCgxpbnRyb2R1Y3Rpb24YAyABKAlSDGludHJvZHVjdGlvbhIUCgVleHRy'
    'YRgEIAEoCVIFZXh0cmESHQoKbWVtYmVyX2lkcxgFIAMoA1IJbWVtYmVySWRz');

@$core.Deprecated('Use createGroupRespDescriptor instead')
const CreateGroupResp$json = {
  '1': 'CreateGroupResp',
  '2': [
    {'1': 'group_id', '3': 1, '4': 1, '5': 3, '10': 'groupId'},
  ],
};

/// Descriptor for `CreateGroupResp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createGroupRespDescriptor = $convert.base64Decode(
    'Cg9DcmVhdGVHcm91cFJlc3ASGQoIZ3JvdXBfaWQYASABKANSB2dyb3VwSWQ=');

@$core.Deprecated('Use updateGroupReqDescriptor instead')
const UpdateGroupReq$json = {
  '1': 'UpdateGroupReq',
  '2': [
    {'1': 'group_id', '3': 1, '4': 1, '5': 3, '10': 'groupId'},
    {'1': 'avatar_url', '3': 2, '4': 1, '5': 9, '10': 'avatarUrl'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
    {'1': 'introduction', '3': 4, '4': 1, '5': 9, '10': 'introduction'},
    {'1': 'extra', '3': 5, '4': 1, '5': 9, '10': 'extra'},
  ],
};

/// Descriptor for `UpdateGroupReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateGroupReqDescriptor = $convert.base64Decode(
    'Cg5VcGRhdGVHcm91cFJlcRIZCghncm91cF9pZBgBIAEoA1IHZ3JvdXBJZBIdCgphdmF0YXJfdX'
    'JsGAIgASgJUglhdmF0YXJVcmwSEgoEbmFtZRgDIAEoCVIEbmFtZRIiCgxpbnRyb2R1Y3Rpb24Y'
    'BCABKAlSDGludHJvZHVjdGlvbhIUCgVleHRyYRgFIAEoCVIFZXh0cmE=');

@$core.Deprecated('Use getGroupReqDescriptor instead')
const GetGroupReq$json = {
  '1': 'GetGroupReq',
  '2': [
    {'1': 'group_id', '3': 1, '4': 1, '5': 3, '10': 'groupId'},
  ],
};

/// Descriptor for `GetGroupReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getGroupReqDescriptor = $convert.base64Decode(
    'CgtHZXRHcm91cFJlcRIZCghncm91cF9pZBgBIAEoA1IHZ3JvdXBJZA==');

@$core.Deprecated('Use getGroupRespDescriptor instead')
const GetGroupResp$json = {
  '1': 'GetGroupResp',
  '2': [
    {'1': 'group', '3': 1, '4': 1, '5': 11, '6': '.pb.Group', '10': 'group'},
  ],
};

/// Descriptor for `GetGroupResp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getGroupRespDescriptor = $convert.base64Decode(
    'CgxHZXRHcm91cFJlc3ASHwoFZ3JvdXAYASABKAsyCS5wYi5Hcm91cFIFZ3JvdXA=');

@$core.Deprecated('Use groupDescriptor instead')
const Group$json = {
  '1': 'Group',
  '2': [
    {'1': 'group_id', '3': 1, '4': 1, '5': 3, '10': 'groupId'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'avatar_url', '3': 3, '4': 1, '5': 9, '10': 'avatarUrl'},
    {'1': 'introduction', '3': 4, '4': 1, '5': 9, '10': 'introduction'},
    {'1': 'user_mum', '3': 5, '4': 1, '5': 5, '10': 'userMum'},
    {'1': 'extra', '3': 6, '4': 1, '5': 9, '10': 'extra'},
    {'1': 'create_time', '3': 7, '4': 1, '5': 3, '10': 'createTime'},
    {'1': 'update_time', '3': 8, '4': 1, '5': 3, '10': 'updateTime'},
  ],
};

/// Descriptor for `Group`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List groupDescriptor = $convert.base64Decode(
    'CgVHcm91cBIZCghncm91cF9pZBgBIAEoA1IHZ3JvdXBJZBISCgRuYW1lGAIgASgJUgRuYW1lEh'
    '0KCmF2YXRhcl91cmwYAyABKAlSCWF2YXRhclVybBIiCgxpbnRyb2R1Y3Rpb24YBCABKAlSDGlu'
    'dHJvZHVjdGlvbhIZCgh1c2VyX211bRgFIAEoBVIHdXNlck11bRIUCgVleHRyYRgGIAEoCVIFZX'
    'h0cmESHwoLY3JlYXRlX3RpbWUYByABKANSCmNyZWF0ZVRpbWUSHwoLdXBkYXRlX3RpbWUYCCAB'
    'KANSCnVwZGF0ZVRpbWU=');

@$core.Deprecated('Use getGroupsRespDescriptor instead')
const GetGroupsResp$json = {
  '1': 'GetGroupsResp',
  '2': [
    {'1': 'groups', '3': 1, '4': 3, '5': 11, '6': '.pb.Group', '10': 'groups'},
  ],
};

/// Descriptor for `GetGroupsResp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getGroupsRespDescriptor = $convert.base64Decode(
    'Cg1HZXRHcm91cHNSZXNwEiEKBmdyb3VwcxgBIAMoCzIJLnBiLkdyb3VwUgZncm91cHM=');

@$core.Deprecated('Use addGroupMembersReqDescriptor instead')
const AddGroupMembersReq$json = {
  '1': 'AddGroupMembersReq',
  '2': [
    {'1': 'group_id', '3': 1, '4': 1, '5': 3, '10': 'groupId'},
    {'1': 'user_ids', '3': 2, '4': 3, '5': 3, '10': 'userIds'},
  ],
};

/// Descriptor for `AddGroupMembersReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addGroupMembersReqDescriptor = $convert.base64Decode(
    'ChJBZGRHcm91cE1lbWJlcnNSZXESGQoIZ3JvdXBfaWQYASABKANSB2dyb3VwSWQSGQoIdXNlcl'
    '9pZHMYAiADKANSB3VzZXJJZHM=');

@$core.Deprecated('Use addGroupMembersRespDescriptor instead')
const AddGroupMembersResp$json = {
  '1': 'AddGroupMembersResp',
  '2': [
    {'1': 'user_ids', '3': 1, '4': 3, '5': 3, '10': 'userIds'},
  ],
};

/// Descriptor for `AddGroupMembersResp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addGroupMembersRespDescriptor = $convert.base64Decode(
    'ChNBZGRHcm91cE1lbWJlcnNSZXNwEhkKCHVzZXJfaWRzGAEgAygDUgd1c2VySWRz');

@$core.Deprecated('Use updateGroupMemberReqDescriptor instead')
const UpdateGroupMemberReq$json = {
  '1': 'UpdateGroupMemberReq',
  '2': [
    {'1': 'group_id', '3': 1, '4': 1, '5': 3, '10': 'groupId'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 3, '10': 'userId'},
    {'1': 'member_type', '3': 3, '4': 1, '5': 14, '6': '.pb.MemberType', '10': 'memberType'},
    {'1': 'remarks', '3': 4, '4': 1, '5': 9, '10': 'remarks'},
    {'1': 'extra', '3': 5, '4': 1, '5': 9, '10': 'extra'},
  ],
};

/// Descriptor for `UpdateGroupMemberReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateGroupMemberReqDescriptor = $convert.base64Decode(
    'ChRVcGRhdGVHcm91cE1lbWJlclJlcRIZCghncm91cF9pZBgBIAEoA1IHZ3JvdXBJZBIXCgd1c2'
    'VyX2lkGAIgASgDUgZ1c2VySWQSLwoLbWVtYmVyX3R5cGUYAyABKA4yDi5wYi5NZW1iZXJUeXBl'
    'UgptZW1iZXJUeXBlEhgKB3JlbWFya3MYBCABKAlSB3JlbWFya3MSFAoFZXh0cmEYBSABKAlSBW'
    'V4dHJh');

@$core.Deprecated('Use deleteGroupMemberReqDescriptor instead')
const DeleteGroupMemberReq$json = {
  '1': 'DeleteGroupMemberReq',
  '2': [
    {'1': 'group_id', '3': 1, '4': 1, '5': 3, '10': 'groupId'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 3, '10': 'userId'},
  ],
};

/// Descriptor for `DeleteGroupMemberReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteGroupMemberReqDescriptor = $convert.base64Decode(
    'ChREZWxldGVHcm91cE1lbWJlclJlcRIZCghncm91cF9pZBgBIAEoA1IHZ3JvdXBJZBIXCgd1c2'
    'VyX2lkGAIgASgDUgZ1c2VySWQ=');

@$core.Deprecated('Use getGroupMembersReqDescriptor instead')
const GetGroupMembersReq$json = {
  '1': 'GetGroupMembersReq',
  '2': [
    {'1': 'group_id', '3': 1, '4': 1, '5': 3, '10': 'groupId'},
  ],
};

/// Descriptor for `GetGroupMembersReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getGroupMembersReqDescriptor = $convert.base64Decode(
    'ChJHZXRHcm91cE1lbWJlcnNSZXESGQoIZ3JvdXBfaWQYASABKANSB2dyb3VwSWQ=');

@$core.Deprecated('Use getGroupMembersRespDescriptor instead')
const GetGroupMembersResp$json = {
  '1': 'GetGroupMembersResp',
  '2': [
    {'1': 'members', '3': 1, '4': 3, '5': 11, '6': '.pb.GroupMember', '10': 'members'},
  ],
};

/// Descriptor for `GetGroupMembersResp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getGroupMembersRespDescriptor = $convert.base64Decode(
    'ChNHZXRHcm91cE1lbWJlcnNSZXNwEikKB21lbWJlcnMYASADKAsyDy5wYi5Hcm91cE1lbWJlcl'
    'IHbWVtYmVycw==');

@$core.Deprecated('Use groupMemberDescriptor instead')
const GroupMember$json = {
  '1': 'GroupMember',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 3, '10': 'userId'},
    {'1': 'nickname', '3': 2, '4': 1, '5': 9, '10': 'nickname'},
    {'1': 'sex', '3': 3, '4': 1, '5': 5, '10': 'sex'},
    {'1': 'avatar_url', '3': 4, '4': 1, '5': 9, '10': 'avatarUrl'},
    {'1': 'user_extra', '3': 5, '4': 1, '5': 9, '10': 'userExtra'},
    {'1': 'member_type', '3': 6, '4': 1, '5': 14, '6': '.pb.MemberType', '10': 'memberType'},
    {'1': 'remarks', '3': 7, '4': 1, '5': 9, '10': 'remarks'},
    {'1': 'extra', '3': 8, '4': 1, '5': 9, '10': 'extra'},
  ],
};

/// Descriptor for `GroupMember`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List groupMemberDescriptor = $convert.base64Decode(
    'CgtHcm91cE1lbWJlchIXCgd1c2VyX2lkGAEgASgDUgZ1c2VySWQSGgoIbmlja25hbWUYAiABKA'
    'lSCG5pY2tuYW1lEhAKA3NleBgDIAEoBVIDc2V4Eh0KCmF2YXRhcl91cmwYBCABKAlSCWF2YXRh'
    'clVybBIdCgp1c2VyX2V4dHJhGAUgASgJUgl1c2VyRXh0cmESLwoLbWVtYmVyX3R5cGUYBiABKA'
    '4yDi5wYi5NZW1iZXJUeXBlUgptZW1iZXJUeXBlEhgKB3JlbWFya3MYByABKAlSB3JlbWFya3MS'
    'FAoFZXh0cmEYCCABKAlSBWV4dHJh');

const $core.Map<$core.String, $core.dynamic> LogicExtServiceBase$json = {
  '1': 'LogicExt',
  '2': [
    {'1': 'RegisterDevice', '2': '.pb.RegisterDeviceReq', '3': '.pb.RegisterDeviceResp'},
    {'1': 'PushRoom', '2': '.pb.PushRoomReq', '3': '.google.protobuf.Empty'},
    {'1': 'SendMessageToFriend', '2': '.pb.SendMessageReq', '3': '.pb.SendMessageResp'},
    {'1': 'AddFriend', '2': '.pb.AddFriendReq', '3': '.google.protobuf.Empty'},
    {'1': 'AgreeAddFriend', '2': '.pb.AgreeAddFriendReq', '3': '.google.protobuf.Empty'},
    {'1': 'SetFriend', '2': '.pb.SetFriendReq', '3': '.pb.SetFriendResp'},
    {'1': 'GetFriends', '2': '.google.protobuf.Empty', '3': '.pb.GetFriendsResp'},
    {'1': 'SendMessageToGroup', '2': '.pb.SendMessageReq', '3': '.pb.SendMessageResp'},
    {'1': 'CreateGroup', '2': '.pb.CreateGroupReq', '3': '.pb.CreateGroupResp'},
    {'1': 'UpdateGroup', '2': '.pb.UpdateGroupReq', '3': '.google.protobuf.Empty'},
    {'1': 'GetGroup', '2': '.pb.GetGroupReq', '3': '.pb.GetGroupResp'},
    {'1': 'GetGroups', '2': '.google.protobuf.Empty', '3': '.pb.GetGroupsResp'},
    {'1': 'AddGroupMembers', '2': '.pb.AddGroupMembersReq', '3': '.pb.AddGroupMembersResp'},
    {'1': 'UpdateGroupMember', '2': '.pb.UpdateGroupMemberReq', '3': '.google.protobuf.Empty'},
    {'1': 'DeleteGroupMember', '2': '.pb.DeleteGroupMemberReq', '3': '.google.protobuf.Empty'},
    {'1': 'GetGroupMembers', '2': '.pb.GetGroupMembersReq', '3': '.pb.GetGroupMembersResp'},
  ],
};

@$core.Deprecated('Use logicExtServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> LogicExtServiceBase$messageJson = {
  '.pb.RegisterDeviceReq': RegisterDeviceReq$json,
  '.pb.RegisterDeviceResp': RegisterDeviceResp$json,
  '.pb.PushRoomReq': PushRoomReq$json,
  '.google.protobuf.Empty': $0.Empty$json,
  '.pb.SendMessageReq': SendMessageReq$json,
  '.pb.SendMessageResp': SendMessageResp$json,
  '.pb.AddFriendReq': AddFriendReq$json,
  '.pb.AgreeAddFriendReq': AgreeAddFriendReq$json,
  '.pb.SetFriendReq': SetFriendReq$json,
  '.pb.SetFriendResp': SetFriendResp$json,
  '.pb.GetFriendsResp': GetFriendsResp$json,
  '.pb.Friend': Friend$json,
  '.pb.CreateGroupReq': CreateGroupReq$json,
  '.pb.CreateGroupResp': CreateGroupResp$json,
  '.pb.UpdateGroupReq': UpdateGroupReq$json,
  '.pb.GetGroupReq': GetGroupReq$json,
  '.pb.GetGroupResp': GetGroupResp$json,
  '.pb.Group': Group$json,
  '.pb.GetGroupsResp': GetGroupsResp$json,
  '.pb.AddGroupMembersReq': AddGroupMembersReq$json,
  '.pb.AddGroupMembersResp': AddGroupMembersResp$json,
  '.pb.UpdateGroupMemberReq': UpdateGroupMemberReq$json,
  '.pb.DeleteGroupMemberReq': DeleteGroupMemberReq$json,
  '.pb.GetGroupMembersReq': GetGroupMembersReq$json,
  '.pb.GetGroupMembersResp': GetGroupMembersResp$json,
  '.pb.GroupMember': GroupMember$json,
};

/// Descriptor for `LogicExt`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List logicExtServiceDescriptor = $convert.base64Decode(
    'CghMb2dpY0V4dBI/Cg5SZWdpc3RlckRldmljZRIVLnBiLlJlZ2lzdGVyRGV2aWNlUmVxGhYucG'
    'IuUmVnaXN0ZXJEZXZpY2VSZXNwEjMKCFB1c2hSb29tEg8ucGIuUHVzaFJvb21SZXEaFi5nb29n'
    'bGUucHJvdG9idWYuRW1wdHkSPgoTU2VuZE1lc3NhZ2VUb0ZyaWVuZBISLnBiLlNlbmRNZXNzYW'
    'dlUmVxGhMucGIuU2VuZE1lc3NhZ2VSZXNwEjUKCUFkZEZyaWVuZBIQLnBiLkFkZEZyaWVuZFJl'
    'cRoWLmdvb2dsZS5wcm90b2J1Zi5FbXB0eRI/Cg5BZ3JlZUFkZEZyaWVuZBIVLnBiLkFncmVlQW'
    'RkRnJpZW5kUmVxGhYuZ29vZ2xlLnByb3RvYnVmLkVtcHR5EjAKCVNldEZyaWVuZBIQLnBiLlNl'
    'dEZyaWVuZFJlcRoRLnBiLlNldEZyaWVuZFJlc3ASOAoKR2V0RnJpZW5kcxIWLmdvb2dsZS5wcm'
    '90b2J1Zi5FbXB0eRoSLnBiLkdldEZyaWVuZHNSZXNwEj0KElNlbmRNZXNzYWdlVG9Hcm91cBIS'
    'LnBiLlNlbmRNZXNzYWdlUmVxGhMucGIuU2VuZE1lc3NhZ2VSZXNwEjYKC0NyZWF0ZUdyb3VwEh'
    'IucGIuQ3JlYXRlR3JvdXBSZXEaEy5wYi5DcmVhdGVHcm91cFJlc3ASOQoLVXBkYXRlR3JvdXAS'
    'Ei5wYi5VcGRhdGVHcm91cFJlcRoWLmdvb2dsZS5wcm90b2J1Zi5FbXB0eRItCghHZXRHcm91cB'
    'IPLnBiLkdldEdyb3VwUmVxGhAucGIuR2V0R3JvdXBSZXNwEjYKCUdldEdyb3VwcxIWLmdvb2ds'
    'ZS5wcm90b2J1Zi5FbXB0eRoRLnBiLkdldEdyb3Vwc1Jlc3ASQgoPQWRkR3JvdXBNZW1iZXJzEh'
    'YucGIuQWRkR3JvdXBNZW1iZXJzUmVxGhcucGIuQWRkR3JvdXBNZW1iZXJzUmVzcBJFChFVcGRh'
    'dGVHcm91cE1lbWJlchIYLnBiLlVwZGF0ZUdyb3VwTWVtYmVyUmVxGhYuZ29vZ2xlLnByb3RvYn'
    'VmLkVtcHR5EkUKEURlbGV0ZUdyb3VwTWVtYmVyEhgucGIuRGVsZXRlR3JvdXBNZW1iZXJSZXEa'
    'Fi5nb29nbGUucHJvdG9idWYuRW1wdHkSQgoPR2V0R3JvdXBNZW1iZXJzEhYucGIuR2V0R3JvdX'
    'BNZW1iZXJzUmVxGhcucGIuR2V0R3JvdXBNZW1iZXJzUmVzcA==');

