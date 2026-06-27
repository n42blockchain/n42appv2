package ai.n42.www

internal object MlsNativeBridge {
    private val loadError: Throwable? = runCatching {
        System.loadLibrary("n42_mls")
    }.exceptionOrNull()

    val isLoaded: Boolean
        get() = loadError == null

    val errorMessage: String?
        get() = loadError?.message

    external fun nativeCreateEngine(identity: ByteArray): Long
    external fun nativeFreeEngine(handle: Long)
    external fun nativeGenerateKeyPackage(handle: Long): ByteArray?
    external fun nativeCreateGroup(handle: Long, groupId: ByteArray): Int
    external fun nativeAddMember(
        handle: Long,
        groupId: ByteArray,
        keyPackage: ByteArray,
    ): ByteArray?
    external fun nativeRemoveMember(
        handle: Long,
        groupId: ByteArray,
        leafIndex: Int,
    ): ByteArray?
    external fun nativeProcessCommit(
        handle: Long,
        groupId: ByteArray,
        commit: ByteArray,
    ): Int
    external fun nativeProcessWelcome(handle: Long, welcome: ByteArray): ByteArray?
    external fun nativeEncrypt(
        handle: Long,
        groupId: ByteArray,
        plaintext: ByteArray,
    ): ByteArray?
    external fun nativeDecrypt(
        handle: Long,
        groupId: ByteArray,
        ciphertext: ByteArray,
    ): ByteArray?
    external fun nativeSelfUpdate(handle: Long, groupId: ByteArray): ByteArray?
}
