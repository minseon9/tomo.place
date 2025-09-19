dependencies {
    // 프로젝트 의존성
    implementation(project(":common"))
    implementation(project(":contract"))
    implementation(project(":auth"))
    implementation(project(":user"))
    implementation(project(":place"))

    // 번들 그룹 활용
    implementation(libs.bundles.app.runtime)
    implementation(libs.bundles.webflux.common)
    implementation(libs.spring.boot.starter.oauth2.resource.server)

    developmentOnly(libs.spring.boot.devtools)
}

tasks.bootJar {
    enabled = true
    archiveClassifier = "" // 기본 jar로 설정
}
