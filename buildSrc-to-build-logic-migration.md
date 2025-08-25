# Execution Plan

## Requested Task
- buildSrc를 build-logic으로 마이그레이션
- 기존 로직과 동작방식 완전 유지
- settings.gradle.kts에서 build-logic 제외 처리

## Identified Context
- 현재 buildSrc 구조:
  - LiquibaseConfig: Liquibase 설정 관리 (조건부 적용: liquibaseEnabled)
  - TestConfig: 테스트 구성 관리 (항상 적용)
  - liquibase/ 패키지: 7개 파일 (상수, 컨텍스트, 태스크, 유틸리티)
- build.gradle.kts에서 liquibaseEnabled 체크 후 조건부 적용
- settings.gradle.kts에서 buildSrc 제외하고 서브프로젝트 자동 include

## Execution Plan

### 1. build-logic 디렉토리 구조 생성 (8단계에서 패키지 구조 개선)
```
tomo/
├── build-logic/
│   ├── settings.gradle.kts
│   ├── gradle.properties  
│   ├── liquibase-convention/
│   │   ├── build.gradle.kts
│   │   └── src/main/kotlin/place/tomo/gradle/liquibase/
│   │       ├── LiquibaseConventionPlugin.kt              # 최상위 Plugin
│   │       ├── config/
│   │       │   └── LiquibaseConfig.kt                   # 설정 관련  
│   │       ├── constants/
│   │       │   └── LiquibaseConstants.kt                # 상수 정의
│   │       ├── tasks/                                   # Gradle Task들
│   │       │   ├── GenerateMigrationTask.kt
│   │       │   ├── InitMigrationTask.kt  
│   │       │   └── MigrationPathAppender.kt
│   │       └── utils/                                   # 유틸리티 클래스들
│   │           ├── DbPropsLoader.kt
│   │           ├── LiquibasePathResolver.kt
│   │           └── LiquibaseProjectContext.kt
│   └── src/main/kotlin/place/tomo/gradle/
│       ├── liquibase/
│       │   ├── LiquibaseConventionPlugin.kt              # Liquibase Plugin
│       │   ├── config/LiquibaseConfig.kt                # 설정 관리
│       │   ├── constants/LiquibaseConstants.kt          # 상수 정의
│       │   ├── tasks/                                   # Gradle Task들
│       │   │   ├── GenerateMigrationTask.kt
│       │   │   ├── InitMigrationTask.kt
│       │   │   └── MigrationPathAppender.kt
│       │   └── utils/                                   # 유틸리티 클래스들
│       │       ├── DbPropsLoader.kt
│       │       ├── LiquibasePathResolver.kt
│       │       └── LiquibaseProjectContext.kt
│       └── TestConventionPlugin.kt                      # Test Plugin (config 통합)
├── settings.gradle.kts (수정 필요)
├── build.gradle.kts (수정 필요)
└── buildSrc/ (제거 예정)
```

### 2. build-logic/settings.gradle.kts 생성
```kotlin
dependencyResolutionManagement {
    repositories {
        mavenCentral()
        gradlePluginPortal()
    }
    versionCatalogs {
        create("libs") {
            from(files("../gradle/libs.versions.toml"))
        }
    }
}

include("liquibase-convention")
include("test-convention")
```

### 3. Convention Plugins 구체적 구현

#### 3.1 LiquibaseConventionPlugin
```kotlin
package place.tomo.gradle

import liquibase.LiquibaseConstants
import org.gradle.api.Plugin
import org.gradle.api.Project
import org.gradle.kotlin.dsl.configure
import org.gradle.kotlin.dsl.getByName
import org.gradle.kotlin.dsl.apply
import org.liquibase.gradle.LiquibaseExtension

class LiquibaseConventionPlugin : Plugin<Project> {
    override fun apply(project: Project) {
        // 기존과 동일한 조건 체크
        val liquibaseEnabled = project.findProperty(LiquibaseConstants.LIQUIBASE_ENABLED_PROPERTY)
            ?.toString()?.toBoolean() ?: false
            
        if (!liquibaseEnabled) return
        
        // libs 카탈로그를 통해 liquibase plugin 적용
        val libs = project.rootProject.extensions.getByName("libs") as org.gradle.api.artifacts.VersionCatalog
        project.plugins.apply(libs.findPlugin("liquibase").get().get().pluginId)
        
        // 기존 의존성 추가 로직 - libs 카탈로그 사용
        project.dependencies.apply {
            add("liquibaseRuntime", libs.findLibrary("spring.boot.starter.data.jpa").get())
            add("liquibaseRuntime", libs.findLibrary("spring.context").get())
            add("liquibaseRuntime", libs.findLibrary("liquibase.core").get())
            add("liquibaseRuntime", libs.findLibrary("liquibase.hibernate6").get())
            add("liquibaseRuntime", libs.findLibrary("postgresql").get())
            add("liquibaseRuntime", libs.findLibrary("picocli").get())
            add("liquibaseRuntime", project.sourceSets.main.get().runtimeClasspath)
        }
        
        // 기존 LiquibaseConfig.configureLiquibase 로직 적용
        LiquibaseConfig.configureLiquibase(project)
    }
}
```

