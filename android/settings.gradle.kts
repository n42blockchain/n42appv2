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
    id("com.android.application") version "8.9.1" apply false
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
    id("org.gradle.toolchains.foojay-resolver-convention") version "0.8.0"
}

include(":app")

// 为缺少 namespace 的第三方插件自动设置 namespace
gradle.beforeProject {
    if (project.name != "app" && project.name != rootProject.name) {
        project.afterEvaluate {
            val android = project.extensions.findByName("android")
            if (android is com.android.build.gradle.LibraryExtension) {
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
 