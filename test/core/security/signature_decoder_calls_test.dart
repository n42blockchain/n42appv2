import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/security/signature_decoder.dart';
import 'package:n42_wallet/core/security/tx_risk_models.dart';

/// Wallet Roadmap S8 —— 合约调用签名可读化（新增 selector 覆盖）测试。
String _call(String selector) => '0x$selector${'0' * 64}';

void main() {
  test('increaseAllowance -> caution', () {
    final r = SignatureDecoder.decodeContractCall(calldata: _call('39509351'));
    expect(r.title, 'Increase Allowance');
    expect(r.riskLevel, TxRiskLevel.caution);
  });

  test('decreaseAllowance -> safe', () {
    final r = SignatureDecoder.decodeContractCall(calldata: _call('a457c2d7'));
    expect(r.title, 'Decrease Allowance');
    expect(r.riskLevel, TxRiskLevel.safe);
  });

  test('ERC-1155 safeTransferFrom recognized', () {
    final r = SignatureDecoder.decodeContractCall(calldata: _call('f242432a'));
    expect(r.title, 'NFT Transfer (ERC-1155)');
  });

  test('WETH wrap/unwrap recognized', () {
    expect(
      SignatureDecoder.decodeContractCall(calldata: _call('d0e30db0')).title,
      'Wrap ETH',
    );
    expect(
      SignatureDecoder.decodeContractCall(calldata: _call('2e1a7d4d')).title,
      'Unwrap WETH',
    );
  });

  test('Uniswap V3 exactInputSingle -> Token Swap', () {
    final r = SignatureDecoder.decodeContractCall(calldata: _call('414bf389'));
    expect(r.title, 'Token Swap');
  });

  test('unknown selector -> caution with warning', () {
    final r = SignatureDecoder.decodeContractCall(calldata: _call('deadbeef'));
    expect(r.riskLevel, TxRiskLevel.caution);
    expect(r.warnings, isNotEmpty);
  });
}
