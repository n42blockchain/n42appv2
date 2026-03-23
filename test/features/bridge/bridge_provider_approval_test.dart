import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/bridge/api/lifi_api.dart';
import 'package:n42_wallet/features/bridge/models/bridge_models.dart';
import 'package:n42_wallet/features/bridge/provider/bridge_provider.dart';
import 'package:n42_wallet/features/models/message_model.dart';

class FakeBridgeApiClient implements BridgeApiClient {
  FakeBridgeApiClient({
    MessageModel? tokensResult,
    MessageModel? stepTransactionResult,
    MessageModel? tokenApprovalResult,
    MessageModel? approvalTransactionResult,
  }) : _tokensResult = tokensResult ?? (MessageModel()..data = <BridgeToken>[]),
       _stepTransactionResult =
           stepTransactionResult ?? (MessageModel()..data = null),
       _tokenApprovalResult =
           tokenApprovalResult ?? (MessageModel()..data = null),
       _approvalTransactionResult =
           approvalTransactionResult ?? (MessageModel()..data = null);

  final MessageModel _tokensResult;
  final MessageModel _stepTransactionResult;
  final MessageModel _tokenApprovalResult;
  final MessageModel _approvalTransactionResult;

  @override
  Future<MessageModel> getChains() async =>
      MessageModel()..data = <BridgeChain>[];

  @override
  Future<MessageModel> getTokens({int? chainId}) async => _tokensResult;

  @override
  Future<MessageModel> getQuote(BridgeQuoteRequest request) async =>
      MessageModel.error()..data = 'unused';

  @override
  Future<MessageModel> getRoutes(BridgeQuoteRequest request) async =>
      MessageModel.error()..data = 'unused';

  @override
  Future<MessageModel> getStepTransaction({
    required Map<String, dynamic> step,
  }) async => _stepTransactionResult;

  @override
  Future<MessageModel> getStatus({
    required String txHash,
    required int fromChainId,
    required int toChainId,
    required String bridge,
  }) async => MessageModel.error()..data = 'unused';

  @override
  Future<MessageModel> getTools() async =>
      MessageModel.error()..data = 'unused';

  @override
  Future<MessageModel> getTokenBalance({
    required String walletAddress,
    required int chainId,
    required String tokenAddress,
  }) async => MessageModel.error()..data = 'unused';

  @override
  Future<MessageModel> getTokenApproval({
    required int chainId,
    required String tokenAddress,
    required String walletAddress,
    required String spenderAddress,
  }) async => _tokenApprovalResult;

  @override
  Future<MessageModel> getApprovalTransaction({
    required int chainId,
    required String tokenAddress,
    required String spenderAddress,
    String? amount,
  }) async => _approvalTransactionResult;
}

BridgeChain _chain(int chainId, String key) {
  return BridgeChain(
    chainId: chainId,
    key: key,
    name: key,
    logoUri: '',
    nativeToken: 'ETH',
    nativeDecimals: 18,
  );
}

BridgeToken _token({required String address, required int chainId}) {
  return BridgeToken(
    address: address,
    symbol: 'USDC',
    name: 'USD Coin',
    decimals: 6,
    chainId: chainId,
    logoUri: '',
  );
}

BridgeRoute _route(BridgeToken fromToken, BridgeToken toToken) {
  return BridgeRoute(
    id: 'route-1',
    steps: [
      BridgeRouteStep(
        type: 'lifi',
        tool: 'lifi',
        toolName: 'LI.FI',
        toolLogoUri: '',
        fromToken: fromToken,
        toToken: toToken,
        fromAmount: '1000000',
        toAmount: '990000',
        estimatedSeconds: 30,
      ),
    ],
    fromToken: fromToken,
    toToken: toToken,
    fromAmount: '1000000',
    toAmount: '990000',
    toAmountMin: '980000',
    gasCostUSD: 1,
    estimatedSeconds: 30,
    tags: const ['RECOMMENDED'],
  );
}

MessageModel _message(dynamic data) => MessageModel()..data = data;

void main() {
  group('BridgeProvider approval flow', () {
    late BridgeChain fromChain;
    late BridgeChain toChain;
    late BridgeToken fromToken;
    late BridgeToken toToken;

    setUp(() {
      fromChain = _chain(1, 'eth');
      toChain = _chain(42161, 'arb');
      fromToken = _token(address: '0xfrom', chainId: 1);
      toToken = _token(address: '0xto', chainId: 42161);
    });

    Future<BridgeProvider> buildProvider(FakeBridgeApiClient api) async {
      final provider = BridgeProvider(lifiApi: api);
      await provider.setFromChain(fromChain);
      await provider.setToChain(toChain);
      provider.setFromToken(fromToken);
      provider.setToToken(toToken);
      provider.setFromAmount('1');
      provider.selectRoute(_route(fromToken, toToken));
      return provider;
    }

    test('fails fast when approval status lookup fails', () async {
      final api = FakeBridgeApiClient(
        tokensResult: _message(<BridgeToken>[fromToken, toToken]),
        stepTransactionResult: _message(
          BridgeTransactionResponse(
            txData: {'to': '0xspender', 'data': '0xabc'},
          ),
        ),
        tokenApprovalResult: MessageModel.error()
          ..data = 'approval lookup failed',
      );
      final provider = await buildProvider(api);
      var signCalls = 0;

      final result = await provider.executeBridge(
        fromAddress: '0xme',
        toAddress: '0xyou',
        signAndSend: (_) async {
          signCalls++;
          return '0xtx';
        },
      );

      expect(result.error, isTrue);
      expect(result.data, 'approval lookup failed');
      expect(provider.state, BridgeState.error);
      expect(signCalls, 0);
    });

    test('fails fast when approval spender is missing', () async {
      final api = FakeBridgeApiClient(
        tokensResult: _message(<BridgeToken>[fromToken, toToken]),
        stepTransactionResult: _message(
          BridgeTransactionResponse(txData: {'data': '0xabc'}),
        ),
      );
      final provider = await buildProvider(api);

      final result = await provider.executeBridge(
        fromAddress: '0xme',
        toAddress: '0xyou',
        signAndSend: (_) async => '0xtx',
      );

      expect(result.error, isTrue);
      expect(result.data, 'Missing approval spender');
      expect(provider.state, BridgeState.error);
    });

    test('fails when approval signing is cancelled', () async {
      final api = FakeBridgeApiClient(
        tokensResult: _message(<BridgeToken>[fromToken, toToken]),
        stepTransactionResult: _message(
          BridgeTransactionResponse(
            txData: {'to': '0xspender', 'data': '0xabc'},
          ),
        ),
        tokenApprovalResult: _message({'allowance': '0'}),
        approvalTransactionResult: _message({'to': '0xapproval'}),
      );
      final provider = await buildProvider(api);
      var signCalls = 0;

      final result = await provider.executeBridge(
        fromAddress: '0xme',
        toAddress: '0xyou',
        signAndSend: (_) async {
          signCalls++;
          return null;
        },
      );

      expect(result.error, isTrue);
      expect(result.data, 'Approval transaction cancelled');
      expect(provider.state, BridgeState.error);
      expect(signCalls, 1);
    });
  });
}
