import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/core/providers/core_providers.dart';
import 'package:n42_wallet/core/utils/responsive_utils.dart';
import 'package:n42_wallet/features/mining_v3/mining_v3_activity.dart';
import 'package:n42_wallet/features/mining_v3/mining_v3_engine.dart';
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
  String _endpoint = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadEndpoint();
  }

  Future<void> _loadEndpoint() async {
    final stored = await ref.read(spUtilProvider).getMiningV3Endpoint();
    final running = ref.read(miningV3EngineProvider).endpoint;
    if (!mounted) return;
    setState(() {
      _endpoint = stored ?? running ?? miningV3DefaultEndpoint;
      _loading = false;
    });
  }

  Future<void> _settings(MiningV3Engine engine) => showAppSheet<void>(
    context,
    builder: (_) => MiningV3ConnectionSheet(
      engine: engine,
      endpoint: engine.endpoint ?? _endpoint,
      onSave: (value) async {
        await ref.read(spUtilProvider).setMiningV3Endpoint(value);
        if (mounted) setState(() => _endpoint = value);
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
