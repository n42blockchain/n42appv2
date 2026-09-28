package ai.n42.fixture.walletcoreapi;

import ai.n42.www.walletcore.BitcoinV2SigningAdapter;
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
import wallet.core.jni.BitcoinSigHashType;
import wallet.core.jni.CoinType;
import wallet.core.jni.Curve;
import wallet.core.jni.DataVector;
import wallet.core.jni.PrivateKey;
import wallet.core.jni.TransactionCompiler;
import wallet.core.jni.proto.Bitcoin;
import wallet.core.jni.proto.BitcoinV2;
import wallet.core.jni.proto.Utxo;

/** Synthetic keys and offline transactions only; invokes the exact production adapter. */
public final class MainActivity extends Activity {
    private static final String TAG = "N42_WC_API_FIXTURE";
    private static final String EXPECTED_ENCODED = "02000000017be4e642bb278018ab12277de9427773ad1c5f5b1d164a157e0d99aa48dc1c1e000000006a473044022078eda020d4b86fcb3af78ef919912e6d79b81164dbbb0b0b96da6ac58a2de4b102201a5fd8d48734d5a02371c4b5ee551a69dca3842edbf577d863cf8ae9fdbbd4590121036666dd712e05a487916384bfcd5973eb53e8038eccbbf97f7eed775b87389536ffffffff01c0aff629010000001976a9145eaaa4f458f9158f86afcba08dd7448d27045e3d88ac00000000";
    private static final String EXPECTED_TXID = "c19f410bf1d70864220e93bca20f836aaaf8cdde84a46692616e9f4480d54885";
    private static final byte[] ALICE_KEY = unhex("56429688a1a6b00b90ccd22a0de0a376b6569d8684022ae92229a28478bfb657");
    private static final byte[] PREV_TXID = reverse(unhex("1e1cdc48aa990d7e154a161d5b5f1cad737742e97d2712ab188027bb42e6e47b"));
    private String token;
    private int pid;
    private boolean passed = true;

    @Override public void onCreate(Bundle state) {
        super.onCreate(state);
        token = getIntent().getStringExtra("token");
        pid = Process.myPid();
        try {
            require(token != null && token.matches("[a-f0-9]{32}"), "token");
            File apk = new File(getApplicationInfo().sourceDir);
            JSONObject begin = record("BEGIN");
            begin.put("apkPath", apk.getCanonicalPath());
            begin.put("apkSha256", sha256(Files.readAllBytes(apk.toPath())));
            begin.put("libraryLookupPath", ((BaseDexClassLoader) getClassLoader()).findLibrary("TrustWalletCore"));
            emit(begin);
            System.loadLibrary("TrustWalletCore");
            JSONObject loaded = record("LOADED");
            loaded.put("nativeMaps", nativeMaps());
            emit(loaded);
            runCase("taggedP2pkh", this::taggedP2pkh);
            runCase("unsupportedP2wsh", this::unsupportedP2wsh);
        } catch (Throwable error) {
            passed = false;
            Log.e(TAG, "Fatal fixture failure", error);
        } finally {
            try {
                JSONObject end = record("END");
                end.put("status", passed ? "PASS" : "FAIL");
                emit(end);
            } catch (Exception error) {
                Log.e(TAG, "Cannot emit END", error);
            }
            finish();
        }
    }

    private interface CaseCall { JSONObject call() throws Exception; }

    private void runCase(String name, CaseCall call) throws Exception {
        JSONObject result = record("CASE");
        result.put("name", name);
        try {
            result.put("result", call.call());
            result.put("outcome", "PASS");
        } catch (Throwable error) {
            passed = false;
            result.put("outcome", "FAIL");
            result.put("error", error.getClass().getName() + ":" + error.getMessage());
        }
        emit(result);
    }

