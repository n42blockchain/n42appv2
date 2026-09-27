# DataStore 1.2.1 bounded Android evidence

Task16F.1 source commit: `9697ba07f43c96bf7cfd856cb75fcc5abd2eccfd` (independently reviewed and published before this archive). The production change constrains the host's 12 resolved AndroidX DataStore modules to 1.2.1 while retaining its legacy SharedPreferences backend. See [report.md](report.md) for test results and limits.

The synthetic fixture was created with Flutter 3.47.5/Dart 3.13.4:

```sh
flutter create --no-pub --platforms=android --project-name datastore_fixture --org ai.n42.fixture "$W/datastore-fixture"
cp -R fixture-overlay/. "$W/datastore-fixture/"
cd "$W/datastore-fixture"
flutter pub get --offline
flutter analyze --no-pub --no-fatal-infos
cd "$W/datastore-fixture/android"
./gradlew :app:dependencyInsight --configuration debugRuntimeClasspath --dependency androidx.datastore --offline
```

Here `$W` is the app worktree's `.superpowers/sdd/dependency-completion-20260925` directory. The overlay includes only fixture files that differ from `flutter create`. To replay the device script in that task workspace, copy `recipe/run_datastore_fixture.sh` and `recipe/verify_datastore_fixture.py` into `$W`, then call `bash "$W/run_datastore_fixture.sh" /path/to/datastore-core.aar`. It is pinned to the documented local Flutter, ADB, NDK strip and emulator-5560 paths. It clears only the synthetic `ai.n42.fixture.datastore_fixture` package, checks an offline strict 16 KB device before/after, and restores strict settings in a trap. Do not run it against a device containing real application data. The pinned official DataStore AAR SHA256 is `435edad7bcb1fbb1a2a46de7be4d6daf299479b3328ebf757ebdfe02810cbdd8`.

`recipe/run_datastore_fixture_run1.sh` has exact SHA256 `f87991ebd9e597281ea923f0867ae741fb8dc1f4400559659450ef59a8faf2ba` from the captured one-APK run. That run's two device phases and native/identity verifier passed, but the script exited 1 at its final whole-debug-APK audit. The whole audit correctly reported 3/5 passing 64-bit libraries; its two failures were debug Flutter engine members. The revised `recipe/run_datastore_fixture.sh` checks the scoped DataStore 2/2 result and reports the whole-debug failure explicitly. It has syntax and analyzer checks, but **was not rerun end-to-end**. Focused postprocessing of the captured audit was successful. Earlier failed Flutter test attempts and Robolectric failure are retained in `logs/`.

The APK itself is excluded from Git: debug fixture APK SHA256 `0ecb6bf189267a334236d877904bc7ea5e08bf324ede04dd2005b1c289964404`, target SDK37. `logs/fixture-seed-result.json` and `logs/fixture-verify-result.json` contain synthetic values and native map observations; `logs/fixture-verification.json` binds both runs to that APK SHA, the AAR/strip-normalized JNI member, ZIP entry offset and distinct PIDs. `manifest.json` hashes all archived members except this README and itself. All `.log` files use deterministic gzip (`mtime=0`); uncompress them for raw text. The report cites the original log basenames; their archived names add `.gz`.

A final production APK/AAB whole-native audit is pending after the remaining owned Task16F library groups. This archive does not establish whole debug or production package 16 KB compliance.
