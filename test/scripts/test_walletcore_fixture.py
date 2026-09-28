import copy
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch


ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "tools/android_native_smoke"))
import run_walletcore_fixture as runner
import verify_walletcore_fixture as verifier


TASK = ROOT / ".superpowers/sdd/dependency-completion-20260925"
APKS = {phase: TASK / relative for phase, relative in {
    "baseline": "task-16f-walletcore-fixture-build/baseline5/walletcore-baseline.apk",
    "candidate": "task-16f-walletcore-fixture-build/candidate3/walletcore-candidate.apk",
}.items()}


def event(phase, token, kind, **fields):
    return {"kind": kind, "phase": phase, "token": token, "pid": 12345, **fields}


def logcat(events):
    return "\n".join(f"09-28 12:00:00.000  {item['pid']}  {item['pid']} I " +
                     "N42_WALLETCORE_FIXTURE: " +
                     json.dumps(item, separators=(",", ":")) for item in events)


def snapshot():
    return {name: {"exit": 0, "stdout": value} for name, value in {
        "page_size": "16384", "linker_mode": "fatal",
        "package_compat_disabled": "true", "airplane_mode": "1",
        "wifi_on": "0", "ip_route": "",
    }.items()}


def phase_receipt(phase, loaded=True):
    apk = APKS[phase]
    _, offset, loads = verifier.member_and_executable_offsets(apk)
    token = "a" * 32
    apk_path = "/data/app/fixture/base.apk"
    begin = event(phase, token, "BEGIN", apkPath=apk_path,
                  apkSha256=verifier.APK_SHA256[phase],
                  libraryLookupPath=f"{apk_path}!/{verifier.MEMBER}")
    events = [begin]
    if loaded:
        maps = [f"10000000-{0x10000000 + size:x} r-xp {start:08x} 00:00 0 {apk_path}"
                for start, size in loads]
        events.append(event(phase, token, "LOADED", nativeMaps=maps))
        for name in verifier.CASES:
            events.append(event(phase, token, "CASE", name=name,
                                required=name != verifier.CASES[-1],
                                outcome="OBSERVED" if name == verifier.CASES[-1] else "PASS",
                                result={"sha256": name}))
    events.append(event(phase, token, "END", status="PASS" if loaded else "FAIL",
                        **({} if loaded else {"error": "native load failed"})))
    return {
        "package": verifier.PACKAGES[phase], "apk_sha256": verifier.APK_SHA256[phase],
        "member_data_offset": offset, "member_executable_loads": loads,
        "pre": snapshot(), "post": snapshot(), "token": token,
        "pulled_apk_sha256": verifier.APK_SHA256[phase],
        "pm_path": {"exit": 0, "stdout": f"package:{apk_path}"},
        "permissions": {"exit": 0, "stdout": f"package: {verifier.PACKAGES[phase]}"},
        "result_logcat": {"exit": 0, "stdout": logcat(events)},
        "events": events,
        **{name: {"exit": 0} for name in ("install", "clear", "pull", "logcat_clear",
                                           "start", "force_stop", "zipalign", "badging",
                                           "apksigner")},
    }


def distinct_process(item, pid, token):
    item["token"] = token
    for record in item["events"]:
        record["pid"] = pid
        record["token"] = token
    item["result_logcat"]["stdout"] = logcat(item["events"])


def full_receipt(baseline_loaded=True):
    baseline = phase_receipt("baseline", baseline_loaded)
    candidate = phase_receipt("candidate")
    distinct_process(baseline, 23456, "b" * 32)
    distinct_process(candidate, 34567, "c" * 32)
    return {
        "schema_version": 1, "device": verifier.DEVICE,
        "build_epoch_sha256": verifier.EPOCH_SHA256,
        "build_epoch": verifier.require_epoch(TASK, APKS),
        "device_tool_sha256": verifier.DEVICE_TOOL_SHA256,
        "git_head": "0" * 40, "source_sha256": {},
        "strict_setup": [{"exit": 0}] * 4,
        "strict_restore": [{"exit": 0}] * 4,
        "final": snapshot(), "phases": {"baseline": baseline, "candidate": candidate},
    }


