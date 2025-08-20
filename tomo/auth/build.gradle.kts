dependencies {
    implementation(project(":contract"))
    implementation(project(":common"))

    // Auth 모듈 전용 의존성
    authDependencies()
}