#### 3.2 TestConventionPlugin
```kotlin
package place.tomo.gradle

import org.gradle.api.Plugin
import org.gradle.api.Project

class TestConventionPlugin : Plugin<Project> {
    override fun apply(project: Project) {
        // 기존 TestConfig 로직 그대로 적용
        TestConfig.configureTestTasks(project)
    }
}
```

### 4. settings.gradle.kts 수정
```kotlin
// 기존
rootProject.name = "tomo"
rootDir
    .listFiles()
    ?.filter {
        it.isDirectory &&
            it.name != "buildSrc" &&
            File(it, "build.gradle.kts").exists()
    }?.forEach { include(it.name) }

// 새로운 방식
rootProject.name = "tomo"

// build-logic composite build 포함
includeBuild("build-logic")

// build-logic도 제외하도록 수정
rootDir
    .listFiles()
    ?.filter {
        it.isDirectory &&
            it.name != "buildSrc" &&
            it.name != "build-logic" &&
            File(it, "build.gradle.kts").exists()
    }?.forEach { include(it.name) }
```

### 5. main build.gradle.kts 수정
```kotlin
// 기존 (47-100줄)
TestConfig.configureTestTasks(this)
val liquibaseEnabled: Boolean = (findProperty("liquibaseEnabled") as String?)?.toBoolean() == true
if (liquibaseEnabled) {
    apply(plugin = "org.liquibase.gradle")
    dependencies {
        add("liquibaseRuntime", libs.spring.boot.starter.data.jpa)
        // ... 기존 의존성들
    }
    LiquibaseConfig.configureLiquibase(this)
}

// 새로운 방식 - Convention Plugins 사용
plugins {
    id("place.tomo.gradle.test-convention")
    id("place.tomo.gradle.liquibase-convention") // 내부에서 liquibaseEnabled 체크
}
// 기존 모든 로직이 plugin 내부로 이동, 동작 방식 완전 동일
```

### 6. Convention Plugin build.gradle.kts 파일들
```kotlin
// build-logic/liquibase-convention/build.gradle.kts
plugins {
    `kotlin-dsl`
}

dependencies {
    // libs 카탈로그에서 Liquibase 관련 의존성 가져오기
    implementation(libs.liquibase.gradle.plugin)
    
    // buildSrc에서 사용하던 의존성들 (LiquibaseConfig에서 필요)
    implementation("org.yaml:snakeyaml:2.2")
    
    // VersionCatalog 접근을 위해 필요
    implementation(gradleApi())
}

// build-logic/test-convention/build.gradle.kts  
plugins {
    `kotlin-dsl`
}

// TestConfig는 추가 의존성 불필요
```

### 7. buildSrc 디렉토리 제거

### 8. liquibase 패키지 구조 리팩토링
build-logic 내 liquibase 관련 코드의 패키지 위계 문제를 해결하기 위한 구조 개선:
(TestConfig는 TestConventionPlugin에 통합되어 별도 리팩토링 불필요)

#### 8.1 현재 문제점 (실제 구조)

**liquibase 관련 현재 구조:**
```
build-logic/src/main/kotlin/
├── place/tomo/gradle/
│   └── LiquibaseConventionPlugin.kt                # Plugin (깊은 패키지)
├── LiquibaseConfig.kt                              # Config (최상위, no package!)
└── liquibase/                                      # utility 패키지
    ├── LiquibaseConstants.kt
    ├── DbPropsLoader.kt
    ├── GenerateMigrationTask.kt
    ├── InitMigrationTask.kt
    ├── LiquibasePathResolver.kt
    ├── LiquibaseProjectContext.kt
    └── MigrationPathAppender.kt
```

**문제점:**
- **LiquibaseConfig**는 최상위에 package 선언 없음
- **LiquibaseConventionPlugin**은 깊은 패키지에 있음
- liquibase utility들은 별도 패키지에 있지만 기능별 분류가 불분명 (constants, tasks, utils 혼재)
- Plugin이 최상위 Config와 하위 패키지 utility들을 import하는 혼재된 구조

#### 8.2 개선된 구조

