dependencies {
    implementation(project(":contract"))

    // 번들 그룹 활용
    implementation(libs.bundles.webflux.common)
    implementation(libs.spring.context)
    implementation(libs.kotlinx.datetime)
    
    // 테스트 의존성 정리
    testImplementation(libs.bundles.testing.core)
    testImplementation(libs.mockk)
}
