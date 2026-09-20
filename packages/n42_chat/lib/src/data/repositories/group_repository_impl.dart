import '../../domain/repositories/contact_repository.dart';
import 'dart:typed_data';
import 'dart:async';

import 'package:matrix/matrix.dart' as matrix;

import '../../core/services/room_join_service.dart';
import '../../domain/entities/bot_config_entity.dart';
import '../../domain/entities/channel_entity.dart';
import '../../domain/entities/content_filter_entity.dart';
import '../../domain/entities/group_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/entities/token_gate_entity.dart';
import '../../domain/repositories/group_repository.dart';
import '../../integration/wallet_bridge.dart';
import '../datasources/matrix/matrix_group_datasource.dart';
import '../datasources/matrix/matrix_client_manager.dart';
import '../datasources/matrix/matrix_message_datasource.dart';
import '../../core/utils/debug_log.dart';
import '../../core/utils/friendly_display_name.dart';
import '../../core/utils/matrix_utils.dart';
import '../../core/utils/room_metadata_utils.dart';

/// 群聊仓库实现
class GroupRepositoryImpl implements IGroupRepository {
  static const String _channelMetaEventType = 'n42.room.channel_meta';

  final MatrixGroupDataSource _groupDataSource;
  final MatrixClientManager _clientManager;
  final IWalletBridge? _walletBridge;
  final IContactRepository? _contactRepository;
  final MatrixMessageDataSource? _messageDataSource;
  late final RoomJoinService _roomJoinService;

  GroupRepositoryImpl(
    this._groupDataSource,
    this._clientManager, {
    IWalletBridge? walletBridge,
    IContactRepository? contactRepository,
    MatrixMessageDataSource? messageDataSource,
    RoomJoinService? roomJoinService,
  }) : _contactRepository = contactRepository,
       _walletBridge = walletBridge,
       _messageDataSource = messageDataSource {
    _roomJoinService =
        roomJoinService ??
        RoomJoinService(_clientManager, verifyGate: verifyTokenGate);
  }

  @override
  Future<List<GroupEntity>> getGroups() async {
    final rooms = _groupDataSource.getAllGroups();
    return Future.wait(
      rooms.map((room) async {
        List<matrix.User>? members;
        try {
          members = await room.requestParticipants().timeout(
            const Duration(seconds: 10),
          );
        } catch (_) {
          // Keep usable cached group metadata during a transient refresh failure.
        }
        return _mapRoomToGroupEntity(room, members: members);
      }),
    );
  }

  @override
  Stream<List<GroupEntity>> watchGroups() async* {
    yield await getGroups();

    final stream = _groupDataSource.onGroupsChanged;
    if (stream != null) {
      await for (final _ in stream) {
        yield await getGroups();
      }
    }
  }

  @override
  Future<GroupEntity?> getGroup(String roomId) async {
    final room = _groupDataSource.getGroup(roomId);
    if (room == null) return null;

    final members = await _groupDataSource.getGroupMembers(roomId);
    return _mapRoomToGroupEntity(room, members: members);
  }

  @override
  Future<List<GroupMember>> getGroupMembers(String roomId) async {
    final users = await _groupDataSource.getGroupMembers(roomId);
    return users.map((user) => _mapUserToGroupMember(roomId, user)).toList();
  }

  @override
  Future<void> setMyGroupNickname(String roomId, String nickname) =>
      _groupDataSource.setMyGroupNickname(roomId, nickname);

  @override
  Future<String> createGroup({
    required String name,
    List<String> inviteUserIds = const [],
    String? topic,
    bool isPublic = false,
    bool enableEncryption = false,
    Uint8List? avatar,
  }) async {
    return await _groupDataSource.createGroup(
      name: name,
      inviteUserIds: inviteUserIds,
      topic: topic,
      isPublic: isPublic,
      enableEncryption: enableEncryption,
      avatar: avatar,
    );
  }

  @override
  Future<void> setGroupName(String roomId, String name) async {
    await _groupDataSource.setGroupName(roomId, name);
  }

  @override
  Future<void> setGroupTopic(String roomId, String topic) async {
    await _groupDataSource.setGroupTopic(roomId, topic);
  }