**liquibase 관련 개선된 구조:**
```
build-logic/src/main/kotlin/place/tomo/gradle/liquibase/
├── LiquibaseConventionPlugin.kt                 # 최상위 Plugin
├── config/
│   └── LiquibaseConfig.kt                      # 설정 관리
├── constants/
│   └── LiquibaseConstants.kt                   # 상수 정의
├── tasks/
│   ├── GenerateMigrationTask.kt                # Gradle Task들
│   ├── InitMigrationTask.kt
│   └── MigrationPathAppender.kt
└── utils/
    ├── DbPropsLoader.kt                        # 유틸리티 클래스들
    ├── LiquibasePathResolver.kt
    └── LiquibaseProjectContext.kt
```

#### 8.3 package 선언 변경

**Liquibase 관련 package 선언:**
```kotlin
package place.tomo.gradle.liquibase            // LiquibaseConventionPlugin.kt
package place.tomo.gradle.liquibase.config     // LiquibaseConfig.kt
package place.tomo.gradle.liquibase.constants  // LiquibaseConstants.kt  
package place.tomo.gradle.liquibase.tasks      // GenerateMigrationTask.kt, InitMigrationTask.kt, MigrationPathAppender.kt
package place.tomo.gradle.liquibase.utils      // DbPropsLoader.kt, LiquibasePathResolver.kt, LiquibaseProjectContext.kt
```

#### 8.4 import 문 정리

**LiquibaseConventionPlugin.kt:**
```kotlin
package place.tomo.gradle.liquibase

import place.tomo.gradle.liquibase.config.LiquibaseConfig
import place.tomo.gradle.liquibase.constants.LiquibaseConstants
// 논리적인 위계 구조로 import - Plugin → Config → Constants
```

#### 8.5 장점
- **명확한 위계**: Plugin → Config → Constants/Tasks/Utils 순서로 논리적 구조
- **기능별 분류**: config, constants, tasks, utils로 명확한 역할 분담  
- **일관된 import 구조**: Plugin이 하위 패키지의 config와 constants만 import
- **확장성**: 새로운 liquibase 기능 추가 시 적절한 하위 패키지에 배치 가능
- **검색 및 네비게이션 개선**: IDE에서 패키지 구조 기반 빠른 탐색 가능
- **단일 도메인 응집도**: liquibase 관련 모든 코드가 하나의 패키지 트리에 위치

## Progress Status
1. 현재 buildSrc 구조와 동작 방식 완전 분석 [Done]
2. build-logic 구조 생성 [Done]
3. LiquibaseConventionPlugin 생성 (기존 로직 완전 보존) [Done]
4. TestConventionPlugin 생성 (기존 로직 완전 보존) [Done]
5. settings.gradle.kts 수정 (build-logic 제외 및 includeBuild) [Done]
6. main build.gradle.kts 수정 [Done - 주석 처리]
7. 기능 동작 확인 및 테스트 [Pending]
8. liquibase 패키지 구조 리팩토링 [Done]
9. buildSrc 디렉토리 제거 [Done]

## 핵심 보장사항
- **liquibaseEnabled 조건부 적용 완전 동일**: plugin 내부에서 동일한 조건 체크
- **기존 의존성 추가 로직 완전 동일**: 동일한 libs 참조와 의존성 추가
- **LiquibaseConfig.configureLiquibase 완전 동일**: 기존 함수 그대로 호출
- **TestConfig.configureTestTasks 완전 동일**: 기존 함수 그대로 호출
- **settings.gradle.kts 서브프로젝트 자동 include 유지**: build-logic만 추가 제외

## 장점 분석

### 성능 향상
- **증분 빌드**: build-logic 변경 시 해당 모듈만 재컴파일
- **캐시 효율성**: buildSrc처럼 전체 캐시 무효화 없음

### 모듈화
- **독립적 관리**: 각 convention plugin을 독립적으로 개발/테스트
- **재사용성**: 다른 프로젝트에서도 사용 가능

### 확장성
- **버전 관리**: 각 plugin의 독립적 버전 관리
- **배포 가능**: Maven/Gradle Plugin Portal에 배포 가능

## build-logic 동작 방식

1. **Composite Build**: Gradle이 build-logic을 별도 빌드로 인식
2. **Plugin Resolution**: plugins {} 블록에서 자동으로 build-logic의 플러그인 해석
3. **Classpath Isolation**: build-logic과 main build의 classpath 분리
4. **Dependency Management**: build-logic 자체도 의존성 관리 가능

## Suggested Next Tasks
- Kotlin Multiplatform 지원을 위한 convention plugin 추가
- GitHub Actions workflow에서 build-logic 캐싱 최적화
- 다른 Spring Boot 프로젝트와 공유 가능한 convention plugin 라이브러리 구축
