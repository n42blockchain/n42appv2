allprojects {
    repositories {
        // Only the maintained verification phase selects the task-owned 4.19 AAR.
        if (System.getenv("N42_SMOKE_SQLCIPHER_MAINTAINED") == "1") {
            exclusiveContent {
                forRepository {
                    maven {
                        url = uri(rootProject.file("../../../../android/native/sqlcipher_android/maven"))
                    }
                }
                filter {
                    includeVersion("net.zetetic", "sqlcipher-android", "4.19.0")
                }
            }
        }
        google()
        mavenCentral()
        maven {
            url = uri("https://jitpack.io")
            content {
                includeGroup("org.torusresearch")
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
