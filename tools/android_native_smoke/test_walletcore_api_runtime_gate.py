"""No-device negative controls for the two Wallet Core API runtime policies."""

import sys
from hashlib import sha256
import json
from pathlib import Path
from tempfile import TemporaryDirectory
import unittest


ROOT = Path(__file__).resolve().parents[2]
TASK = ROOT / ".superpowers/sdd/dependency-completion-20260925"
sys.path.insert(0, str(Path(__file__).resolve().parent))
import verify_walletcore_api_fixture as gate  # noqa: E402


def success(stdout):
    return {"exit": 0, "stdout": stdout}


def snapshot(serial):
    state = {"state": success("device"), "boot": success("1"),
             "sdk": success("26" if serial == "emulator-5562" else "35"),
             "abi": success("arm64-v8a"), "airplane": success("1"),
             "wifi": success("0"), "route": success(""),
             "default_network": success("Active default network: none")}
    if serial == "emulator-5560":
        state.update({"page": success("16384"), "linker": success("fatal"),
                      "compat": success("true")})
    else:
        state["page"] = success("KernelPageSize:        4 kB")
    return state


class RuntimeGateTests(unittest.TestCase):
    def test_exact_epoch_and_both_mapping_page_sizes(self):
        apk = TASK / "task-16f-walletcore-api-fixture/build3/walletcore-api-candidate.apk"
        self.assertEqual(gate.require_epoch(TASK, apk)["apk_sha256"], gate.APK_SHA256)
        self.assertEqual(gate.inspect_apk(apk, 16384)["member_data_offset"], 2048000)
        self.assertEqual(gate.inspect_apk(apk, 4096)["member_data_offset"], 2048000)

    def test_substituted_apk_rejected(self):
        with TemporaryDirectory(dir=TASK) as temp:
            altered = Path(temp) / "fixture.apk"
            altered.write_bytes(b"not the reviewed APK")
            with self.assertRaisesRegex(ValueError, "path changed|APK changed"):
                gate.require_epoch(TASK, altered)

    def test_strict_and_api26_policies_are_distinct(self):
        strict = snapshot("emulator-5560")
        api26 = snapshot("emulator-5562")
        gate.require_snapshot(strict, "emulator-5560", "test")
        gate.require_snapshot(api26, "emulator-5562", "test")
        api26["page"] = success("KernelPageSize:        16 kB")
        with self.assertRaisesRegex(ValueError, "4 KB"):
            gate.require_snapshot(api26, "emulator-5562", "test")
        strict["linker"] = success("true")
        with self.assertRaisesRegex(ValueError, "strict 16 KB"):
            gate.require_snapshot(strict, "emulator-5560", "test")

    def test_logcat_token_and_pid_rejected(self):
        token = "a" * 32
        def row(pid, kind, name=""):
            data = f'{{"kind":"{kind}","token":"{token}","pid":{pid}'
            if name:
                data += f',"name":"{name}"'
            return f"09-28 01:02:03.456 {pid} {pid} I {gate.TAG}: {data}}}"
        log = "\n".join([row(12, "BEGIN"), row(12, "LOADED"),
                         row(12, "CASE", "taggedP2pkh"),
                         row(12, "CASE", "unsupportedP2wsh"), row(12, "END")])
        self.assertEqual(len(gate.parse_events(log, token)), 5)
        with self.assertRaisesRegex(ValueError, "stale"):
            gate.parse_events(log, "b" * 32)
        with self.assertRaisesRegex(ValueError, "PID-mismatched"):
            gate.parse_events(log.replace(" 12 12 I", " 13 12 I", 1), token)

    def test_synthetic_replay_rejects_wrong_native_map_and_error(self):
        apk = TASK / "task-16f-walletcore-api-fixture/build3/walletcore-api-candidate.apk"
        serial = "emulator-5562"
        token = "c" * 32
        pid = 77
        path = "/data/app/synthetic/ai.n42.fixture.walletcoreapi/base.apk"
        info = gate.inspect_apk(apk, 4096)
        offset, length = info["executable_loads"][0]
        mapping = f"70000000-{0x70000000 + length:x} r-xp {offset:x} 00:00 0 {path}"
        events = [
            {"kind": "BEGIN", "token": token, "pid": pid, "apkPath": path,
             "apkSha256": gate.APK_SHA256,
             "libraryLookupPath": f"{path}!/{gate.MEMBER}"},
            {"kind": "LOADED", "token": token, "pid": pid, "nativeMaps": [mapping]},
            {"kind": "CASE", "token": token, "pid": pid, "name": "taggedP2pkh",
             "outcome": "PASS", "result": {"encoded": gate.EXPECTED_ENCODED,
             "encodedSha256": sha256(bytes.fromhex(gate.EXPECTED_ENCODED)).hexdigest(),
             "rawSignatureControlSha256": sha256(bytes.fromhex(gate.EXPECTED_ENCODED)).hexdigest(),
             "txid": gate.EXPECTED_TXID}},
            {"kind": "CASE", "token": token, "pid": pid, "name": "unsupportedP2wsh",
             "outcome": "PASS", "result": {"error": "Bitcoin V2 pre-sign V2 error: Error_not_supported"}},
            {"kind": "END", "token": token, "pid": pid, "status": "PASS"},
        ]
        log = "\n".join(f"09-28 01:02:03.456 {pid} {pid} I {gate.TAG}: {json.dumps(e, separators=(',', ':'))}"
                        for e in events)
        item = {"pre": snapshot(serial), "post": snapshot(serial),
                "initial": snapshot(serial), "apk_info": info,
                "pulled_apk_sha256": gate.APK_SHA256, "token": token,
                "pm_path": success("package:" + path),
                "result_logcat": success(log), "events": events,
                "badging": success(f"package: name='{gate.PACKAGE}'"),
                "permissions": success(""), "zipalign": success(""),
                "apksigner": success(""),
                **{key: success("") for key in (
                    "install", "clear", "pull", "logcat_clear", "start", "force_stop")}}
        self.assertEqual(gate.verify_device(serial, item, apk)["pid"], pid)
        item["events"][1]["nativeMaps"] = []
        item["result_logcat"] = success("\n".join(
            f"09-28 01:02:03.456 {pid} {pid} I {gate.TAG}: {json.dumps(e, separators=(',', ':'))}"
            for e in item["events"]))
        with self.assertRaisesRegex(ValueError, "native executable mappings missing"):
            gate.verify_device(serial, item, apk)
        item["events"][1]["nativeMaps"] = [mapping]
        item["events"][3]["result"]["error"] = "OK"
        item["result_logcat"] = success("\n".join(
            f"09-28 01:02:03.456 {pid} {pid} I {gate.TAG}: {json.dumps(e, separators=(',', ':'))}"
            for e in item["events"]))
        with self.assertRaisesRegex(ValueError, "explicit error"):
            gate.verify_device(serial, item, apk)


if __name__ == "__main__":
    unittest.main()
