plugins {
    id("com.android.application") version "9.4.1" apply false
}

layout.buildDirectory.set(file(providers.gradleProperty("walletCoreFixtureBuildRoot").get() + "/root"))
