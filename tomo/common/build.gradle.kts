dependencies {
    implementation(project(":contract"))

    // 번들 그룹 활용
    implementation(libs.bundles.webflux.common)
    implementation(libs.kotlinx.datetime)
    implementation(libs.spring.boot.starter.test)
    implementation(libs.spring.boot.starter.security)
    implementation(libs.spring.security.test)
    implementation(libs.spring.boot.starter.oauth2.resource.server)

    // 테스트 의존성 정리
    testImplementation(libs.bundles.testing.core)
    testImplementation(libs.mockk)
}
