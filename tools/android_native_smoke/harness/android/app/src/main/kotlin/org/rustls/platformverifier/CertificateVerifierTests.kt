package org.rustls.platformverifier

import android.content.Context

// The supplier's ffi-testing feature exports these JNI test entries only in
// the isolated fixture build. They are absent from the production SDK.
object CertificateVerifierTests {
    @JvmStatic external fun mockTests(context: Context): String
    @JvmStatic external fun verifyMockRootUsage(context: Context): String
}