    private static BitcoinV2SigningAdapter.Compiler compiler() {
        return new BitcoinV2SigningAdapter.Compiler() {
            @Override public byte[] preImageHashes(byte[] originalInput) {
                return TransactionCompiler.preImageHashes(CoinType.BITCOIN, originalInput);
            }
            @Override public byte[] compileWithSignatures(byte[] originalInput,
                    java.util.List<byte[]> signatures, java.util.List<byte[]> publicKeys) {
                DataVector sigs = new DataVector();
                DataVector keys = new DataVector();
                for (byte[] sig : signatures) sigs.add(sig);
                for (byte[] key : publicKeys) keys.add(key);
                return TransactionCompiler.compileWithSignatures(
                        CoinType.BITCOIN, originalInput, sigs, keys);
            }
        };
    }

    private JSONObject taggedP2pkh() throws Exception {
        PrivateKey alice = new PrivateKey(ALICE_KEY);
        byte[] publicKey = alice.getPublicKeySecp256k1(true).data();
        byte[] bob = unhex("037ed9a436e11ec4947ac4b7823787e24ba73180f1edd2857bff19c9f4d62b65bf");
        BitcoinV2.Input input = BitcoinV2.Input.newBuilder()
                .setOutPoint(Utxo.OutPoint.newBuilder().setHash(bs(PREV_TXID)).setVout(0))
                .setValue(5_000_000_000L).setSighashType(BitcoinSigHashType.ALL.value())
                .setScriptBuilder(BitcoinV2.Input.InputBuilder.newBuilder().setP2Pkh(
                        BitcoinV2.PublicKeyOrHash.newBuilder().setPubkey(bs(publicKey)))).build();
        BitcoinV2.Output output = BitcoinV2.Output.newBuilder().setValue(4_999_000_000L)
                .setBuilder(BitcoinV2.Output.OutputBuilder.newBuilder().setP2Pkh(
                        BitcoinV2.PublicKeyOrHash.newBuilder().setPubkey(bs(bob)))).build();
        BitcoinV2.SigningInput v2 = BitcoinV2.SigningInput.newBuilder()
                .setChainInfo(BitcoinV2.ChainInfo.newBuilder().setP2PkhPrefix(0).setP2ShPrefix(5))
                .addPublicKeys(bs(publicKey))
                .setBuilder(BitcoinV2.TransactionBuilder.newBuilder().addInputs(input).addOutputs(output)
                        .setVersion(BitcoinV2.TransactionVersion.V2)
                        .setInputSelector(BitcoinV2.InputSelector.UseAll).setFixedDustThreshold(546))
                .build();
        byte[] original = Bitcoin.SigningInput.newBuilder().setSigningV2(v2).build().toByteArray();
        byte[] encoded = BitcoinV2SigningAdapter.compile(original, publicKey,
                alice::signAsDER, compiler());
        require(EXPECTED_ENCODED.equals(hex(encoded)), "tagged encoded transaction differs");
        byte[] rawEncoded = BitcoinV2SigningAdapter.compile(original, publicKey,
                hash -> alice.sign(hash, Curve.SECP256K1), compiler());
        require(EXPECTED_ENCODED.equals(hex(rawEncoded)), "tagged raw-signature control differs");
        String txid = hex(reverse(MessageDigest.getInstance("SHA-256").digest(
                MessageDigest.getInstance("SHA-256").digest(encoded))));
        require(EXPECTED_TXID.equals(txid), "tagged txid differs");
        JSONObject result = new JSONObject();
        result.put("inputSha256", sha256(original));
        result.put("encoded", hex(encoded));
        result.put("encodedSha256", sha256(encoded));
        result.put("rawSignatureControlSha256", sha256(rawEncoded));
        result.put("txid", txid);
        return result;
    }

