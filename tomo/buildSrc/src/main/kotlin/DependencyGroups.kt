import org.gradle.kotlin.dsl.DependencyHandlerScope

/**
 * 개발/운영 환경 기본 의존성
 */
fun DependencyHandlerScope.productionDependencies() {
    "implementation"("org.jetbrains.kotlin:kotlin-reflect")
    "implementation"("org.jetbrains.kotlin:kotlin-stdlib")
    "implementation"("org.springframework.boot:spring-boot-starter")
    "implementation"("org.springframework.boot:spring-boot-starter-web")
    "implementation"("org.springframework.boot:spring-boot-starter-web-services")
    "implementation"("org.springframework.boot:spring-boot-starter-security")
    "implementation"("org.springframework.boot:spring-boot-starter-data-jpa")
    "implementation"("org.springframework.boot:spring-boot-starter-validation")
    "runtimeOnly"("org.postgresql:postgresql")
}

/**
 * 개발 전용 의존성
 */
fun DependencyHandlerScope.developmentDependencies() {
    "developmentOnly"("org.springframework.boot:spring-boot-devtools")
}

/**
 * 테스트 의존성
 */
fun DependencyHandlerScope.testDependencies() {
    "testImplementation"("org.springframework.boot:spring-boot-starter-data-jpa")
    "testImplementation"("org.springframework.boot:spring-boot-starter-test")
    "testImplementation"("org.springframework.security:spring-security-test")
    "testImplementation"("org.jetbrains.kotlin:kotlin-test-junit5")
    "testImplementation"("io.mockk:mockk:1.13.11")
    "testImplementation"("org.mockito:mockito-core")
    "testImplementation"("org.mockito:mockito-junit-jupiter")
    "testImplementation"("com.h2database:h2")
    "testImplementation"("net.datafaker:datafaker:2.0.1")
    "testRuntimeOnly"("org.junit.platform:junit-platform-launcher")
}

/**
 * Auth 모듈 전용 의존성
 */
fun DependencyHandlerScope.authDependencies() {
    "implementation"("org.springframework.boot:spring-boot-starter-webflux")
    "implementation"("org.springframework.boot:spring-boot-starter-oauth2-client")
    "implementation"("org.springframework.boot:spring-boot-starter-cache")
    "implementation"("org.springframework.boot:spring-boot-starter-aop")
    "implementation"("com.github.ben-manes.caffeine:caffeine")
    "implementation"("io.github.resilience4j:resilience4j-spring-boot3:2.2.0")
    
    // JWT
    "implementation"("io.jsonwebtoken:jjwt-api:0.12.5")
    "runtimeOnly"("io.jsonwebtoken:jjwt-impl:0.12.5")
    "runtimeOnly"("io.jsonwebtoken:jjwt-jackson:0.12.5")
    
    // Coroutines
    "implementation"("org.jetbrains.kotlinx:kotlinx-coroutines-core")
    "implementation"("org.jetbrains.kotlinx:kotlinx-coroutines-reactor")
}

/**
 * Tomo 모듈 전용 의존성
 */
fun DependencyHandlerScope.tomoDependencies() {
    "implementation"("org.springframework.boot:spring-boot-starter-actuator")
    "implementation"("org.springframework.boot:spring-boot-starter-webflux")
    "implementation"("org.springframework.boot:spring-boot-starter-cache")
    "implementation"("com.github.ben-manes.caffeine:caffeine")
    "implementation"("io.netty:netty-all")
    "implementation"("org.jetbrains.kotlinx:kotlinx-coroutines-reactor")
}

/**
 * Common 모듈 전용 의존성
 */
fun DependencyHandlerScope.commonDependencies() {
    "implementation"("org.springframework.boot:spring-boot-starter-webflux")
    "implementation"("org.springframework:spring-context")
    "implementation"("org.jetbrains.kotlinx:kotlinx-coroutines-reactor")
    "implementation"("org.jetbrains.kotlinx:kotlinx-datetime:0.7.1")
    "implementation"("org.springframework.boot:spring-boot-starter-test")
    "implementation"("io.mockk:mockk:1.13.11")
    
    // 테스트용 Security 의존성
    "testImplementation"("org.springframework.security:spring-security-test")
    "testImplementation"("org.springframework.boot:spring-boot-starter-security")
}

/**
 * User 모듈 전용 의존성 (기본 의존성만 사용)
 */
fun DependencyHandlerScope.userDependencies() {
    // User 모듈은 기본 의존성만 사용 (추가 의존성 없음)
}

/**
 * Liquibase 런타임 의존성
 */
fun DependencyHandlerScope.liquibaseDependencies() {
    "liquibaseRuntime"("org.springframework.boot:spring-boot-starter-data-jpa")
    "liquibaseRuntime"("org.springframework:spring-context")
    "liquibaseRuntime"("org.liquibase:liquibase-core")
    "liquibaseRuntime"("org.liquibase.ext:liquibase-hibernate6:4.33.0")
    "liquibaseRuntime"("org.postgresql:postgresql")
    "liquibaseRuntime"("info.picocli:picocli:4.7.5")
}
