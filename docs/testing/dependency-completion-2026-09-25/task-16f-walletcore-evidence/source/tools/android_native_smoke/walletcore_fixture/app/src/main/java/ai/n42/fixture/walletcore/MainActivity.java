package ai.n42.fixture.walletcore;

import android.app.Activity;
import android.os.Bundle;
import android.os.Process;
import android.util.Log;
import com.google.protobuf.ByteString;
import dalvik.system.BaseDexClassLoader;
import java.io.File;
import java.nio.file.Files;
import java.security.MessageDigest;
import org.json.JSONArray;
import org.json.JSONObject;
import wallet.core.java.AnySigner;
import wallet.core.jni.BitcoinSigHashType;
import wallet.core.jni.CoinType;
import wallet.core.jni.Curve;
import wallet.core.jni.DataVector;
import wallet.core.jni.HDWallet;
import wallet.core.jni.PrivateKey;
import wallet.core.jni.TransactionCompiler;
import wallet.core.jni.proto.Bitcoin;
import wallet.core.jni.proto.BitcoinV2;
import wallet.core.jni.proto.Common;
import wallet.core.jni.proto.Ethereum;
import wallet.core.jni.proto.Utxo;

/** Offline, test-only calls against the tagged Wallet Core Java and JNI contract. */
public final class MainActivity extends Activity {
    private static final String TAG = "N42_WALLETCORE_FIXTURE";
    private static final String WORDS =
            "ripple scissors kick mammal hire column oak again sun offer wealth tomorrow wagon turn fatal";
    private static final String ENTROPY = "ba5821e8c356c05ba5f025d9532fe0f21f65d594";
    private static final String SEED = "7ae6f661157bda6492f6162701e570097fc726b6235011ea5ad09bf04986731ed4d92bc43cbdee047b60ea0dd1b1fa4274377c9bf5bd14ab1982c272d8076f29";
    private static final String BTC_ADDRESS = "bc1qumwjg8danv2vm29lp5swdux4r60ezptzz7ce85";
    private static final String ETH_LEGACY = "f86c098504a817c800825208943535353535353535353535353535353535353535880de0b6b3a76400008025a028ef61340bd939bc2195fe537567866003e1a15d3c71ff63e1590620aa636276a067cbe9d8997f761aecb703304b3800ccf555c9f3dc64214b297fb1966a3b6d83";
    private static final String ETH_1559 = "02f8b00180847735940084b2d05e00830130b9946b175474e89094c44da98b954eedeac495271d0f80b844a9059cbb0000000000000000000000005322b34c88ed0691971bf52a7047448f0f4efc840000000000000000000000000000000000000000000000001bc16d674ec80000c080a0adfcfdf98d4ed35a8967a0c1d78b42adb7c5d831cf5a3272654ec8f8bcd7be2ea011641e065684f6aa476f4fd250aa46cd0b44eccdb0a6e1650d658d1998684cdf";
    private static final String BTC_V2_SIGHASH = "6a0e072da66b141fdb448323d54765cafcaf084a06d2fa13c8aed0c694e50d18";
    private static final String BTC_V2_SIGNATURE = "78eda020d4b86fcb3af78ef919912e6d79b81164dbbb0b0b96da6ac58a2de4b11a5fd8d48734d5a02371c4b5ee551a69dca3842edbf577d863cf8ae9fdbbd45900";
    private static final String BTC_V2_ENCODED = "02000000017be4e642bb278018ab12277de9427773ad1c5f5b1d164a157e0d99aa48dc1c1e000000006a473044022078eda020d4b86fcb3af78ef919912e6d79b81164dbbb0b0b96da6ac58a2de4b102201a5fd8d48734d5a02371c4b5ee551a69dca3842edbf577d863cf8ae9fdbbd4590121036666dd712e05a487916384bfcd5973eb53e8038eccbbf97f7eed775b87389536ffffffff01c0aff629010000001976a9145eaaa4f458f9158f86afcba08dd7448d27045e3d88ac00000000";
    private static final String BTC_V2_TXID = "c19f410bf1d70864220e93bca20f836aaaf8cdde84a46692616e9f4480d54885";

    private String phase;
    private String token;
    private int pid;
    private boolean requiredPassed = true;

