import 'dart:async';

import 'package:flutter/material.dart';

import '../../../integration/bridge/bridge_manager.dart';
import '../../../integration/bridge/bridge_platform.dart';
import '../../../integration/bridge/bridge_state.dart';

/// Detail page for a single bridge platform.
///
/// Shows connection status, allows login/logout, and provides
/// bridge management controls.
class BridgeDetailPage extends StatefulWidget {
  final BridgePlatform platform;
  final BridgeManager bridgeManager;

  const BridgeDetailPage({
    super.key,
    required this.platform,
    required this.bridgeManager,
  });

  @override
  State<BridgeDetailPage> createState() => _BridgeDetailPageState();
}

class _BridgeDetailPageState extends State<BridgeDetailPage> {
  StreamSubscription<Map<BridgePlatform, BridgeState>>? _subscription;
  late BridgeState _state;
  bool _isActionInProgress = false;
  String? _lastResponse;
  String? _qrCodeUrl;

  BridgePlatformInfo get _info =>
      BridgePlatformRegistry.getInfo(widget.platform);

  @override
  void initState() {
    super.initState();
    _state = widget.bridgeManager.getState(widget.platform);
    _subscription = widget.bridgeManager.stateStream.listen((states) {
      final newState = states[widget.platform];
      if (newState != null && mounted) {
        setState(() => _state = newState);
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() {
      _isActionInProgress = true;
      _lastResponse = null;
      _qrCodeUrl = null;
    });

    try {
      final response = await widget.bridgeManager.login(widget.platform);
      if (mounted) {
        setState(() {
          _lastResponse = response.text;
          _qrCodeUrl = response.qrCodeUrl;
          _isActionInProgress = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _lastResponse = 'Error: $e';
          _isActionInProgress = false;
        });
      }
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Disconnect ${_info.displayName}?'),
        content: const Text(
          'You will stop receiving messages from this platform '
          'until you reconnect.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isActionInProgress = true);

    try {
      final response = await widget.bridgeManager.logout(widget.platform);
      if (mounted) {
        setState(() {
          _lastResponse = response.text;
          _isActionInProgress = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _lastResponse = 'Error: $e';
          _isActionInProgress = false;
        });
      }
    }
  }

  Future<void> _handleSync() async {
    setState(() => _isActionInProgress = true);

    try {
      final response =
          await widget.bridgeManager.syncContacts(widget.platform);
      if (mounted) {
        setState(() {
          _lastResponse = response.text;
          _isActionInProgress = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _lastResponse = 'Error: $e';
          _isActionInProgress = false;
        });
      }
    }
  }

  Future<void> _handleRefreshStatus() async {
    setState(() => _isActionInProgress = true);

    try {
      final response =
          await widget.bridgeManager.queryStatus(widget.platform);
      if (mounted) {
        setState(() {
          _lastResponse = response.text;
          _isActionInProgress = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _lastResponse = 'Error: $e';
          _isActionInProgress = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF111111) : const Color(0xFFEDEDED),
      appBar: AppBar(
        title: Text(_info.displayName),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0.5,
      ),
      body: ListView(
        children: [
          _buildHeader(isDark),
          const SizedBox(height: 12),
          _buildStatusSection(isDark),
          const SizedBox(height: 12),
          _buildActionsSection(isDark),
          if (_lastResponse != null) ...[
            const SizedBox(height: 12),
            _buildResponseSection(isDark),
          ],
          if (_qrCodeUrl != null) ...[
            const SizedBox(height: 12),
            _buildQRSection(isDark),
          ],
          const SizedBox(height: 12),
          _buildInfoSection(isDark),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: _info.brandColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _info.icon,
              color: _info.brandColor,
              size: 32,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _info.displayName,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _info.description,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection(bool isDark) {
    final bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Container(
      color: bgColor,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'STATUS',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white54 : Colors.black45,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatusIndicator(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _statusTitle,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                    if (_state.remoteUsername != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          _state.remoteUsername!,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white54 : Colors.black45,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator() {
    Color color;
    IconData icon;

    switch (_state.status) {
      case BridgeConnectionStatus.connected:
        color = const Color(0xFF07C160);
        icon = Icons.check_circle;
      case BridgeConnectionStatus.connecting:
      case BridgeConnectionStatus.reconnecting:
        color = Colors.orange;
        icon = Icons.sync;
      case BridgeConnectionStatus.error:
        color = Colors.red;
        icon = Icons.error;
      case BridgeConnectionStatus.disconnected:
        color = Colors.grey;
        icon = Icons.remove_circle_outline;
      case BridgeConnectionStatus.notAvailable:
        color = Colors.grey.shade400;
        icon = Icons.block;
    }

    return Icon(icon, color: color, size: 28);
  }

  String get _statusTitle {
    switch (_state.status) {
      case BridgeConnectionStatus.connected:
        return 'Connected';
      case BridgeConnectionStatus.connecting:
        return 'Connecting...';
      case BridgeConnectionStatus.reconnecting:
        return 'Reconnecting...';
      case BridgeConnectionStatus.error:
        return 'Error';
      case BridgeConnectionStatus.disconnected:
        return 'Not Connected';
      case BridgeConnectionStatus.notAvailable:
        return 'Not Available';
    }
  }

  Widget _buildActionsSection(bool isDark) {
    final bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Container(
      color: bgColor,
      child: Column(
        children: [
          if (_state.canLogin)
            _buildActionTile(
              icon: Icons.login,
              title: 'Connect',
              color: _info.brandColor,
              onTap: _isActionInProgress ? null : _handleLogin,
            ),
          if (_state.isConnected) ...[
            _buildActionTile(
              icon: Icons.sync,
              title: 'Sync Contacts',
              onTap: _isActionInProgress ? null : _handleSync,
            ),
            _buildActionTile(
              icon: Icons.refresh,
              title: 'Refresh Status',
              onTap: _isActionInProgress ? null : _handleRefreshStatus,
            ),
            const Divider(height: 1),
            _buildActionTile(
              icon: Icons.logout,
              title: 'Disconnect',
              color: Colors.red,
              onTap: _isActionInProgress ? null : _handleLogout,
            ),
          ],
          if (_state.isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          if (_state.hasError)
            _buildActionTile(
              icon: Icons.refresh,
              title: 'Retry Connection',
              color: Colors.orange,
              onTap: _isActionInProgress ? null : _handleLogin,
            ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    Color? color,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultColor = isDark ? Colors.white70 : Colors.black87;

    return ListTile(
      leading: Icon(icon, color: color ?? defaultColor, size: 22),
      title: Text(
        title,
        style: TextStyle(
          color: color ?? defaultColor,
          fontSize: 16,
        ),
      ),
      trailing: _isActionInProgress
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : null,
      onTap: onTap,
    );
  }

  Widget _buildResponseSection(bool isDark) {
    final bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Container(
      color: bgColor,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BRIDGE RESPONSE',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white54 : Colors.black45,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          SelectableText(
            _lastResponse!,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.black54,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQRSection(bool isDark) {
    final bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Container(
      color: bgColor,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            'Scan QR Code',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Open ${_info.displayName} on your phone and scan this QR code to link your account.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ),
          const SizedBox(height: 16),
          // QR code would be displayed here using the mxc:// URL
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Center(
              child: Text(
                'QR Code\n(from bridge bot)',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(bool isDark) {
    final bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white54 : Colors.black45;

    return Container(
      color: bgColor,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'INFO',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: textColor,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Platform', _info.displayName, textColor),
          _buildInfoRow('Status', _info.isActive ? 'Active' : 'Low maintenance', textColor),
          _buildInfoRow('Language', _info.language, textColor),
          _buildInfoRow('DMs', _info.supportsDM ? 'Supported' : 'Not supported', textColor),
          _buildInfoRow('Groups', _info.supportsGroups ? 'Supported' : 'Not supported', textColor),
          _buildInfoRow('Relay mode', _info.supportsRelay ? 'Supported' : 'Not supported', textColor),
          _buildInfoRow(
            'Auth methods',
            _info.authMethods.map((m) => m.name).join(', '),
            textColor,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: TextStyle(fontSize: 14, color: color)),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: color.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
