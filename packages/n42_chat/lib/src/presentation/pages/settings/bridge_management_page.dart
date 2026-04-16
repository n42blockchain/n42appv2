import 'package:flutter/material.dart';

import '../../../core/di/injection.dart';
import '../../../core/services/bridge_management_service.dart';
import '../../../domain/entities/bridge_entity.dart';

/// 跨协议桥接管理页面。
///
/// 显示已配置的 Bridge 列表、连接状态、可添加的新 Bridge 模板。
class BridgeManagementPage extends StatefulWidget {
  const BridgeManagementPage({super.key});

  @override
  State<BridgeManagementPage> createState() => _BridgeManagementPageState();
}

class _BridgeManagementPageState extends State<BridgeManagementPage> {
  late final BridgeManagementService _service;

  @override
  void initState() {
    super.initState();
    _service = getIt.isRegistered<BridgeManagementService>()
        ? getIt<BridgeManagementService>()
        : BridgeManagementService();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('跨协议桥接')),
      body: StreamBuilder<List<BridgeEntity>>(
        stream: _service.bridgesStream,
        initialData: _service.currentBridges,
        builder: (context, snapshot) {
          final bridges = snapshot.data ?? [];
          return ListView(
            children: [
              if (bridges.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text('已配置', style: TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 14,
                  )),
                ),
                ...bridges.map((b) => _buildBridgeTile(b, configured: true)),
                const Divider(height: 32),
              ],
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text('可添加', style: TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 14,
                )),
              ),
              ..._service.availableBridgeTemplates
                  .where((t) => !bridges.any((b) => b.protocol == t.protocol))
                  .map((t) => _buildBridgeTile(t, configured: false)),
              const SizedBox(height: 32),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '桥接需要在 Matrix Homeserver 侧部署对应的 Appservice '
                  '（如 matrix-appservice-slack）。此处仅管理配置元数据。',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBridgeTile(BridgeEntity bridge, {required bool configured}) {
    final statusColor = switch (bridge.status) {
      BridgeConnectionStatus.connected => Colors.green,
      BridgeConnectionStatus.connecting => Colors.orange,
      BridgeConnectionStatus.error => Colors.red,
      BridgeConnectionStatus.disconnected => Colors.grey,
    };

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.grey[200],
        child: Text(
          bridge.protocolLabel.substring(0, 1),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(bridge.protocolLabel),
      subtitle: configured
          ? Text(
              bridge.isConnected
                  ? '已连接 · ${bridge.linkedRoomIds.length} 个频道'
                  : bridge.errorMessage ?? '未连接',
              style: TextStyle(color: statusColor, fontSize: 12),
            )
          : const Text('点击添加', style: TextStyle(fontSize: 12)),
      trailing: configured
          ? Icon(Icons.circle, size: 10, color: statusColor)
          : const Icon(Icons.add_circle_outline, size: 20),
      onTap: () => configured
          ? _showBridgeDetail(bridge)
          : _addBridge(bridge),
    );
  }

  Future<void> _addBridge(BridgeEntity template) async {
    final url = await _showInputDialog(
      title: '添加 ${template.protocolLabel} Bridge',
      hint: 'Appservice URL (e.g. https://bridge.example.com)',
    );
    if (url == null || url.isEmpty) return;

    final bridge = BridgeEntity(
      id: '${template.protocol.name}_${DateTime.now().millisecondsSinceEpoch}',
      protocol: template.protocol,
      displayName: template.protocolLabel,
      appserviceUrl: url,
      status: BridgeConnectionStatus.disconnected,
    );
    await _service.saveBridge(bridge);
  }

  void _showBridgeDetail(BridgeEntity bridge) {
    showDialog<void>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(bridge.protocolLabel),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('状态: ${bridge.status.name}'),
            if (bridge.appserviceUrl != null)
              Text('URL: ${bridge.appserviceUrl}'),
            Text('关联房间: ${bridge.linkedRoomIds.length} 个'),
            if (bridge.connectedAt != null)
              Text('连接时间: ${bridge.connectedAt}'),
            if (bridge.errorMessage != null)
              Text('错误: ${bridge.errorMessage}',
                  style: const TextStyle(color: Colors.red)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(c);
              await _service.removeBridge(bridge.id);
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  Future<String?> _showInputDialog({
    required String title,
    required String hint,
  }) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: hint),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, controller.text.trim()),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
