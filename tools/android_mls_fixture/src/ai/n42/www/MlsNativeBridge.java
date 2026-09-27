package ai.n42.www;

final class MlsNativeBridge {
    static {
        String library = System.getenv("N42_MLS_FIXTURE_LIBRARY");
        if (library == null || !library.startsWith("/data/local/tmp/n42-mls-fixture/")) {
            throw new IllegalStateException("Fixture library path is required");
        }
        System.load(library);
    }

    native long nativeCreateEngine(byte[] identity);
    native void nativeFreeEngine(long handle);
    native byte[] nativeGenerateKeyPackage(long handle);
    native int nativeCreateGroup(long handle, byte[] groupId);
    native byte[] nativeAddMember(long handle, byte[] groupId, byte[] keyPackage);
    native byte[] nativeRemoveMember(long handle, byte[] groupId, int leafIndex);
    native int nativeProcessCommit(long handle, byte[] groupId, byte[] commit);
    native byte[] nativeProcessWelcome(long handle, byte[] welcome);
    native byte[] nativeEncrypt(long handle, byte[] groupId, byte[] plaintext);
    native byte[] nativeDecrypt(long handle, byte[] groupId, byte[] ciphertext);
    native byte[] nativeSelfUpdate(long handle, byte[] groupId);
}
