# Gradle 리팩토링 계획

## 개요
기존 Gradle 설정의 의존성 관리를 체계화하고 중복을 제거하여 유지보수성을 향상시키는 리팩토링 계획입니다.

## 목표
- 의존성 그룹화 및 중복 제거
- buildSrc를 통한 공통 로직 분리
- 버전 카탈로그 도입으로 중앙 집중식 버전 관리
- 기존 로직 보존하면서 구조 개선

## 작업 순서

### 1단계: 버전 카탈로그 생성

#### 1.1 gradle/libs.versions.toml 파일 생성
```toml
[versions]
spring-boot = "3.5.0"
spring-dependency-management = "1.1.7"
liquibase-gradle = "2.2.2"
kotlin = "2.1.21"
mockk = "1.13.11"
datafaker = "2.0.1"
liquibase-hibernate = "4.33.0"
picocli = "4.7.5"
caffeine = "3.1.8"
resilience4j = "2.2.0"
jjwt = "0.12.5"
kotlinx-datetime = "0.7.1"

[libraries]
# Spring Boot
spring-boot-starter = { module = "org.springframework.boot:spring-boot-starter" }
spring-boot-starter-web = { module = "org.springframework.boot:spring-boot-starter-web" }
spring-boot-starter-web-services = { module = "org.springframework.boot:spring-boot-starter-web-services" }
spring-boot-starter-security = { module = "org.springframework.boot:spring-boot-starter-security" }
spring-boot-starter-data-jpa = { module = "org.springframework.boot:spring-boot-starter-data-jpa" }
spring-boot-starter-validation = { module = "org.springframework.boot:spring-boot-starter-validation" }
spring-boot-starter-webflux = { module = "org.springframework.boot:spring-boot-starter-webflux" }
spring-boot-starter-oauth2-client = { module = "org.springframework.boot:spring-boot-starter-oauth2-client" }
spring-boot-starter-cache = { module = "org.springframework.boot:spring-boot-starter-cache" }
spring-boot-starter-aop = { module = "org.springframework.boot:spring-boot-starter-aop" }
spring-boot-starter-actuator = { module = "org.springframework.boot:spring-boot-starter-actuator" }
spring-boot-starter-test = { module = "org.springframework.boot:spring-boot-starter-test" }
spring-boot-devtools = { module = "org.springframework.boot:spring-boot-devtools" }

# Kotlin
kotlin-reflect = { module = "org.jetbrains.kotlin:kotlin-reflect" }
kotlin-stdlib = { module = "org.jetbrains.kotlin:kotlin-stdlib" }
kotlin-test-junit5 = { module = "org.jetbrains.kotlin:kotlin-test-junit5" }
kotlinx-coroutines-core = { module = "org.jetbrains.kotlinx:kotlinx-coroutines-core" }
kotlinx-coroutines-reactor = { module = "org.jetbrains.kotlinx:kotlinx-coroutines-reactor" }
kotlinx-datetime = { module = "org.jetbrains.kotlinx:kotlinx-datetime", version.ref = "kotlinx-datetime" }

# Database
postgresql = { module = "org.postgresql:postgresql" }
h2 = { module = "com.h2database:h2" }

# Testing
spring-security-test = { module = "org.springframework.security:spring-security-test" }
mockk = { module = "io.mockk:mockk", version.ref = "mockk" }
mockito-core = { module = "org.mockito:mockito-core" }
mockito-junit-jupiter = { module = "org.mockito:mockito-junit-jupiter" }
datafaker = { module = "net.datafaker:datafaker", version.ref = "datafaker" }
junit-platform-launcher = { module = "org.junit.platform:junit-platform-launcher" }

# Cache & Resilience
caffeine = { module = "com.github.ben-manes.caffeine:caffeine", version.ref = "caffeine" }
resilience4j-spring-boot3 = { module = "io.github.resilience4j:resilience4j-spring-boot3", version.ref = "resilience4j" }

# JWT
jjwt-api = { module = "io.jsonwebtoken:jjwt-api", version.ref = "jjwt" }
jjwt-impl = { module = "io.jsonwebtoken:jjwt-impl", version.ref = "jjwt" }
jjwt-jackson = { module = "io.jsonwebtoken:jjwt-jackson", version.ref = "jjwt" }

# Netty
netty-all = { module = "io.netty:netty-all" }

# Liquibase
liquibase-core = { module = "org.liquibase:liquibase-core" }
liquibase-hibernate6 = { module = "org.liquibase.ext:liquibase-hibernate6", version.ref = "liquibase-hibernate" }
picocli = { module = "info.picocli:picocli", version.ref = "picocli" }

# Spring
spring-context = { module = "org.springframework:spring-context" }

[plugins]
spring-boot = { id = "org.springframework.boot", version.ref = "spring-boot" }
spring-dependency-management = { id = "io.spring.dependency-management", version.ref = "spring-dependency-management" }
liquibase = { id = "org.liquibase.gradle", version.ref = "liquibase-gradle" }
kotlin-jvm = { id = "org.jetbrains.kotlin.jvm", version.ref = "kotlin" }
kotlin-spring = { id = "org.jetbrains.kotlin.plugin.spring", version.ref = "kotlin" }
kotlin-jpa = { id = "org.jetbrains.kotlin.plugin.jpa", version.ref = "kotlin" }
```

