import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

typedef _PairN = Int32 Function(Pointer<Uint8>, Pointer<Uint8>);
typedef _SignN = Int32 Function(Pointer<Uint8>, Pointer<Uint8>, Pointer<Uint8>);
typedef _VerifyN = Int32 Function(
  Pointer<Uint8>,
  Pointer<Uint8>,
  Pointer<Uint8>,
  IntPtr,
);

/// Native PQClean Falcon-512. Never derives Falcon keys from EVM private keys.
final class FalconCrypto {
  FalconCrypto(DynamicLibrary library)
    : _pair = library
          .lookupFunction<_PairN, int Function(Pointer<Uint8>, Pointer<Uint8>)>(
            'n42_pq_keypair',
          ),
      _sign = library
          .lookupFunction<
            _SignN,
            int Function(Pointer<Uint8>, Pointer<Uint8>, Pointer<Uint8>)
          >('n42_pq_sign'),
      _verify = library
          .lookupFunction<
            _VerifyN,
            int Function(Pointer<Uint8>, Pointer<Uint8>, Pointer<Uint8>, int)
          >('n42_pq_verify');
  factory FalconCrypto.mobile() => FalconCrypto(
    Platform.isIOS
        ? DynamicLibrary.process()
        : DynamicLibrary.open('libn42_pq.so'),
  );
  static const publicKeySize = 897,
      secretKeySize = 1281,
      maxSignatureSize = 666;
  final int Function(Pointer<Uint8>, Pointer<Uint8>) _pair;
  final int Function(Pointer<Uint8>, Pointer<Uint8>, Pointer<Uint8>) _sign;
  final int Function(Pointer<Uint8>, Pointer<Uint8>, Pointer<Uint8>, int)
  _verify;

  ({Uint8List publicKey, Uint8List secretKey}) generate() {
    final p = calloc<Uint8>(publicKeySize), s = calloc<Uint8>(secretKeySize);
    try {
      if (_pair(p, s) != 0) throw StateError('Falcon key generation failed');
      return (
        publicKey: Uint8List.fromList(p.asTypedList(publicKeySize)),
        secretKey: Uint8List.fromList(s.asTypedList(secretKeySize)),
      );
    } finally {
      s.asTypedList(secretKeySize).fillRange(0, secretKeySize, 0);
      calloc.free(s);
      calloc.free(p);
    }
  }

  Uint8List sign(Uint8List secret, Uint8List digest) {
    if (secret.length != secretKeySize || digest.length != 32) {
      throw ArgumentError('Invalid Falcon signing input');
    }
    final s = calloc<Uint8>(secretKeySize),
        m = calloc<Uint8>(32),
        out = calloc<Uint8>(maxSignatureSize);
    try {
      s.asTypedList(secretKeySize).setAll(0, secret);
      m.asTypedList(32).setAll(0, digest);
      final count = _sign(s, m, out);
      if (count <= 0 || count > maxSignatureSize) {
        throw StateError('Falcon signing failed');
      }
      return Uint8List.fromList(out.asTypedList(count));
    } finally {
      s.asTypedList(secretKeySize).fillRange(0, secretKeySize, 0);
      calloc.free(s);
      calloc.free(m);
      calloc.free(out);
    }
  }

  bool verify(Uint8List publicKey, Uint8List digest, Uint8List signature) {
    if (publicKey.length != publicKeySize ||
        digest.length != 32 ||
        signature.isEmpty ||
        signature.length > maxSignatureSize) {
      return false;
    }
    final p = calloc<Uint8>(publicKeySize),
        m = calloc<Uint8>(32),
        s = calloc<Uint8>(signature.length);
    try {
      p.asTypedList(publicKeySize).setAll(0, publicKey);
      m.asTypedList(32).setAll(0, digest);
      s.asTypedList(signature.length).setAll(0, signature);
      return _verify(p, m, s, signature.length) == 0;
    } finally {
      calloc.free(p);
      calloc.free(m);
      calloc.free(s);
    }
  }
}
