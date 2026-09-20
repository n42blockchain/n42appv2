import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/network/mev_protection.dart';

void main() {
  group('MEV transaction routing', () {
    test('unsupported chains never use the Ethereum private relay', () async {
      expect(MevProtectionService.getProtectedRpc(137), isNull);
      final risk = MevProtectionService.assessRisk(
        chainId: 137,
        data: '0x38ed1739',
        value: BigInt.from(10).pow(20),
      );
      expect(risk.level, MevRiskLevel.none);
      expect(risk.shouldProtect, isFalse);
      await expectLater(
        MevProtectionService.instance.sendProtectedTransaction(
          chainId: 137,
          signedTx: '0x00',
        ),
        throwsA(isA<MevProtectionException>()),
      );
    });

    test('Ethereum uses the chosen standard or fast private relay', () {
      expect(MevProtectionService.isAvailable(1), isTrue);
      expect(
        MevProtectionService.getProtectedRpc(1),
        MevProtectionService.flashbotsRpc,
      );
      expect(
        MevProtectionService.getProtectedRpc(1, fast: true),
        MevProtectionService.flashbotsFastRpc,
      );
    });

    for (final selector in ['38ed1739', '04E45AAF', '3593564c']) {
      test(
        'swap selector $selector requires protection without native value',
        () {
          final risk = MevProtectionService.assessRisk(
            chainId: 1,
            data: '0x${selector}00000000',
            value: BigInt.zero,
          );
          expect(risk.level, MevRiskLevel.high);
          expect(risk.shouldProtect, isTrue);
        },
      );
    }

    for (final selector in ['095ea7b3', 'a22cb465', 'd505accf']) {
      test('approval selector $selector recommends protection', () {
        final risk = MevProtectionService.assessRisk(
          chainId: 1,
          data: '0x$selector',
        );
        expect(risk.level, MevRiskLevel.medium);
        expect(risk.shouldProtect, isTrue);
      });
    }

    test('unknown contract calls become protected above one ETH', () {
      final oneEth = BigInt.from(10).pow(18);
      final atBoundary = MevProtectionService.assessRisk(
        chainId: 1,
        data: '0x12345678',
        value: oneEth,
      );
      final aboveBoundary = MevProtectionService.assessRisk(
        chainId: 1,
        data: '0x12345678',
        value: oneEth + BigInt.one,
      );
      expect(atBoundary.shouldProtect, isFalse);
      expect(atBoundary.level, MevRiskLevel.low);
      expect(aboveBoundary.shouldProtect, isTrue);
      expect(aboveBoundary.level, MevRiskLevel.medium);
    });

    test('plain native transfer is classified without decoding a selector', () {
      final risk = MevProtectionService.assessRisk(chainId: 1, data: '0x');
      expect(risk.level, MevRiskLevel.low);
      expect(risk.shouldProtect, isFalse);
    });
  });

  test('bundle status requires actual boolean confirmation', () {
    final pending = FlashbotsStatus.fromJson({'isOnChain': 'true'});
    expect(pending.isOnChain, isFalse);
    expect(pending.isSimulated, isFalse);
    expect(pending.isSentToMiners, isFalse);
    expect(pending.receivedAt, isNull);
    final included = FlashbotsStatus.fromJson({
      'isOnChain': true,
      'isSimulated': true,
      'isSentToMiners': true,
      'receivedAt': 123,
    });
    expect(included.isOnChain, isTrue);
    expect(included.isSimulated, isTrue);
    expect(included.isSentToMiners, isTrue);
    expect(included.receivedAt, 123);
  });
}
