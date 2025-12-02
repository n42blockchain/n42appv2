//
//  Generated code. Do not modify.
//  source: business.int.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

import 'business.ext.pbjson.dart' as $0;
import 'google/protobuf/empty.pbjson.dart' as $1;

@$core.Deprecated('Use authReqDescriptor instead')
const AuthReq$json = {
  '1': 'AuthReq',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 3, '10': 'userId'},
    {'1': 'device_id', '3': 2, '4': 1, '5': 3, '10': 'deviceId'},
    {'1': 'token', '3': 3, '4': 1, '5': 9, '10': 'token'},
  ],
};

/// Descriptor for `AuthReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List authReqDescriptor = $convert.base64Decode(
    'CgdBdXRoUmVxEhcKB3VzZXJfaWQYASABKANSBnVzZXJJZBIbCglkZXZpY2VfaWQYAiABKANSCG'
    'RldmljZUlkEhQKBXRva2VuGAMgASgJUgV0b2tlbg==');

@$core.Deprecated('Use getUsersReqDescriptor instead')
const GetUsersReq$json = {
  '1': 'GetUsersReq',
  '2': [
    {'1': 'user_ids', '3': 1, '4': 3, '5': 11, '6': '.pb.GetUsersReq.UserIdsEntry', '10': 'userIds'},
  ],
  '3': [GetUsersReq_UserIdsEntry$json],
};

@$core.Deprecated('Use getUsersReqDescriptor instead')
const GetUsersReq_UserIdsEntry$json = {
  '1': 'UserIdsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 3, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 5, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `GetUsersReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getUsersReqDescriptor = $convert.base64Decode(
    'CgtHZXRVc2Vyc1JlcRI3Cgh1c2VyX2lkcxgBIAMoCzIcLnBiLkdldFVzZXJzUmVxLlVzZXJJZH'
    'NFbnRyeVIHdXNlcklkcxo6CgxVc2VySWRzRW50cnkSEAoDa2V5GAEgASgDUgNrZXkSFAoFdmFs'
    'dWUYAiABKAVSBXZhbHVlOgI4AQ==');

@$core.Deprecated('Use getUsersRespDescriptor instead')
const GetUsersResp$json = {
  '1': 'GetUsersResp',
  '2': [
    {'1': 'users', '3': 1, '4': 3, '5': 11, '6': '.pb.GetUsersResp.UsersEntry', '10': 'users'},
  ],
  '3': [GetUsersResp_UsersEntry$json],
};

@$core.Deprecated('Use getUsersRespDescriptor instead')
const GetUsersResp_UsersEntry$json = {
  '1': 'UsersEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 3, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 11, '6': '.pb.User', '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `GetUsersResp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getUsersRespDescriptor = $convert.base64Decode(
    'CgxHZXRVc2Vyc1Jlc3ASMQoFdXNlcnMYASADKAsyGy5wYi5HZXRVc2Vyc1Jlc3AuVXNlcnNFbn'
    'RyeVIFdXNlcnMaQgoKVXNlcnNFbnRyeRIQCgNrZXkYASABKANSA2tleRIeCgV2YWx1ZRgCIAEo'
    'CzIILnBiLlVzZXJSBXZhbHVlOgI4AQ==');

const $core.Map<$core.String, $core.dynamic> BusinessIntServiceBase$json = {
  '1': 'BusinessInt',
  '2': [
    {'1': 'Auth', '2': '.pb.AuthReq', '3': '.google.protobuf.Empty'},
    {'1': 'GetUser', '2': '.pb.GetUserReq', '3': '.pb.GetUserResp'},
    {'1': 'GetUsers', '2': '.pb.GetUsersReq', '3': '.pb.GetUsersResp'},
  ],
};

@$core.Deprecated('Use businessIntServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> BusinessIntServiceBase$messageJson = {
  '.pb.AuthReq': AuthReq$json,
  '.google.protobuf.Empty': $1.Empty$json,
  '.pb.GetUserReq': $0.GetUserReq$json,
  '.pb.GetUserResp': $0.GetUserResp$json,
  '.pb.User': $0.User$json,
  '.pb.GetUsersReq': GetUsersReq$json,
  '.pb.GetUsersReq.UserIdsEntry': GetUsersReq_UserIdsEntry$json,
  '.pb.GetUsersResp': GetUsersResp$json,
  '.pb.GetUsersResp.UsersEntry': GetUsersResp_UsersEntry$json,
};

/// Descriptor for `BusinessInt`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List businessIntServiceDescriptor = $convert.base64Decode(
    'CgtCdXNpbmVzc0ludBIrCgRBdXRoEgsucGIuQXV0aFJlcRoWLmdvb2dsZS5wcm90b2J1Zi5FbX'
    'B0eRIqCgdHZXRVc2VyEg4ucGIuR2V0VXNlclJlcRoPLnBiLkdldFVzZXJSZXNwEi0KCEdldFVz'
    'ZXJzEg8ucGIuR2V0VXNlcnNSZXEaEC5wYi5HZXRVc2Vyc1Jlc3A=');