    @Override public void onCreate(Bundle state) {
        super.onCreate(state);
        phase = getIntent().getStringExtra("phase");
        token = getIntent().getStringExtra("token");
        pid = Process.myPid();
        try {
            check("baseline".equals(phase) || "candidate".equals(phase), "phase");
            check(token != null && token.matches("[a-f0-9]{32}"), "token");
            JSONObject start = common("BEGIN");
            File apk = new File(getApplicationInfo().sourceDir);
            start.put("apkPath", apk.getCanonicalPath());
            start.put("apkSha256", sha256(Files.readAllBytes(apk.toPath())));
            start.put("libraryLookupPath", ((BaseDexClassLoader) getClassLoader()).findLibrary("TrustWalletCore"));
            emit(start);
            System.loadLibrary("TrustWalletCore");
            JSONObject loaded = common("LOADED");
            loaded.put("nativeMaps", nativeMaps());
            emit(loaded);
            runCase("hdwallet", true, this::hdWallet);
            runCase("ethereumLegacy", true, () -> ethereum(false));
            runCase("ethereum1559", true, () -> ethereum(true));
            runCase("bitcoinCompilerV2", true, this::bitcoinCompilerV2);
            runCase("bitcoinAppP2wsh", false, this::bitcoinAppP2wsh);
            JSONObject end = common("END");
            end.put("status", requiredPassed ? "PASS" : "FAIL");
            emit(end);
        } catch (Throwable error) {
            try {
                JSONObject end = common("END");
                end.put("status", "FAIL");
                end.put("error", error.getClass().getName() + ":" + String.valueOf(error.getMessage()));
                emit(end);
            } catch (Exception ignored) {
                Log.e(TAG, "Cannot emit fatal fixture result", error);
            }
        } finally {
            finish();
        }
    }

    private interface CaseCall { JSONObject call() throws Exception; }

    private void runCase(String name, boolean required, CaseCall call) throws Exception {
        JSONObject record = common("CASE");
        record.put("name", name);
        record.put("required", required);
        try {
            JSONObject result = call.call();
            record.put("outcome", required ? "PASS" : "OBSERVED");
            record.put("result", result);
        } catch (Throwable error) {
            record.put("outcome", required ? "FAIL" : "OBSERVED_ERROR");
            record.put("errorClass", error.getClass().getName());
            record.put("errorMessage", String.valueOf(error.getMessage()));
            if (required) requiredPassed = false;
        }
        emit(record);
    }

    private JSONObject hdWallet() throws Exception {
        HDWallet wallet = new HDWallet(WORDS, "TREZOR");
        check(WORDS.equals(wallet.mnemonic()), "mnemonic");
        check(ENTROPY.equals(hex(wallet.entropy())), "entropy");
        check(SEED.equals(hex(wallet.seed())), "seed");
        PrivateKey key = wallet.getKeyForCoin(CoinType.BITCOIN);
        String address = CoinType.BITCOIN.deriveAddress(key);
        check(BTC_ADDRESS.equals(address), "Bitcoin derived address");
        JSONObject result = new JSONObject();
        result.put("entropy", hex(wallet.entropy()));
        result.put("seedSha256", sha256(wallet.seed()));
        result.put("keySha256", sha256(key.data()));
        result.put("bitcoinAddress", address);
        return result;
    }

