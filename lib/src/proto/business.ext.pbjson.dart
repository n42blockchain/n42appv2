//
//  Generated code. Do not modify.
//  source: business.ext.proto
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

@$core.Deprecated('Use signInReqDescriptor instead')
const SignInReq$json = {
  '1': 'SignInReq',
  '2': [
    {'1': 'phone_number', '3': 1, '4': 1, '5': 9, '10': 'phoneNumber'},
    {'1': 'code', '3': 2, '4': 1, '5': 9, '10': 'code'},
    {'1': 'device_id', '3': 3, '4': 1, '5': 3, '10': 'deviceId'},
  ],
};

/// Descriptor for `SignInReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List signInReqDescriptor = $convert.base64Decode(
    'CglTaWduSW5SZXESIQoMcGhvbmVfbnVtYmVyGAEgASgJUgtwaG9uZU51bWJlchISCgRjb2RlGA'
    'IgASgJUgRjb2RlEhsKCWRldmljZV9pZBgDIAEoA1IIZGV2aWNlSWQ=');

@$core.Deprecated('Use signInRespDescriptor instead')
const SignInResp$json = {
  '1': 'SignInResp',
  '2': [
    {'1': 'is_new', '3': 1, '4': 1, '5': 8, '10': 'isNew'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 3, '10': 'userId'},
    {'1': 'token', '3': 3, '4': 1, '5': 9, '10': 'token'},
  ],
};

/// Descriptor for `SignInResp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List signInRespDescriptor = $convert.base64Decode(
    'CgpTaWduSW5SZXNwEhUKBmlzX25ldxgBIAEoCFIFaXNOZXcSFwoHdXNlcl9pZBgCIAEoA1IGdX'
    'NlcklkEhQKBXRva2VuGAMgASgJUgV0b2tlbg==');

@$core.Deprecated('Use userDescriptor instead')
const User$json = {
  '1': 'User',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 3, '10': 'userId'},
    {'1': 'nickname', '3': 2, '4': 1, '5': 9, '10': 'nickname'},
    {'1': 'sex', '3': 3, '4': 1, '5': 5, '10': 'sex'},
    {'1': 'avatar_url', '3': 4, '4': 1, '5': 9, '10': 'avatarUrl'},
    {'1': 'extra', '3': 5, '4': 1, '5': 9, '10': 'extra'},
    {'1': 'create_time', '3': 6, '4': 1, '5': 3, '10': 'createTime'},
    {'1': 'update_time', '3': 7, '4': 1, '5': 3, '10': 'updateTime'},
  ],
};

/// Descriptor for `User`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userDescriptor = $convert.base64Decode(
    'CgRVc2VyEhcKB3VzZXJfaWQYASABKANSBnVzZXJJZBIaCghuaWNrbmFtZRgCIAEoCVIIbmlja2'
    '5hbWUSEAoDc2V4GAMgASgFUgNzZXgSHQoKYXZhdGFyX3VybBgEIAEoCVIJYXZhdGFyVXJsEhQK'
    'BWV4dHJhGAUgASgJUgVleHRyYRIfCgtjcmVhdGVfdGltZRgGIAEoA1IKY3JlYXRlVGltZRIfCg'
    't1cGRhdGVfdGltZRgHIAEoA1IKdXBkYXRlVGltZQ==');

@$core.Deprecated('Use getUserReqDescriptor instead')
const GetUserReq$json = {
  '1': 'GetUserReq',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 3, '10': 'userId'},
  ],
};

/// Descriptor for `GetUserReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getUserReqDescriptor = $convert.base64Decode(
    'CgpHZXRVc2VyUmVxEhcKB3VzZXJfaWQYASABKANSBnVzZXJJZA==');

@$core.Deprecated('Use getUserRespDescriptor instead')
const GetUserResp$json = {
  '1': 'GetUserResp',
  '2': [
    {'1': 'user', '3': 1, '4': 1, '5': 11, '6': '.pb.User', '10': 'user'},
  ],
};

/// Descriptor for `GetUserResp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getUserRespDescriptor = $convert.base64Decode(
    'CgtHZXRVc2VyUmVzcBIcCgR1c2VyGAEgASgLMggucGIuVXNlclIEdXNlcg==');

