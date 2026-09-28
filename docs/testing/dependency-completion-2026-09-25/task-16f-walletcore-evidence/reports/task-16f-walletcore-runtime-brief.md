# Wallet Core 4.8.4 synthetic JNI runtime brief

Preparation only, 2026-09-28. This records exact local tagged-source and app
call evidence for the next fixture stage. No fixture APK, device run, app build,
native relink or business-code change was made here. The maintained AAR is
under independent packaging review; its recipe fix is separately committed as
`89e214c2a6f30c0a5ee7c7c26682eeb110207df0`.

## Identical Java/proto runtime on both APKs

Use the exact published `wallet-core:4.8.4` AAR as baseline and the maintained
same-coordinate AAR as candidate. The latter changes only four JNI members;
`classes.jar`, manifest, AAR metadata and all proto artifacts are exact
published bytes. Build separate release-like disposable APKs from the same
fixture source, with the same `wallet-core-proto:4.8.4` JAR (SHA-256
`95659a930e640196ace64743377d013f9cc71cdbfe471c1279fa9f7d65812a4b`)
and **app-selected** `protobuf-javalite:4.36.2` JAR (SHA-256
`8f4f93d08cb37130ecb0bc69d376d7d27c36ff04ddb1bb27430b06caa9fa062e`).
The published proto POM requires 3.22.3, while the actual app Gradle release
compile/runtime configurations select 4.36.2. The 141 tagged/generated Java
sources compiled with that 4.36.2 JAR; serialization and JNI execution still
require the fixture. `jni/java/wallet/core/java/AnySigner.java` at tag
`d40d24a63d92619167903369308bf0e2f7eb3a59` implements
`sign(MessageLite, CoinType, Parser<T>)` by serializing input, calling native
`nativeSign(byte[], int)`, then parsing output. Compare full serialized
`SigningOutput` bytes as well as its fields on baseline/candidate.

## Tagged deterministic calls

Sources below are in `task-16f-walletcore-build/source/` at the exact tag.
Use the literal test-only inputs, no generated mnemonic, account or RPC data.

| Path | JNI/Java call and exact tagged assertion |
| --- | --- |
| `android/app/src/androidTest/java/com/trustwallet/core/app/utils/TestHDWallet.kt:60-66` | `HDWallet(words, "TREZOR")`; `words = "ripple scissors kick mammal hire column oak again sun offer wealth tomorrow wagon turn fatal"`; `mnemonic()` equals input; entropy hex `ba5821e8c356c05ba5f025d9532fe0f21f65d594`; 64-byte seed hex `7ae6f661157bda6492f6162701e570097fc726b6235011ea5ad09bf04986731ed4d92bc43cbdee047b60ea0dd1b1fa4274377c9bf5bd14ab1982c272d8076f29`. |
| `TestHDWallet.kt:92-100` | For the same wallet, `getKeyForCoin(CoinType.BITCOIN)` and `CoinType.BITCOIN.deriveAddress(key)` yield `bc1qumwjg8danv2vm29lp5swdux4r60ezptzz7ce85`. Compare the key's 32 raw bytes baseline/candidate as well; the cited tagged test supplies an address golden, not an exact key-byte golden. |
| `android/app/src/androidTest/java/com/trustwallet/core/app/blockchains/ethereum/TestEthereumTransactionSigner.kt:26-45` | Legacy `Ethereum.SigningInput`: private key `46` repeated 32 bytes, destination `0x35` repeated 20 bytes, chain ID `01`, nonce `09`, gas price `04a817c800`, gas limit `5208`, transfer amount `0de0b6b3a7640000`, default Legacy mode. `AnySigner.sign(input, ETHEREUM, SigningOutput.parser())` encoded hex must equal `f86c098504a817c800825208943535353535353535353535353535353535353535880de0b6b3a76400008025a028ef61340bd939bc2195fe537567866003e1a15d3c71ff63e1590620aa636276a067cbe9d8997f761aecb703304b3800ccf555c9f3dc64214b297fb1966a3b6d83`. |
| `TestEthereumTransactionSigner.kt:77-103` | EIP-1559 ERC20 vector: private key `608dcb1742bb3fb7aec002074e3420e4fab7d00cced79ccdac53ed5b27138151`, DAI contract `0x6b175474e89094c44da98b954eedeac495271d0f`, chain `01`, nonce `00`, `TransactionMode.Enveloped`, inclusion fee `77359400`, max fee `b2d05e00`, gas `0130b9`, transfer to `0x5322b34c88ed0691971bf52a7047448f0f4efc84`, amount `1bc16d674ec80000`. Assert the exact encoded hex below and baseline/candidate complete `SigningOutput.toByteArray()` equality. |

The tagged EIP-1559 `SigningOutput.encoded` golden is
`02f8b00180847735940084b2d05e00830130b9946b175474e89094c44da98b954eedeac495271d0f80b844a9059cbb0000000000000000000000005322b34c88ed0691971bf52a7047448f0f4efc840000000000000000000000000000000000000000000000001bc16d674ec80000c080a0adfcfdf98d4ed35a8967a0c1d78b42adb7c5d831cf5a3272654ec8f8bcd7be2ea011641e065684f6aa476f4fd250aa46cd0b44eccdb0a6e1650d658d1998684cdf`.

