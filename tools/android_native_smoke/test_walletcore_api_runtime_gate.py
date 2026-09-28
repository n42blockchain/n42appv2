"""No-device negative controls for the two Wallet Core API runtime policies."""

import sys
from hashlib import sha256
import json
from pathlib import Path
import shutil
from tempfile import TemporaryDirectory
import unittest


ROOT = Path(__file__).resolve().parents[2]
TASK = ROOT / ".superpowers/sdd/dependency-completion-20260925"
sys.path.insert(0, str(Path(__file__).resolve().parent))
import verify_walletcore_api_fixture as gate  # noqa: E402


def success(stdout, argv=None):
    return {"exit": 0, "stdout": stdout, "argv": argv}


def adb_result(serial, stdout, *command):
    return success(stdout, [gate.ADB, "-s", serial, *command])


def snapshot(serial):
    values = {"boot": "1", "sdk": "26" if serial == "emulator-5562" else "37",
              "abi": "arm64-v8a", "airplane": "1", "wifi": "0", "route": "",
              "default_network": "Active default network: none",
              "page": "KernelPageSize:        4 kB" if serial == "emulator-5562" else "16384",
              "linker": "fatal", "compat": "true"}
    state = {"state": adb_result(serial, "device", "get-state")}
    state.update({key: adb_result(serial, values[key], *command)
                  for key, command in gate.snapshot_commands(serial).items()})
    return state


def ownership():
    result = {}
    for serial, owner in gate.OWNERS.items():
        result[serial] = {
            "launch_receipt_sha256": owner["source_sha256"],
            "state": adb_result(serial, "device", "get-state"),
            "avd": adb_result(serial, owner["avd"] + "\nOK", "emu", "avd", "name"),
            "process": success(owner["command"],
                               ["ps", "-p", str(owner["pid"]), "-o", "command="]),
            "avd_files": success(
                "n" + str(TASK / owner["avd_dir"] / "multiinstance.lock"),
                ["lsof", "-nP", "-p", str(owner["pid"]), "-Fn"]),
            "ports": {str(port): success(f"p{owner['pid']}\ncqemu-system-aarch64-headless\nn127.0.0.1:{port}",
                                         ["lsof", "-nP", f"-iTCP:{port}",
                                          "-sTCP:LISTEN", "-Fpcn"])
                      for port in (owner["port"], owner["port"] + 1)},
        }
    return result


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
        api26["page"]["stdout"] = "KernelPageSize:        16 kB"
        with self.assertRaisesRegex(ValueError, "4 KB"):
            gate.require_snapshot(api26, "emulator-5562", "test")
        strict["linker"]["stdout"] = "true"
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
                "pm_path": adb_result(serial, "package:" + path, "shell", "pm", "path", gate.PACKAGE),
                "result_logcat": adb_result(serial, log, "logcat", "-d", "-v", "threadtime", "-s", f"{gate.TAG}:I"), "events": events,
                "badging": success(f"package: name='{gate.PACKAGE}'"),
                "permissions": success(""), "zipalign": success(""),
                "apksigner": success(""),
                "install": adb_result(serial, "", "install", "-r", str(apk)),
                "clear": adb_result(serial, "", "shell", "pm", "clear", gate.PACKAGE),
                "logcat_clear": adb_result(serial, "", "logcat", "-c"),
                "start": adb_result(serial, "", "shell", "am", "start", "-W", "-n",
                                    f"{gate.PACKAGE}/ai.n42.fixture.walletcoreapi.MainActivity",
                                    "--es", "token", token),
                "force_stop": adb_result(serial, "", "shell", "am", "force-stop", gate.PACKAGE)}
        with TemporaryDirectory(dir=TASK) as temp:
            out = Path(temp)
            pulled = out / f"{serial}-installed.apk"
            shutil.copyfile(apk, pulled)
            item["pull_path"] = str(pulled)
            item["pull"] = adb_result(serial, "", "pull", path, str(pulled))
            self.assertEqual(gate.verify_device(serial, item, apk, out)["pid"], pid)
            pulled.unlink()
            with self.assertRaisesRegex(ValueError, "retained installed APK"):
                gate.verify_device(serial, item, apk, out)
            pulled.write_bytes(b"substituted")
            with self.assertRaisesRegex(ValueError, "retained installed APK"):
                gate.verify_device(serial, item, apk, out)
            shutil.copyfile(apk, pulled)
            item["pull"]["argv"][2] = "emulator-5560"
            with self.assertRaisesRegex(ValueError, "command/serial"):
                gate.verify_device(serial, item, apk, out)
            item["pull"]["argv"][2] = serial
            item["install"]["argv"][2] = "emulator-5560"
            with self.assertRaisesRegex(ValueError, "command/serial"):
                gate.verify_device(serial, item, apk, out)
            item["install"]["argv"][2] = serial
            item["start"]["argv"][2] = "emulator-5560"
            with self.assertRaisesRegex(ValueError, "command/serial"):
                gate.verify_device(serial, item, apk, out)
            item["start"]["argv"][2] = serial
            item["pre"]["sdk"]["argv"][2] = "emulator-5560"
            with self.assertRaisesRegex(ValueError, "command/serial"):
                gate.verify_device(serial, item, apk, out)
            item["pre"]["sdk"]["argv"][2] = serial
            item["events"][1]["nativeMaps"] = []
            item["result_logcat"] = adb_result(serial, "\n".join(
                f"09-28 01:02:03.456 {pid} {pid} I {gate.TAG}: {json.dumps(e, separators=(',', ':'))}"
                for e in item["events"]), "logcat", "-d", "-v", "threadtime", "-s", f"{gate.TAG}:I")
            with self.assertRaisesRegex(ValueError, "native executable mappings missing"):
                gate.verify_device(serial, item, apk, out)
            item["events"][1]["nativeMaps"] = [mapping]
            item["events"][3]["result"]["error"] = "OK"
            item["result_logcat"] = adb_result(serial, "\n".join(
                f"09-28 01:02:03.456 {pid} {pid} I {gate.TAG}: {json.dumps(e, separators=(',', ':'))}"
                for e in item["events"]), "logcat", "-d", "-v", "threadtime", "-s", f"{gate.TAG}:I")
            with self.assertRaisesRegex(ValueError, "explicit error"):
                gate.verify_device(serial, item, apk, out)

    def test_owner_receipts_and_host_pid_are_bound(self):
        record = ownership()
        gate.require_ownership(TASK, record)
        record["emulator-5562"]["process"]["stdout"] = "replacement emulator"
        with self.assertRaisesRegex(ValueError, "host emulator PID"):
            gate.require_ownership(TASK, record)
        record = ownership()
        record["emulator-5562"]["ports"]["5562"]["stdout"] = "p1\nn127.0.0.1:5562"
        with self.assertRaisesRegex(ValueError, "host port"):
            gate.require_ownership(TASK, record)


if __name__ == "__main__":
    unittest.main()