  @override
  Future<void> setGroupAvatar(String roomId, Uint8List avatar) async {
    await _groupDataSource.setGroupAvatar(roomId, avatar);
  }

  @override
  Future<void> setGroupAnnouncement(String roomId, String announcement) async {
    await _groupDataSource.setGroupAnnouncement(roomId, announcement);
  }

  @override
  Future<void> setGroupVisibility(String roomId, bool isPublic) async {
    await _groupDataSource.setGroupVisibility(roomId, isPublic);
  }

  @override
  Future<void> inviteUser(String roomId, String userId) async {
    await _groupDataSource.inviteUser(roomId, userId);
  }

  @override
  Future<void> inviteUsers(String roomId, List<String> userIds) async {
    await _groupDataSource.inviteUsers(roomId, userIds);
  }

  @override
  Future<void> kickMember(
    String roomId,
    String userId, {
    String? reason,
  }) async {
    await _groupDataSource.kickMember(roomId, userId, reason: reason);
  }

  @override
  Future<void> banMember(String roomId, String userId, {String? reason}) async {
    await _groupDataSource.banMember(roomId, userId, reason: reason);
  }

  @override
  Future<void> unbanMember(String roomId, String userId) async {
    await _groupDataSource.unbanMember(roomId, userId);
  }

  @override
  Future<void> setMemberPowerLevel(
    String roomId,
    String userId,
    int powerLevel,
  ) async {
    await _groupDataSource.setUserPowerLevel(roomId, userId, powerLevel);
  }

  @override
  Future<void> setAsAdmin(String roomId, String userId) async {
    await setMemberPowerLevel(roomId, userId, 50);
  }

  @override
  Future<void> removeAdmin(String roomId, String userId) async {
    await setMemberPowerLevel(roomId, userId, 0);
  }

  @override
  Future<void> joinGroup(String roomId) async {
    await _roomJoinService.join(roomId);
  }

  @override
  Future<String> joinGroupByAlias(String alias) async {
    return await _roomJoinService.join(alias);
  }

  @override
  Future<String> getGroupInviteLink(String roomId) async {
    return _groupDataSource.getGroupInviteLink(roomId);
  }

  @override
  Future<void> leaveGroup(String roomId) async {
    await _groupDataSource.leaveGroup(roomId);
  }

  @override
  Future<void> deleteGroup(String roomId) async {
    await _groupDataSource.deleteGroup(roomId);
  }

  @override
  Future<List<GroupEntity>> getPendingGroupInvites() async {
    final rooms = _groupDataSource.getPendingGroupInvites();
    final client = _clientManager.client;
    final userId = client?.userID;
    final pending = <GroupEntity>[];
    for (final room in rooms) {
      final invitation = userId == null
          ? null
          : room.getState(matrix.EventTypes.RoomMember, userId);
      final inviter = invitation?.senderId;
      var joined = false;
      if (_contactRepository != null &&
          inviter != null &&
          inviter != userId &&
          invitation?.content['membership'] == 'invite') {
        try {
          final contact = await _contactRepository.getContactById(inviter);
          if (!identical(client, _clientManager.client) ||
              client?.userID != userId) {
            throw StateError('Account changed during group invitation review');
          }
          if (contact?.isFriend == true &&
              contact?.isBlocked != true &&
              room.membership == matrix.Membership.invite) {
            await _roomJoinService.join(room.id);
            joined = true;
          }
        } catch (_) {
          // A failed relationship lookup/admission remains a visible invitation.
        }
      }
      if (!identical(client, _clientManager.client) ||
          client?.userID != userId) {
        throw StateError('Account changed during group invitation review');
      }
      if (!joined) pending.add(_mapRoomToGroupEntity(room));
    }
    return pending;
  }

  @override
  Future<void> acceptGroupInvite(String roomId) async {
    await _roomJoinService.join(roomId);
  }

  @override
  Future<void> rejectGroupInvite(String roomId) async {
    await _groupDataSource.rejectGroupInvite(roomId);
  }

  // ============================================
  // 置顶消息管理
  // ============================================

  @override
  Future<List<String>> getPinnedEventIds(String roomId) async {
    return _groupDataSource.getPinnedEventIds(roomId);
  }

