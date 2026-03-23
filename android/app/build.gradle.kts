import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.reader(Charsets.UTF_8).use { reader ->
        keystoreProperties.load(reader)
    }
}

val localConfigProperties = Properties()
val localConfigPropertiesFile = rootProject.file("local.properties")
if (localConfigPropertiesFile.exists()) {
    localConfigPropertiesFile.reader(Charsets.UTF_8).use { reader ->
        localConfigProperties.load(reader)
    }
}

fun readConfigValue(name: String, defaultValue: String = ""): String {
    val gradleValue = providers.gradleProperty(name).orNull
    val localValue = localConfigProperties.getProperty(name)
    val envValue = System.getenv(name)
    return gradleValue ?: localValue ?: envValue ?: defaultValue
}

fun escapeResValue(value: String): String {
    return value
        .replace("\\", "\\\\")
        .replace("\"", "\\\"")
}

android {
    namespace = "ai.n42.www"
    // Google Play 2026 要求: compileSdk 36, targetSdk 35 (Android 15)
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        //coreLibraryDesugaringEnabled true
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_21
        targetCompatibility = JavaVersion.VERSION_21
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_21.toString()
    }

    sourceSets {
        getByName("main").java.srcDirs("src/main/kotlin")
    }

    defaultConfig {
        applicationId = "ai.n42.www"
        // Google Play 要求: minSdk 24 (Android 7.0), targetSdk 35 (Android 15)
        minSdk = 24
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        // 多 DEX 支持
        multiDexEnabled = true
        externalNativeBuild {
            cmake {
                // 允许 flexible page sizes
                arguments += listOf("-DANDROID_SUPPORT_FLEXIBLE_PAGE_SIZES=ON")
            }
        }
        resValue(
            "string",
            "n42_chat_google_client_id",
            escapeResValue(readConfigValue("N42_CHAT_GOOGLE_CLIENT_ID"))
        )
        resValue(
            "string",
            "n42_chat_google_server_client_id",
            escapeResValue(readConfigValue("N42_CHAT_GOOGLE_SERVER_CLIENT_ID"))
        )
        resValue(
            "string",
            "n42_chat_twitter_api_key",
            escapeResValue(readConfigValue("N42_CHAT_TWITTER_API_KEY"))
        )
        resValue(
            "string",
            "n42_chat_twitter_api_secret",
            escapeResValue(readConfigValue("N42_CHAT_TWITTER_API_SECRET"))
        )
        resValue(
            "string",
            "n42_chat_twitter_redirect_uri",
            escapeResValue(readConfigValue("N42_CHAT_TWITTER_REDIRECT_URI", "n42://auth/twitter"))
        )
        resValue(
            "string",
            "n42_chat_wechat_app_id",
            escapeResValue(readConfigValue("N42_CHAT_WECHAT_APP_ID"))
        )
        resValue(
            "string",
            "n42_chat_wechat_universal_link",
            escapeResValue(readConfigValue("N42_CHAT_WECHAT_UNIVERSAL_LINK"))
        )
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = keystoreProperties["storeFile"]?.let { file(it as String) }
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            // 启用代码混淆和资源压缩以提高安全性
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            ndk {
                debugSymbolLevel = "FULL"
                abiFilters += listOf("armeabi-v7a", "arm64-v8a", "x86_64", "x86")
            }
        }

        getByName("debug") {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }

    lint {
        checkReleaseBuilds = false
        disable.add("InvalidPackage")
    }

    packaging {
        resources {
            // 指定不压缩的文件
            excludes += setOf("!Regula/faceSdkResource.dat")
        }
    }
}

dependencies {
    // ✅ 加入 desugar_jdk_libs，解决 flutter_local_notifications 的需求
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    implementation("com.trustwallet:wallet-core:4.6.0")
    implementation("androidx.appcompat:appcompat:1.6.1")
    implementation("com.google.android.material:material:1.9.0")
    implementation("com.squareup.okhttp3:okhttp:4.11.0")
    // compileOnly：仅供编译期使用，运行时由 flutter_mining 插件的 mobile-sdk-release.aar 提供，避免 duplicate class 冲突
    compileOnly(files("libs/mobile-sdk-android.aar"))
    // compileOnly：仅供编译期，运行时由 flutter_mining 插件的 evm-module 提供
    compileOnly(files("libs/evm.aar"))
}

flutter {
    source = "../.."
}