class WalletCoreFixtureVerifierTest(unittest.TestCase):
    def test_git_epoch_contains_every_reviewed_source(self):
        head = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=ROOT,
                                       text=True).strip()
        sources = {name: verifier.digest(ROOT / name)
                   for name in verifier.REVIEWED_SOURCES}
        verifier.require_git_epoch(head, sources)
        wrong = {**sources, verifier.REVIEWED_SOURCES[0]: "0" * 64}
        with self.assertRaisesRegex(ValueError, "source receipt changed"):
            verifier.require_git_epoch(head, wrong)

    def test_epoch_and_exact_apk_members_are_pinned_before_device(self):
        epoch = verifier.require_epoch(TASK, APKS)
        self.assertEqual(epoch["apk_sha256"], verifier.APK_SHA256)
        self.assertEqual(epoch["apk_arm64_member_sha256"], verifier.MEMBER_SHA256)
        self.assertFalse(verifier.aligned_elf(
            verifier.member_and_executable_offsets(APKS["baseline"])[0]))
        self.assertTrue(verifier.aligned_elf(
            verifier.member_and_executable_offsets(APKS["candidate"])[0]))
        wrong = {**APKS, "candidate": APKS["baseline"]}
        with self.assertRaisesRegex(ValueError, "candidate: pinned APK changed"):
            verifier.require_epoch(TASK, wrong)

    def test_runner_rejects_wrong_apk_before_any_adb_call(self):
        with tempfile.TemporaryDirectory(dir=TASK) as directory:
            with patch.object(runner, "adb", side_effect=AssertionError("device touched")):
                with self.assertRaisesRegex(ValueError, "candidate: pinned APK changed"):
                    runner.run(TASK, {**APKS, "candidate": APKS["baseline"]},
                               Path(directory) / "unused")
        with tempfile.TemporaryDirectory() as directory:
            with self.assertRaisesRegex(ValueError, "under task root"):
                runner.run(TASK, APKS, Path(directory) / "outside")

    def test_strict_state_requires_wifi_and_offline_route(self):
        verifier.require_strict(snapshot(), "test")
        bad = snapshot()
        bad["wifi_on"]["stdout"] = "1"
        with self.assertRaisesRegex(ValueError, "wifi_on"):
            verifier.require_strict(bad, "test")
        bad = snapshot()
        bad["ip_route"]["stdout"] = "default via 10.0.2.2"
        with self.assertRaisesRegex(ValueError, "ip_route"):
            verifier.require_strict(bad, "test")

    def test_fresh_logcat_token_pid_and_case_framing(self):
        item = phase_receipt("candidate")
        events = verifier.parse_events(item["result_logcat"]["stdout"],
                                       "candidate", item["token"])
        self.assertEqual([e["kind"] for e in events][0:2], ["BEGIN", "LOADED"])
        with self.assertRaisesRegex(ValueError, "stale, foreign"):
            verifier.parse_events(item["result_logcat"]["stdout"], "candidate", "b" * 32)
        truncated = item["result_logcat"]["stdout"] + "\n" + \
            "09-28 12:00:00.000  12345  12345 I N42_WALLETCORE_FIXTURE: {"
        with self.assertRaisesRegex(ValueError, "malformed or truncated"):
            verifier.parse_events(truncated, "candidate", item["token"])
        missing = copy.deepcopy(events)
        missing.pop(3)
        with self.assertRaisesRegex(ValueError, "missing or unordered"):
            verifier.parse_events(logcat(missing), "candidate", item["token"])

    def test_candidate_requires_native_maps_and_all_tagged_goldens(self):
        item = phase_receipt("candidate")
        verifier.verify_phase("candidate", item, APKS["candidate"])
        wrong = copy.deepcopy(item)
        wrong["events"][1]["nativeMaps"] = []
        wrong["result_logcat"]["stdout"] = logcat(wrong["events"])
        with self.assertRaisesRegex(ValueError, "maps missing"):
            verifier.verify_phase("candidate", wrong, APKS["candidate"])
        wrong = copy.deepcopy(item)
        wrong["events"][2]["outcome"] = "FAIL"
        wrong["result_logcat"]["stdout"] = logcat(wrong["events"])
        with self.assertRaisesRegex(ValueError, "golden failed"):
            verifier.verify_phase("candidate", wrong, APKS["candidate"])
        wrong = copy.deepcopy(item)
        wrong["pulled_apk_sha256"] = "0" * 64
        with self.assertRaisesRegex(ValueError, "installed pulled APK"):
            verifier.verify_phase("candidate", wrong, APKS["candidate"])
        wrong = copy.deepcopy(item)
        wrong["permissions"]["stdout"] += "\nuses-permission: android.permission.INTERNET"
        with self.assertRaisesRegex(ValueError, "ZIP/package inspection"):
            verifier.verify_phase("candidate", wrong, APKS["candidate"])

    def test_baseline_native_load_failure_is_preserved_as_failure(self):
        item = phase_receipt("baseline", loaded=False)
        result = verifier.verify_phase("baseline", item, APKS["baseline"])
        self.assertEqual(result["status"], "FAIL")
        with self.assertRaisesRegex(ValueError, "incomplete or duplicate process framing"):
            verifier.parse_events(logcat(item["events"][:-1]), "baseline", item["token"])

    def test_full_replay_requires_parity_when_baseline_loaded(self):
        receipt = full_receipt()
        with patch.object(verifier, "require_git_epoch"):
            result = verifier.verify(receipt, TASK, APKS)
            self.assertEqual(result["parity"], "all five cases equal")
            wrong = copy.deepcopy(receipt)
            wrong["phases"]["candidate"]["events"][-2]["result"] = {"sha256": "different"}
            wrong["phases"]["candidate"]["result_logcat"]["stdout"] = logcat(
                wrong["phases"]["candidate"]["events"])
            with self.assertRaisesRegex(ValueError, "baseline/candidate behavior differs"):
                verifier.verify(wrong, TASK, APKS)

    def test_full_replay_records_baseline_load_failure_without_claiming_parity(self):
        receipt = full_receipt(False)
        with patch.object(verifier, "require_git_epoch"):
            result = verifier.verify(receipt, TASK, APKS)
        self.assertTrue(result["candidate_passed"])
        self.assertEqual(result["baseline_status"], "FAIL")
        self.assertEqual(result["parity"], "baseline unavailable")


if __name__ == "__main__":
    unittest.main()