  @override
  Future<void> pinMessage(String roomId, String eventId) async {
    await _groupDataSource.pinMessage(roomId, eventId);
  }

  @override
  Future<void> unpinMessage(String roomId, String eventId) async {
    await _groupDataSource.unpinMessage(roomId, eventId);
  }

  @override
  Future<void> setPinnedMessages(String roomId, List<String> eventIds) async {
    await _groupDataSource.setPinnedMessages(roomId, eventIds);
  }

  @override
  bool canPinMessages(String roomId) {
    return _groupDataSource.canPinMessages(roomId);
  }

  @override
  Future<MessageEntity?> getMessageById(String roomId, String eventId) async {
    final msgDs = _messageDataSource;
    if (msgDs == null) return null;

    final client = _clientManager.client;
    if (client == null) return null;

    final room = client.getRoomById(roomId);
    if (room == null) return null;

    final event = await room.getEventById(eventId);
    if (event == null) return null;

    return msgDs.mapEventToMessage(event, room);
  }

  // ============================================
  // 群人数上限
  // ============================================

  @override
  Future<int?> getMaxMembers(String roomId) async =>
      _groupDataSource.getMaxMembers(roomId);

  @override
  Future<void> setMaxMembers(String roomId, int? maxMembers) async =>
      _groupDataSource.setMaxMembers(roomId, maxMembers);

  // ============================================
  // 子频道管理
  // ============================================

  @override
  Future<List<ChannelEntity>> getChannels(String parentRoomId) async =>
      _groupDataSource.getChannels(parentRoomId);

  @override
  Future<String> createChannel(
    String parentRoomId, {
    required String name,
    String? topic,
    String? category,
  }) async => _groupDataSource.createChannel(
    parentRoomId,
    name: name,
    topic: topic,
    category: category,
  );

  @override
  Future<void> updateChannel(
    String parentRoomId,
    String channelRoomId, {
    String? name,
    String? topic,
    String? category,
  }) async => _groupDataSource.updateChannel(
    parentRoomId,
    channelRoomId,
    name: name,
    topic: topic,
    category: category,
  );

  @override
  Future<void> deleteChannel(String parentRoomId, String channelRoomId) async =>
      _groupDataSource.deleteChannel(parentRoomId, channelRoomId);

  // ============================================
  // Bot 配置
  // ============================================

  @override
  Future<BotConfig?> getBotConfig(String roomId) async =>
      _groupDataSource.getBotConfig(roomId);

  @override
  Future<void> setBotConfig(String roomId, BotConfig config) async =>
      _groupDataSource.setBotConfig(roomId, config);

  // ============================================
  // 关键词过滤
  // ============================================

  @override
  Future<ContentFilterConfig?> getContentFilter(String roomId) async =>
      _groupDataSource.getContentFilter(roomId);

  @override
  Future<void> setContentFilter(
    String roomId,
    ContentFilterConfig config,
  ) async => _groupDataSource.setContentFilter(roomId, config);

  // ============================================
  // 代币门控
  // ============================================

  @override
  Future<TokenGateConfig?> getTokenGate(String roomId) async {
    final data = _groupDataSource.getTokenGateConfigStrict(roomId);
    if (data == null) return null;
    return _parseTokenGate(data);
  }

  @override
  Future<void> setTokenGate(String roomId, TokenGateConfig config) async {
    _parseTokenGate(config.toJson());
    await _groupDataSource.setTokenGateConfig(roomId, config.toJson());
  }

