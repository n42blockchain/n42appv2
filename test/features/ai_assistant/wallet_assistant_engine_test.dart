import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/ai_assistant/domain/wallet_ai_channel.dart';
import 'package:n42_wallet/features/ai_assistant/domain/wallet_assistant_engine.dart';
import 'package:n42_wallet/features/ai_assistant/domain/wallet_snapshot.dart';

/// Wallet Roadmap L3-M1 —— AI 助手引擎（只读+建议）测试。
class _StubChannel implements WalletAiChannel {
  final String? reply;
  _StubChannel(this.reply);
  @override
  Future<String?> ask(String systemPrompt, String userPrompt) async => reply;
}

const _snap = WalletSnapshot(
  totalUsd: 1234.5,
  chainName: 'Ethereum',
  gasGwei: 12,
  assets: [
    WalletAsset(symbol: 'ETH', balance: '0.5', usdValue: 1200),
    WalletAsset(symbol: 'USDC', balance: '34.5', usdValue: 34.5),
  ],
);

void main() {
  group('classify', () {
    test('recognizes intents in en + zh', () {
      expect(
        WalletAssistantEngine.classify('what is my balance'),
        WalletIntent.balance,
      );
      expect(WalletAssistantEngine.classify('我的余额'), WalletIntent.balance);
      expect(WalletAssistantEngine.classify('gas 现在多少'), WalletIntent.gas);
      expect(WalletAssistantEngine.classify('持仓总值'), WalletIntent.portfolio);
      expect(WalletAssistantEngine.classify('help'), WalletIntent.help);
      expect(
        WalletAssistantEngine.classify('tell me a joke'),
        WalletIntent.unknown,
      );
    });
  });

  group('deterministic answers (no channel)', () {
    const engine = WalletAssistantEngine();

    test('balance lists tokens', () async {
      final a = await engine.answer('balance', _snap);
      expect(a, contains('0.5 ETH'));
      expect(a, contains('34.5 USDC'));
    });

    test('portfolio shows total', () async {
      final a = await engine.answer('portfolio', _snap);
      expect(a, contains('\$1234.50'));
    });

    test('gas gives price + timing hint', () async {
      final a = await engine.answer('gas?', _snap);
      expect(a, contains('12.0 gwei'));
      expect(a, contains('Low'));
    });

    test('unknown without channel -> fallback', () async {
      final a = await engine.answer('tell me a joke', _snap);
      expect(a, contains('only read'));
    });
  });

  group('channel fallback', () {
    test('unknown uses LLM channel when available', () async {
      final engine = WalletAssistantEngine(channel: _StubChannel('42 jokes'));
      final a = await engine.answer('tell me a joke', _snap);
      expect(a, '42 jokes');
    });

    test('null channel reply -> fallback', () async {
      final engine = WalletAssistantEngine(channel: _StubChannel(null));
      final a = await engine.answer('tell me a joke', _snap);
      expect(a, contains('unavailable'));
    });

    test('known intent ignores channel (deterministic)', () async {
      final engine = WalletAssistantEngine(channel: _StubChannel('LLM SAYS X'));
      final a = await engine.answer('balance', _snap);
      expect(a, isNot(contains('LLM SAYS X')));
    });
  });
}
