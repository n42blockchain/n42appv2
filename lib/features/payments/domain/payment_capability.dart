/// Execution environments must never inherit approval from each other.
enum PaymentEnvironment { production, sandbox, localSimulation }

enum PaymentFeature {
  fiatTransfer,
  fiatRedPacket,
  cryptoTransfer,
  cryptoRedPacket,
  onRamp,
  offRamp;

  bool get requiresNetwork => switch (this) {
    fiatTransfer || fiatRedPacket => false,
    cryptoTransfer || cryptoRedPacket || onRamp || offRamp => true,
  };
}

enum PaymentKycStatus { unknown, pending, rejected, verified }

/// Stable domain reasons; presentation layers provide localized explanations.
enum PaymentUnavailableReason {
  productionDisabled,
  capabilityNotConfigured,
  environmentMismatch,
  featureMismatch,
  capabilityDisabled,
  regionMissing,
  regionUnsupported,
  kycMissing,
  kycPending,
  kycRejected,
  operationNotApproved,
  networkMissing,
  networkUnsupported,
}

class PaymentCapabilityRequest {
  final PaymentEnvironment environment;
  final PaymentFeature feature;

  /// Country code selected by the application's reviewed eligibility process.
  /// This model does not derive eligibility from device locale or IP address.
  final String? region;
  final PaymentKycStatus kycStatus;

  /// Canonical, namespaced network identifier, never a token symbol.
  final String? networkId;

  const PaymentCapabilityRequest({
    required this.environment,
    required this.feature,
    this.region,
    this.kycStatus = PaymentKycStatus.unknown,
    this.networkId,
  });
}

/// An explicit, environment- and feature-scoped eligibility configuration.
///
/// Supply reviewed configuration, not untrusted client/API flags. Approval for
/// transfers does not imply approval for red packets or either ramp direction.
/// These fields are domain policy inputs, not a payment provider API schema.
class PaymentCapability {
  final PaymentEnvironment environment;
  final PaymentFeature feature;
  final bool enabled;

  /// Reviewed approval for the provider operation or self-custody chain flow.
  final bool operationApproved;

  /// Only reviewed crypto transfer/red-packet configurations may opt out.
  /// Fiat and ramp features always require verified KYC in this policy.
  final bool requiresKyc;
  final Set<String> supportedRegions;
  final Set<String> supportedNetworkIds;

  PaymentCapability({
    required this.environment,
    required this.feature,
    this.enabled = false,
    this.operationApproved = false,
    this.requiresKyc = true,
    Set<String> supportedRegions = const {},
    Set<String> supportedNetworkIds = const {},
  }) : supportedRegions = Set.unmodifiable(supportedRegions),
       supportedNetworkIds = Set.unmodifiable(supportedNetworkIds);
}

class PaymentCapabilityDecision {
  final PaymentEnvironment environment;
  final PaymentFeature feature;
  final List<PaymentUnavailableReason> unavailableReasons;

  PaymentCapabilityDecision._({
    required this.environment,
    required this.feature,
    required List<PaymentUnavailableReason> unavailableReasons,
  }) : unavailableReasons = List.unmodifiable(unavailableReasons);

  /// Availability applies only to [environment], including local simulation.
  bool get isAvailable => unavailableReasons.isEmpty;

  bool get isProductionAvailable =>
      environment == PaymentEnvironment.production && isAvailable;
}

/// Fail-closed capability evaluation. It neither authorizes nor executes funds.
///
/// Actual payments still require authoritative account eligibility, exact asset
/// and amount validation, and the provider/chain's transaction authorization.
class PaymentCapabilityPolicy {
  final bool productionEnabled;

  const PaymentCapabilityPolicy({this.productionEnabled = false});

  PaymentCapabilityDecision evaluate(
    PaymentCapabilityRequest request, {
    PaymentCapability? capability,
  }) {
    final reasons = <PaymentUnavailableReason>[];
    if (request.environment == PaymentEnvironment.production &&
        !productionEnabled) {
      reasons.add(PaymentUnavailableReason.productionDisabled);
    }

    if (capability == null) {
      reasons.add(PaymentUnavailableReason.capabilityNotConfigured);
    } else {
      if (capability.environment != request.environment) {
        reasons.add(PaymentUnavailableReason.environmentMismatch);
      }
      if (capability.feature != request.feature) {
        reasons.add(PaymentUnavailableReason.featureMismatch);
      }
      if (!capability.enabled) {
        reasons.add(PaymentUnavailableReason.capabilityDisabled);
      }
      if (!capability.operationApproved) {
        reasons.add(PaymentUnavailableReason.operationNotApproved);
      }
    }

    final region = request.region;
    if (region == null || region.trim().isEmpty) {
      reasons.add(PaymentUnavailableReason.regionMissing);
    } else if (capability != null &&
        !capability.supportedRegions.contains(region)) {
      reasons.add(PaymentUnavailableReason.regionUnsupported);
    }

    final canExemptKyc =
        request.feature == PaymentFeature.cryptoTransfer ||
        request.feature == PaymentFeature.cryptoRedPacket;
    final requiresKyc = !canExemptKyc || capability?.requiresKyc != false;
    if (requiresKyc) {
      switch (request.kycStatus) {
        case PaymentKycStatus.unknown:
          reasons.add(PaymentUnavailableReason.kycMissing);
        case PaymentKycStatus.pending:
          reasons.add(PaymentUnavailableReason.kycPending);
        case PaymentKycStatus.rejected:
          reasons.add(PaymentUnavailableReason.kycRejected);
        case PaymentKycStatus.verified:
          break;
      }
    }

    if (request.feature.requiresNetwork) {
      final network = request.networkId;
      if (network == null || network.trim().isEmpty) {
        reasons.add(PaymentUnavailableReason.networkMissing);
      } else if (capability != null &&
          !capability.supportedNetworkIds.contains(network)) {
        reasons.add(PaymentUnavailableReason.networkUnsupported);
      }
    }

    return PaymentCapabilityDecision._(
      environment: request.environment,
      feature: request.feature,
      unavailableReasons: reasons,
    );
  }
}
