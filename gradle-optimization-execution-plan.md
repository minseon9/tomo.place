# Execution Plan

## Requested Task
1. `allprojects`에 공통 Java/Kotlin 설정 이동
2. 의존성 관리 개선
   - 번들 그룹 더 적극적 활용
   - 프로젝트별 특화 의존성 분리

## Identified Context
- Gradle 8.14.2 멀티프로젝트 환경 (6개 서브프로젝트: auth, user, common, contract, tomo, build-logic)
- **build-logic 마이그레이션 완료**: buildSrc → build-logic으로 Convention Plugin 기반 마이그레이션 완료
- **Convention Plugin 적용**: test-convention, liquibase-convention이 subprojects에 적용됨
- **build-logic 제외 처리 완료**: settings.gradle.kts에서 build-logic이 이미 제외되어 있음
- 현재 `subprojects` 블록에 Java/Kotlin 설정이 모든 서브프로젝트에 중복 적용
- `libs.versions.toml`에 번들 그룹이 일부 정의되어 있으나 충분히 활용되지 않음
- `tomo` 모듈은 실행 가능한 JAR이므로 `bootJar { enabled = true }` 필요
- 각 서브프로젝트별로 중복된 의존성 패턴 존재

## Execution Plan

### 1. Java/Kotlin 설정을 allprojects로 이동

**현재 상태 (tomo/build.gradle.kts):**
```kotlin
subprojects {
    apply(plugin = "kotlin")
    apply(plugin = "kotlin-spring")
    apply(plugin = "kotlin-jpa")
    apply(plugin = "org.springframework.boot")
    apply(plugin = "io.spring.dependency-management")

    apply(plugin = "place.tomo.gradle.test-convention")
    apply(plugin = "place.tomo.gradle.liquibase-convention")

    java {
        toolchain {
            languageVersion = JavaLanguageVersion.of(21)
        }
    }

    kotlin {
        compilerOptions {
            freeCompilerArgs.addAll("-Xjsr305=strict")
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_21)
        }
    }
    
    // 태스크 및 의존성 설정...
}
```

**개선 후:**
```kotlin
allprojects {
    group = "place.tomo"
    version = "1.0.0-SNAPSHOT"

    repositories {
        mavenCentral()
    }

    // 공통 Java/Kotlin 설정을 allprojects로 이동
    apply(plugin = "kotlin")
    
    java {
        toolchain {
            languageVersion = JavaLanguageVersion.of(21)
        }
    }

    kotlin {
        compilerOptions {
            freeCompilerArgs.addAll("-Xjsr305=strict")
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_21)
        }
    }
}

subprojects {
    // Spring 관련 플러그인과 Convention Plugin만 유지
    apply(plugin = "kotlin-spring")
    apply(plugin = "kotlin-jpa")
    apply(plugin = "org.springframework.boot")
    apply(plugin = "io.spring.dependency-management")

    apply(plugin = "place.tomo.gradle.test-convention")
    apply(plugin = "place.tomo.gradle.liquibase-convention")

    // 기본적으로 모든 서브프로젝트는 라이브러리 JAR
    tasks.getByName<org.springframework.boot.gradle.tasks.bundling.BootJar>("bootJar") {
        enabled = false
    }

    tasks.getByName<Jar>("jar") {
        enabled = true
    }
    
    // 나머지 설정들...
}
```

### 2. 번들 그룹 확장 및 개선

**현재 libs.versions.toml의 번들 분석:**
- `kotlin-basic`: kotlin-reflect, kotlin-stdlib
- `spring-boot-core`: starter, web, validation, security
- `spring-boot-web-services`: web-services
- `spring-boot-data`: data-jpa
- `testing-core`: test, security-test, kotlin-test-junit5
- `testing-mock`: mockk, mockito-core, mockito-junit-jupiter
- `testing-utils`: h2, datafaker
- `kotlinx-coroutines`: core, reactor

**추가할 번들 그룹:**
```toml
# auth 모듈용 번들
auth-core = [
    "spring-boot-starter-webflux",
    "spring-boot-starter-oauth2-client",
    "spring-boot-starter-cache",
    "spring-boot-starter-aop",
    "caffeine",
    "resilience4j-spring-boot3"
]

# JWT 번들 (이미 정의되어 있지만 사용되지 않음)
jwt = [
    "jjwt-api",
    "jjwt-impl", 
    "jjwt-jackson"
]

# 공통 WebFlux 번들
webflux-common = [
    "spring-boot-starter-webflux",
    "kotlinx-coroutines-reactor"
]

# 실행 애플리케이션용 번들
app-runtime = [
    "spring-boot-starter-actuator",
    "spring-boot-starter-cache",
    "caffeine",
    "netty-all"
]
```

### 3. 프로젝트별 특화 의존성 분리

**현재 각 모듈별 의존성 패턴:**