    private JSONObject ethereum(boolean enveloped) throws Exception {
        byte[] privateKey = unhex(enveloped
                ? "608dcb1742bb3fb7aec002074e3420e4fab7d00cced79ccdac53ed5b27138151"
                : "4646464646464646464646464646464646464646464646464646464646464646");
        Ethereum.SigningInput.Builder input = Ethereum.SigningInput.newBuilder()
                .setPrivateKey(bs(new PrivateKey(privateKey).data()))
                .setToAddress(enveloped ? "0x6b175474e89094c44da98b954eedeac495271d0f"
                        : "0x3535353535353535353535353535353535353535")
                .setChainId(bs(unhex("01")))
                .setNonce(bs(unhex(enveloped ? "00" : "09")))
                .setGasLimit(bs(unhex(enveloped ? "0130b9" : "5208")));
        if (enveloped) {
            input.setTxMode(Ethereum.TransactionMode.Enveloped)
                    .setMaxInclusionFeePerGas(bs(unhex("77359400")))
                    .setMaxFeePerGas(bs(unhex("b2d05e00")))
                    .setTransaction(Ethereum.Transaction.newBuilder().setErc20Transfer(
                            Ethereum.Transaction.ERC20Transfer.newBuilder()
                                    .setTo("0x5322b34c88ed0691971bf52a7047448f0f4efc84")
                                    .setAmount(bs(unhex("1bc16d674ec80000")))));
        } else {
            input.setGasPrice(bs(unhex("04a817c800")))
                    .setTransaction(Ethereum.Transaction.newBuilder().setTransfer(
                            Ethereum.Transaction.Transfer.newBuilder()
                                    .setAmount(bs(unhex("0de0b6b3a7640000")))));
        }
        Ethereum.SigningOutput output = AnySigner.sign(input.build(), CoinType.ETHEREUM,
                Ethereum.SigningOutput.parser());
        check((enveloped ? ETH_1559 : ETH_LEGACY).equals(hex(output.getEncoded().toByteArray())),
                "Ethereum encoded golden");
        JSONObject result = new JSONObject();
        result.put("encodedSha256", sha256(output.getEncoded().toByteArray()));
        result.put("signingOutputSha256", sha256(output.toByteArray()));
        result.put("signingOutputBytes", output.getSerializedSize());
        result.put("error", output.getError().name());
        return result;
    }

    private JSONObject bitcoinCompilerV2() throws Exception {
        PrivateKey alice = new PrivateKey(unhex(
                "56429688a1a6b00b90ccd22a0de0a376b6569d8684022ae92229a28478bfb657"));
        byte[] alicePublic = alice.getPublicKeySecp256k1(true).data();
        byte[] bobPublic = unhex(
                "037ed9a436e11ec4947ac4b7823787e24ba73180f1edd2857bff19c9f4d62b65bf");
        byte[] txid = reverse(unhex(
                "1e1cdc48aa990d7e154a161d5b5f1cad737742e97d2712ab188027bb42e6e47b"));
        BitcoinV2.Input input = BitcoinV2.Input.newBuilder()
                .setOutPoint(Utxo.OutPoint.newBuilder().setHash(bs(txid)).setVout(0))
                .setValue(5_000_000_000L).setSighashType(BitcoinSigHashType.ALL.value())
                .setScriptBuilder(BitcoinV2.Input.InputBuilder.newBuilder().setP2Pkh(
                        BitcoinV2.PublicKeyOrHash.newBuilder().setPubkey(bs(alicePublic))))
                .build();
        BitcoinV2.Output output = BitcoinV2.Output.newBuilder().setValue(4_999_000_000L)
                .setBuilder(BitcoinV2.Output.OutputBuilder.newBuilder().setP2Pkh(
                        BitcoinV2.PublicKeyOrHash.newBuilder().setPubkey(bs(bobPublic))))
                .build();
        BitcoinV2.SigningInput v2 = BitcoinV2.SigningInput.newBuilder()
                .setChainInfo(BitcoinV2.ChainInfo.newBuilder().setP2PkhPrefix(0).setP2ShPrefix(5))
                .addPublicKeys(bs(alicePublic))
                .setBuilder(BitcoinV2.TransactionBuilder.newBuilder()
                        .addInputs(input).addOutputs(output)
                        .setVersion(BitcoinV2.TransactionVersion.V2)
                        .setInputSelector(BitcoinV2.InputSelector.UseAll)
                        .setFixedDustThreshold(546))
                .build();
        byte[] signingInput = Bitcoin.SigningInput.newBuilder().setSigningV2(v2).build().toByteArray();
        byte[] preBytes = TransactionCompiler.preImageHashes(CoinType.BITCOIN, signingInput);
        Bitcoin.PreSigningOutput pre = Bitcoin.PreSigningOutput.parseFrom(preBytes);
        check(pre.getError() == Common.SigningError.OK, "Bitcoin preimage error");
        check(pre.hasPreSigningResultV2(), "Bitcoin V2 preimage absent");
        check(pre.getPreSigningResultV2().getError() == Common.SigningError.OK,
                "Bitcoin V2 preimage error");
        check(pre.getPreSigningResultV2().getSighashesCount() == 1, "Bitcoin sighash count");
        byte[] sighash = pre.getPreSigningResultV2().getSighashes(0).getSighash().toByteArray();
        check(BTC_V2_SIGHASH.equals(hex(sighash)), "Bitcoin sighash golden");
        byte[] signature = alice.sign(sighash, Curve.SECP256K1);
        check(BTC_V2_SIGNATURE.equals(hex(signature)), "Bitcoin signature golden");
        DataVector signatures = new DataVector();
        signatures.add(signature);
        DataVector publicKeys = new DataVector();
        publicKeys.add(alicePublic);
        byte[] outputBytes = TransactionCompiler.compileWithSignatures(
                CoinType.BITCOIN, signingInput, signatures, publicKeys);
        Bitcoin.SigningOutput compiled = Bitcoin.SigningOutput.parseFrom(outputBytes);
        check(compiled.getError() == Common.SigningError.OK, "Bitcoin compiler error");
        check(compiled.hasSigningResultV2(), "Bitcoin V2 result absent");
        check(compiled.getSigningResultV2().getError() == Common.SigningError.OK,
                "Bitcoin V2 compiler error");
        check(BTC_V2_ENCODED.equals(hex(compiled.getSigningResultV2().getEncoded().toByteArray())),
                "Bitcoin encoded golden");
        check(BTC_V2_TXID.equals(hex(compiled.getSigningResultV2().getTxid().toByteArray())),
                "Bitcoin txid golden");
        JSONObject result = new JSONObject();
        result.put("preimageSha256", sha256(preBytes));
        result.put("preimageBytes", preBytes.length);
        result.put("signingOutputSha256", sha256(outputBytes));
        result.put("signingOutputBytes", outputBytes.length);
        result.put("encodedSha256", sha256(compiled.getSigningResultV2().getEncoded().toByteArray()));
        result.put("txid", BTC_V2_TXID);
        return result;
    }

