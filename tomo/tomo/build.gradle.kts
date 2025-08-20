dependencies {
    implementation(project(":common"))
    implementation(project(":contract"))
    implementation(project(":auth"))
    implementation(project(":user"))

    tomoDependencies()
    developmentDependencies()
}

tasks.bootJar {
    enabled = true
    archiveClassifier = "" // 기본 jar로 설정
}
