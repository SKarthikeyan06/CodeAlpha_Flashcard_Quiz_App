allprojects {
    repositories {
        google()
        mavenCentral()
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

subprojects {
    val subproject = this
    val configureLibrary = {
        if (subproject.plugins.hasPlugin("com.android.library")) {
            subproject.configure<com.android.build.gradle.LibraryExtension> {
                compileSdk = 36
            }
        }
    }
    if (subproject.state.executed) {
        configureLibrary()
    } else {
        subproject.afterEvaluate {
            configureLibrary()
        }
    }
}
