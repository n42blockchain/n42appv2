import 'dart:typed_data';
import 'package:hashlib/hashlib.dart';

/// Blake3 hash function wrapper matching Rust n42-jmt's Blake3Hasher.
///
/// Uses the `hashlib` package which provides a pure Dart Blake3 implementation
/// with SIMD acceleration where available.
class Blake3Hash {
  Blake3Hash._();

  /// Compute Blake3 hash of [data], returning 32 bytes.
  static Uint8List hash(Uint8List data) {
    final digest = blake3.convert(data);
    return Uint8List.fromList(digest.bytes);
  }

  /// Compute Blake3 hash of concatenated byte arrays.
  static Uint8List hashAll(List<Uint8List> parts) {
    final sink = blake3.createSink();
    for (final part in parts) {
      sink.add(part);
    }
    final digest = sink.digest();
    return Uint8List.fromList(digest.bytes);
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