### 2단계: buildSrc에 공통 로직 분리

#### 2.1 buildSrc/src/main/kotlin/DependencyGroups.kt 생성
**목적**: 모든 의존성을 중앙에서 관리하여 중복을 제거하고 일관성을 보장
```kotlin
import org.gradle.api.artifacts.DependencySubstitution
import org.gradle.api.artifacts.VersionCatalogsExtension
import org.gradle.kotlin.dsl.getByType

object DependencyGroups {
    
    // 개발/운영 환경 의존성 (기본 의존성)
    fun DependencyHandlerScope.productionDependencies() {
        // Spring Boot Starters
        implementation("org.jetbrains.kotlin:kotlin-reflect")
        implementation("org.jetbrains.kotlin:kotlin-stdlib")
        implementation("org.springframework.boot:spring-boot-starter")
        implementation("org.springframework.boot:spring-boot-starter-web")
        implementation("org.springframework.boot:spring-boot-starter-web-services")
        implementation("org.springframework.boot:spring-boot-starter-security")
        implementation("org.springframework.boot:spring-boot-starter-data-jpa")
        implementation("org.springframework.boot:spring-boot-starter-validation")
        
        // Database
        runtimeOnly("org.postgresql:postgresql")
    }
    
    // 개발 전용 의존성
    fun DependencyHandlerScope.developmentDependencies() {
        developmentOnly("org.springframework.boot:spring-boot-devtools")
    }
    
    // 테스트 의존성
    fun DependencyHandlerScope.testDependencies() {
        testImplementation("org.springframework.boot:spring-boot-starter-data-jpa")
        testImplementation("org.springframework.boot:spring-boot-starter-test")
        testImplementation("org.springframework.security:spring-security-test")
        testImplementation("org.jetbrains.kotlin:kotlin-test-junit5")
        testImplementation("io.mockk:mockk:1.13.11")
        testImplementation("org.mockito:mockito-core")
        testImplementation("org.mockito:mockito-junit-jupiter")
        testImplementation("com.h2database:h2")
        testImplementation("net.datafaker:datafaker:2.0.1")
        testRuntimeOnly("org.junit.platform:junit-platform-launcher")
    }
    
    // Liquibase 의존성
    fun DependencyHandlerScope.liquibaseDependencies() {
        add("liquibaseRuntime", "org.springframework.boot:spring-boot-starter-data-jpa")
        add("liquibaseRuntime", "org.springframework:spring-context")
        add("liquibaseRuntime", "org.liquibase:liquibase-core")
        add("liquibaseRuntime", "org.liquibase.ext:liquibase-hibernate6:4.33.0")
        add("liquibaseRuntime", "org.postgresql:postgresql")
        add("liquibaseRuntime", "info.picocli:picocli:4.7.5")
        add("liquibaseRuntime", sourceSets.main.get().runtimeClasspath)
    }
    
    // Auth 모듈 의존성
    fun DependencyHandlerScope.authDependencies() {
        implementation("org.springframework.boot:spring-boot-starter-webflux")
        implementation("org.springframework.boot:spring-boot-starter-oauth2-client")
        implementation("org.springframework.boot:spring-boot-starter-cache")
        implementation("org.springframework.boot:spring-boot-starter-aop")
        implementation("com.github.ben-manes.caffeine:caffeine")
        implementation("io.github.resilience4j:resilience4j-spring-boot3:2.2.0")
        
        // JWT
        implementation("io.jsonwebtoken:jjwt-api:0.12.5")
        runtimeOnly("io.jsonwebtoken:jjwt-impl:0.12.5")
        runtimeOnly("io.jsonwebtoken:jjwt-jackson:0.12.5")
        
        // Coroutines
        implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core")
        implementation("org.jetbrains.kotlinx:kotlinx-coroutines-reactor")
    }
    
    // Tomo 모듈 의존성
    fun DependencyHandlerScope.tomoDependencies() {
        implementation("org.springframework.boot:spring-boot-starter-actuator")
        implementation("org.springframework.boot:spring-boot-starter-webflux")
        implementation("org.springframework.boot:spring-boot-starter-cache")
        implementation("com.github.ben-manes.caffeine:caffeine")
        implementation("io.netty:netty-all")
        implementation("org.jetbrains.kotlinx:kotlinx-coroutines-reactor")
    }
    
    // Common 모듈 의존성
    fun DependencyHandlerScope.commonDependencies() {
        implementation("org.springframework.boot:spring-boot-starter-webflux")
        implementation("org.springframework:spring-context")
        implementation("org.jetbrains.kotlinx:kotlinx-coroutines-reactor")
        implementation("org.jetbrains.kotlinx:kotlinx-datetime:0.7.1")
        implementation("org.springframework.boot:spring-boot-starter-test")
        implementation("io.mockk:mockk:1.13.11")
        
        // 테스트용 Security 의존성
        testImplementation("org.springframework.security:spring-security-test")
        testImplementation("org.springframework.boot:spring-boot-starter-security")
    }
    
    // User 모듈 의존성 (기본 의존성만 사용)
    fun DependencyHandlerScope.userDependencies() {
        // User 모듈은 기본 의존성만 사용 (추가 의존성 없음)
    }
}
```

