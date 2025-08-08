## 목표

- `identity` 서브프로젝트를 `auth`, `user` 두 서브프로젝트로 분리
- 두 모듈 간 결합 최소화: 엔티티 직접 참조 금지, `contract`의 Port/DTO/VO로만 통신
- 인증/인가는 미들웨어에서 완료하고, UI 계층에는 `email`/`UserDetails`만 전달 [[memory:4194650]]
- OAuth/OIDC 및 소셜 계정 관련 로직은 전부 `auth` 모듈에 집중 [[memory:4194643]]

## 최종 모듈 구조

- `contract`: Ports, DTO, VO(`UserId`, `Email`, 등)만 포함
- `common`: 공용 유틸/인프라(`HttpClient`, `UserContextArgumentResolver` 등)
- `auth`: 인증/인가, OIDC, 소셜 계정, 시큐리티(필터/설정), 관련 UI
- `user`: 사용자 도메인(엔티티/도메인 서비스/리포지토리/컨트롤러)
- `tomo`(메인 앱): 위 모듈들을 의존하고 부팅/라우팅/마이그레이션 조립

의존 그래프:
- `auth` → `contract`, `common`
- `user` → `contract`, `common`
- `tomo` → `auth`, `user`, `contract`, `common`
- `contract`/`common`은 어떤 도메인에도 의존하지 않음

## 단계별 작업 계획

### 0) 준비
- 통합 테스트/빌드가 녹색인지 확인(현재 상태 스냅샷 확보)

리스크/주의:
- 대규모 파일 이동으로 충돌 가능성↑ → 작은 커밋/PR 단위로 쪼개기, 각 단계마다 빌드/테스트 유지

### 1) contract 보강(교차 통신의 유일한 경로)
- VO 추가: `UserId`, `Email`
- Port 정리/보강:
  - `UserCommandPort`: `create(CreateUserCommand): UserId`, `softDelete(UserId)`
  - `UserQueryPort`: `findByEmail(Email): UserSummaryDTO?`
  - `SocialAccountCommandPort`: `link(LinkSocialAccountCommand)`, `softDeleteByUserId(UserId)`
- DTO/Command는 도메인 엔티티를 절대 노출하지 않도록 유지

예시(개념 스니펫):
```kotlin
data class UserId(val value: Long)
data class Email(val value: String)

interface UserCommandPort {
    fun create(command: CreateUserCommand): UserId
    fun softDelete(userId: UserId)
}
data class CreateUserCommand(val email: Email, val rawPassword: String?)

interface SocialAccountCommandPort {
    fun link(command: LinkSocialAccountCommand)
    fun softDeleteByUserId(userId: UserId)
}
data class LinkSocialAccountCommand(val userId: UserId, val provider: OIDCProviderType, val subject: String)
```

리스크/주의:
- 계약에 도메인 내부 개념이 스며들면 순환/결합 발생 → VO/DTO로만 표현, 엔티티/리포지토리 금지

### 2) 새 서브프로젝트 생성 및 Gradle 설정
- `auth/build.gradle.kts` 생성(핵심 의존):
```kotlin
dependencies {
    implementation(project(":contract"))
    implementation(project(":common"))
    implementation("org.springframework.boot:spring-boot-starter-security")
    implementation("org.springframework.boot:spring-boot-starter-web")
    implementation("org.springframework.boot:spring-boot-starter-data-jpa")
    // JWT, OIDC 관련 의존성
}
```
- `user/build.gradle.kts` 생성:
```kotlin
dependencies {
    implementation(project(":contract"))
    implementation(project(":common"))
    implementation("org.springframework.boot:spring-boot-starter-web")
    implementation("org.springframework.boot:spring-boot-starter-data-jpa")
}
```
- `tomo/build.gradle.kts`에 의존 추가:
```kotlin
dependencies {
    implementation(project(":auth"))
    implementation(project(":user"))
    implementation(project(":contract"))
    implementation(project(":common"))
    implementation("org.liquibase:liquibase-core")
}
```

