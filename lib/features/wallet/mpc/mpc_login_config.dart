import 'package:web3auth_flutter/enums.dart';

import 'mpc_provider.dart';
import 'web3auth_mpc_provider.dart';

/// Public SDK configuration, separate from Chat OAuth and other products.
/// The existing wallet transaction adapter is experimental; opt in explicitly.
class MpcLoginConfig {
  final String clientId;
  final String network;
  final bool enabled;

  const MpcLoginConfig({
    this.clientId = const String.fromEnvironment('N42_WEB3AUTH_CLIENT_ID'),
    this.network = const String.fromEnvironment(
      'N42_WEB3AUTH_NETWORK',
      defaultValue: 'sapphire_devnet',
    ),
    this.enabled = const bool.fromEnvironment('N42_MPC_ENABLED'),
  });

  bool get isConfigured =>
      enabled &&
      clientId.trim().isNotEmpty &&
      (network == 'sapphire_devnet' || network == 'sapphire_mainnet');

  bool register({required bool isMobile}) {
    if (!isMobile || !isConfigured) return false;
    final registry = MpcProviderRegistry.instance;
    if (registry.get('web3auth') == null) {
      registry.register(
        Web3AuthMpcProvider(
          clientId: clientId.trim(),
          redirectUrl: Uri.parse('n42://auth'),
          network: network == 'sapphire_mainnet'
              ? Web3AuthNetwork.sapphire_mainnet
              : Web3AuthNetwork.sapphire_devnet,
        ),
      );
    }
    return true;
  }
}
