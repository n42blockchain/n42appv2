package ai.n42.www.walletcore;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import wallet.core.jni.proto.Bitcoin;
import wallet.core.jni.proto.BitcoinV2;
import wallet.core.jni.proto.Common.SigningError;

/** Checks the V2 envelopes and returns only a successful raw Bitcoin transaction. */
public final class BitcoinV2SigningAdapter {
    @FunctionalInterface
    public interface HashSigner {
        byte[] sign(byte[] sighash);
    }

    public interface Compiler {
        byte[] preImageHashes(byte[] originalInput);

        byte[] compileWithSignatures(byte[] originalInput, List<byte[]> signatures,
                List<byte[]> publicKeys);
    }

    private BitcoinV2SigningAdapter() {}

    private static void require(boolean condition, String reason) {
        if (!condition) throw new IllegalArgumentException(reason);
    }

    public static byte[] compile(byte[] originalInput, byte[] expectedPublicKey,
            HashSigner signer, Compiler compiler) {
        require(originalInput != null && originalInput.length > 0,
                "Bitcoin V2 signing input empty");
        require(expectedPublicKey != null && expectedPublicKey.length == 33,
                "Bitcoin V2 compressed public key missing");
        require(signer != null && compiler != null, "Bitcoin V2 signer/compiler missing");

        Bitcoin.PreSigningOutput pre;
        try {
            pre = Bitcoin.PreSigningOutput.parseFrom(compiler.preImageHashes(originalInput));
        } catch (Exception error) {
            throw new IllegalArgumentException("Bitcoin V2 pre-sign envelope invalid", error);
        }
        require(pre.getError() == SigningError.OK,
                "Bitcoin V2 pre-sign outer error: " + pre.getError());
        require(pre.hasPreSigningResultV2(), "Bitcoin V2 pre-sign V2 result missing");
        BitcoinV2.PreSigningOutput nestedPre = pre.getPreSigningResultV2();
        require(nestedPre.getError() == SigningError.OK,
                "Bitcoin V2 pre-sign V2 error: " + nestedPre.getError() + " "
                        + nestedPre.getErrorMessage());
        require(nestedPre.getSighashesCount() > 0, "Bitcoin V2 sighashes empty");

        List<byte[]> signatures = new ArrayList<>();
        List<byte[]> publicKeys = new ArrayList<>();
        for (BitcoinV2.PreSigningOutput.Sighash item : nestedPre.getSighashesList()) {
            BitcoinV2.PreSigningOutput.SigningMethod method = item.getSigningMethod();
            require(method == BitcoinV2.PreSigningOutput.SigningMethod.Legacy
                    || method == BitcoinV2.PreSigningOutput.SigningMethod.Segwit,
                    "Bitcoin V2 unsupported signing method: " + method);
            require(!item.hasTweak(), "Bitcoin V2 unexpected signing tweak");
            require(Arrays.equals(expectedPublicKey, item.getPublicKey().toByteArray()),
                    "Bitcoin V2 public key mismatch");
            byte[] hash = item.getSighash().toByteArray();
            require(hash.length == 32, "Bitcoin V2 sighash length invalid");
            byte[] signature = signer.sign(hash);
            require(signature != null && signature.length > 0,
                    "Bitcoin V2 signature empty");
            signatures.add(signature);
            publicKeys.add(expectedPublicKey);
        }

        Bitcoin.SigningOutput signed;
        try {
            signed = Bitcoin.SigningOutput.parseFrom(
                    compiler.compileWithSignatures(originalInput, signatures, publicKeys));
        } catch (Exception error) {
            throw new IllegalArgumentException("Bitcoin V2 signing envelope invalid", error);
        }
        require(signed.getError() == SigningError.OK,
                "Bitcoin V2 sign outer error: " + signed.getError());
        require(signed.hasSigningResultV2(), "Bitcoin V2 sign V2 result missing");
        BitcoinV2.SigningOutput nestedSigned = signed.getSigningResultV2();
        require(nestedSigned.getError() == SigningError.OK,
                "Bitcoin V2 sign V2 error: " + nestedSigned.getError() + " "
                        + nestedSigned.getErrorMessage());
        byte[] encoded = nestedSigned.getEncoded().toByteArray();
        require(encoded.length > 0, "Bitcoin V2 encoded transaction empty");
        return encoded;
    }
}
