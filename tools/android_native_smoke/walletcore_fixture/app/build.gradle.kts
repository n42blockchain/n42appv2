plugins {
    id("com.android.application")
}

val fixturePhase = providers.gradleProperty("walletCoreFixturePhase").get()
require(fixturePhase in setOf("baseline", "candidate")) { "Unexpected fixture phase" }
val fixtureAar = providers.gradleProperty("walletCoreFixtureAar").get()
val fixtureProto = providers.gradleProperty("walletCoreFixtureProto").get()
val fixtureJavalite = providers.gradleProperty("walletCoreFixtureJavalite").get()
val fixtureBuildRoot = providers.gradleProperty("walletCoreFixtureBuildRoot").get()
val fixtureKeystore = providers.gradleProperty("walletCoreFixtureKeystore").get()

layout.buildDirectory.set(file("$fixtureBuildRoot/app"))

android {
    namespace = "ai.n42.fixture.walletcore"
    compileSdk = 37
    defaultConfig {
        applicationId = "ai.n42.fixture.walletcore.$fixturePhase"
        minSdk = 26
        targetSdk = 37
        ndk { abiFilters += "arm64-v8a" }
    }
    packaging { jniLibs.useLegacyPackaging = false }
    lint { checkReleaseBuilds = false }
    signingConfigs.create("fixture") {
        storeFile = file(fixtureKeystore)
        storePassword = "synthetic-only"
        keyAlias = "fixture"
        keyPassword = "synthetic-only"
    }
    buildTypes.getByName("release").signingConfig = signingConfigs.getByName("fixture")
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
}

dependencies {
    implementation(files(fixtureAar))
    implementation(files(fixtureProto))
    implementation(files(fixtureJavalite))
}