#### 2.2 buildSrc/src/main/kotlin/TestConfig.kt 생성
```kotlin
import org.gradle.api.tasks.testing.Test
import org.gradle.api.tasks.testing.logging.TestExceptionFormat

object TestConfig {
    
    fun configureTestTasks(project: Project) {
        project.tasks.withType<Test> {
            useJUnitPlatform()
            
            testLogging {
                events("started", "passed", "skipped", "failed", "standardOut", "standardError")
                showStandardStreams = true
                showCauses = true
                showExceptions = true
                showStackTraces = true
                exceptionFormat = TestExceptionFormat.FULL
            }
        }
    }
}
```

#### 2.3 buildSrc/src/main/kotlin/LiquibaseConfig.kt 생성
```kotlin
import buildsrc.liquibase.AppendIncludeTask
import buildsrc.liquibase.DbPropsLoader
import buildsrc.liquibase.GenerateMigrationTask
import buildsrc.liquibase.InitMigrationTask
import org.gradle.api.Project
import org.gradle.api.tasks.TaskProvider
import java.io.File

object LiquibaseConfig {
    
    fun configureLiquibase(project: Project) {
        val liquibaseEnabled: Boolean = (project.findProperty("liquibaseEnabled") as String?)?.toBoolean() == true
        
        if (!liquibaseEnabled) return
        
        project.apply(mapOf("plugin" to "org.liquibase.gradle"))
        
        project.dependencies {
            add("liquibaseRuntime", "org.springframework.boot:spring-boot-starter-data-jpa")
            add("liquibaseRuntime", "org.springframework:spring-context")
            add("liquibaseRuntime", "org.liquibase:liquibase-core")
            add("liquibaseRuntime", "org.liquibase.ext:liquibase-hibernate6:4.33.0")
            add("liquibaseRuntime", "org.postgresql:postgresql")
            add("liquibaseRuntime", "info.picocli:picocli:4.7.5")
            add("liquibaseRuntime", project.sourceSets.main.get().runtimeClasspath)
        }
        
        project.plugins.withId("org.liquibase.gradle") {
            configureLiquibaseExtension(project)
            configureLiquibaseTasks(project)
        }
    }
    
    private fun configureLiquibaseExtension(project: Project) {
        val mainProjectName = project.rootProject.findProperty("mainProjectName")
        val isMainProject = project.name == mainProjectName
        val moduleBasePath = "${project.name}/src/main/resources/db/changelog"
        val moduleMainChangelog = "$moduleBasePath/db.changelog-${project.name}.yml"
        val mainAggregateChangelog = "$mainProjectName/src/main/resources/db/changelog/db.changelog-main.yml"
        val mainProps = project.rootProject.file("$mainProjectName/src/main/resources/application.properties")
        
        project.configure<org.liquibase.gradle.LiquibaseExtension> {
            val cfg = DbPropsLoader.load(mainProps)
            val changeLogFilePath = if (isMainProject) mainAggregateChangelog else moduleMainChangelog
            
            val searchPaths: String = buildSearchPaths(project, isMainProject)
            
            activities.register("main") {
                arguments = mapOf(
                    "changeLogFile" to changeLogFilePath,
                    "url" to cfg.url,
                    "username" to cfg.username,
                    "password" to cfg.password,
                    "driver" to cfg.driver,
                    "logLevel" to "DEBUG",
                    "verbose" to "true",
                    "searchPath" to searchPaths,
                )
            }
        }
    }
    
    private fun buildSearchPaths(project: Project, isMainProject: Boolean): String {
        return buildList {
            add(project.relativePath(project.rootProject.projectDir))
            if (isMainProject) {
                val enabledModules = project.rootProject.subprojects.filter {
                    (it.findProperty("liquibaseEnabled") as String?)?.toBoolean() == true
                }
                addAll(
                    enabledModules.map {
                        project.relativePath(it.projectDir.resolve("src/main/resources/db/changelog"))
                    }
                )
            } else {
                add(project.relativePath(project.projectDir.resolve("src/main/resources/db/changelog")))
            }
        }.joinToString(",")
    }
    
    private fun configureLiquibaseTasks(project: Project) {
        val mainProjectName = project.rootProject.findProperty("mainProjectName")
        val isMainProject = project.name == mainProjectName
        val moduleMainChangelog = "${project.name}/src/main/resources/db/changelog/db.changelog-${project.name}.yml"
        val mainAggregateChangelog = "$mainProjectName/src/main/resources/db/changelog/db.changelog-main.yml"
        val mainProps = project.rootProject.file("$mainProjectName/src/main/resources/application.properties")
        
        // Init Migration Task
        val initMigration = project.tasks.register<InitMigrationTask>("initMigration")
        
        // Append Main Include Task (for non-main projects)
        if (!isMainProject) {
            val appendMain = project.tasks.register<AppendIncludeTask>("appendMainInclude") {
                targetChangelogPath = project.rootProject.file(mainAggregateChangelog).absolutePath
                includeFilePath = moduleMainChangelog
                mustRunAfter(initMigration)
            }
            initMigration.configure { finalizedBy(appendMain) }
        }
        
        // Generate Migration Task
        val ts = System.currentTimeMillis()
        val desc = (project.findProperty("desc") as String?) ?: "change"
        val outFile = File(project.projectDir, "src/main/resources/db/changelog/migrations/$ts-$desc-changelog-${project.name}.yml")
        val entityPkg = (project.findProperty("liquibaseEntityPackage") as String?) ?: "place.tomo.${project.name}.domain.entities"
        
        val generateMigration = project.tasks.register<GenerateMigrationTask>("generateMigration") {
            liquibaseClasspath = project.configurations.getByName("liquibaseRuntime")
            entityPackage = entityPkg
            propertiesFile = mainProps
            changelogOutputFile = outFile
        }
        generateMigration.configure { dependsOn(project.tasks.named("classes"), initMigration) }
        
        // Append Module Include Task
        val appendModule = project.tasks.register<AppendIncludeTask>("appendMigrationInclude") {
            targetChangelogPath = project.file("src/main/resources/db/changelog/db.changelog-${project.name}.yml").absolutePath
            includeFilePath = "migrations/$ts-$desc-changelog-${project.name}.yml"
            mustRunAfter(generateMigration)
        }
        generateMigration.configure { finalizedBy(appendModule) }
    }
}
```

