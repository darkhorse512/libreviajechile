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

    // Algunos plugins (p. ej. flutter_plugin_android_lifecycle, dep. de
    // file_picker e image_picker) exigen compileSdk 36. Los módulos de plugin
    // se compilan por defecto contra flutter.compileSdkVersion (34), lo que
    // rompe la verificación de metadatos AAR. Forzamos compileSdk 36 en todos
    // los subproyectos Android. (Debe registrarse ANTES de evaluationDependsOn,
    // que evalúa los proyectos de forma anticipada.)
    afterEvaluate {
        val androidExt = project.extensions.findByName("android") ?: return@afterEvaluate
        val setter = androidExt.javaClass.methods.firstOrNull { m ->
            (m.name == "setCompileSdkVersion" || m.name == "setCompileSdk") &&
                m.parameterTypes.size == 1 &&
                (m.parameterTypes[0] == Int::class.javaPrimitiveType ||
                    m.parameterTypes[0] == Integer::class.java)
        }
        try {
            setter?.invoke(androidExt, 36)
        } catch (_: Exception) {
        }
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
