import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../integration/bridge/bridge_manager.dart';
import '../../../integration/bridge/bridge_platform.dart';
import '../../../integration/bridge/bridge_state.dart';
import 'bridge_detail_page.dart';

/// Page displaying all available bridge platforms and their connection status.
///
/// Shows a list of Mautrix bridge platforms grouped by status:
/// connected bridges first, then available bridges, then unavailable.
class BridgeListPage extends StatefulWidget {
  final BridgeManager bridgeManager;

  const BridgeListPage({super.key, required this.bridgeManager});

  @override
  State<BridgeListPage> createState() => _BridgeListPageState();
}

class _BridgeListPageState extends State<BridgeListPage> {
  StreamSubscription<Map<BridgePlatform, BridgeState>>? _subscription;
  Map<BridgePlatform, BridgeState> _states = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _states = widget.bridgeManager.states;
    _subscription = widget.bridgeManager.stateStream.listen((states) {
      if (mounted) {
        setState(() => _states = states);
      }
    });
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      if (!widget.bridgeManager.isInitialized) {
        await widget.bridgeManager.initialize();
      }
    } catch (e) {
      debugPrint('BridgeListPage: initialize failed: $e');
    } finally {
      if (mounted) {
        setState(() {
          _states = widget.bridgeManager.states;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshBridges() async {
    if (mounted) {
      setState(() => _isLoading = true);
    }
    try {
      await widget.bridgeManager.rediscoverBridges();
    } catch (e) {
      debugPrint('BridgeListPage: rediscover failed: $e');
    } finally {
      if (mounted) {
        setState(() {
          _states = widget.bridgeManager.states;
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: context.pageBackground,
      appBar: AppBar(
        title: const Text('Connected Accounts'),
        backgroundColor: context.surfaceColor,
        foregroundColor: context.textPrimary,
        elevation: 0.5,
        actions: [
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refreshBridges,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(context, isDark),
    );
  }

  Widget _buildBody(BuildContext context, bool isDark) {
    final connected = <BridgeState>[];
    final available = <BridgeState>[];
    final unavailable = <BridgeState>[];

    for (final state in _states.values) {
      if (state.isConnected || state.isLoading) {
        connected.add(state);
      } else if (state.isAvailable) {
        available.add(state);
      } else {
        unavailable.add(state);
      }
    }

    return ListView(
      children: [
        if (connected.isNotEmpty) ...[
          _buildSectionHeader('Connected', isDark),
          ...connected.map((s) => _buildBridgeTile(context, s, isDark)),
        ],
        if (available.isNotEmpty) ...[
          _buildSectionHeader('Available', isDark),
          ...available.map((s) => _buildBridgeTile(context, s, isDark)),
        ],
        if (unavailable.isNotEmpty) ...[
          _buildSectionHeader('Not Available', isDark),
          ...unavailable.map((s) => _buildBridgeTile(context, s, isDark)),
        ],
        const SizedBox(height: 40),
        _buildFooterNote(isDark),
      ],
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: context.textTertiary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildBridgeTile(
    BuildContext context,
    BridgeState state,
    bool isDark,
  ) {
    final info = BridgePlatformRegistry.getInfo(state.platform);
    final bgColor = context.surfaceColor;
    final textColor = context.textPrimary;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0.5),
      color: bgColor,
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: state.isAvailable
                ? info.brandColor.withValues(alpha: 0.12)
                : Colors.grey.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            info.icon,
            color: state.isAvailable ? info.brandColor : context.textTertiary,
            size: 22,
          ),
        ),
        title: Text(
          info.displayName,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: state.isAvailable ? textColor : context.textTertiary,
          ),
        ),
        subtitle: Text(
          _getStatusText(state),
          style: TextStyle(fontSize: 13, color: _getStatusColor(state)),
        ),
        trailing: _buildTrailingWidget(state),
        onTap: state.isAvailable
            ? () => _openDetail(context, state.platform)
            : null,
      ),
    );
  }

  String _getStatusText(BridgeState state) {
    switch (state.status) {
      case BridgeConnectionStatus.connected:
        return state.remoteUsername != null
            ? 'Connected as ${state.remoteUsername}'
            : 'Connected';
      case BridgeConnectionStatus.connecting:
        return 'Connecting...';
      case BridgeConnectionStatus.reconnecting:
        return 'Reconnecting...';
      case BridgeConnectionStatus.error:
        return state.errorMessage ?? 'Connection error';
      case BridgeConnectionStatus.disconnected:
        return 'Tap to connect';
      case BridgeConnectionStatus.notAvailable:
        return 'Not configured on server';
    }
  }

  Color _getStatusColor(BridgeState state) {
    switch (state.status) {
      case BridgeConnectionStatus.connected:
        return AppColors.primary;
      case BridgeConnectionStatus.connecting:
      case BridgeConnectionStatus.reconnecting:
        return AppColors.warning;
      case BridgeConnectionStatus.error:
        return AppColors.error;
      case BridgeConnectionStatus.disconnected:
        return AppColors.textTertiary;
      case BridgeConnectionStatus.notAvailable:
        return AppColors.textTertiary;
    }
  }

  Widget? _buildTrailingWidget(BridgeState state) {
    if (state.isLoading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    if (state.isConnected) {
      return const Icon(Icons.check_circle, color: AppColors.primary, size: 20);
    }
    if (state.hasError) {
      return const Icon(Icons.error_outline, color: AppColors.error, size: 20);
    }
    if (state.isAvailable) {
      return const Icon(AppIcons.chevron, color: AppColors.textTertiary, size: 20);
    }
    return null;
  }

  Widget _buildFooterNote(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        'Bridge availability depends on server configuration. '
        'Contact your server admin to enable additional bridges.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          color: context.textTertiary,
        ),
      ),
    );
  }

  void _openDetail(BuildContext context, BridgePlatform platform) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BridgeDetailPage(
          platform: platform,
          bridgeManager: widget.bridgeManager,
        ),
      ),
    );
  }
}