### 3단계: 루트 build.gradle.kts 수정

#### 3.1 기존 build.gradle.kts를 새로운 구조로 변경
```kotlin
import buildsrc.liquibase.AppendIncludeTask
import buildsrc.liquibase.DbPropsLoader
import buildsrc.liquibase.GenerateMigrationTask
import buildsrc.liquibase.InitMigrationTask

plugins {
    alias(libs.plugins.spring.boot) apply false
    alias(libs.plugins.spring.dependency.management) apply false
    alias(libs.plugins.liquibase) apply false
    alias(libs.plugins.kotlin.jvm)
    alias(libs.plugins.kotlin.spring) apply false
    alias(libs.plugins.kotlin.jpa) apply false
}

allprojects {
    group = "place.tomo"
    version = "1.0.0-SNAPSHOT"

    repositories {
        mavenCentral()
    }
}

subprojects {
    apply(plugin = "kotlin")
    apply(plugin = "kotlin-spring")
    apply(plugin = "kotlin-jpa")
    apply(plugin = "org.springframework.boot")
    apply(plugin = "io.spring.dependency-management")

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

    tasks.getByName<org.springframework.boot.gradle.tasks.bundling.BootJar>("bootJar") {
        enabled = false
    }

    tasks.getByName<Jar>("jar") {
        enabled = true
    }

    // buildSrc로 분리된 테스트 설정 적용
    TestConfig.configureTestTasks(this)

    dependencies {
        // buildSrc로 분리된 의존성 그룹 적용
        DependencyGroups.productionDependencies()
        DependencyGroups.testDependencies()
    }

    // buildSrc로 분리된 Liquibase 설정 적용
    LiquibaseConfig.configureLiquibase(this)
}

tasks.register("runTomo") {
    dependsOn(":tomo:bootRun")
}
```

