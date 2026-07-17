import 'dart:typed_data';

import 'package:blake3_dart/blake3_dart.dart';

/// Blake3 hash function wrapper matching Rust n42-jmt's Blake3Hasher.
///
/// Uses a pure Dart implementation that is portable across Flutter platforms.
class Blake3Hash {
  Blake3Hash._();

  /// Compute Blake3 hash of [data], returning 32 bytes.
  static Uint8List hash(Uint8List data) {
    return blake3(data);
  }

  /// Compute Blake3 hash of concatenated byte arrays.
  static Uint8List hashAll(List<Uint8List> parts) {
    final bytes = BytesBuilder(copy: false);
    for (final part in parts) {
      bytes.add(part);
    }
    return blake3(bytes.takeBytes());
  }

  /// Domain-separated account key hash: blake3(b"n42:account:" || address).
  static Uint8List accountKey(Uint8List address) {
    assert(address.length == 20, 'address must be 20 bytes');
    final domain = Uint8List.fromList('n42:account:'.codeUnits);
    final combined = Uint8List(domain.length + address.length);
    combined.setAll(0, domain);
    combined.setAll(domain.length, address);
    return hash(combined);
  }

  /// Domain-separated storage key hash: blake3(b"n42:storage:" || address || slot).
  static Uint8List storageKey(Uint8List address, Uint8List slot) {
    assert(address.length == 20, 'address must be 20 bytes');
    assert(slot.length == 32, 'slot must be 32 bytes');
    final domain = Uint8List.fromList('n42:storage:'.codeUnits);
    final combined = Uint8List(domain.length + address.length + slot.length);
    combined.setAll(0, domain);
    combined.setAll(domain.length, address);
    combined.setAll(domain.length + address.length, slot);
    return hash(combined);
  }
}
