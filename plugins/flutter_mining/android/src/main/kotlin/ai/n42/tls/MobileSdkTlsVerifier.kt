package ai.n42.tls

import android.content.Context

/** Binds Android's certificate verifier to the verifier inside libmobile_sdk.so. */
class MobileSdkTlsVerifier {
    fun initialize(context: Context): Boolean {
        Class.forName("org.rustls.platformverifier.CertificateVerifier", false, context.classLoader)
        return initializeNative(context)
    }

    private external fun initializeNative(context: Context): Boolean
}
