#!/usr/bin/env python3
"""Run the opt-in smoke app on an already booted, installed iOS simulator.

This registers one ephemeral verifier on the configured testnet. It changes
foreground apps on the selected simulator. It never reads the verifier key.
"""

import argparse
import json
import pathlib
import shutil
import subprocess
import time


def simctl(*arguments):
    return subprocess.check_output(
        ["xcrun", "simctl", *arguments], text=True
    ).strip()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("simulator", help="Explicit booted simulator UUID")
    parser.add_argument("--output", type=pathlib.Path, required=True)
    args = parser.parse_args()
    bundle = "mining.ai.n42.www.flutterMiningExample"
    container = pathlib.Path(simctl("get_app_container", args.simulator, bundle, "data"))
    results = container / "tmp" / "n42-mobileverify-ios-smoke"
    # Remove only this harness's previous flags and public results.
    subprocess.run(
        ["xcrun", "simctl", "terminate", args.simulator, bundle],
        check=False, capture_output=True,
    )
    shutil.rmtree(results, ignore_errors=True)
    simctl("launch", args.simulator, bundle)
    seen = set()
    deadline = time.monotonic() + 600
    try:
        while time.monotonic() < deadline:
            try:
                data = json.loads((results / "results.json").read_text())
            except (FileNotFoundError, json.JSONDecodeError):
                time.sleep(1)
                continue
            stage = data["stage"]
            if stage not in seen:
                print(stage, flush=True)
                seen.add(stage)
            if stage in ("failed", "passed"):
                args.output.parent.mkdir(parents=True, exist_ok=True)
                args.output.write_text(json.dumps(data, indent=2) + "\n")
                if stage == "failed":
                    raise RuntimeError(data["values"].get("failure", "Smoke failed"))
                return
            if stage in ("ready-for-background", "ready-after-stop"):
                simctl("launch", args.simulator, "com.apple.Preferences")
                time.sleep(12 if stage == "ready-for-background" else 6)
                simctl("launch", args.simulator, bundle)
                flag = "resume.request" if stage == "ready-for-background" else "stopped-resume.request"
                (results / flag).touch()
                time.sleep(3)
            time.sleep(1)
        raise TimeoutError("iOS smoke app did not finish within ten minutes")
    except BaseException:
        # A killed process cannot leave a native mining loop running.
        subprocess.run(["xcrun", "simctl", "terminate", args.simulator, bundle], check=False)
        raise


if __name__ == "__main__":
    main()
