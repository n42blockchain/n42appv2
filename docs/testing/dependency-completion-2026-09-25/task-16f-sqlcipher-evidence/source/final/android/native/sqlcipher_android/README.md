# SQLCipher Android native rebuild

`scripts/build_sqlcipher_android.py` rebuilds only the four `libsqlcipher.so` members. It does not replace the app dependency or publish a supplier artifact.

Use an isolated checkout of [sqlcipher-android](https://github.com/sqlcipher/sqlcipher-android) at `9a5d685404489cbff14d4c46da81555de1a38787`. In its `sqlcipher/src/main/jni/sqlcipher/src` directory, check out [SQLCipher core](https://github.com/sqlcipher/sqlcipher) at `c4b275a47932888216bade83aff2bbc73df0ff85`. The wrapper's original gitlink points to 4.16.0, so this override is required for a 4.19.0 candidate. In `sqlcipher/src/main/jni/libtomcrypt/src`, check out [LibTomCrypt](https://github.com/sqlcipher/libtomcrypt) at `476a9579ae94f32b9ea9e2747bfb04b302370259`. Keep all three checkouts clean and their ignored generated files absent.

On the recorded macOS/Xcode 27.0 build host with Android NDK `28.2.13676358`:

```sh
python3 scripts/build_sqlcipher_android.py \
  --source /absolute/path/to/isolated/sqlcipher-android \
  --out /absolute/path/to/new/output \
  --ndk /absolute/path/to/ndk/28.2.13676358
```

The recipe verifies the three commits, clean source, selected source/license bytes, NDK/Xcode tool bytes, and an unused output path before editing the isolated checkout. It runs the pinned core's `./configure --with-tempstore=yes --disable-tcl` and `make sqlite3.c`, checks both generated files, patches only the final shared-library link for 16 KB common pages and `JNIHelp.cpp` for the Android API dependent `strerror_r` return type, then invokes `ndk-build` with API23 for all four ABIs. It clears inherited `SQLCIPHER_CFLAGS` and `MAKEFILES` so the wrapper's LibTomCrypt and SQLite feature defaults remain selected without an injected makefile. Logs, generated-file hashes, exact source patch, tool identities and native member hashes are emitted under `--out`.

`scripts/build_sqlcipher_android_maven.py` checks the official 4.19.0 AAR, POM, module, sources and javadoc hashes, plus the accepted four native hashes and source-build manifest. It copies all 17 original AAR entries, replacing only the four `jni/<ABI>/libsqlcipher.so` members. The other 13 entries, including the original Java classes and resources, remain bytewise identical. The official POM and auxiliary JARs are copied exactly; only the two AAR file records in Gradle module metadata receive new size and digests. To regenerate the tracked local module from retained inputs:

```sh
python3 scripts/build_sqlcipher_android_maven.py \
  --official-dir /absolute/path/to/official-4.19.0-artifacts \
  --candidate-dir /absolute/path/to/accepted-native-build \
  --candidate-manifest /absolute/path/to/accepted-native-build/manifest.json \
  --output-root /absolute/path/to/empty/output-root
```

The app uses an exclusive local repository for this exact `net.zetetic:sqlcipher-android:4.19.0` module; both the host and vendored `sqflite_sqlcipher` plugin request that version. This is a maintained source candidate built with NDK28.2, while the wrapper tag requests NDK25.2 and its published Maven AAR does not attest its full native source or toolchain. Candidate4 was built before the final expanded tool-byte and `MAKEFILES` recipe guards; those guards do not retroactively describe its build environment. Actual Java and SQLite FFI database behavior on the strict 16 KB emulator remains a separate acceptance gate. The 4096-byte SQLCipher database page default is unchanged; it is separate from ELF memory page alignment.
