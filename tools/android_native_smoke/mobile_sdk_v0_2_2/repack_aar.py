"""Replace all native payloads in the pinned supplier AAR with a maintained build."""

import argparse
from pathlib import Path
from zipfile import ZIP_DEFLATED, ZipFile, ZipInfo


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("official_aar", type=Path)
    parser.add_argument("jni_directory", type=Path)
    parser.add_argument("output_aar", type=Path)
    args = parser.parse_args()

    libraries = []
    for abi in ("arm64-v8a", "x86_64"):
        files = sorted((args.jni_directory / abi).glob("*.so"))
        names = [file.name for file in files]
        if (
            len(files) != 2
            or names.count("libmobile_sdk.so") != 1
            or sum(name.startswith("librustls_platform_verifier-") for name in names) != 1
        ):
            raise ValueError(f"expected one mobile SDK and one verifier library for {abi}")
        libraries.extend((abi, file) for file in files)

    with ZipFile(args.official_aar) as original, ZipFile(args.output_aar, "w") as rebuilt:
        for entry in original.infolist():
            if not entry.filename.startswith("jni/"):
                rebuilt.writestr(entry, original.read(entry.filename))
        for abi, file in libraries:
            entry = ZipInfo(f"jni/{abi}/{file.name}", (1980, 2, 1, 0, 0, 0))
            entry.compress_type = ZIP_DEFLATED
            entry.external_attr = 0o100644 << 16
            rebuilt.writestr(entry, file.read_bytes())


if __name__ == "__main__":
    main()
