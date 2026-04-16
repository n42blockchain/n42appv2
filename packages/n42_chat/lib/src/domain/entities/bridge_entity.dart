import 'package:equatable/equatable.dart';

/// 支持的桥接协议类型。
enum BridgeProtocol {
  slack,
  discord,
  telegram,
  xmpp,
  irc,
  whatsapp,
  signal,
}

/// 桥接连接状态。
enum BridgeConnectionStatus {
  disconnected,
  connecting,
  connected,
  error,
}

/// 一个跨协议桥接实例。
///
/// 对应 Matrix Appservice Bridge（如 matrix-appservice-slack）的一个配置。
class BridgeEntity extends Equatable {
  const BridgeEntity({
    required this.id,
    required this.protocol,
    required this.displayName,
    this.status = BridgeConnectionStatus.disconnected,
    this.iconUrl,
    this.homeserverUrl,
    this.appserviceUrl,
    this.linkedRoomIds = const [],
    this.remoteWorkspaceId,
    this.remoteWorkspaceName,
    this.connectedAt,
    this.errorMessage,
  });

  final String id;
  final BridgeProtocol protocol;
  final String displayName;
  final BridgeConnectionStatus status;
  final String? iconUrl;
  final String? homeserverUrl;
  final String? appserviceUrl;
  final List<String> linkedRoomIds;
  final String? remoteWorkspaceId;
  final String? remoteWorkspaceName;
  final DateTime? connectedAt;
  final String? errorMessage;

  bool get isConnected => status == BridgeConnectionStatus.connected;

  String get protocolLabel => switch (protocol) {
        BridgeProtocol.slack => 'Slack',
        BridgeProtocol.discord => 'Discord',
        BridgeProtocol.telegram => 'Telegram',
        BridgeProtocol.xmpp => 'XMPP',
        BridgeProtocol.irc => 'IRC',
        BridgeProtocol.whatsapp => 'WhatsApp',
        BridgeProtocol.signal => 'Signal',
      };

  BridgeEntity copyWith({
    BridgeConnectionStatus? status,
    List<String>? linkedRoomIds,
    String? remoteWorkspaceId,
    String? remoteWorkspaceName,
    DateTime? connectedAt,
    String? errorMessage,
  }) {
    return BridgeEntity(
      id: id,
      protocol: protocol,
      displayName: displayName,
      status: status ?? this.status,
      iconUrl: iconUrl,
      homeserverUrl: homeserverUrl,
      appserviceUrl: appserviceUrl,
      linkedRoomIds: linkedRoomIds ?? this.linkedRoomIds,
      remoteWorkspaceId: remoteWorkspaceId ?? this.remoteWorkspaceId,
      remoteWorkspaceName: remoteWorkspaceName ?? this.remoteWorkspaceName,
      connectedAt: connectedAt ?? this.connectedAt,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'protocol': protocol.name,
        'display_name': displayName,
        'status': status.name,
        'icon_url': iconUrl,
        'homeserver_url': homeserverUrl,
        'appservice_url': appserviceUrl,
        'linked_room_ids': linkedRoomIds,
        'remote_workspace_id': remoteWorkspaceId,
        'remote_workspace_name': remoteWorkspaceName,
        'connected_at': connectedAt?.millisecondsSinceEpoch,
        'error_message': errorMessage,
      };

  factory BridgeEntity.fromJson(Map<String, dynamic> json) => BridgeEntity(
        id: json['id'] as String,
        protocol: BridgeProtocol.values.firstWhere(
          (p) => p.name == json['protocol'],
          orElse: () => BridgeProtocol.slack,
        ),
        displayName: json['display_name'] as String? ?? '',
        status: BridgeConnectionStatus.values.firstWhere(
          (s) => s.name == json['status'],
          orElse: () => BridgeConnectionStatus.disconnected,
        ),
        iconUrl: json['icon_url'] as String?,
        homeserverUrl: json['homeserver_url'] as String?,
        appserviceUrl: json['appservice_url'] as String?,
        linkedRoomIds: (json['linked_room_ids'] as List?)?.cast<String>() ?? const [],
        remoteWorkspaceId: json['remote_workspace_id'] as String?,
        remoteWorkspaceName: json['remote_workspace_name'] as String?,
        connectedAt: json['connected_at'] != null
            ? DateTime.fromMillisecondsSinceEpoch(json['connected_at'] as int)
            : null,
        errorMessage: json['error_message'] as String?,
      );

  @override
  List<Object?> get props => [
        id, protocol, displayName, status, iconUrl, homeserverUrl,
        appserviceUrl, linkedRoomIds, remoteWorkspaceId,
        remoteWorkspaceName, connectedAt, errorMessage,
      ];
}

/// 桥接的远端频道/房间映射。
class BridgeRoomMapping extends Equatable {
  const BridgeRoomMapping({
    required this.matrixRoomId,
    required this.remoteChannelId,
    required this.remoteChannelName,
    required this.bridgeId,
    this.isActive = true,
  });

  final String matrixRoomId;
  final String remoteChannelId;
  final String remoteChannelName;
  final String bridgeId;
  final bool isActive;

  @override
  List<Object?> get props => [
        matrixRoomId, remoteChannelId, remoteChannelName, bridgeId, isActive,
      ];
}