### 4단계: 모듈별 build.gradle.kts 수정

#### 4.1 auth/build.gradle.kts 수정
```kotlin
dependencies {
    implementation(project(":contract"))
    implementation(project(":common"))

    // Auth 모듈 전용 의존성
    DependencyGroups.authDependencies()
}
```

#### 4.2 tomo/build.gradle.kts 수정
```kotlin
dependencies {
    implementation(project(":common"))
    implementation(project(":contract"))
    implementation(project(":auth"))
    implementation(project(":user"))
    
    // Tomo 모듈 전용 의존성
    DependencyGroups.tomoDependencies()
    
    // 개발 전용 의존성
    DependencyGroups.developmentDependencies()
}

tasks.bootJar {
    enabled = true
    archiveClassifier = ""
}
```

#### 4.3 user/build.gradle.kts 수정
```kotlin
dependencies {
    implementation(project(":contract"))
    implementation(project(":common"))
    
    // User 모듈 전용 의존성
    DependencyGroups.userDependencies()
}
```

#### 4.4 common/build.gradle.kts 수정
```kotlin
dependencies {
    implementation(project(":contract"))
    
    // Common 모듈 전용 의존성
    DependencyGroups.commonDependencies()
}
```

## 작업 체크리스트

### 1단계: 버전 카탈로그 생성
- [ ] `gradle/libs.versions.toml` 파일 생성
- [ ] 모든 버전 정보 입력
- [ ] 모든 라이브러리 정의
- [ ] 모든 플러그인 정의

### 2단계: buildSrc에 공통 로직 분리
- [ ] `buildSrc/src/main/kotlin/DependencyGroups.kt` 생성
- [ ] `buildSrc/src/main/kotlin/TestConfig.kt` 생성
- [ ] `buildSrc/src/main/kotlin/LiquibaseConfig.kt` 생성
- [ ] 각 파일의 함수들이 올바르게 정의되었는지 확인

### 3단계: 루트 build.gradle.kts 수정
- [ ] 플러그인 선언을 버전 카탈로그 사용으로 변경
- [ ] 기존 의존성 블록을 buildSrc 함수 호출로 변경
- [ ] 테스트 설정을 buildSrc 함수 호출로 변경
- [ ] Liquibase 설정을 buildSrc 함수 호출로 변경
- [ ] 기존 Liquibase 로직이 모두 제거되었는지 확인

### 4단계: 모듈별 build.gradle.kts 수정
- [ ] auth/build.gradle.kts 수정
- [ ] tomo/build.gradle.kts 수정
- [ ] user/build.gradle.kts 수정
- [ ] common/build.gradle.kts 수정
- [ ] 각 모듈에서 중복된 의존성이 제거되었는지 확인

### 5단계: 검증
- [ ] `./gradlew build` 실행하여 빌드 성공 확인
- [ ] `./gradlew test` 실행하여 테스트 성공 확인
- [ ] `./gradlew :tomo:bootRun` 실행하여 애플리케이션 실행 확인
- [ ] Liquibase 관련 태스크가 정상 작동하는지 확인

## 주의사항

1. **기존 로직 보존**: 모든 기존 기능이 그대로 작동해야 함
2. **단계별 진행**: 각 단계를 완료한 후 다음 단계로 진행
3. **검증 필수**: 각 단계 완료 후 빌드 및 테스트 실행으로 검증
4. **백업**: 작업 전 현재 상태를 Git으로 커밋하여 백업

## 예상 효과

1. **의존성 중복 제거**: 공통 의존성이 한 곳에서 관리됨
2. **버전 관리 개선**: 버전 카탈로그로 중앙 집중식 버전 관리
3. **코드 재사용성 향상**: buildSrc를 통한 공통 로직 재사용
4. **유지보수성 향상**: 모듈별 의존성이 명확히 분리됨
5. **확장성 개선**: 새로운 모듈 추가 시 쉽게 적용 가능
6. **모듈별 의존성 관리**: 각 서브모듈의 의존성이 중앙에서 관리되어 일관성 보장
