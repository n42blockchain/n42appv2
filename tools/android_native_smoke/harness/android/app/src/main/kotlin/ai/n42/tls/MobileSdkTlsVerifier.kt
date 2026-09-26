package ai.n42.tls

import android.content.Context

class MobileSdkTlsVerifier {
    fun initialize(context: Context): Boolean {
        Class.forName("org.rustls.platformverifier.CertificateVerifier", false, context.classLoader)
        return initializeNative(context.applicationContext)
    }

    private external fun initializeNative(context: Context): Boolean
}
