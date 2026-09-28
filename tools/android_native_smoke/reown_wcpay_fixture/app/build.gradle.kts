import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
}

kotlin { compilerOptions { jvmTarget.set(JvmTarget.JVM_17) } }

val fixtureAppId = providers.gradleProperty("reownFixtureAppId").orNull
    ?: error("-PreownFixtureAppId is required")
val fixtureAar = providers.gradleProperty("reownFixtureAar").orNull
val mismatchInput = providers.gradleProperty("reownFixtureMismatchDir").orNull
require((fixtureAar == null) != (mismatchInput == null)) {
    "Provide exactly one of -PreownFixtureAar or -PreownFixtureMismatchDir"
}

android {
    namespace = "ai.n42.fixture.reown"
    compileSdk = 37
    defaultConfig {
        applicationId = fixtureAppId
        minSdk = 26
        targetSdk = 37
        ndk { abiFilters += "arm64-v8a" }
    }
    packaging { jniLibs.useLegacyPackaging = false }
    buildTypes.getByName("release").signingConfig = signingConfigs.getByName("debug")
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    if (mismatchInput != null) {
        sourceSets.getByName("main").java.srcDir("$mismatchInput/bindings")
        sourceSets.getByName("main").jniLibs.srcDir("$mismatchInput/jni")
    }
}

dependencies {
    if (fixtureAar != null) implementation(files(fixtureAar))
    implementation("net.java.dev.jna:jna:5.17.0@aar")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.7.1")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.1")
}
