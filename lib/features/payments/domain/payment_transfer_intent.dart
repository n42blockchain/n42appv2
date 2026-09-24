import 'payment_amount.dart';
import 'payment_asset.dart';

/// Validated construction parameters for an EVM ERC-20 transfer.
///
/// This is NOT signing authorization, a signed transaction, or proof of funds.
/// Balances, expected asset identity and fee quote must come from trusted,
/// account-scoped callers. This class performs no RPC, signing or broadcasting.
/// The caller must revalidate expiry/balances and obtain explicit authorization
/// before constructing the final transaction with nonce and gas parameters.
final class PaymentTransferIntent {
  factory PaymentTransferIntent.prepare({
    required PaymentAmount amount,
    required String expectedNetwork,
    required String expectedContract,
    required String recipient,
    required BigInt tokenBalance,
    required BigInt nativeFeeBalance,
    required BigInt quotedFee,
    required DateTime expiresAt,
    required DateTime now,
  }) {
    final id = amount.asset.id;
    if (id.namespace != 'eip155' || id.isNative) {
      throw ArgumentError('An EVM contract token is required');
    }
    final expectedId = PaymentAssetId(
      namespace: 'eip155',
      network: expectedNetwork,
      contract: expectedContract,
    );
    if (id != expectedId) {
      throw ArgumentError(
        'Selected asset does not match expected network and contract',
      );
    }
    if (BigInt.parse(id.contract!.substring(2), radix: 16) == BigInt.zero) {
      throw ArgumentError('Token contract must not be the zero address');
    }
    final recipientMatch = _addressPattern.matchAsPrefix(recipient);
    if (recipientMatch == null || recipientMatch.end != recipient.length) {
      throw ArgumentError.value(
        recipient,
        'recipient',
        'Expected a 20-byte EVM address',
      );
    }
    final canonicalRecipient = recipient.toLowerCase();
    if (BigInt.parse(canonicalRecipient.substring(2), radix: 16) ==
        BigInt.zero) {
      throw ArgumentError('Recipient must not be the zero address');
    }
    if (amount.units <= BigInt.zero || amount.units > maxUint256) {
      throw ArgumentError('Transfer amount must be positive and fit uint256');
    }
    if (tokenBalance.isNegative ||
        nativeFeeBalance.isNegative ||
        quotedFee.isNegative) {
      throw ArgumentError('Balances and quoted fee must not be negative');
    }
    if (tokenBalance < amount.units) {
      throw StateError('Insufficient token balance');
    }
    if (nativeFeeBalance < quotedFee) {
      throw StateError('Insufficient native balance for quoted fee');
    }
    if (!expiresAt.isAfter(now)) {
      throw StateError('Fee quote has expired');
    }

    final addressWord = canonicalRecipient.substring(2).padLeft(64, '0');
    final amountWord = amount.units.toRadixString(16).padLeft(64, '0');
    return PaymentTransferIntent._(
      amount: amount,
      recipient: canonicalRecipient,
      calldata: '0xa9059cbb$addressWord$amountWord',
      quotedFee: quotedFee,
      expiresAt: expiresAt.toUtc(),
      preparedAt: now.toUtc(),
    );
  }

  const PaymentTransferIntent._({
    required this.amount,
    required this.recipient,
    required this.calldata,
    required this.quotedFee,
    required this.expiresAt,
    required this.preparedAt,
  });

  static final BigInt maxUint256 = (BigInt.one << 256) - BigInt.one;
  static final _addressPattern = RegExp(
    r'0x[0-9a-f]{40}',
    caseSensitive: false,
  );

  final PaymentAmount amount;
  final String recipient;
  final String calldata;
  final BigInt quotedFee;
  final DateTime expiresAt;
  final DateTime preparedAt;

  String get namespace => amount.asset.id.namespace;
  String get network => amount.asset.id.network;
  BigInt get chainId => BigInt.parse(network);

  /// Transaction destination is the token contract, not the recipient.
  String get to => amount.asset.id.contract!;

  /// An ERC-20 transfer attaches no native currency to the contract call.
  BigInt get value => BigInt.zero;

  /// Rechecks the review state immediately before a signer is invoked.
  ///
  /// The confirmation screen must pass the displayed account and the account
  /// returned by device authorization separately. Current balances and fee
  /// data must be fetched again by the caller; any changed fee requires a new
  /// review. This guard does not itself perform device authorization or sign.
  void validateForSigning({
    required String preparedForAddress,
    required String activeAddress,
    required String authorizedAddress,
    required BigInt tokenBalance,
    required BigInt nativeFeeBalance,
    required BigInt quotedFee,
    required DateTime now,
  }) {
    final prepared = _canonicalNonzeroAddress(
      preparedForAddress,
      'preparedForAddress',
    );
    final active = _canonicalNonzeroAddress(activeAddress, 'activeAddress');
    final authorized = _canonicalNonzeroAddress(
      authorizedAddress,
      'authorizedAddress',
    );
    if (prepared != active || prepared != authorized) {
      throw StateError('Active wallet or device authorization changed');
    }
    if (tokenBalance.isNegative ||
        nativeFeeBalance.isNegative ||
        quotedFee.isNegative) {
      throw ArgumentError('Balances and fee must not be negative');
    }
    if (tokenBalance < amount.units) {
      throw StateError('Insufficient token balance at signing time');
    }
    if (nativeFeeBalance < quotedFee) {
      throw StateError('Insufficient native balance for fee at signing time');
    }
    if (quotedFee != this.quotedFee) {
      throw StateError('Fee quote changed; review the transfer again');
    }
    if (!expiresAt.isAfter(now)) {
      throw StateError('Fee quote has expired');
    }
  }

  static String _canonicalNonzeroAddress(String value, String name) {
    final match = _addressPattern.matchAsPrefix(value);
    if (match == null || match.end != value.length) {
      throw ArgumentError.value(value, name, 'Expected a 20-byte EVM address');
    }
    if (BigInt.parse(value.substring(2), radix: 16) == BigInt.zero) {
      throw ArgumentError.value(value, name, 'Address must not be zero');
    }
    return value.toLowerCase();
  }
}