리스크/주의:
- 순환 의존 방지: `auth`와 `user`는 서로를 의존하지 않음. 둘 다 `contract`만 의존
- 컴포넌트 스캔 중복/누락 방지: 각 모듈의 `@Configuration` 범위를 명확히 유지

### 3) 코드 이동(패키지 유지, 모듈만 분리)
- `identity/src/main/kotlin/place/tomo/auth/**` → `auth/src/main/kotlin/place/tomo/auth/**`
- `identity/src/main/kotlin/place/tomo/user/**` → `user/src/main/kotlin/place/tomo/user/**`
- 리소스(`application.properties`, `db/changelog/**`)도 각 모듈로 이동/분리
- 패키지 네임스페이스는 유지(`place.tomo.auth`, `place.tomo.user`)

리스크/주의:
- 이동 후 import 경로/컴포넌트 스캔 누락 → 모듈별 `@SpringBootApplication` 보다는 `@Configuration` 구성으로 참여
- 빈 충돌 방지: 시큐리티 빈은 `auth`에만 존재해야 함

### 4) 시큐리티/미들웨어는 `auth`에 집중
- `JwtAuthenticationFilter`, `SecurityConfig`, `CustomUserDetailsService`를 `auth`로 이동
- `CustomUserDetailsService`는 `UserQueryPort`를 통해 사용자 조회(직접 엔티티 참조 금지)
- 컨트롤러는 `CurrentUser`/`email`만 받도록 유지(미들웨어에서 인증 완료) [[memory:4194650]]

참고(현재 구조와 유사한 필터 흐름):
```kotlin
// JWT 추출 → 검증 → UserDetails 로드 → SecurityContext 설정 → 체인 진행
```

리스크/주의:
- `SecurityFilterChain`이 둘 이상 등록되면 충돌 → `auth`에만 존재하도록 점검
- `UserDetailsService`가 `user`에 누락되면 인증 실패 → `UserQueryPort` 기반 구현을 `auth`에 배치

### 5) 교차 참조 제거 및 Port 호출로 대체
- `auth` ↔ `user` 간 엔티티 직접 참조 제거
- `SocialAccountEntity`는 `userId: UserId`(VO)만 보유, `@ManyToOne` 제거
- 오케스트레이션은 애플리케이션 서비스에서 Port 호출로 수행

예시(개념 스니펫):
```kotlin
class AuthApplicationService(
    private val userCommandPort: UserCommandPort,
    private val socialAccountCommandPort: SocialAccountCommandPort,
    private val authenticationService: AuthenticationService,
) {
    @Transactional
    fun signUpByOidc(req: OidcSignUpRequest): AuthTokenDTO {
        val userId = userCommandPort.create(CreateUserCommand(Email(req.email), null))
        socialAccountCommandPort.link(LinkSocialAccountCommand(userId, req.provider, req.subject))
        return authenticationService.issueTokens(subject = req.email)
    }
}
```

리스크/주의:
- 어댑터 빈 누락 → 각 모듈의 `infra.adapters`에 Port 구현 및 빈 등록
- Port/DTO가 도메인 내부 타입을 새어 보내지 않도록 유지

### 6) JPA 매핑/소프트 삭제 정책
- 교차 애그리거트 연관관계 제거: JPA 연관 대신 FK 컬럼 + VO 매핑(`@Embedded` + `@AttributeOverride`)
- 소프트 삭제: 각 애그리거트에서 `@SQLDelete` + `@Where` 또는 Repository 커스텀 업데이트 사용
- 교차 전파: 애플리케이션 서비스에서 동기 트랜잭션으로 함께 처리, 또는 도메인 이벤트(아웃박스)로 비동기 처리

