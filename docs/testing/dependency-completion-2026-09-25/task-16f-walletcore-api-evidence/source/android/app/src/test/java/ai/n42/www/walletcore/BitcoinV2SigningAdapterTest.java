package ai.n42.www.walletcore;

import static org.junit.Assert.assertArrayEquals;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertThrows;
import static org.junit.Assert.assertTrue;

import com.google.protobuf.ByteString;
import java.util.ArrayList;
import java.util.List;
import org.junit.Test;
import wallet.core.jni.proto.Bitcoin;
import wallet.core.jni.proto.BitcoinV2;
import wallet.core.jni.proto.Common.SigningError;

public final class BitcoinV2SigningAdapterTest {
    private static final byte[] INPUT = {1, 2, 3};
    private static final byte[] KEY = new byte[33];
    private static final byte[] HASH = new byte[32];
    private static final byte[] SIGNATURE = {7, 8};
    private static final byte[] ENCODED = {2, 0, 0, 0, 9};

    static {
        KEY[0] = 2;
        HASH[0] = 1;
    }

    private static Bitcoin.PreSigningOutput pre(SigningError outer,
            BitcoinV2.PreSigningOutput nested) {
        Bitcoin.PreSigningOutput.Builder builder = Bitcoin.PreSigningOutput.newBuilder()
                .setError(outer);
        if (nested != null) builder.setPreSigningResultV2(nested);
        return builder.build();
    }

    private static BitcoinV2.PreSigningOutput nested(SigningError error,
            BitcoinV2.PreSigningOutput.SigningMethod method, byte[] key, byte[] hash) {
        BitcoinV2.PreSigningOutput.Builder builder = BitcoinV2.PreSigningOutput.newBuilder()
                .setError(error);
        if (hash != null) {
            builder.addSighashes(BitcoinV2.PreSigningOutput.Sighash.newBuilder()
                    .setPublicKey(ByteString.copyFrom(key))
                    .setSighash(ByteString.copyFrom(hash))
                    .setSigningMethod(method));
        }
        return builder.build();
    }

    private static Bitcoin.SigningOutput output(SigningError outer,
            BitcoinV2.SigningOutput nested) {
        Bitcoin.SigningOutput.Builder builder = Bitcoin.SigningOutput.newBuilder()
                .setError(outer);
        if (nested != null) builder.setSigningResultV2(nested);
        return builder.build();
    }

    private static BitcoinV2.SigningOutput signed(SigningError error, byte[] encoded) {
        return BitcoinV2.SigningOutput.newBuilder().setError(error)
                .setEncoded(ByteString.copyFrom(encoded)).build();
    }

    private static final class Engine implements BitcoinV2SigningAdapter.Compiler {
        Bitcoin.PreSigningOutput pre = pre(SigningError.OK,
                nested(SigningError.OK, BitcoinV2.PreSigningOutput.SigningMethod.Legacy,
                        KEY, HASH));
        Bitcoin.SigningOutput result = output(SigningError.OK, signed(SigningError.OK, ENCODED));
        byte[] preInput;
        byte[] compileInput;
        List<byte[]> signatures;
        List<byte[]> publicKeys;

        @Override
        public byte[] preImageHashes(byte[] input) {
            preInput = input;
            return pre.toByteArray();
        }

        @Override
        public byte[] compileWithSignatures(byte[] input, List<byte[]> signatures,
                List<byte[]> publicKeys) {
            compileInput = input;
            this.signatures = new ArrayList<>(signatures);
            this.publicKeys = new ArrayList<>(publicKeys);
            return result.toByteArray();
        }
    }

    private static byte[] compile(Engine engine) {
        return BitcoinV2SigningAdapter.compile(INPUT, KEY, hash -> {
            assertArrayEquals(HASH, hash);
            return SIGNATURE;
        }, engine);
    }

    private static void rejected(Engine engine, String reason) {
        IllegalArgumentException error = assertThrows(IllegalArgumentException.class,
                () -> compile(engine));
        assertTrue(error.getMessage(), error.getMessage().contains(reason));
    }

    @Test
    public void validV2ReturnsOnlyEncodedTransactionAndUsesOriginalInput() {
        Engine engine = new Engine();
        assertArrayEquals(ENCODED, compile(engine));
        assertArrayEquals(INPUT, engine.preInput);
        assertArrayEquals(INPUT, engine.compileInput);
        assertArrayEquals(SIGNATURE, engine.signatures.get(0));
        assertArrayEquals(KEY, engine.publicKeys.get(0));
        assertEquals(1, engine.signatures.size());
    }

    @Test
    public void outerAndNestedPreSignErrorsAreRejected() {
        Engine engine = new Engine();
        engine.pre = pre(SigningError.Error_invalid_params,
                nested(SigningError.OK, BitcoinV2.PreSigningOutput.SigningMethod.Legacy,
                        KEY, HASH));
        rejected(engine, "pre-sign outer");
        engine.pre = pre(SigningError.OK,
                nested(SigningError.Error_not_supported,
                        BitcoinV2.PreSigningOutput.SigningMethod.Segwit, KEY, HASH));
        rejected(engine, "Error_not_supported");
    }

    @Test
    public void missingNestedAndEmptyHashesAreRejected() {
        Engine engine = new Engine();
        engine.pre = pre(SigningError.OK, null);
        rejected(engine, "pre-sign V2 result missing");
        engine.pre = pre(SigningError.OK, nested(SigningError.OK,
                BitcoinV2.PreSigningOutput.SigningMethod.Legacy, KEY, null));
        rejected(engine, "sighashes empty");
    }

    @Test
    public void wrongKeyAndSigningMethodAreRejectedBeforeSigning() {
        Engine engine = new Engine();
        byte[] other = KEY.clone();
        other[0] = 1;
        engine.pre = pre(SigningError.OK, nested(SigningError.OK,
                BitcoinV2.PreSigningOutput.SigningMethod.Segwit, other, HASH));
        rejected(engine, "public key mismatch");
        engine.pre = pre(SigningError.OK, nested(SigningError.OK,
                BitcoinV2.PreSigningOutput.SigningMethod.Taproot, KEY, HASH));
        rejected(engine, "signing method");
    }

    @Test
    public void emptySighashOrSignatureIsRejected() {
        Engine engine = new Engine();
        engine.pre = pre(SigningError.OK, nested(SigningError.OK,
                BitcoinV2.PreSigningOutput.SigningMethod.Segwit, KEY, new byte[0]));
        rejected(engine, "sighash length");
        engine.pre = pre(SigningError.OK, nested(SigningError.OK,
                BitcoinV2.PreSigningOutput.SigningMethod.Segwit, KEY, HASH));
        IllegalArgumentException error = assertThrows(IllegalArgumentException.class,
                () -> BitcoinV2SigningAdapter.compile(INPUT, KEY, hash -> new byte[0], engine));
        assertTrue(error.getMessage().contains("signature empty"));
    }

    @Test
    public void signingOutputErrorsAndEmptyEncodedAreRejected() {
        Engine engine = new Engine();
        engine.result = output(SigningError.Error_invalid_params,
                signed(SigningError.OK, ENCODED));
        rejected(engine, "sign outer");
        engine.result = output(SigningError.OK, null);
        rejected(engine, "sign V2 result missing");
        engine.result = output(SigningError.OK,
                signed(SigningError.Error_not_supported, ENCODED));
        rejected(engine, "Error_not_supported");
        engine.result = output(SigningError.OK, signed(SigningError.OK, new byte[0]));
        rejected(engine, "encoded transaction empty");
    }
}
