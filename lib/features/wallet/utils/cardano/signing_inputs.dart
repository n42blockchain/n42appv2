/// The current native bridge signs ADA-only inputs. UTxOs carrying other
/// assets remain unspent until native multi-asset change is implemented.
class CardanoSigningInputs {
  final List<Map<String, dynamic>> utxos;
  final BigInt balance;
  final bool excludesNativeAssets;

  CardanoSigningInputs._(this.utxos, this.balance, this.excludesNativeAssets);

  static final _max = BigInt.parse('9223372036854775807');

  static BigInt _quantity(dynamic raw) {
    if (raw is! String || !RegExp(r'^[1-9][0-9]*$').hasMatch(raw)) {
      throw const FormatException('Invalid Cardano input quantity');
    }
    final value = BigInt.parse(raw);
    if (value > _max) throw const FormatException('Cardano quantity overflow');
    return value;
  }

  factory CardanoSigningInputs.fromBlockfrost(dynamic raw, String sender) {
    if (raw is! List || raw.isEmpty || sender.isEmpty) {
      throw const FormatException('Cardano inputs are unavailable');
    }
    final selected = <Map<String, dynamic>>[];
    final seen = <String>{};
    var balance = BigInt.zero;
    var excludesNativeAssets = false;
    for (final value in raw) {
      if (value is! Map) throw const FormatException('Invalid Cardano input');
      final hash = value['tx_hash'];
      final index = value['output_index'];
      final address = value['address'];
      final amounts = value['amount'];
      if (hash is! String ||
          !RegExp(r'^[0-9a-fA-F]{64}$').hasMatch(hash) ||
          index is! int ||
          index < 0 ||
          index > 0xffffffff ||
          address != sender ||
          amounts is! List ||
          amounts.isEmpty ||
          !seen.add('${hash.toLowerCase()}:$index')) {
        throw const FormatException('Invalid or duplicate Cardano input');
      }
      BigInt? lovelace;
      final units = <String>{};
      var hasTokens = false;
      for (final amount in amounts) {
        if (amount is! Map) {
          throw const FormatException('Invalid Cardano asset');
        }
        final unit = amount['unit'];
        if (unit is! String || !units.add(unit)) {
          throw const FormatException('Invalid or duplicate Cardano asset');
        }
        final quantity = _quantity(amount['quantity']);
        if (unit == 'lovelace') {
          lovelace = quantity;
        } else {
          // 28-byte policy ID followed by a 0..32-byte asset name.
          if (!RegExp(r'^[0-9a-f]{56}([0-9a-f]{2}){0,32}$').hasMatch(unit)) {
            throw const FormatException('Invalid Cardano asset identifier');
          }
          hasTokens = true;
        }
      }
      if (lovelace == null) throw const FormatException('Missing lovelace');
      if (hasTokens) {
        excludesNativeAssets = true;
        continue;
      }
      balance += lovelace;
      if (balance > _max) {
        throw const FormatException('Cardano balance overflow');
      }
      selected.add({
        'txHash': hash.toLowerCase(),
        'outputIndex': index,
        'amount': lovelace.toString(),
        'address': address,
      });
    }
    return CardanoSigningInputs._(selected, balance, excludesNativeAssets);
  }

  /// A bounded local validity window, in slots, relative to the selected node.
  static String ttl(dynamic block) {
    final slot = block is Map ? block['slot'] : null;
    if (slot is! int ||
        slot < 0 ||
        BigInt.from(slot) > _max - BigInt.from(3600)) {
      throw const FormatException('Cardano block slot is unavailable');
    }
    return (BigInt.from(slot) + BigInt.from(3600)).toString();
  }
}