The tagged ERC20 1559 test uses `Ethereum.Transaction.ERC20Transfer`, rather
than the simpler legacy native transfer. This deliberately exercises both
transaction modes and protobuf parse/serialize through JNI. A failure in either
published baseline or candidate must remain a recorded result, not be hidden
by relaxing the acceptance gate.

## Bitcoin compiler: known oracle and app-shaped route

The tag's `tests/chains/Bitcoin/TransactionCompilerTests.cpp:24-260`
`BitcoinCompiler.CompileWithSignatures` is a **legacy Bitcoin protobuf,
P2WPKH input** oracle, not P2WSH. Its three asserted preimage `data_hash`
values, in returned order, are
`505f527f00e15fcc5a2d2416c9970beb57dfdfaca99e572a01f143b24dd8fab6`,
`a296bead4172007be69b21971a790e076388666c162a9505698415f1b003ebd7`,
and `60ed6e9371e5ddc72fd88e46a12cb2f68516ebd307c0fd31b1b55cf767272101`.
It passes the original serialized `Bitcoin.SigningInput` to both
`TransactionCompiler.preImageHashes` and `compileWithSignatures`, supplies
three fixed DER signatures and matching compressed public keys, and asserts
serialized output length 786, encoded transaction length 518 and full encoded
hex in `ExpectedTx`. A Java/JNI transcription of that exact oracle tests both
compiler calls independently of the app-shaped P2WSH case; compare complete
proto results and the tagged goldens.

The real app route is
`android/app/src/main/kotlin/ai/n42/www/walletcore/TransactionSignerHandler.kt:1016-1082`.
It builds `BitcoinV2.TransactionBuilder` version V2, UseAll, dust 546, fee,
one or more `BitcoinV2.Input` records with reversed txid, vout, sequence
`Int.MAX_VALUE`, value, SIGHASH_ALL and `scriptData` from `witnessValue`;
sets a destination/max-amount output and testnet prefixes 111/196/`tb`;
embeds that V2 input in `Bitcoin.SigningInput.signingV2`; calls
`TransactionCompiler.preImageHashes(BITCOIN, serialized legacy wrapper)`;
parses `Bitcoin.PreSigningOutput.hashPublicKeys`; signs each `dataHash` with
`PrivateKey.signAsDER`, adds DER bytes and compressed secp256k1 public keys to
`DataVector`s; then calls `compileWithSignatures`. The app currently passes
the returned **preImageHashes bytes** as that latter call's second argument.
The tag's known compiler test instead passes its original signing-input bytes.
The fixture should reproduce the app call literally and record the parsed
error/hash count/output or exception in both phases, while keeping the tagged
known-valid compiler oracle distinct. Matching old/new output alone cannot
establish that the app-shaped business path produces a valid transaction.

Related source boundaries are specific: tag
`rust/tw_tests/tests/chains/bitcoin/bitcoin_sign/p2wsh.rs` has passing P2WSH
**output** cases, but its P2WSH **input** test is commented TODO; tag
`rust/chains/tw_bitcoin/src/modules/tx_builder/utxo_protobuf.rs` comments out
the V2 P2WSH input builder and says P2SH/P2WSH input scriptPubkeys are not yet
supported in one path. These do not prove the app's complete route fails,
especially because its `scriptData` path differs. Treat an actual published
baseline failure as a characterized existing behavior, preserve the raw
result, and ask root to scope any business fix separately; do not change the
current crypto/signing route during native relink verification.

## Device evidence gate for the later authorized run

Use only dedicated emulator `emulator-5560`, strict 16 KB and offline from
before install through after each call. Run published and candidate APKs in
separate freshly started processes; never load both native libraries into one
process. Pin fixture source/APK/AAR/proto/Javalite hashes before installation;
check local and installed APK bytes, packaged `arm64-v8a/libTrustWalletCore.so`
member bytes, actual classloader/native library path, PID and `/proc/PID/maps`
for the loaded member. Record contemporaneous strict/offline settings before
and after each phase and bind every result to the same fresh PID. Compare the
tagged goldens first, then old/new complete protobuf results for the
app-shaped case. A baseline fail is evidence of baseline behavior, never a
candidate pass; no production app install, real account/key, payment, network
call or broadcast is within this fixture.

The maintained AAR hash from the reviewed packaging stage is
`560cf86e132e4b4ee18afb70daf670e12e8fd34684a03eb38b9e49e39cd0f57d`;
its stripped ARM64 JNI member hash is
`f2ad3625ae3e691369baaf3bede441f9b56500e5a2655b33baa0ca2866fa3a3d`.
The published AAR hash is
`04ea7ab9527beeb3f4d650b13108deb08ec8a857f4e62b86df3e953dfa9e4d87`.
The APK packaged-member byte hash and installed map path must be measured
from the actual APK/build, not assumed equal to raw AAR JNI bytes if the
Android Gradle Plugin strips or transforms them.
