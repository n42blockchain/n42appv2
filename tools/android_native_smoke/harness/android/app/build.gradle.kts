plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.n42.android_native_smoke"
    compileSdk = 37
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.n42.android_native_smoke"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 26
        targetSdk = 37
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

val legacyBouncy = System.getenv("N42_SMOKE_BC_LEGACY") == "1"
if (!legacyBouncy) {
    configurations.configureEach {
        exclude(group = "org.bouncycastle", module = "bcprov-jdk15on")
    }
}

dependencies {
    // The seed run reproduces sqflite_sqlcipher's published 4.10.0 AAR.
    // The verification run uses the host's 4.19.0 AAR and the same app data.
    implementation("net.zetetic:sqlcipher-android:${System.getenv("N42_SMOKE_SQLCIPHER_AAR") ?: "4.19.0"}@aar")
    implementation("androidx.sqlite:sqlite:2.7.1")
    implementation(platform("com.fasterxml.jackson:jackson-bom:2.22.3"))
    implementation("org.web3j:core:4.8.8-android")
    implementation("org.torusresearch:torus-utils-java:4.0.3")
    if (legacyBouncy) {
        implementation("org.bouncycastle:bcprov-jdk15on:1.68")
    } else {
        implementation("org.bouncycastle:bcprov-jdk15to18:1.86")
    }
    implementation("org.java-websocket:Java-WebSocket:1.6.0")
    implementation("com.google.protobuf:protobuf-javalite:4.36.2")
    implementation("com.android.billingclient:billing:9.1.0")
}
