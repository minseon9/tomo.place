dependencies {
    implementation(project(":common"))
    implementation(project(":contract"))
    implementation(project(":identity"))
    implementation("org.springframework.boot:spring-boot-starter-actuator")
    implementation("org.springframework.boot:spring-boot-starter-security")
    // Spring Cloud OpenFeign
//    implementation("org.springframework.cloud:spring-cloud-starter-openfeign")
    developmentOnly("org.springframework.boot:spring-boot-devtools")
    testImplementation("org.springframework.security:spring-security-test")
}

tasks.bootJar {
    enabled = true
    archiveClassifier = "" // 기본 jar로 설정
}
