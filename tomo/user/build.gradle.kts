dependencies {
    implementation(project(":contract"))
    implementation(project(":common"))
    
    // User 모듈 전용 의존성
    userDependencies()
}