@$core.Deprecated('Use updateUserReqDescriptor instead')
const UpdateUserReq$json = {
  '1': 'UpdateUserReq',
  '2': [
    {'1': 'nickname', '3': 1, '4': 1, '5': 9, '10': 'nickname'},
    {'1': 'sex', '3': 2, '4': 1, '5': 5, '10': 'sex'},
    {'1': 'avatar_url', '3': 3, '4': 1, '5': 9, '10': 'avatarUrl'},
    {'1': 'extra', '3': 4, '4': 1, '5': 9, '10': 'extra'},
  ],
};

/// Descriptor for `UpdateUserReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateUserReqDescriptor = $convert.base64Decode(
    'Cg1VcGRhdGVVc2VyUmVxEhoKCG5pY2tuYW1lGAEgASgJUghuaWNrbmFtZRIQCgNzZXgYAiABKA'
    'VSA3NleBIdCgphdmF0YXJfdXJsGAMgASgJUglhdmF0YXJVcmwSFAoFZXh0cmEYBCABKAlSBWV4'
    'dHJh');

@$core.Deprecated('Use searchUserReqDescriptor instead')
const SearchUserReq$json = {
  '1': 'SearchUserReq',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
  ],
};

/// Descriptor for `SearchUserReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List searchUserReqDescriptor = $convert.base64Decode(
    'Cg1TZWFyY2hVc2VyUmVxEhAKA2tleRgBIAEoCVIDa2V5');

@$core.Deprecated('Use searchUserRespDescriptor instead')
const SearchUserResp$json = {
  '1': 'SearchUserResp',
  '2': [
    {'1': 'users', '3': 1, '4': 3, '5': 11, '6': '.pb.User', '10': 'users'},
  ],
};

/// Descriptor for `SearchUserResp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List searchUserRespDescriptor = $convert.base64Decode(
    'Cg5TZWFyY2hVc2VyUmVzcBIeCgV1c2VycxgBIAMoCzIILnBiLlVzZXJSBXVzZXJz');

const $core.Map<$core.String, $core.dynamic> BusinessExtServiceBase$json = {
  '1': 'BusinessExt',
  '2': [
    {'1': 'SignIn', '2': '.pb.SignInReq', '3': '.pb.SignInResp'},
    {'1': 'GetUser', '2': '.pb.GetUserReq', '3': '.pb.GetUserResp'},
    {'1': 'UpdateUser', '2': '.pb.UpdateUserReq', '3': '.google.protobuf.Empty'},
    {'1': 'SearchUser', '2': '.pb.SearchUserReq', '3': '.pb.SearchUserResp'},
  ],
};

@$core.Deprecated('Use businessExtServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> BusinessExtServiceBase$messageJson = {
  '.pb.SignInReq': SignInReq$json,
  '.pb.SignInResp': SignInResp$json,
  '.pb.GetUserReq': GetUserReq$json,
  '.pb.GetUserResp': GetUserResp$json,
  '.pb.User': User$json,
  '.pb.UpdateUserReq': UpdateUserReq$json,
  '.google.protobuf.Empty': $0.Empty$json,
  '.pb.SearchUserReq': SearchUserReq$json,
  '.pb.SearchUserResp': SearchUserResp$json,
};

/// Descriptor for `BusinessExt`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List businessExtServiceDescriptor = $convert.base64Decode(
    'CgtCdXNpbmVzc0V4dBInCgZTaWduSW4SDS5wYi5TaWduSW5SZXEaDi5wYi5TaWduSW5SZXNwEi'
    'oKB0dldFVzZXISDi5wYi5HZXRVc2VyUmVxGg8ucGIuR2V0VXNlclJlc3ASNwoKVXBkYXRlVXNl'
    'chIRLnBiLlVwZGF0ZVVzZXJSZXEaFi5nb29nbGUucHJvdG9idWYuRW1wdHkSMwoKU2VhcmNoVX'
    'NlchIRLnBiLlNlYXJjaFVzZXJSZXEaEi5wYi5TZWFyY2hVc2VyUmVzcA==');

