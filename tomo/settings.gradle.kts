rootProject.name = "tomo"

rootDir.listFiles()
    ?.filter {
        it.isDirectory &&
            it.name != "buildSrc" && // Gradle 예약 디렉토리: 서브프로젝트로 포함 금지
            File(it, "build.gradle.kts").exists()
    }
    ?.forEach { include(it.name) }