  @override
  Future<TokenGateVerificationResult> verifyTokenGate(String roomId) async {
    if (_walletBridge == null) {
      return TokenGateVerificationResult.error('Wallet not connected');
    }

    final TokenGateConfig? config;
    try {
      config = await getTokenGate(roomId);
    } catch (e) {
      return TokenGateVerificationResult.error('Unable to read token gate: $e');
    }
    if (config == null || !config.enabled || config.rules.isEmpty) {
      return const TokenGateVerificationResult(passed: true);
    }

    final ruleResults = <TokenGateRuleResult>[];

    for (final rule in config.rules) {
      try {
        BigInt actualBalance;

        switch (rule.tokenStandard) {
          case TokenStandard.erc20:
            actualBalance = await _walletBridge.getErc20Balance(
              contractAddress: rule.contractAddress ?? '',
              chainId: rule.chainId,
            );
            break;
          case TokenStandard.erc721:
            final nftCount = await _walletBridge.getErc721Balance(
              contractAddress: rule.contractAddress ?? '',
              chainId: rule.chainId,
            );
            actualBalance = BigInt.from(nftCount);
            break;
          case TokenStandard.erc1155:
            actualBalance = await _walletBridge.getErc1155Balance(
              contractAddress: rule.contractAddress ?? '',
              tokenId: rule.tokenId ?? BigInt.zero,
              chainId: rule.chainId,
            );
            break;
          case TokenStandard.native:
            if (!const {1, 10, 56, 137, 42161}.contains(rule.chainId)) {
              throw const FormatException('Unsupported native token chain');
            }
            final balanceStr = await _walletBridge.getBalance(
              nativeTokenSymbolForChainId(rule.chainId),
            );
            actualBalance = _parseNativeBalance(balanceStr);
            break;
        }

        ruleResults.add(
          TokenGateRuleResult(
            rule: rule,
            passed: actualBalance >= rule.minBalance,
            actualBalance: actualBalance,
          ),
        );
      } catch (e) {
        ruleResults.add(
          TokenGateRuleResult(
            rule: rule,
            passed: false,
            actualBalance: BigInt.zero,
            errorMessage: e.toString(),
          ),
        );
      }
    }

    final passed = config.operator == GateOperator.and
        ? ruleResults.every((r) => r.passed)
        : ruleResults.any((r) => r.passed);

    return TokenGateVerificationResult(
      passed: passed,
      ruleResults: ruleResults,
    );
  }

  /// The display model has tolerant legacy defaults; admission checks cannot
  /// reinterpret corrupt rules as a zero threshold or a disabled gate.
  TokenGateConfig _parseTokenGate(Map<String, dynamic> data) {
    if (data['enabled'] is! bool) {
      throw const FormatException('Invalid token gate enabled flag');
    }
    if (data['enabled'] == true) {
      final rules = data['rules'];
      final operator = data['operator'];
      if (rules is! List ||
          rules.isEmpty ||
          (operator != null &&
              !GateOperator.values.any((v) => v.name == operator))) {
        throw const FormatException('Invalid token gate rules or operator');
      }
      for (final rule in rules) {
        if (rule is! Map<String, dynamic> ||
            !TokenStandard.values.any(
              (v) => v.name == rule['token_standard'],
            )) {
          throw const FormatException('Invalid token gate rule');
        }
        final minimum = rule['min_balance'];
        final chainId = rule['chain_id'];
        if (minimum is! String ||
            !RegExp(r'^\d+$').hasMatch(minimum) ||
            chainId is! int ||
            chainId <= 0) {
          throw const FormatException('Invalid token gate minimum or chain');
        }
        if (rule['token_standard'] != TokenStandard.native.name) {
          final address = rule['contract_address'];
          if (address is! String ||
              !RegExp(r'^0x[0-9a-fA-F]{40}$').hasMatch(address)) {
            throw const FormatException('Invalid token gate contract');
          }
        }
        if (rule['token_standard'] == TokenStandard.erc1155.name) {
          final tokenId = rule['token_id'];
          if (tokenId is! String || !RegExp(r'^\d+$').hasMatch(tokenId)) {
            throw const FormatException('Invalid ERC-1155 token ID');
          }
        }
      }
    }
    return TokenGateConfig.fromJson(data);
  }

  BigInt _parseNativeBalance(String value) {
    final normalized = value.trim();
    if (!RegExp(r'^\d+(?:\.\d{1,18})?$').hasMatch(normalized)) {
      throw const FormatException('Invalid native token balance');
    }
    final parts = normalized.split('.');
    final fraction = parts.length == 1 ? '' : parts[1];
    return BigInt.parse(parts[0]) * BigInt.from(10).pow(18) +
        BigInt.parse(fraction.padRight(18, '0'));
  }

  // ============================================
  // 成员加入监听
  // ============================================

  @override
  Stream<String> watchMemberJoinEvents(String roomId) =>
      _groupDataSource.watchMemberJoinEvents(roomId);

  @override
  Future<void> sendBotNotice(String roomId, String message) =>
      _groupDataSource.sendBotNotice(roomId, message);

