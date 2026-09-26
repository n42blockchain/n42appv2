package com.n42.android_native_smoke

// Fixture-only independent blst implementation. Never packaged in the app.
object BlsOracle {
    init { System.loadLibrary("n42_bls_fixture_oracle") }

    @JvmStatic external fun verifyPair(secretHex: String, publicHex: String): Boolean
}
