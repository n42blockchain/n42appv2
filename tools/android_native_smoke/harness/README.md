# Android native smoke harness

This Flutter app uses the isolated package ID `com.n42.android_native_smoke`.
It exercises the host's SQLCipher AAR/JNI and sqlite3 FFI arrangement, Matrix's
unkeyed sqflite database, and the Vodozemac native handshake. It does not use
the wallet application's package ID, accounts, keys, or data.

Use Flutter 3.47.5, JDK 21, Android SDK 37, and an isolated Android emulator.
Set `ANDROID_HOME`, `ANDROID_SDK_ROOT`, and `JAVA_HOME` to those installations.
From this directory, run the following two commands **in order** on the same
emulator. Replace `emulator-5554` with that emulator's serial if needed.

```sh
N42_SMOKE_SQLCIPHER_AAR=4.10.0 flutter test \
  integration_test/native_smoke_test.dart -d emulator-5554 --no-uninstall \
  --dart-define=N42_SMOKE_PHASE=seed

flutter test integration_test/native_smoke_test.dart -d emulator-5554 \
  --no-uninstall --dart-define=N42_SMOKE_PHASE=verify
```

The first run creates a keyed database with the published 4.10.0 AAR and a
plaintext source in this app's private storage. The second run replaces only
the APK with the 4.19.0 AAR and checks that the old encrypted file survives,
that correct and incorrect keys behave as expected, that sqlite3 FFI uses
SQLCipher 4.19, and that `sqlcipher_export` migrates the plaintext source.
It also opens an actual `MatrixSdkDatabase` without a key and performs a
Megolm encrypt/decrypt roundtrip through Vodozemac. The verification run
also checks Bouncy Castle 1.86, Web3j signing, recovery, Keccak, BIP39 and
BIP32 vectors, Torus address derivation, MediaPipe protobuf lite
serialization, a local WebSocket handshake/echo, and a historical CallKit JSON
value. The BIP39 fixture is from
[Trezor's published vectors](https://github.com/trezor/python-mnemonic/blob/master/vectors.json);
the BIP32 `m/0H` private key is decoded from
[BIP32 test vector 1](https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki).
`--no-uninstall` is
required: Flutter otherwise removes the seed app and its private fixture.

To compare Torus account identity with the former Bouncy Castle 1.68 artifact,
run this optional command. It uses two public test keys and checks both Torus
address APIs against the same fixed values as the 1.86 verification run.

```sh
N42_SMOKE_BC_LEGACY=1 flutter test \
  integration_test/native_smoke_test.dart -d emulator-5554 --no-uninstall \
  --dart-define=N42_SMOKE_PHASE=compatibility
```

The fixture key is a test-only literal in the test source. Remove this
isolated app when finished with
`adb -s emulator-5554 uninstall com.n42.android_native_smoke`.
Running on a 4 KB emulator establishes native
runtime behavior only for that page size. The final 16 KB device run remains
a separate acceptance step.
