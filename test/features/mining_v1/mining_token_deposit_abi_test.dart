import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/mining_v1/api/mining_token.dart';
import 'package:web3dart/web3dart.dart';

void main() {
  test('deposit ABI encodes the independent BLS oracle bytes', () {
    const publicKey =
        '850e1b31deb8cf7202b3a060f79ba72d107688cda71f2fa78016c29395e148cb192904c7dfa7d64a2a09b7c95ef5168b';
    const signature =
        'ae57498fe373727aa21011bcc2debacbb09ed69c93bac38848752fa9f60f750d942e1fde6ec94bc819e4d6da6b3dac7419ad5b87e7ffefe74fa0fa321ca281b1add3967c6666025ef9ebedc39bd71058a05c76044b54cc79d4c934a488d30ce6';
    final function = ContractAbi.fromJson(
      astMining,
      'Token',
    ).functions.singleWhere((candidate) => candidate.name == 'deposit');
    final encoded = function.encodeCall([
      hexToBytes(publicKey),
      hexToBytes(signature),
    ]);

    const selector = '164af1df';
    const publicOffset =
        '0000000000000000000000000000000000000000000000000000000000000040';
    const signatureOffset =
        '00000000000000000000000000000000000000000000000000000000000000a0';
    const publicLength =
        '0000000000000000000000000000000000000000000000000000000000000030';
    const signatureLength =
        '0000000000000000000000000000000000000000000000000000000000000060';
    const publicPadding = '00000000000000000000000000000000';
    expect(
      bytesToHex(encoded),
      '$selector$publicOffset$signatureOffset'
      '$publicLength$publicKey$publicPadding'
      '$signatureLength$signature',
    );
  });
}
