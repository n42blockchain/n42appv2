# T27 Cosmos-family address derivation - 2026-07-27

## Scope

- Source base: `master@1005e8d3`
- Flutter: `3.44.8`
- WalletCore: `4.7.0`
- iOS device: physical iPhone, iOS 27.0
- Android device: Pixel 8 API 36 arm64 emulator
- Test mnemonic: public BIP-39 `abandon ... about` vector; no user key data

## Implementation conclusion

WalletCore 4.7.0 contains a dedicated `CoinType` for every one of the 18
affected chains. Dart method-channel arguments and custom bech32 code were
therefore unnecessary. Swift and Kotlin now map each app coin symbol to its
WalletCore type and classify it as Cosmos:

| App symbols | WalletCore types |
|---|---|
| INJ, TIA, DYDX, OSMO | NativeInjective, Tia, Dydx, Osmosis |
| AKT, NTRN, SCRT, STRD | Akash, Neutron, Secret, Stride |
| JUNO, KUJI, XPRT, RUNE | Juno, Kujira, Persistence, THORChain |
| KAVA2, SEI2, CRE | Kava, Sei, Crescent |
| SOMM, MARS, CMDX | Sommelier, Mars, Comdex |

This uses WalletCore's own public-key type, HRP, address encoding, and
validation metadata. ATOM remains mapped to `Cosmos` exactly as before.

The canonical chain configuration has two derivation paths that differ from
the abbreviated T27 task table:

- RUNE: `m/44'/931'/0'/0/0`
- KAVA2: `m/44'/459'/0'/0/0`

The implementation and device test retain those existing paths. INJ remains
60, SCRT remains 529, and the other configured Cosmos-family chains use 118.

## Results

| Item | Result | Evidence |
|---|---:|---|
| A1 Android address format | PASS | Pixel 8 API 36 generated all 19 addresses. Every address had its configured bech32 prefix; none began with `0x`. |
| A2 iOS address generation | PASS | Physical iPhone generated all 19 addresses, including INJ, OSMO, TIA, DYDX, and NTRN, without an empty result. |
| A3 Android/iOS equality | PASS | Both platforms ran the same committed public mnemonic vector and matched all 19 fixed expected addresses byte-for-byte. |
| A4 ATOM regression | PASS | Both platforms produced the unchanged fixed ATOM vector `cosmos19rl4cm2hmr8afy4kldpxz3fka4jguq0auqdal4`. |
| A5 live balance | PARTIAL | The existing registry test passed all four cases: 19-chain coverage, per-chain REST/denom routing, no ATOM fallback, and no invalid testnet fallback. The public address vector has no approved funded account, so a non-zero asset balance was not claimed. |
| A6 all 19 chains | PASS | The committed integration test generated and checked all 19 configured Cosmos-family addresses on both platforms. |

## Cross-platform address evidence

Both devices produced the following exact values:

```text
ATOM=cosmos19rl4cm2hmr8afy4kldpxz3fka4jguq0auqdal4
INJ=inj1npvwllfr9dqr8erajqqr6s0vxnk2ak55re90dz
TIA=celestia19rl4cm2hmr8afy4kldpxz3fka4jguq0ad2ud9c
DYDX=dydx19rl4cm2hmr8afy4kldpxz3fka4jguq0a4erelz
OSMO=osmo19rl4cm2hmr8afy4kldpxz3fka4jguq0a5m7df8
AKT=akash19rl4cm2hmr8afy4kldpxz3fka4jguq0a3mq6x0
NTRN=neutron19rl4cm2hmr8afy4kldpxz3fka4jguq0aclyl9j
SCRT=secret1gkle2qetd47g4qlruxu8kx4m97875t66qsgr0p
STRD=stride19rl4cm2hmr8afy4kldpxz3fka4jguq0altdpte
JUNO=juno19rl4cm2hmr8afy4kldpxz3fka4jguq0a2jwxcf
KUJI=kujira19rl4cm2hmr8afy4kldpxz3fka4jguq0adg09jl
XPRT=persistence19rl4cm2hmr8afy4kldpxz3fka4jguq0ajvtw33
RUNE=thor1gm00vwsfcp48enm4uv9e5dhm37jtd0ye27wrx0
KAVA2=kava1fzgm3840v4xwme059mfnx9rc5qgzl0enq7qgac
SEI2=sei19rl4cm2hmr8afy4kldpxz3fka4jguq0a3vute5
CRE=cre19rl4cm2hmr8afy4kldpxz3fka4jguq0acg7c2c
SOMM=somm19rl4cm2hmr8afy4kldpxz3fka4jguq0asuz3wl
MARS=mars19rl4cm2hmr8afy4kldpxz3fka4jguq0apa5y2w
CMDX=comdex19rl4cm2hmr8afy4kldpxz3fka4jguq0am00lxz
```

## Commands

```sh
JAVA_HOME=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home \
  ./gradlew :app:compileReleaseKotlin

flutter test integration_test/t27_cosmos_address_test.dart \
  -d emulator-5554 --no-pub

flutter test integration_test/t27_cosmos_address_test.dart \
  -d 00008150-000E2469149A401C --no-pub

flutter test test/features/wallet/cosmos_balance_api_registry_test.dart --no-pub

flutter analyze --no-fatal-infos
```

Results:

- Android Release Kotlin: `BUILD SUCCESSFUL`
- Android integration: `All tests passed`
- Physical iPhone integration: `All tests passed`
- Cosmos balance registry: 4 tests passed
- Analyze: 0 errors, 0 warnings, 131 pre-existing infos
- Current-source iOS Release: built in 296.3 seconds, installed and launched;
  device reported N42Wallet `2.4.8 (2026072603)`

The iOS simulator compile passed the changed Swift source but later failed at
linking because the simulator build could not find the existing
`TensorFlowLiteSelectTfOps` framework. The physical-device build, install,
launch, native address calls, and assertions all passed, so this unrelated
simulator linker issue does not weaken A2/A3/A6.

After testing, the current-source Release app replaced the Debug integration
test app on the physical iPhone.

## Product decision

Do not hide the 18 chains from `allChainUrlMap`. The P0 behavior is corrected
on both native platforms, and all 19 configured address formats now have
cross-platform device evidence. A temporary Dart-side feature removal would
now create unnecessary product regression.
