# Wallet Core API two-device runner gate fix 1

Addresses the two HOLD findings in `task-16f-walletcore-app-api-runner-review.md`; still **no device fixture run** and no APK/native/production-adapter rebuild.

## Ownership before action

The runner now performs read-only checks for **both** designated emulators before strict configuration or either APK install. The task launch sources are `android-16kb-environment.json` SHA-256 `f1104db6e1f5ec4a3f957094090a77a751ee78d6b08d2eef397405efb2faea7f` and `task-api26-avd/launch.json` SHA-256 `a8f3b15e83fd6ec43371205257763dd0f698993dd2f2a12c848b386c5c0ee869`. The former pins the strict AVD, port and SDK but has no original host PID; a read-only host observation on 2026-09-28 found PID **49781** owning both 5560/5561 with exact `N42_Dependency_API37_16KB` command and task-owned AVD lock. The API 26 launch receipt pins PID **8313**, and host observation confirmed it owns 5562/5563 with exact `N42_API26_ARM64_W` command and task-owned AVD lock. These PID/command/AVD/port/lock values are frozen in the runner gate. If either process restarts or a serial is reassigned, the runner fails closed and requires a new explicit qualification; it does not silently accept a replacement.

The preflight records exact `adb -s <serial> get-state`, `adb -s <serial> emu avd name`, `ps -p <pid> -o command=`, `lsof` port owners and the process's open task-owned `multiinstance.lock`. The standalone verifier checks these command results and the original launch source hashes. The runner does not mutate emulator-5560 until **both** ownership checks pass.

## Installed APK and command replay

Each installed `<serial>-installed.apk` remains under the task receipt directory. Replay now requires that regular file, rejects a symlink, reads its actual bytes and matches the pinned build3 APK SHA-256 `f3f627565b70b42787f15bce7cf1c8024a6c4696b916a289e196a96d6526b855`. The verifier also binds exact `adb -s` argv for every state snapshot, install, clear, `pm path`, pull remote/local path, logcat, launch nonce and force-stop. The receipt alone can no longer stand in for a missing or changed pulled file. Actual device evidence remains pending.

Focused no-device checks: `python3 -m unittest tools/android_native_smoke/test_walletcore_api_runtime_gate.py -v` and `python3 -O -m unittest ... -v` each passed **6/6**, including changed host owner/port, deleted/substituted pulled APK, wrong serial for pull/install/start/snapshot, altered native map and missing unsupported error. The synthetic receipt is only a verifier regression. No device command was run for this fix; host `ps`/`lsof` observations were read-only.
