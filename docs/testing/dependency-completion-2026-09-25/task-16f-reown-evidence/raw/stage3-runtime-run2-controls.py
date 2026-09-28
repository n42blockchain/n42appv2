"""Mutate copies of a successful Reown receipt and require semantic rejection."""

import copy
import json
from pathlib import Path

from tools.android_native_smoke.verify_reown_wcpay_fixture import verify


ROOT = Path(__file__).resolve().parents[3]
W = Path(__file__).resolve().parent
RUN = W / "task-16f-reown-stage3-runtime-run2"
APKS = {phase: W / "task-16f-reown-stage3-build-v2" / f"{phase}.apk"
        for phase in ("baseline", "candidate", "mismatch")}
JNA = Path("/Users/jieliu/.gradle/caches/modules-2/files-2.1/net.java.dev.jna/jna/5.17.0/4134d63c53cbf9650b11ee950df093add29f14cf/jna-5.17.0.aar")
MISMATCH = W / "task-16f-reown-stage3-build/mismatch-input"


def edit_result(receipt, phase, change):
    item = receipt["phases"][phase]
    change(item["result"])
    log = item["result_logcat"]["stdout"].splitlines()
    for index, line in enumerate(log):
        marker = "N42_REOWN_FIXTURE: "
        if marker in line:
            log[index] = line[:line.index(marker) + len(marker)] + json.dumps(
                item["result"], separators=(",", ":"))
            break
    else:
        raise RuntimeError("missing tagged log line")
    item["result_logcat"]["stdout"] = "\n".join(log)


def wrong_map(result):
    fields = result["executableApkMaps"][0].split()
    fields[2] = "00000000"
    result["executableApkMaps"][0] = " ".join(fields)


def stale_log_pid(receipt):
    log = receipt["phases"]["candidate"]["result_logcat"]["stdout"]
    original = str(receipt["phases"]["candidate"]["result"]["pid"])
    changed = log.replace(f" {original} {original} I N42_REOWN_FIXTURE:",
                          " 99999 99999 I N42_REOWN_FIXTURE:", 1)
    if changed == log:
        raise RuntimeError("candidate PID log frame absent")
    receipt["phases"]["candidate"]["result_logcat"]["stdout"] = changed


def run():
    original = json.loads((RUN / "reown-runtime-receipt.json").read_text())
    checks = [
        ("wrong_strict_state", lambda r: r["phases"]["candidate"]["pre"]
         ["package_compat_disabled"].__setitem__("stdout", "false"),
         "candidate pre: package_compat_disabled mismatch"),
        ("missing_typed_error", lambda r: edit_result(r, "candidate",
         lambda x: x.pop("confirmJsonParse")), "candidate: confirmJsonParse typed error mismatch"),
        ("mismatch_checker_accepted", lambda r: edit_result(r, "mismatch",
         lambda x: x.__setitem__("mismatchError", "Mismatched binding was accepted")),
         "mismatch: mismatchError"),
        ("wrong_executable_map", lambda r: edit_result(r, "candidate", wrong_map),
         "candidate: lib/arm64-v8a/libuniffi_yttrium_wcpay.so executable map misses LOAD"),
        ("wrong_installed_hash", lambda r: edit_result(r, "candidate",
         lambda x: x.__setitem__("apkSha256", "0" * 64)),
         "candidate: installed APK hash mismatch"),
        ("wrong_source_hash", lambda r: r["source_sha256"].__setitem__(
         next(iter(r["source_sha256"])), "0" * 64), "source input identity mismatch"),
        ("stale_log_pid", stale_log_pid, "candidate: log PID mismatch"),
    ]
    results = []
    for name, change, expected in checks:
        receipt = copy.deepcopy(original)
        change(receipt)
        try:
            verify(receipt, APKS, JNA, MISMATCH)
        except ValueError as error:
            if expected not in str(error):
                raise RuntimeError(f"{name}: wrong rejection: {error}") from error
            results.append({"control": name, "rejected": str(error)})
        else:
            raise RuntimeError(f"{name}: mutated receipt accepted")
    print(json.dumps({"passed": True, "rejected": results}, indent=2))


if __name__ == "__main__":
    run()
