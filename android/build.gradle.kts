



val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

buildscript {
    dependencies {
        classpath("com.google.gms:google-services:4.4.0") // or latest


        classpath("com.android.tools.build:gradle:8.7.3")
        classpath("com.google.gms:google-services:4.3.15")
// ✅ latest version
    }
}

plugins {
    id("com.android.application") version "8.7.3" apply false

    id("com.google.gms.google-services") version "4.3.15" apply false // ✅ here too
}


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