  // ============================================
  // 辅助方法
  // ============================================

  GroupEntity _mapRoomToGroupEntity(
    matrix.Room room, {
    List<matrix.User>? members,
  }) {
    final avatarUrlStr = _groupDataSource.getGroupAvatarUrl(room.id);
    final myUserId = _clientManager.client?.userID;
    final channelMeta = room.getState(_channelMetaEventType)?.content;
    final isChannel = channelMeta?['parent_room_id'] != null;
    final joinRule = _mapJoinRule(room.joinRules);
    final powerLevels = room
        .getState(matrix.EventTypes.RoomPowerLevels)
        ?.content;
    final eventLevels = powerLevels?['events'] as Map?;
    final messagePowerLevel =
        _asInt(eventLevels?['m.room.message']) ??
        _asInt(powerLevels?['events_default']) ??
        0;
    final membersCanSpeak =
        channelMeta?['members_can_speak'] as bool? ?? messagePowerLevel <= 0;
    final showMemberList =
        channelMeta?['show_member_list'] as bool? ?? !isChannel;
    final slowModeInterval = _asInt(channelMeta?['slow_mode_interval']) ?? 0;
    final canEditName = _groupDataSource.canSendStateEvent(
      room.id,
      'm.room.name',
      fallbackMinPowerLevel: 50,
    );
    final canEditAvatar = _groupDataSource.canSendStateEvent(
      room.id,
      'm.room.avatar',
      fallbackMinPowerLevel: 50,
    );
    final canEditDescription = _groupDataSource.canSendStateEvent(
      room.id,
      'm.room.topic',
      fallbackMinPowerLevel: 50,
    );
    final canChangeVisibility = _groupDataSource.canSendStateEvent(
      room.id,
      'm.room.join_rules',
      fallbackMinPowerLevel: 50,
    );
    final canManageChannels = _groupDataSource.canSendStateEvent(
      room.id,
      'n42.room.channels',
      fallbackMinPowerLevel: 50,
    );
    final canManageBot = _groupDataSource.canSendStateEvent(
      room.id,
      'n42.room.bot_config',
      fallbackMinPowerLevel: 50,
    );
    final canManageContentFilter = _groupDataSource.canSendStateEvent(
      room.id,
      'n42.room.content_filter',
      fallbackMinPowerLevel: 50,
    );
    final canManageMemberLimit = _groupDataSource.canSendStateEvent(
      room.id,
      'n42.room.settings',
      fallbackMinPowerLevel: 50,
    );
    final canManageTokenGate = _groupDataSource.canSendStateEvent(
      room.id,
      'n42.token_gate',
      fallbackMinPowerLevel: 50,
    );
    final canChangeSettings =
        _groupDataSource.canChangeSettings(room.id) ||
        canEditName ||
        canEditAvatar ||
        canEditDescription ||
        canChangeVisibility ||
        canManageChannels ||
        canManageBot ||
        canManageContentFilter ||
        canManageMemberLimit ||
        canManageTokenGate;

    GroupRole myRole = GroupRole.member;
    if (_groupDataSource.isGroupOwner(room.id, myUserId)) {
      myRole = GroupRole.owner;
    } else if (_groupDataSource.isGroupAdmin(room.id, myUserId)) {
      myRole = GroupRole.admin;
    }

    // 成员数量包括已加入和已邀请的成员
    final joinedCount = room.summary.mJoinedMemberCount ?? 0;
    final invitedCount = room.summary.mInvitedMemberCount ?? 0;

    // 获取置顶消息ID列表
    final pinnedEventIds = _groupDataSource.getPinnedEventIds(room.id);

    // Read token gate config
    TokenGateConfig? tokenGateConfig;
    try {
      final tokenGateData = _groupDataSource.getTokenGateConfig(room.id);
      if (tokenGateData != null) {
        tokenGateConfig = TokenGateConfig.fromJson(tokenGateData);
      }
    } catch (e) {
      debugLog('Error: $e');
    }

    final maxMembers = _groupDataSource.getMaxMembers(room.id);
    final knownMembers =
        members ??
        room.getParticipants([
          matrix.Membership.join,
          matrix.Membership.invite,
        ]);
    final knownCount = knownMembers
        .where(
          (u) =>
              u.membership == matrix.Membership.join ||
              u.membership == matrix.Membership.invite,
        )
        .map((u) => u.id)
        .toSet()
        .length;
    final knownInvitedCount = knownMembers
        .where((u) => u.membership == matrix.Membership.invite)
        .map((u) => u.id)
        .toSet()
        .length;
    final pendingCount = knownInvitedCount > invitedCount
        ? knownInvitedCount
        : invitedCount;
    final summaryCount = joinedCount + invitedCount;
    final memberCount = knownCount > summaryCount ? knownCount : summaryCount;
    final canonicalAliasLocalpart = extractAliasLocalpart(room.canonicalAlias);
    final groupType = isChannel
        ? GroupType.channel
        : (memberCount > 1000 || (maxMembers ?? 0) > 1000)
        ? GroupType.superGroup
        : GroupType.group;

    return GroupEntity(
      roomId: room.id,
      name: room.getLocalizedDisplayname(),
      avatarUrl: avatarUrlStr,
      topic: room.topic,
      announcement: _groupDataSource.getGroupAnnouncement(room.id),
      pinnedEventIds: pinnedEventIds,
      memberCount: memberCount,
      invitedMemberCount: pendingCount,
      maxMembers: maxMembers,
      members:
          members?.map((u) => _mapUserToGroupMember(room.id, u)).toList() ?? [],
      isEncrypted: room.encrypted,
      isPublic: room.joinRules == matrix.JoinRules.public,
      createdAt: null, // StrippedStateEvent doesn't have originServerTs
      myRole: myRole,
      canInvite: _groupDataSource.canInviteMembers(room.id),
      canKick: _groupDataSource.canKickMembers(room.id),
      canChangeSettings: canChangeSettings,
      canEditName: canEditName,
      canEditAvatar: canEditAvatar,
      canEditDescription: canEditDescription,
      canChangeVisibility: canChangeVisibility,
      canManageChannels: canManageChannels,
      canManageBot: canManageBot,
      canManageContentFilter: canManageContentFilter,
      canManageMemberLimit: canManageMemberLimit,
      canManageTokenGate: canManageTokenGate,
      groupType: groupType,
      subscriberCount: isChannel ? memberCount : 0,
      joinRule: joinRule,
      membersCanSpeak: membersCanSpeak,
      showMemberList: showMemberList,
      slowModeInterval: slowModeInterval,
      channelUsername: canonicalAliasLocalpart,
      tokenGate: tokenGateConfig,
    );
  }

