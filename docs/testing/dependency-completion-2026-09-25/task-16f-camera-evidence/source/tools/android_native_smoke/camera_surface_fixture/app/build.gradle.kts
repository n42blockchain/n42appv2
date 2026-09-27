plugins {
    id("com.android.application")
}

val cameraAar = providers.gradleProperty("cameraFixtureAar")
    .orNull ?: error("-PcameraFixtureAar is required")
val fixtureAppId = providers.gradleProperty("cameraFixtureAppId")
    .orNull ?: error("-PcameraFixtureAppId is required")

android {
    namespace = "ai.n42.fixture.camera"
    compileSdk = 37
    defaultConfig {
        applicationId = fixtureAppId
        minSdk = 23
        targetSdk = 37
    }
    packaging {
        jniLibs.useLegacyPackaging = false
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
}

dependencies {
    implementation(files(cameraAar))
}