    private JSONObject bitcoinAppP2wsh() throws Exception {
        PrivateKey key = new PrivateKey(unhex(
                "56429688a1a6b00b90ccd22a0de0a376b6569d8684022ae92229a28478bfb657"));
        byte[] txid = reverse(unhex(
                "1e1cdc48aa990d7e154a161d5b5f1cad737742e97d2712ab188027bb42e6e47b"));
        byte[] witnessValue = unhex(
                "0020ff25429251b5a84f452230a3c75fd886b7fc5a7865ce4a7bb7a9d7c5be6da3db");
        BitcoinV2.Input input = BitcoinV2.Input.newBuilder()
                .setOutPoint(Utxo.OutPoint.newBuilder().setHash(bs(txid)).setVout(0))
                .setSequence(BitcoinV2.Input.Sequence.newBuilder().setSequence(Integer.MAX_VALUE))
                .setValue(100_000L).setSighashType(BitcoinSigHashType.ALL.value())
                .setScriptData(bs(witnessValue)).build();
        BitcoinV2.TransactionBuilder builder = BitcoinV2.TransactionBuilder.newBuilder()
                .setLockTime(0).setFeePerVb(1).setVersion(BitcoinV2.TransactionVersion.V2)
                .setInputSelector(BitcoinV2.InputSelector.UseAll)
                .setFixedDustThreshold(546).addInputs(input)
                .setMaxAmountOutput(BitcoinV2.Output.newBuilder()
                        .setToAddress("tb1qwgpxgwn33z3ke9s7q65l976pseh4edrzfmyvl0")
                        .setValue(90_000L)).build();
        BitcoinV2.SigningInput signingV2 = BitcoinV2.SigningInput.newBuilder()
                .setBuilder(builder)
                .setChainInfo(BitcoinV2.ChainInfo.newBuilder()
                        .setP2PkhPrefix(111).setP2ShPrefix(196).setHrp("tb"))
                .build();
        byte[] signingInput = Bitcoin.SigningInput.newBuilder()
                .setSigningV2(signingV2).build().toByteArray();
        JSONObject result = new JSONObject();
        result.put("signingInputSha256", sha256(signingInput));
        String stage = "preImageHashes";
        try {
            byte[] preBytes = TransactionCompiler.preImageHashes(CoinType.BITCOIN, signingInput);
            result.put("preimageSha256", sha256(preBytes));
            result.put("preimageBytes", preBytes.length);
            stage = "parsePreSigningOutput";
            Bitcoin.PreSigningOutput pre = Bitcoin.PreSigningOutput.parseFrom(preBytes);
            result.put("preimageError", pre.getError().name());
            result.put("preimageErrorMessage", pre.getErrorMessage());
            result.put("hashPublicKeysCount", pre.getHashPublicKeysCount());
            DataVector signatures = new DataVector();
            DataVector publicKeys = new DataVector();
            stage = "signPreimages";
            for (Bitcoin.HashPublicKey hash : pre.getHashPublicKeysList()) {
                signatures.add(key.signAsDER(hash.getDataHash().toByteArray()));
                publicKeys.add(key.getPublicKeySecp256k1(true).data());
            }
            // This is deliberately the app's current call shape: preBytes, not signingInput.
            stage = "compileWithSignatures";
            byte[] compiled = TransactionCompiler.compileWithSignatures(
                    CoinType.BITCOIN, preBytes, signatures, publicKeys);
            result.put("compilerOutputSha256", sha256(compiled));
            result.put("compilerOutputBytes", compiled.length);
            stage = "parseSigningOutput";
            Bitcoin.SigningOutput output = Bitcoin.SigningOutput.parseFrom(compiled);
            result.put("compilerError", output.getError().name());
            result.put("compilerErrorMessage", output.getErrorMessage());
            result.put("encodedSha256", sha256(output.getEncoded().toByteArray()));
            result.put("encodedBytes", output.getEncoded().size());
        } catch (Throwable error) {
            result.put("failureStage", stage);
            result.put("errorClass", error.getClass().getName());
            result.put("errorMessage", String.valueOf(error.getMessage()));
        }
        return result;
    }

