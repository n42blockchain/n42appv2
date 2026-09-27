#!/usr/bin/env python3
"""Check synthetic host C ABI output against decoded transaction fields."""

import json
import sys
from pathlib import Path


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(message)


def dynamic_arg(encoded: bytes, offset: int) -> bytes:
    require(offset % 32 == 0 and offset + 32 <= len(encoded), "invalid ABI offset")
    length = int.from_bytes(encoded[offset : offset + 32], "big")
    require(offset + 32 + length <= len(encoded), "invalid ABI length")
    return encoded[offset + 32 : offset + 32 + length]


def main() -> None:
    if len(sys.argv) != 3:
        raise SystemExit("usage: verify_host_c_abi.py HOST_OUTPUT ANDROID_GOLDEN_JSON")
    rows = [line.split("\t", 2) for line in Path(sys.argv[1]).read_text().splitlines()]
    require(all(len(row) == 3 for row in rows), "malformed host output")
    checks = {name: value for kind, name, value in rows if kind == "CHECK"}
    require(checks == {"keypair_relation": "pass", "error_contract": "pass"}, "missing C checks")
    cases = {name: json.loads(value) for kind, name, value in rows if kind == "CASE"}
    require(len(cases) == 7 and len(rows) == 9, "missing or duplicate C cases")

    golden = json.loads(Path(sys.argv[2]).read_text())["new_raw"]
    deposit = cases["deposit_prefixed"]
    require(deposit == cases["deposit_unprefixed"], "deposit prefix changed bytes")
    require(deposit == json.loads(golden["deposit"]), "deposit differs from Android source fixture")
    require(deposit["to"] == "0x5fbdb2315678afecb367f032d93f642f64180aa3", "deposit to")
    require(deposit["value"] == "0x1bc16d674ec800000", "deposit value")
    require(deposit["gas"] == "0x493e0", "deposit gas")
    calldata = bytes.fromhex(deposit["data"][2:])
    require(len(calldata) == 420 and calldata[:4].hex() == "22895118", "deposit selector/length")
    encoded = calldata[4:]
    offsets = [int.from_bytes(encoded[i * 32 : (i + 1) * 32], "big") for i in range(3)]
    pubkey, withdrawal, signature = [dynamic_arg(encoded, offset) for offset in offsets]
    require(len(pubkey) == 48 and pubkey.hex() ==
            "8a2470d8ccb2e43b3b5295cfee71508f8808e166e5f152d5af9fe022d95e300dc7c5814f2c9eb71e2da8412beb61c53a", "deposit pubkey")
    require(withdrawal == bytes.fromhex("01" + "00" * 11 + "a0ee7a142d267c1f36714e4a8f75612f20a79720"), "withdrawal credentials")
    require(len(signature) == 96 and any(signature), "deposit signature shape")
    require(len(encoded[96:128]) == 32 and any(encoded[96:128]), "deposit root shape")

    fee = cases["fee_call"]
    require(fee == json.loads(golden["feeCall"]), "fee template differs from Android source fixture")
    require(fee["to"] == "0x00000961ef480eb55e80d19ad83579a64c007002" and
            fee["data"] == "0x" and "value" not in fee, "fee template fields")
    expected_exit = json.loads(golden["exit"])
    for name in ("exit_hex", "exit_no_prefix", "exit_empty", "exit_null"):
        result = cases[name]
        require(result == expected_exit, f"{name} differs from Android source fixture")
        data = bytes.fromhex(result["data"][2:])
        require(len(data) == 56 and data[:48] == pubkey and data[48:] == bytes(8), f"{name} calldata")
        require(result["value"] == "0x1", f"{name} default/explicit fee")
    print("host C ABI: 7 transaction cases, BLS relationship, and error contract passed")


if __name__ == "__main__":
    main()
