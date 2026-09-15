import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet_connect/provider/wallet_connect_provider.dart';
import 'package:reown_walletkit/reown_walletkit.dart' as wc;
import 'package:reown_core/relay_client/i_relay_client.dart';
import 'package:reown_core/pairing/i_pairing.dart';

/// In-memory SDK boundary: no relay, signing keys or live accounts.
class WalletKitFake extends Fake implements wc.ReownWalletKit {
  @override
  final WalletCoreFake core = WalletCoreFake();
  @override
  final WalletSignFake reOwnSign = WalletSignFake();
  @override
  final onSessionProposal = wc.Event<wc.SessionProposalEvent>();
  @override
  final onSessionRequest = wc.Event<wc.SessionRequestEvent>();
  @override
  final onSessionDelete = wc.Event<wc.SessionDelete>();
  @override
  final onSessionExpire = wc.Event<wc.SessionExpire>();
  @override
  final onProposalExpire = wc.Event<wc.SessionProposalEvent>();
  @override
  final onSessionProposalError = wc.Event<wc.SessionProposalErrorEvent>();

  final responses = <(String, wc.JsonRpcResponse)>[];
  final handlers = <(String, String)>[];
  final accounts = <(String, String)>[];
  final activeSessions = <String, wc.SessionData>{};
  final pairingRequests = <Uri>[];
  Object? pairingError;

  @override
  Future<wc.PairingInfo> pair({required Uri uri}) async {
    pairingRequests.add(uri);
    if (pairingError != null) throw pairingError!;
    return pairingInfo(uri.path.split('@').first);
  }

  @override
  Map<String, wc.SessionData> getActiveSessions() => Map.of(activeSessions);

  @override
  Future<void> respondSessionRequest({
    required String topic,
    required wc.JsonRpcResponse response,
  }) async => responses.add((topic, response));

  @override
  void registerRequestHandler({
    required String chainId,
    required String method,
    dynamic Function(String, dynamic)? handler,
  }) => handlers.add((chainId, method));

  @override
  void registerAccount({
    required String chainId,
    required String accountAddress,
  }) => accounts.add((chainId, accountAddress));
}

class WalletCoreFake extends Fake implements wc.IReownCore {
  @override
  final WalletRelayFake relayClient = WalletRelayFake();
  @override
  final WalletPairingFake pairing = WalletPairingFake();
}

class WalletPairingFake extends Fake implements IPairing {
  final activePairings = <wc.PairingInfo>[];
  @override
  List<wc.PairingInfo> getPairings() => List.of(activePairings);
}

wc.PairingInfo pairingInfo(String topic, {bool active = true}) =>
    wc.PairingInfo(
      topic: topic,
      expiry: 2200000000,
      relay: wc.Relay('irn'),
      active: active,
    );

class WalletRelayFake extends Fake implements IRelayClient {
  @override
  final onRelayClientConnect = wc.Event<wc.EventArgs>();
  @override
  final onRelayClientDisconnect = wc.Event<wc.EventArgs>();
  @override
  final onRelayClientError = wc.Event<wc.ErrorEvent>();
  @override
  final onRelayClientMessage = wc.Event<wc.MessageEvent>();
  int connects = 0;
  int disconnects = 0;
  Future<void> Function() onConnect = () async {};

  @override
  Future<void> connect({String? relayUrl}) async {
    connects++;
    await onConnect();
  }

  @override
  Future<void> disconnect() async => disconnects++;
}

class WalletSignFake extends Fake implements wc.IReownSign {
  final pings = <String>[];
  Future<void> Function() onPing = () async {};

  @override
  Future<void> ping({required String topic}) async {
    pings.add(topic);
    await onPing();
  }
}

/// Exercise the production mixins while isolating key loading and navigation.
class SessionPreviewProvider extends WalletConnectProvider {
  final availableChains = <String, CoinModel>{};
  final initializedChains = <String>[];
  final states = <WalletConnectState>[];
  bool canInitialize = true;

  @override
  CoinModel? coinModelFind(String chainId) => availableChains[chainId];

  @override
  Future<bool> web3clientInitFromChainId(String chain) async {
    initializedChains.add(chain);
    return canInitialize;
  }

  @override
  Future<void> viewStateDeal(WalletConnectState state, {dynamic params}) async {
    states.add(state);
    walletConnectState = state;
    if (state == WalletConnectState.error) errorMessage = params as String;
  }
}

CoinModel sessionCoin({
  String type = 'ETH',
  String blockchain = 'Ethereum',
  String? address = '0x1111111111111111111111111111111111111111',
  int chainId = 1,
  bool isTest = false,
}) => CoinModel()
  ..address = address
  ..isTest = isTest
  ..coin = {
    'name': type,
    'coinType': type,
    'blockchainType': blockchain,
    'chainId': chainId,
    'chainId_test': 11155111,
  };

wc.SessionRequestEvent sessionRequest(
  String method,
  dynamic params, {
  String chain = 'eip155:1',
  String topic = 'request-topic',
  int id = 42,
}) => wc.SessionRequestEvent(
  id,
  topic,
  method,
  chain,
  params,
  wc.TransportType.relay,
);
