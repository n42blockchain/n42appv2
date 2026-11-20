import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/core/providers/core_providers.dart';
import 'package:n42_wallet/core/utils/responsive_utils.dart';
import 'package:n42_wallet/features/mining_v3/mining_v3_activity.dart';
import 'package:n42_wallet/features/mining_v3/mining_v3_engine.dart';
import 'package:n42_wallet/features/mining_v3/mining_v3_nodes.dart';
import 'package:n42_wallet/features/mining_v3/mining_v3_providers.dart';
import 'package:n42_wallet/features/mining_v3/widgets/mining_v3_block_sheet.dart';
import 'package:n42_wallet/features/mining_v3/widgets/mining_v3_connection_sheet.dart';
import 'package:n42_wallet/features/mining_v3/widgets/mining_v3_dashboard.dart';

class MiningV3Page extends ConsumerStatefulWidget {
  const MiningV3Page({super.key});

  @override
  ConsumerState<MiningV3Page> createState() => _MiningV3PageState();
}

class _MiningV3PageState extends ConsumerState<MiningV3Page> {
  /// [miningV3AutoNodeId] or the id of a node the user picked.
  String _selection = miningV3AutoNodeId;

  /// The node this device is assigned to when [_selection] is auto.
  MiningV3Node _autoNode = miningV3Nodes.first;
  bool _loading = true;

  String get _endpoint => miningV3UrlOverride.isNotEmpty
      ? miningV3UrlOverride
      : (miningV3NodeById(_selection) ?? _autoNode).url;

  @override
  void initState() {
    super.initState();
    _loadNode();
  }

  Future<void> _loadNode() async {
    final prefs = ref.read(spUtilProvider);
    final stored = await prefs.getMiningV3Node();
    var auto = miningV3NodeById(await prefs.getMiningV3AutoNode());
    if (auto == null) {
      // Spread devices across the fleet; the choice sticks to this device.
      auto = miningV3Nodes[Random().nextInt(miningV3Nodes.length)];
      try {
        await prefs.setMiningV3AutoNode(auto.id);
      } catch (_) {
        // Not persisted: a new node is assigned next time, which still works.
      }
    }
    if (!mounted) return;
    setState(() {
      _autoNode = auto!;
      _selection = miningV3NodeById(stored) != null
          ? stored!
          : miningV3AutoNodeId;
      _loading = false;
    });
  }

  Future<void> _settings(MiningV3Engine engine) => showAppSheet<void>(
    context,
    builder: (_) => MiningV3ConnectionSheet(
      engine: engine,
      selection: _selection,
      autoNode: _autoNode,
      onSave: (value) async {
        await ref.read(spUtilProvider).setMiningV3Node(value);
        if (mounted) setState(() => _selection = value);
      },
    ),
  );

  Future<void> _toggle(MiningV3Engine engine) async {
    if (engine.busy || _loading) return;
    if (engine.running || engine.pausedForBackground) {
      await engine.stop();
      return;
    }
    if (normalizeMiningV3Endpoint(_endpoint) == null) {
      await _settings(engine);
      return;
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      await Permission.notification.request();
    }
    if (!mounted) return;
    await engine.start(_endpoint);
  }

  void _block(MiningV3Engine engine, MiningV3Block block) {
    showAppSheet<void>(
      context,
      builder: (_) => MiningV3BlockSheet(engine: engine, block: block),
    );
  }

  @override
  Widget build(BuildContext context) {
    final engine = ref.watch(miningV3EngineProvider);
    final scaffold = Scaffold.maybeOf(context);
    return MiningV3Dashboard(
      engine: engine,
      endpoint: _endpoint,
      autoNode: _selection == miningV3AutoNodeId,
      loading: _loading,
      // The home navigation overlays the tab content on narrow screens.
      bottomInset: ResponsiveUtils.useSideNavigation(context)
          ? 0
          : kBottomNavigationBarHeight +
                MediaQuery.textScalerOf(context).scale(AppSpacing.space8),
      onToggle: _loading ? null : () => _toggle(engine),
      onSettings: () => _settings(engine),
      onBlock: (block) => _block(engine, block),
      onMenu: scaffold?.hasDrawer == true ? scaffold!.openDrawer : null,
    );
  }
}
