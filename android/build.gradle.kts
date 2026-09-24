plugins {
    id("com.google.gms.google-services") version "4.4.3" apply false
}

allprojects {
    repositories {
        google()
        mavenCentral()
        // ✅ TrustWallet 私有仓库 (需要 GitHub 认证)
        maven {
            url = uri("https://maven.pkg.github.com/trustwallet/wallet-core")
            content {
                includeGroup("com.trustwallet")
            }
            val props = java.util.Properties()
            val localPropertiesFile = rootProject.file("local.properties")
            if (localPropertiesFile.exists()) {
                localPropertiesFile.inputStream().use { props.load(it) }
            }
            credentials {
                username = System.getenv("WALLET_CORE_USER") ?: props.getProperty("wallet_core.user")
                password = System.getenv("WALLET_CORE_KEY") ?: props.getProperty("wallet_core.key")
            }
        }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
