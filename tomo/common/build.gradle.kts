dependencies {
    implementation(project(":contract"))
    implementation("org.springframework.boot:spring-boot-starter-webflux")
    implementation("org.springframework:spring-context")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-reactor")
    implementation("org.jetbrains.kotlinx:kotlinx-datetime:0.7.1")
    implementation("org.springframework.boot:spring-boot-starter-test")
    implementation("io.mockk:mockk:1.13.11")

    // 테스트용 Security 의존성 추가
    testImplementation("org.springframework.security:spring-security-test")
    testImplementation("org.springframework.boot:spring-boot-starter-security")
}
