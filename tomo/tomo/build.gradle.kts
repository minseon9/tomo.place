dependencies {
    implementation(project(":common"))
    implementation(project(":contract"))
    implementation(project(":auth"))
    implementation(project(":user"))
    
    // Tomo 모듈 전용 의존성
    tomoDependencies()
    
    // 개발 전용 의존성
    developmentDependencies()
}

tasks.bootJar {
    enabled = true
    archiveClassifier = "" // 기본 jar로 설정
}
