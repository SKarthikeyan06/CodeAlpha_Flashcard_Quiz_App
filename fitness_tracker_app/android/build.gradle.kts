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
    if (subproject.state.executed) {
        if (subproject.plugins.hasPlugin("com.android.application") ||
            subproject.plugins.hasPlugin("com.android.library")) {
            val android = subproject.extensions.findByName("android") as? com.android.build.gradle.BaseExtension
            android?.compileSdkVersion(36)
        }
    } else {
        subproject.afterEvaluate {
            if (subproject.plugins.hasPlugin("com.android.application") ||
                subproject.plugins.hasPlugin("com.android.library")) {
                val android = subproject.extensions.findByName("android") as? com.android.build.gradle.BaseExtension
                android?.compileSdkVersion(36)
            }
        }
    }
}
