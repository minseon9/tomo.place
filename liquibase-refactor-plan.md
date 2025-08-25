# 실행 계획

## 요청된 작업
Liquibase 설정에서 공통으로 사용되는 변수들을 분리하여 재활용성과 가독성을 개선

## 식별된 컨텍스트
- buildSrc에서 LiquibaseConfig로 Liquibase 설정이 응집됨
- 공통 변수들(mainProjectName, 경로들)이 여러 곳에서 반복 사용됨
- 하드코딩된 경로 패턴과 파일명들이 존재함
- 현재 LiquibaseConfig.kt에서 다음 변수들이 반복적으로 계산됨:
  ```kotlin
  val mainProjectName = project.findProperty("mainProjectName") as String
  val isMainProject = project.name == mainProjectName
  val moduleBasePath = "${project.name}/src/main/resources/db/changelog"
  val moduleMainChangelog = "$moduleBasePath/db.changelog-${project.name}.yml"
  val mainAggregateChangelog = "$mainProjectName/src/main/resources/db/changelog/db.changelog-main.yml"
  val properties = DbPropsLoader.load()
  ```

## 실행 계획

### 1. LiquibaseConstants 객체 생성
**상태**: [Done]
**파일**: `buildSrc/src/main/kotlin/liquibase/LiquibaseConstants.kt`
**목적**: 하드코딩된 상수들을 중앙 집중화

**코드 예시**:
```kotlin
object LiquibaseConstants {
    const val CHANGELOG_DIR = "src/main/resources/db/changelog"
    const val CHANGELOG_FILE_PREFIX = "db.changelog-"
    const val MAIN_CHANGELOG_NAME = "db.changelog-main.yml"
    // ... 기타 상수들
}
```

### 2. LiquibasePathResolver 클래스 생성
**상태**: [Pending]
**파일**: `buildSrc/src/main/kotlin/liquibase/LiquibasePathResolver.kt`
**목적**: 프로젝트별 경로 계산 로직을 캡슐화하고 재사용성 향상

**코드 예시**:
```kotlin
class LiquibasePathResolver(private val project: Project) {
    private val mainProjectName: String by lazy {
        project.findProperty(LiquibaseConstants.MAIN_PROJECT_NAME_PROPERTY) as String
    }
    
    val isMainProject: Boolean by lazy {
        project.name == mainProjectName
    }
    
    val moduleBasePath: String by lazy {
        "${project.name}/${LiquibaseConstants.CHANGELOG_DIR}"
    }
    
    val moduleMainChangelog: String by lazy {
        "$moduleBasePath/${LiquibaseConstants.CHANGELOG_FILE_PREFIX}${project.name}${LiquibaseConstants.CHANGELOG_FILE_SUFFIX}"
    }
    
    val mainAggregateChangelog: String by lazy {
        "$mainProjectName/${LiquibaseConstants.CHANGELOG_DIR}/${LiquibaseConstants.MAIN_CHANGELOG_NAME}"
    }
    
    fun getSearchPaths(): String {
        // 검색 경로 계산 로직
    }
    
    fun getMigrationOutputFile(timestamp: Long, description: String): File {
        // 마이그레이션 파일 경로 계산
    }
}
```

### 3. LiquibaseProjectContext 데이터 클래스 생성
**상태**: [Pending]
**파일**: `buildSrc/src/main/kotlin/liquibase/LiquibaseProjectContext.kt`
**목적**: 프로젝트 컨텍스트 정보를 구조화하여 전달

**코드 예시**:
```kotlin
data class LiquibaseProjectContext(
    val project: Project,
    val pathResolver: LiquibasePathResolver,
    val dbProps: DbProps,
    val entityPackage: String
) {
    companion object {
        fun create(project: Project): LiquibaseProjectContext {
            val pathResolver = LiquibasePathResolver(project)
            val dbProps = DbPropsLoader.load()
            val entityPackage = project.findProperty(LiquibaseConstants.LIQUIBASE_ENTITY_PACKAGE_PROPERTY) as String?
                ?: "${LiquibaseConstants.DEFAULT_ENTITY_PACKAGE_PREFIX}.${project.name}.${LiquibaseConstants.ENTITY_PACKAGE_SUFFIX}"
            
            return LiquibaseProjectContext(project, pathResolver, dbProps, entityPackage)
        }
    }
}
```

### 4. LiquibaseConfig 리팩토링
**상태**: [Pending]
**파일**: `buildSrc/src/main/kotlin/LiquibaseConfig.kt`
**목적**: 새로운 유틸리티 클래스들을 활용하여 코드 간소화 및 가독성 향상

**변경 전**:
```kotlin
private fun configureLiquibaseTasks(project: Project) {
    val mainProjectName = project.findProperty("mainProjectName") as String
    val isMainProject = project.name == mainProjectName
    val moduleBasePath = "${project.name}/src/main/resources/db/changelog"
    val moduleMainChangelog = "$moduleBasePath/db.changelog-${project.name}.yml"
    val mainAggregateChangelog = "$mainProjectName/src/main/resources/db/changelog/db.changelog-main.yml"
    val properties = DbPropsLoader.load()
    // ...
}
```

**변경 후**:
```kotlin
private fun configureLiquibaseTasks(project: Project) {
    val context = LiquibaseProjectContext.create(project)
    
    registerLiquibaseActivity(context)
    createInitMigrationTask(context)
    createGenerateMigrationTask(context)
}
```

### 5. 메서드 시그니처 업데이트
**상태**: [Pending]
**수정 대상**: 
- `registerLiquibaseActivity()` 메서드
- `createInitMigrationTask()` 메서드  
- `createGenerateMigrationTask()` 메서드

**변경 예시**:
```kotlin
// 변경 전
private fun registerLiquibaseActivity(
    project: Project,
    dbProps: DbProps,
    isMainProject: Boolean,
    moduleMainChangelog: String,
    mainAggregateChangelog: String,
)

// 변경 후
private fun registerLiquibaseActivity(context: LiquibaseProjectContext)
```

### 6. 테스트 및 검증
**상태**: [Pending]
**검증 항목**:
- 기존 Liquibase 태스크들이 정상 동작하는지 확인
- 모든 경로가 올바르게 계산되는지 검증
- 빌드 스크립트 컴파일 오류 없음 확인

## 진행 상태
1. LiquibaseConstants 객체 생성 [Done]
2. LiquibasePathResolver 클래스 생성 [Pending]
3. LiquibaseProjectContext 데이터 클래스 생성 [Pending]
4. LiquibaseConfig 리팩토링 [Pending]
5. 메서드 시그니처 업데이트 [Pending]
6. 테스트 및 검증 [Pending]

## 제안된 다음 작업
- 성능 개선을 위한 경로 캐싱 메커니즘 추가
- 프로젝트별 Liquibase 설정 커스터마이징 지원
- Liquibase 설정 검증 로직 추가