    private JSONObject unsupportedP2wsh() throws Exception {
        PrivateKey alice = new PrivateKey(ALICE_KEY);
        byte[] publicKey = alice.getPublicKeySecp256k1(true).data();
        byte[] script = unhex("0020ff25429251b5a84f452230a3c75fd886b7fc5a7865ce4a7bb7a9d7c5be6da3db");
        BitcoinV2.Input input = BitcoinV2.Input.newBuilder()
                .setOutPoint(Utxo.OutPoint.newBuilder().setHash(bs(PREV_TXID)).setVout(0))
                .setSequence(BitcoinV2.Input.Sequence.newBuilder().setSequence(Integer.MAX_VALUE))
                .setValue(100_000L).setSighashType(BitcoinSigHashType.ALL.value())
                .setScriptData(bs(script)).build();
        BitcoinV2.TransactionBuilder builder = BitcoinV2.TransactionBuilder.newBuilder()
                .setLockTime(0).setFeePerVb(1).setVersion(BitcoinV2.TransactionVersion.V2)
                .setInputSelector(BitcoinV2.InputSelector.UseAll).setFixedDustThreshold(546)
                .addInputs(input).setMaxAmountOutput(BitcoinV2.Output.newBuilder()
                        .setToAddress("tb1qwgpxgwn33z3ke9s7q65l976pseh4edrzfmyvl0")
                        .setValue(90_000L)).build();
        BitcoinV2.SigningInput v2 = BitcoinV2.SigningInput.newBuilder().setBuilder(builder)
                .setChainInfo(BitcoinV2.ChainInfo.newBuilder().setP2PkhPrefix(111)
                        .setP2ShPrefix(196).setHrp("tb")).build();
        byte[] original = Bitcoin.SigningInput.newBuilder().setSigningV2(v2).build().toByteArray();
        String message;
        try {
            BitcoinV2SigningAdapter.compile(original, publicKey, alice::signAsDER, compiler());
            throw new IllegalStateException("unsupported V2 P2WSH returned transaction bytes");
        } catch (IllegalArgumentException expected) {
            message = expected.getMessage();
        }
        require(message.contains("Error_not_supported"), "unsupported error was not preserved: " + message);
        JSONObject result = new JSONObject();
        result.put("inputSha256", sha256(original));
        result.put("error", message);
        return result;
    }

    private JSONObject record(String kind) throws Exception {
        JSONObject json = new JSONObject();
        json.put("kind", kind);
        json.put("token", token);
        json.put("pid", pid);
        return json;
    }

    private JSONArray nativeMaps() throws Exception {
        JSONArray rows = new JSONArray();
        String apk = getApplicationInfo().sourceDir;
        for (String row : Files.readAllLines(new File("/proc/self/maps").toPath())) {
            if (row.contains("r-xp") &&
                    (row.contains(apk) || row.contains("libTrustWalletCore.so"))) rows.put(row);
        }
        return rows;
    }

    private static void emit(JSONObject json) {
        String row = json.toString();
        if (row.length() > 3500) throw new IllegalStateException("Fixture record too large");
        Log.i(TAG, row);
    }

    private static void require(boolean ok, String reason) {
        if (!ok) throw new IllegalStateException(reason);
    }

    private static ByteString bs(byte[] bytes) { return ByteString.copyFrom(bytes); }

    private static byte[] reverse(byte[] bytes) {
        byte[] result = bytes.clone();
        for (int i = 0; i < result.length / 2; i++) {
            byte b = result[i];
            result[i] = result[result.length - 1 - i];
            result[result.length - 1 - i] = b;
        }
        return result;
    }

    private static byte[] unhex(String value) {
        byte[] result = new byte[value.length() / 2];
        for (int i = 0; i < result.length; i++) {
            int a = Character.digit(value.charAt(2 * i), 16);
            int b = Character.digit(value.charAt(2 * i + 1), 16);
            if (a < 0 || b < 0) throw new IllegalArgumentException("hex");
            result[i] = (byte) ((a << 4) | b);
        }
        return result;
    }

    private static String hex(byte[] bytes) {
        StringBuilder text = new StringBuilder(bytes.length * 2);
        for (byte b : bytes) text.append(String.format("%02x", b & 0xff));
        return text.toString();
    }

    private static String sha256(byte[] bytes) throws Exception {
        return hex(MessageDigest.getInstance("SHA-256").digest(bytes));
    }
}
