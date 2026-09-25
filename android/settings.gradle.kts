pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.13.2" apply false
    id("org.jetbrains.kotlin.android") version "2.4.20" apply false
    id("org.gradle.toolchains.foojay-resolver-convention") version "1.0.0"
}

include(":app")

// flutter_mining 插件的本地 AAR 桥接模块（避免 library 项目不能直接依赖 local .aar 的限制）
include(":mobile-sdk-module")
project(":mobile-sdk-module").projectDir =
    file("../plugins/flutter_mining/android/mobile-sdk-module")
include(":evm-module")
project(":evm-module").projectDir =
    file("../plugins/flutter_mining/android/evm-module")

// 为缺少 namespace 的第三方插件自动设置 namespace
gradle.beforeProject {
    if (project.name != "app" && project.name != rootProject.name) {
        project.afterEvaluate {
            val android = project.extensions.findByName("android")
            if (android is com.android.build.gradle.LibraryExtension) {
                // Some Flutter plugins pin API 31/33 below their AndroidX dependencies' API floor.
                val compileSdkApi = android.compileSdkVersion
                    ?.removePrefix("android-")
                    ?.substringBefore('.')
                    ?.toIntOrNull()
                if (compileSdkApi == null || compileSdkApi < 36) {
                    android.compileSdkVersion(36)
                }
                if (android.namespace.isNullOrEmpty()) {
                    val manifestFile = project.file("src/main/AndroidManifest.xml")
                    if (manifestFile.exists()) {
                        val content = manifestFile.readText()
                        val regex = """package\s*=\s*["']([^"']+)["']""".toRegex()
                        val match = regex.find(content)
                        if (match != null) {
                            android.namespace = match.groupValues[1]
                        }
                    }
                }
            }
        }
    }
}