  GroupMember _mapUserToGroupMember(String roomId, matrix.User user) {
    final powerLevel = _groupDataSource.getUserPowerLevel(roomId, user.id);

    GroupRole role = GroupRole.member;
    if (powerLevel >= 100) {
      role = GroupRole.owner;
    } else if (powerLevel >= 50) {
      role = GroupRole.admin;
    }

    String? avatarUrl;
    final client = _clientManager.client;
    if (user.avatarUrl != null && client != null) {
      avatarUrl = MatrixUtils.getAvatarUrl(
        user.avatarUrl,
        client: client,
        size: 96,
      );
    }

    // 根据 Matrix 用户状态确定成员状态
    final membershipStatus = user.membership == matrix.Membership.invite
        ? MembershipStatus.invited
        : MembershipStatus.joined;

    return GroupMember(
      userId: user.id,
      displayName: FriendlyDisplayName.resolve(
        displayName: user.calcDisplayname(),
        userId: user.id,
      ),
      avatarUrl: avatarUrl,
      role: role,
      powerLevel: powerLevel,
      membershipStatus: membershipStatus,
    );
  }

  JoinRule _mapJoinRule(matrix.JoinRules? joinRules) {
    switch (joinRules) {
      case matrix.JoinRules.public:
        return JoinRule.public;
      case matrix.JoinRules.knock:
        return JoinRule.knock;
      case matrix.JoinRules.restricted:
      case matrix.JoinRules.knockRestricted:
        return JoinRule.restricted;
      case matrix.JoinRules.private:
      case matrix.JoinRules.invite:
      case null:
        return JoinRule.invite;
    }
  }

  int? _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }
}
