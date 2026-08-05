import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/features/wallet/provider/legacy_wallet_adapter.dart';
import 'package:n42_wallet/core/utils/app_logger.dart';
import 'package:n42_wallet/core/storage/sp_util.dart';
import 'package:n42_wallet/core/utils/event_bus.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/core/enums/load.dart';
import 'package:n42_wallet/features/mining/domain/entities/mining_entity.dart';
import 'package:n42_wallet/features/mining_v2/api/mining_api.dart';
import 'package:n42_wallet/features/mining_v2/api/mining_web3.dart';
import 'package:n42_wallet/features/mining_v2/models/mining_withdrawals_daily.dart';
import 'package:n42_wallet/features/mining_v2/provider/mining_web_socket_bridge.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';
import 'package:n42_wallet/features/utils/data_utils.dart';
import 'package:n42_wallet/features/wallet/api/token_view_api.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/features/widgets/chart_histogram.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';

part 'mining_v2_provider_state.dart';
part 'mining_v2_provider_actions.dart';
part 'mining_v2_provider_beacon.dart';
part 'mining_v2_provider_websocket.dart';

// ==================== Mining Constants ====================
// These constants define the timing and threshold values for mining operations

/// Duration of one valid mining cycle in seconds.
/// This is the block time for the N chain beacon consensus.
const int kMiningCycleSeconds = 128;

/// Maximum inactivity score before penalties apply.
/// When score reaches this value, validator is considered at high risk.
const int kMaxInactivityScore = 2700;

/// Interval for checking transaction confirmation status.
const int kTxConfirmCheckIntervalSeconds = 5;

/// Interval for refreshing mining withdrawal data.
const int kWithdrawalRefreshIntervalSeconds = 128;

/// Default wait time for beacon validator status check.
const int kBeaconValidatorWaitSeconds = 200;

/// Interval for periodic mining status updates.
const int kMiningStatusIntervalSeconds = 30;

/// Risk level thresholds (percentage of max inactivity score).
const double kLowRiskThreshold = 33.33;
const double kModerateRiskThreshold = 66.66;

/// Inactivity score segment size (for UI display).
const int kInactivityScoreSegmentSize = 900;

/// Number of days for mining history chart.
const int kMiningHistoryDays = 7;

/// Maximum WebSocket reconnection attempts before giving up.
const int kMaxReconnectAttempts = 5;

// ==================== Provider ====================

class MiningV2Provider extends ChangeNotifier
    with
        _MiningStateMixin,
        _MiningActionsMixin,
        _MiningBeaconMixin,
        _MiningWebSocketMixin {
  @override
  void dispose() {
    disposeState();
    super.dispose();
  }
}

// ==================== Supporting Types ====================

/// WebSocket connection state.
enum WebSocketState { disconnected, connecting, connected, reconnecting }

/// Mining-specific wallet info.
///
/// Used for displaying wallet list in mining UI.
class MiningWalletInfo {
  final int index;
  final String name;
  final String address;
  final bool isMainWallet;
  final bool hasCoinN;

  MiningWalletInfo({
    required this.index,
    required this.name,
    required this.address,
    required this.isMainWallet,
    required this.hasCoinN,
  });
}