예시(개념 스니펫):
```kotlin
@Embeddable
data class UserId(val value: Long)

@Entity
@SQLDelete(sql = "UPDATE social_accounts SET deleted_at = now() WHERE id = ?")
@Where(clause = "deleted_at IS NULL")
class SocialAccountEntity(
    @Embedded
    @AttributeOverride(name = "value", column = Column(name = "user_id", nullable = false))
    val userId: UserId,
    ...
)

interface SocialAccountRepository : JpaRepository<SocialAccountEntity, Long> {
    @Modifying(clearAutomatically = true, flushAutomatically = true)
    @Query("""
        UPDATE SocialAccountEntity s
        SET s.deletedAt = CURRENT_TIMESTAMP
        WHERE s.userId = :userId AND s.deletedAt IS NULL
    """)
    fun softDeleteByUserId(userId: UserId): Int
}
```

리스크/주의:
- 연관관계 제거 후 조회 N+1 대체 필요 → 명시적 쿼리, 슬라이스 DTO 조회로 전환
- 이벤트 기반 전파 시 일관성 지연/중복 처리 → 아웃박스/멱등키 적용

### 7) Liquibase 마이그레이션 구성
- 모듈별 변경 로그를 제공하고, `tomo`의 마스터에서 include

예시(개념 스니펫):
```yaml
databaseChangeLog:
  - include:
      file: classpath:/db/changelog/auth/db.changelog-auth.yml
  - include:
      file: classpath:/db/changelog/user/db.changelog-user.yml
```

리스크/주의:
- 동일 변경에 대한 이중 실행 방지: 체인지셋 id/author 고유성 확보
- FK는 DB에서 유지(JPA 연관과 무관) → 삭제 정책은 애플리케이션에서 오케스트레이션

### 8) API 표면 정리
- `auth`: `/api/auth/**`, `/api/oidc/**`
- `user`: `/api/users/**`
- 컨트롤러 응답은 `fromDto` 정적 생성자로 매핑하여 UI를 얇게 유지 [[memory:4194650]]

리스크/주의:
- 엔드포인트 경로 충돌/이동 → 클라이언트/게이트웨이 라우팅 업데이트 체크

### 9) CI/빌드/테스트
- Gradle 멀티모듈 빌드 파이프라인 갱신(`:auth`, `:user` 포함)
- 통합 테스트: 가입/로그인/소프트 삭제 교차 플로우 검증
- 로컬 프로필/시크릿(env) 분리 확인(JWT 시크릿, OIDC 클라이언트 설정)

리스크/주의:
- 테스트에서 컴포넌트 스캔 경계로 인한 빈 누락 → 테스트 전용 `@Import`/`@SpringBootTest` 설정 조정

### 10) `identity` 제거(최종)
- 모든 의존과 코드 이동이 완료되고 빌드/테스트가 녹색이면 `identity`를 settings에서 제외하고 제거
- 필요 시 한동안 파사드/리다이렉트 컨트롤러를 두어 호환 계층 유지 후 점진 제거

리스크/주의:
- 런타임 환경에 남아 있는 설정/경로 의존 → 배포 전 점검 체크리스트로 확인

## PR 분할 제안(권장)
1) contract 보강(Port/DTO/VO 추가) + 컴파일 통과 확인
2) user 모듈 생성 + 코드 이동 + 빌드/테스트
3) auth 모듈 생성 + 코드 이동 + 시큐리티 구성 이전 + 빌드/테스트
4) 교차 참조 제거 → Port 호출로 대체(양 모듈) + 통합 테스트
5) Liquibase include 정리 + 마이그레이션 검증
6) API 경로/게이트웨이 점검 + 클라이언트 영향 최소화
7) identity 제거

## 롤백 전략
- 각 단계 릴리즈 가능 상태로 유지(기능 플래그/라우팅 토글)
- 실패 시 이전 태그로 롤백, DB 체인지셋은 비파괴적 변경 우선

## 체크리스트(요약)
- Port/DTO/VO 외부 노출에서 도메인 엔티티 금지
- 시큐리티 빈은 `auth`에만 존재, 컨트롤러는 `CurrentUser`/`email`만 의존 [[memory:4194650]]
- JPA 연관 제거, DB FK 유지, 소프트 삭제는 오케스트레이션으로 전파
- Liquibase는 `tomo` 마스터에서 모듈별 변경 로그를 include
- CI/테스트는 매 단계 녹색 유지, 작은 PR로 진행


