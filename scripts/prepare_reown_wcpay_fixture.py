#!/usr/bin/env python3
"""Stage an intentionally mismatched WCPay Kotlin binding with unchanged candidate JNI."""

import argparse
from hashlib import sha256
import json
from pathlib import Path
from zipfile import ZipFile


SOURCE_HASHES = {
    "generated-yttrium.kt": "92458f5d5dcc13410f27b733b6c8771164a7e392118ca83313928642b64766ad",
    "generated-uniffi_yttrium.kt": "5bf20f4f39126830d1ecc00f43498c079ae06f1fc8dcd5db4141d0c97f168f84",
}
CANDIDATE_AAR_SHA256 = "edf6908e5ec8c3e0b0ef2d45b47347c55ea84c96907fd952fadb84b038607303"
CANDIDATE_ARM64_SHA256 = "a89f233ea9a99d4cfb7591bc87bc468adae422c118e452524fcacb38467d9bff"
MEMBER = "jni/arm64-v8a/libuniffi_yttrium_wcpay.so"
EXPECTED = b"uniffi_yttrium_checksum_func_register_logger() != 32546.toShort()"
MISMATCH = b"uniffi_yttrium_checksum_func_register_logger() != 32547.toShort()"


def digest(data):
    return sha256(data).hexdigest()


def prepare_mismatch(source, aar, output):
    source, aar, output = Path(source), Path(aar), Path(output)
    if output.exists():
        raise ValueError(f"output already exists: {output}")
    original = {}
    for name, expected_hash in SOURCE_HASHES.items():
        data = (source / name).read_bytes()
        if digest(data) != expected_hash:
            raise ValueError(f"binding SHA256 mismatch: {name}")
        original[name] = data
    if original["generated-yttrium.kt"].count(EXPECTED) != 1:
        raise ValueError("expected checksum site is not unique")
    aar_bytes = aar.read_bytes()
    if digest(aar_bytes) != CANDIDATE_AAR_SHA256:
        raise ValueError("AAR SHA256 mismatch")
    with ZipFile(aar) as archive:
        native = archive.read(MEMBER)
    if digest(native) != CANDIDATE_ARM64_SHA256:
        raise ValueError("candidate ARM64 member SHA256 mismatch")
    altered = original["generated-yttrium.kt"].replace(EXPECTED, MISMATCH, 1)
    (output / "bindings").mkdir(parents=True)
    (output / "jni/arm64-v8a").mkdir(parents=True)
    (output / "bindings/yttrium.kt").write_bytes(altered)
    (output / "bindings/uniffi_yttrium.kt").write_bytes(original["generated-uniffi_yttrium.kt"])
    (output / MEMBER).write_bytes(native)
    receipt = {
        "original_binding_sha256": SOURCE_HASHES,
        "altered_binding_sha256": digest(altered),
        "changed_checksum": "register_logger 32546 -> 32547",
        "candidate_aar_sha256": digest(aar_bytes),
        "native_member": MEMBER,
        "native_sha256": digest(native),
    }
    (output / "preparation.json").write_text(json.dumps(receipt, indent=2) + "\n")
    return receipt


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--binding-source", type=Path, required=True)
    parser.add_argument("--candidate-aar", type=Path, required=True)
    parser.add_argument("--out-dir", type=Path, required=True)
    args = parser.parse_args()
    print(json.dumps(prepare_mismatch(args.binding_source, args.candidate_aar, args.out_dir), indent=2))


if __name__ == "__main__":
    main()
