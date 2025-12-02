//
//  Generated code. Do not modify.
//  source: logic.ext.proto
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

import 'google/protobuf/empty.pb.dart' as $0;
import 'logic.ext.pb.dart' as $1;
import 'logic.ext.pbjson.dart';

export 'logic.ext.pb.dart';

abstract class LogicExtServiceBase extends $pb.GeneratedService {
  $async.Future<$1.RegisterDeviceResp> registerDevice($pb.ServerContext ctx, $1.RegisterDeviceReq request);
  $async.Future<$0.Empty> pushRoom($pb.ServerContext ctx, $1.PushRoomReq request);
  $async.Future<$1.SendMessageResp> sendMessageToFriend($pb.ServerContext ctx, $1.SendMessageReq request);
  $async.Future<$0.Empty> addFriend($pb.ServerContext ctx, $1.AddFriendReq request);
  $async.Future<$0.Empty> agreeAddFriend($pb.ServerContext ctx, $1.AgreeAddFriendReq request);
  $async.Future<$1.SetFriendResp> setFriend($pb.ServerContext ctx, $1.SetFriendReq request);
  $async.Future<$1.GetFriendsResp> getFriends($pb.ServerContext ctx, $0.Empty request);
  $async.Future<$1.SendMessageResp> sendMessageToGroup($pb.ServerContext ctx, $1.SendMessageReq request);
  $async.Future<$1.CreateGroupResp> createGroup($pb.ServerContext ctx, $1.CreateGroupReq request);
  $async.Future<$0.Empty> updateGroup($pb.ServerContext ctx, $1.UpdateGroupReq request);
  $async.Future<$1.GetGroupResp> getGroup($pb.ServerContext ctx, $1.GetGroupReq request);
  $async.Future<$1.GetGroupsResp> getGroups($pb.ServerContext ctx, $0.Empty request);
  $async.Future<$1.AddGroupMembersResp> addGroupMembers($pb.ServerContext ctx, $1.AddGroupMembersReq request);
  $async.Future<$0.Empty> updateGroupMember($pb.ServerContext ctx, $1.UpdateGroupMemberReq request);
  $async.Future<$0.Empty> deleteGroupMember($pb.ServerContext ctx, $1.DeleteGroupMemberReq request);
  $async.Future<$1.GetGroupMembersResp> getGroupMembers($pb.ServerContext ctx, $1.GetGroupMembersReq request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'RegisterDevice': return $1.RegisterDeviceReq();
      case 'PushRoom': return $1.PushRoomReq();
      case 'SendMessageToFriend': return $1.SendMessageReq();
      case 'AddFriend': return $1.AddFriendReq();
      case 'AgreeAddFriend': return $1.AgreeAddFriendReq();
      case 'SetFriend': return $1.SetFriendReq();
      case 'GetFriends': return $0.Empty();
      case 'SendMessageToGroup': return $1.SendMessageReq();
      case 'CreateGroup': return $1.CreateGroupReq();
      case 'UpdateGroup': return $1.UpdateGroupReq();
      case 'GetGroup': return $1.GetGroupReq();
      case 'GetGroups': return $0.Empty();
      case 'AddGroupMembers': return $1.AddGroupMembersReq();
      case 'UpdateGroupMember': return $1.UpdateGroupMemberReq();
      case 'DeleteGroupMember': return $1.DeleteGroupMemberReq();
      case 'GetGroupMembers': return $1.GetGroupMembersReq();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'RegisterDevice': return this.registerDevice(ctx, request as $1.RegisterDeviceReq);
      case 'PushRoom': return this.pushRoom(ctx, request as $1.PushRoomReq);
      case 'SendMessageToFriend': return this.sendMessageToFriend(ctx, request as $1.SendMessageReq);
      case 'AddFriend': return this.addFriend(ctx, request as $1.AddFriendReq);
      case 'AgreeAddFriend': return this.agreeAddFriend(ctx, request as $1.AgreeAddFriendReq);
      case 'SetFriend': return this.setFriend(ctx, request as $1.SetFriendReq);
      case 'GetFriends': return this.getFriends(ctx, request as $0.Empty);
      case 'SendMessageToGroup': return this.sendMessageToGroup(ctx, request as $1.SendMessageReq);
      case 'CreateGroup': return this.createGroup(ctx, request as $1.CreateGroupReq);
      case 'UpdateGroup': return this.updateGroup(ctx, request as $1.UpdateGroupReq);
      case 'GetGroup': return this.getGroup(ctx, request as $1.GetGroupReq);
      case 'GetGroups': return this.getGroups(ctx, request as $0.Empty);
      case 'AddGroupMembers': return this.addGroupMembers(ctx, request as $1.AddGroupMembersReq);
      case 'UpdateGroupMember': return this.updateGroupMember(ctx, request as $1.UpdateGroupMemberReq);
      case 'DeleteGroupMember': return this.deleteGroupMember(ctx, request as $1.DeleteGroupMemberReq);
      case 'GetGroupMembers': return this.getGroupMembers(ctx, request as $1.GetGroupMembersReq);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => LogicExtServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => LogicExtServiceBase$messageJson;
}