#### auth 모듈 (현재):
```kotlin
dependencies {
    implementation(project(":contract"))
    implementation(project(":common"))

    implementation(libs.spring.boot.starter.webflux)
    implementation(libs.spring.boot.starter.oauth2.client)
    implementation(libs.spring.boot.starter.cache)
    implementation(libs.spring.boot.starter.aop)
    implementation(libs.caffeine)
    implementation(libs.resilience4j.spring.boot3)

    implementation(libs.jjwt.api)
    runtimeOnly(libs.jjwt.impl)
    runtimeOnly(libs.jjwt.jackson)

    implementation(libs.bundles.kotlinx.coroutines)
}
```

**개선 후 auth 모듈:**
```kotlin
dependencies {
    implementation(project(":contract"))
    implementation(project(":common"))

    // 번들 그룹 활용
    implementation(libs.bundles.auth.core)
    implementation(libs.bundles.jwt)
    runtimeOnly(libs.bundles.jwt.runtime)  // impl, jackson만 런타임
    implementation(libs.bundles.kotlinx.coroutines)
}
```

#### common 모듈 (현재):
```kotlin
dependencies {
    implementation(project(":contract"))

    implementation(libs.spring.boot.starter.webflux)
    implementation(libs.spring.context)
    implementation(libs.kotlinx.coroutines.reactor)
    implementation(libs.kotlinx.datetime)
    implementation(libs.spring.boot.starter.test)
    implementation(libs.mockk)

    testImplementation(libs.spring.security.test)
    testImplementation(libs.spring.boot.starter.security)
}
```

**개선 후 common 모듈:**
```kotlin
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
```

#### tomo 모듈 (현재):
```kotlin
dependencies {
    implementation(project(":common"))
    implementation(project(":contract"))
    implementation(project(":auth"))
    implementation(project(":user"))

    implementation(libs.spring.boot.starter.actuator)
    implementation(libs.spring.boot.starter.webflux)
    implementation(libs.spring.boot.starter.cache)
    implementation(libs.caffeine)
    implementation(libs.netty.all)
    implementation(libs.kotlinx.coroutines.reactor)

    developmentOnly(libs.spring.boot.devtools)
}

tasks.bootJar {
    enabled = true
    archiveClassifier = ""
}
```

**개선 후 tomo 모듈:**
```kotlin
dependencies {
    // 프로젝트 의존성
    implementation(project(":common"))
    implementation(project(":contract"))
    implementation(project(":auth"))
    implementation(project(":user"))

    // 번들 그룹 활용
    implementation(libs.bundles.app.runtime)
    implementation(libs.bundles.webflux.common)

    developmentOnly(libs.spring.boot.devtools)
}

tasks.bootJar {
    enabled = true
    archiveClassifier = ""
}
```

### 4. 공통 의존성을 subprojects로 이동

**루트 build.gradle.kts의 subprojects 블록 개선:**
```kotlin
subprojects {
    // Spring 관련 플러그인
    apply(plugin = "kotlin-spring")
    apply(plugin = "kotlin-jpa")
    apply(plugin = "org.springframework.boot")
    apply(plugin = "io.spring.dependency-management")

    // 기본 JAR 태스크 설정
    tasks.getByName<org.springframework.boot.gradle.tasks.bundling.BootJar>("bootJar") {
        enabled = false
    }
    tasks.getByName<Jar>("jar") {
        enabled = true
    }

    val libs = rootProject.libs
    dependencies {
        // 모든 서브프로젝트 공통 의존성
        implementation(libs.bundles.kotlin.basic)
        implementation(libs.bundles.spring.boot.core)
        implementation(libs.bundles.spring.boot.data)
        runtimeOnly(libs.postgresql)

        // 공통 테스트 의존성
        testImplementation(libs.bundles.testing.core)
        testImplementation(libs.bundles.testing.mock)
        testImplementation(libs.bundles.testing.utils)
        testRuntimeOnly(libs.junit.platform.launcher)
    }

    // Liquibase 설정 (기존 유지)
    val liquibaseEnabled: Boolean = (findProperty("liquibaseEnabled") as String?)?.toBoolean() == true
    if (liquibaseEnabled) {
        // ... 기존 Liquibase 설정
    }
}
```

## Progress Status
1. Java/Kotlin 설정을 allprojects로 이동 [Done]
2. 번들 그룹 확장 및 개선 [Done]
3. 프로젝트별 특화 의존성 분리 [Done]
4. 설정 검증 및 테스트 [Done]

## Suggested Next Tasks
- Convention Plugin을 통한 설정 표준화 완료
- 빌드 성능 최적화 (병렬 빌드, 캐시 활용)
- 프로젝트별 특화 플러그인 적용 (예: auth 모듈에만 OAuth 관련 설정)
- build-logic의 독립적 버전 관리 및 배포 가능성 검토
