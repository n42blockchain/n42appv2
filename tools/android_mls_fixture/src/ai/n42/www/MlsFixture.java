package ai.n42.www;

import java.nio.ByteBuffer;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.io.IOException;
import java.util.Arrays;

/** Synthetic, account-free JNI protocol fixture. Run only on an isolated Android device. */
public final class MlsFixture {
    private static byte[] bytes(String value) {
        return value.getBytes(StandardCharsets.UTF_8);
    }

    private static void check(boolean condition, String label) {
        if (!condition) throw new AssertionError(label);
        System.out.println("PASS " + label);
    }

    public static void main(String[] args) {
        MlsNativeBridge bridge = new MlsNativeBridge();
        String architecture = System.getProperty("os.arch");
        System.out.println("PROCESS_ARCH " + architecture);
        check("aarch64".equals(architecture), "arm64-process");
        String library = System.getenv("N42_MLS_FIXTURE_LIBRARY");
        try {
            boolean mapped = false;
            for (String line : Files.readAllLines(Paths.get("/proc/self/maps"))) {
                if (line.contains(library)) {
                    System.out.println("LOADED_MAP " + line);
                    mapped = true;
                    break;
                }
            }
            check(mapped, "mapped-selected-library");
        } catch (IOException error) {
            throw new AssertionError("Cannot inspect process mapping", error);
        }
        byte[] group = bytes("synthetic-mls-room");
        long alice = bridge.nativeCreateEngine(bytes("synthetic-alice"));
        long bob = bridge.nativeCreateEngine(bytes("synthetic-bob"));
        check(alice != 0 && bob != 0, "engine");
        try {
            byte[] keyPackage = bridge.nativeGenerateKeyPackage(bob);
            check(keyPackage != null && keyPackage.length > 0, "key-package");
            check(bridge.nativeCreateGroup(alice, group) == 0, "create-group");
            byte[] pair = bridge.nativeAddMember(alice, group, keyPackage);
            check(pair != null && pair.length > 4, "add-member");
            int commitLength = ByteBuffer.wrap(pair, 0, 4).getInt();
            check(commitLength > 0 && commitLength < pair.length - 4, "pair-format");
            byte[] welcome = Arrays.copyOfRange(pair, 4 + commitLength, pair.length);
            check(Arrays.equals(group, bridge.nativeProcessWelcome(bob, welcome)), "welcome");
            byte[] first = bytes("hello synthetic bob");
            byte[] ciphertext = bridge.nativeEncrypt(alice, group, first);
            check(ciphertext != null && ciphertext.length > 0, "encrypt");
            check(Arrays.equals(first, bridge.nativeDecrypt(bob, group, ciphertext)), "decrypt");
            byte[] reply = bytes("hello synthetic alice");
            check(Arrays.equals(reply, bridge.nativeDecrypt(alice, group,
                    bridge.nativeEncrypt(bob, group, reply))), "reverse-roundtrip");
            byte[] update = bridge.nativeSelfUpdate(alice, group);
            check(update != null && update.length > 0, "self-update");
            check(bridge.nativeProcessCommit(bob, group, update) == 0, "process-commit");
            byte[] after = bytes("after synthetic rotation");
            check(Arrays.equals(after, bridge.nativeDecrypt(bob, group,
                    bridge.nativeEncrypt(alice, group, after))), "post-update-roundtrip");
            check(bridge.nativeEncrypt(alice, bytes("missing-group"), first) == null,
                    "unknown-group-rejected");
            check(bridge.nativeRemoveMember(alice, group, -1) == null,
                    "negative-leaf-rejected");
            check(bridge.nativeProcessCommit(bob, group, bytes("invalid-commit")) != 0,
                    "invalid-commit-rejected");
            System.out.println("MLS_FIXTURE_PASS");
        } finally {
            bridge.nativeFreeEngine(bob);
            bridge.nativeFreeEngine(alice);
        }
    }
}
