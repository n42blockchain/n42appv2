import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/payments/domain/payment_capability.dart';

void main() {
  const enabledPolicy = PaymentCapabilityPolicy(productionEnabled: true);

  PaymentCapability config({
    PaymentEnvironment environment = PaymentEnvironment.production,
    PaymentFeature feature = PaymentFeature.cryptoTransfer,
    bool enabled = true,
    bool operationApproved = true,
    bool requiresKyc = true,
    Set<String> networks = const {'eip155:8453'},
  }) => PaymentCapability(
    environment: environment,
    feature: feature,
    enabled: enabled,
    operationApproved: operationApproved,
    requiresKyc: requiresKyc,
    supportedRegions: {'US'},
    supportedNetworkIds: networks,
  );

  PaymentCapabilityRequest request({
    PaymentEnvironment environment = PaymentEnvironment.production,
    PaymentFeature feature = PaymentFeature.cryptoTransfer,
    String? region = 'US',
    PaymentKycStatus kycStatus = PaymentKycStatus.verified,
    String? networkId = 'eip155:8453',
  }) => PaymentCapabilityRequest(
    environment: environment,
    feature: feature,
    region: region,
    kycStatus: kycStatus,
    networkId: networkId,
  );

  test('production stays closed by default even with complete approval', () {
    final result = const PaymentCapabilityPolicy().evaluate(
      request(),
      capability: config(),
    );
    expect(result.isAvailable, isFalse);
    expect(result.isProductionAvailable, isFalse);
    expect(result.unavailableReasons, [
      PaymentUnavailableReason.productionDisabled,
    ]);
  });

  test('missing configuration and prerequisites fail closed together', () {
    final result = enabledPolicy.evaluate(
      const PaymentCapabilityRequest(
        environment: PaymentEnvironment.production,
        feature: PaymentFeature.cryptoTransfer,
      ),
    );
    expect(result.isAvailable, isFalse);
    expect(result.unavailableReasons, [
      PaymentUnavailableReason.capabilityNotConfigured,
      PaymentUnavailableReason.regionMissing,
      PaymentUnavailableReason.kycMissing,
      PaymentUnavailableReason.networkMissing,
    ]);
  });

  test('new capability configuration defaults to disabled and unapproved', () {
    final result = enabledPolicy.evaluate(
      request(),
      capability: PaymentCapability(
        environment: PaymentEnvironment.production,
        feature: PaymentFeature.cryptoTransfer,
      ),
    );
    expect(result.isAvailable, isFalse);
    expect(
      result.unavailableReasons,
      containsAll([
        PaymentUnavailableReason.capabilityDisabled,
        PaymentUnavailableReason.operationNotApproved,
        PaymentUnavailableReason.regionUnsupported,
        PaymentUnavailableReason.networkUnsupported,
      ]),
    );
  });

  for (final environment in PaymentEnvironment.values) {
    for (final feature in PaymentFeature.values) {
      test('$environment $feature allows only explicitly configured scope', () {
        final result = enabledPolicy.evaluate(
          request(environment: environment, feature: feature),
          capability: config(environment: environment, feature: feature),
        );
        expect(result.environment, environment);
        expect(result.feature, feature);
        expect(result.isAvailable, isTrue);
        expect(result.unavailableReasons, isEmpty);
        expect(
          result.isProductionAvailable,
          environment == PaymentEnvironment.production,
        );
      });
    }

    for (final other in PaymentEnvironment.values) {
      if (environment == other) continue;
      test('$environment cannot inherit $other capability', () {
        final result = enabledPolicy.evaluate(
          request(environment: environment),
          capability: config(environment: other),
        );
        expect(result.isAvailable, isFalse);
        expect(result.isProductionAvailable, isFalse);
        expect(result.unavailableReasons, [
          PaymentUnavailableReason.environmentMismatch,
        ]);
      });
    }
  }

  for (final feature in PaymentFeature.values) {
    test('$feature approval cannot enable a different feature', () {
      for (final other in PaymentFeature.values) {
        if (feature == other) continue;
        final result = enabledPolicy.evaluate(
          request(feature: feature),
          capability: config(feature: other),
        );
        expect(result.isAvailable, isFalse);
        expect(result.unavailableReasons, [
          PaymentUnavailableReason.featureMismatch,
        ]);
      }
    });

    if (feature.requiresNetwork) {
      test('$feature rejects absent and unsupported networks', () {
        for (final network in [null, '', ' ', 'eip155:1', 'USDC']) {
          final result = enabledPolicy.evaluate(
            request(feature: feature, networkId: network),
            capability: config(feature: feature),
          );
          expect(result.isAvailable, isFalse);
          expect(result.unavailableReasons, [
            network == null || network.trim().isEmpty
                ? PaymentUnavailableReason.networkMissing
                : PaymentUnavailableReason.networkUnsupported,
          ]);
        }
      });
    } else {
      test('$feature does not require a blockchain network', () {
        final result = enabledPolicy.evaluate(
          request(feature: feature, networkId: null),
          capability: config(feature: feature, networks: {}),
        );
        expect(result.isAvailable, isTrue);
      });
    }
  }

  test('missing and unsupported regions are rejected', () {
    for (final region in [null, '', ' ', 'GB', 'us']) {
      final result = enabledPolicy.evaluate(
        request(region: region),
        capability: config(),
      );
      expect(result.isAvailable, isFalse);
      expect(result.unavailableReasons, [
        region == null || region.trim().isEmpty
            ? PaymentUnavailableReason.regionMissing
            : PaymentUnavailableReason.regionUnsupported,
      ]);
    }
  });

  for (final entry in {
    PaymentKycStatus.unknown: PaymentUnavailableReason.kycMissing,
    PaymentKycStatus.pending: PaymentUnavailableReason.kycPending,
    PaymentKycStatus.rejected: PaymentUnavailableReason.kycRejected,
  }.entries) {
    test('${entry.key} KYC fails closed', () {
      final result = enabledPolicy.evaluate(
        request(kycStatus: entry.key),
        capability: config(),
      );
      expect(result.isAvailable, isFalse);
      expect(result.unavailableReasons, [entry.value]);
    });
  }

  test('operation approval and feature enablement are independent gates', () {
    for (final approved in [false, true]) {
      for (final enabled in [false, true]) {
        final result = enabledPolicy.evaluate(
          request(),
          capability: config(enabled: enabled, operationApproved: approved),
        );
        expect(result.isAvailable, approved && enabled);
        expect(result.unavailableReasons, [
          if (!enabled) PaymentUnavailableReason.capabilityDisabled,
          if (!approved) PaymentUnavailableReason.operationNotApproved,
        ]);
      }
    }
  });

  for (final feature in PaymentFeature.values) {
    test('$feature KYC exemption respects the operation boundary', () {
      final result = enabledPolicy.evaluate(
        request(feature: feature, kycStatus: PaymentKycStatus.unknown),
        capability: config(feature: feature, requiresKyc: false),
      );
      final isCrypto =
          feature == PaymentFeature.cryptoTransfer ||
          feature == PaymentFeature.cryptoRedPacket;
      expect(result.isAvailable, isCrypto);
      expect(result.unavailableReasons, [
        if (!isCrypto) PaymentUnavailableReason.kycMissing,
      ]);
    });
  }

  test('allowlists and decision reasons cannot be mutated after creation', () {
    final regions = <String>{'US'};
    final networks = <String>{'eip155:8453'};
    final capability = PaymentCapability(
      environment: PaymentEnvironment.production,
      feature: PaymentFeature.cryptoTransfer,
      enabled: true,
      operationApproved: true,
      supportedRegions: regions,
      supportedNetworkIds: networks,
    );
    regions.add('GB');
    networks.add('eip155:1');
    final result = enabledPolicy.evaluate(
      request(region: 'GB', networkId: 'eip155:1'),
      capability: capability,
    );
    expect(result.isAvailable, isFalse);
    expect(result.unavailableReasons, [
      PaymentUnavailableReason.regionUnsupported,
      PaymentUnavailableReason.networkUnsupported,
    ]);
    expect(() => capability.supportedRegions.add('GB'), throwsUnsupportedError);
    expect(
      () => capability.supportedNetworkIds.add('eip155:1'),
      throwsUnsupportedError,
    );
    expect(() => result.unavailableReasons.clear(), throwsUnsupportedError);
  });
}
