"""Build a fixture AAR with test-only arm64 Rust and maintained production x86 libraries."""

import argparse
from pathlib import Path
from zipfile import ZIP_DEFLATED, ZipFile, ZipInfo


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("official_aar", type=Path)
    parser.add_argument("jni_dir", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    expected = {
        "arm64-v8a": {"libmobile_sdk.so", "librustls_platform_verifier.so"},
        "x86_64": {"libmobile_sdk.so", "librustls_platform_verifier-672ddd532c0f437d.so"},
    }
    for abi, names in expected.items():
        actual = {path.name for path in (args.jni_dir / abi).glob("*.so")}
        if actual != names:
            raise ValueError(f"{abi}: expected {names}, got {actual}")

    with ZipFile(args.official_aar) as official, ZipFile(args.output, "w") as fixture:
        for entry in official.infolist():
            if not entry.filename.startswith("jni/"):
                fixture.writestr(entry, official.read(entry.filename))
        for abi, names in expected.items():
            for name in sorted(names):
                entry = ZipInfo(f"jni/{abi}/{name}", (1980, 2, 1, 0, 0, 0))
                entry.compress_type = ZIP_DEFLATED
                entry.external_attr = 0o100644 << 16
                fixture.writestr(entry, (args.jni_dir / abi / name).read_bytes())


if __name__ == "__main__":
    main()
