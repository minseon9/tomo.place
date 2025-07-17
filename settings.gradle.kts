rootProject.name = "mapa"

rootDir.listFiles().filter { it.isDirectory && (File(it, "build.gradle.kts").exists()) }.forEach {
    include(it.name)
}
