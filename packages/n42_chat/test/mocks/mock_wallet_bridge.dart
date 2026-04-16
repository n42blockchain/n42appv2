import 'package:n42_chat/src/integration/wallet_bridge.dart';

/// Mock wallet bridge for testing only.
///
/// Contains hardcoded fake data — MUST NOT be used in production.
class MockWalletBridge extends IWalletBridge {
  @override
  bool get isWalletConnected => true;

  @override
  String? get walletAddress => '0x1234567890abcdef1234567890abcdef12345678';

  @override
  Future<List<TokenInfo>> getSupportedTokens() async {
    return const [
      TokenInfo(
        symbol: 'ETH',
        name: 'Ethereum',
        decimals: 18,
        isNative: true,
      ),
      TokenInfo(
        symbol: 'USDT',
        name: 'Tether USD',
        decimals: 6,
        contractAddress: '0xdac17f958d2ee523a2206206994597c13d831ec7',
      ),
    ];
  }

  @override
  Future<String> getBalance(String token) async {
    return token == 'ETH' ? '1.5' : '100.00';
  }

  @override
  Future<TransferResult> requestTransfer({
    required String toAddress,
    required String amount,
    required String token,
    String? memo,
  }) async {
    await Future<void>.delayed(const Duration(seconds: 2));
    return TransferResult.success('0x${'1234' * 16}');
  }

  @override
  Future<PaymentRequest> generatePaymentRequest({
    required String amount,
    required String token,
    String? memo,
  }) async {
    return PaymentRequest(
      requestId: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      token: token,
      receiverAddress: walletAddress!,
      memo: memo,
      qrCodeData: 'n42://pay?address=$walletAddress&amount=$amount&token=$token',
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(minutes: 30)),
    );
  }

  @override
  Future<void> showReceiveQRCode() async {}

  @override
  bool isValidAddress(String address) {
    return address.startsWith('0x') && address.length == 42;
  }

  @override
  Future<WalletUserInfo?> getUserInfoByAddress(String address) async {
    return null;
  }
}