    private JSONObject common(String kind) throws Exception {
        JSONObject record = new JSONObject();
        record.put("kind", kind);
        record.put("phase", phase);
        record.put("token", token);
        record.put("pid", pid);
        return record;
    }

    private JSONArray nativeMaps() throws Exception {
        JSONArray lines = new JSONArray();
        String apk = getApplicationInfo().sourceDir;
        for (String line : Files.readAllLines(new File("/proc/self/maps").toPath())) {
            if (line.contains("r-xp") &&
                    (line.contains(apk) || line.contains("libTrustWalletCore.so"))) lines.put(line);
        }
        return lines;
    }

    private static void emit(JSONObject record) {
        String text = record.toString();
        if (text.length() > 3500) throw new IllegalStateException("Fixture result too large");
        Log.i(TAG, text);
    }

    private static void check(boolean value, String name) {
        if (!value) throw new IllegalStateException(name);
    }

    private static ByteString bs(byte[] bytes) { return ByteString.copyFrom(bytes); }

    private static byte[] reverse(byte[] data) {
        byte[] result = data.clone();
        for (int i = 0; i < result.length / 2; i++) {
            byte next = result[i];
            result[i] = result[result.length - 1 - i];
            result[result.length - 1 - i] = next;
        }
        return result;
    }

    private static byte[] unhex(String hex) {
        if (hex.length() % 2 != 0) throw new IllegalArgumentException("Odd hex length");
        byte[] result = new byte[hex.length() / 2];
        for (int i = 0; i < result.length; i++) {
            int high = Character.digit(hex.charAt(i * 2), 16);
            int low = Character.digit(hex.charAt(i * 2 + 1), 16);
            if (high < 0 || low < 0) throw new IllegalArgumentException("Invalid hex");
            result[i] = (byte) ((high << 4) | low);
        }
        return result;
    }

    private static String hex(byte[] bytes) {
        StringBuilder result = new StringBuilder(bytes.length * 2);
        for (byte value : bytes) result.append(String.format("%02x", value & 0xff));
        return result.toString();
    }

    private static String sha256(byte[] data) throws Exception {
        byte[] digest = MessageDigest.getInstance("SHA-256").digest(data);
        return hex(digest);
    }
}
