# OIDC 인증 API 통합 리팩토링 실행 계획

## Requested Task
OIDC 인증에서 signup과 login API를 통합하여 하나의 `/api/auth/signup` 엔드포인트로 처리하고, 가입이 되어있지 않은 경우만 따로 처리하도록 리팩토링

## Identified Context
- 현재 AuthController에서 `/api/auth/signup`과 `/api/auth/login` 두 개의 엔드포인트가 분리되어 있음
- OIDCApplicationService에서 `signUp()`과 `authenticate()` 메서드가 분리되어 있음
- `signUp()`은 사용자 생성/조회 + 소셜 계정 연결 + 토큰 발급을 처리
- `authenticate()`는 기존 소셜 계정 확인 + 토큰 발급만 처리
- LoginRequestBody와 SignupRequestBody가 동일한 구조를 가지고 있음
- 테스트 케이스에서 signup과 login을 별도로 테스트하고 있음

## Execution Plan

### 1. AuthController 리팩토링 [Pending]
**파일**: `tomo/auth/src/main/kotlin/place/tomo/auth/ui/controllers/AuthController.kt`

**변경 사항**:
- `/api/auth/login` 엔드포인트 제거
- `/api/auth/signup` 엔드포인트만 유지
- `LoginRequestBody` import 제거
- `authenticate()` 메서드 제거

**코드 예시**:
```kotlin
@RestController
@RequestMapping("/api/auth")
class AuthController(
    private val oidcAuthService: OIDCApplicationService,
) {
    @PostMapping("/signup")
    fun signUp(
        @RequestBody @Valid body: SignupRequestBody,
    ): ResponseEntity<LoginResponseBody> {
        val response = oidcAuthService.signUp(OIDCSignUpRequest(body.provider, body.authorizationCode))
        return ResponseEntity.ok(LoginResponseBody(token = response.token, refreshToken = response.refreshToken))
    }
}
```

### 2. OIDCApplicationService 리팩토링 [Pending]
**파일**: `tomo/auth/src/main/kotlin/place/tomo/auth/application/services/OIDCApplicationService.kt`

**변경 사항**:
- `authenticate()` 메서드 제거
- `signUp()` 메서드에서 기존 사용자 처리 로직 개선
- `OIDCAuthenticateRequest` import 제거
- 비활성화된 유저 처리 로직 추가

**코드 예시**:
```kotlin
@Service
class OIDCApplicationService(
    private val authenticateService: AuthenticationService,
    private val userDomainPort: UserDomainPort,
    private val socialAccountService: SocialAccountDomainService,
) {
    @Transactional
    fun signUp(request: OIDCSignUpRequest): LoginResponse {
        val oidcUserInfo = authenticateService.getOidcUserInfo(request.provider, request.authorizationCode)
        
        // 기존 사용자 확인 및 생성 (비활성화된 유저는 예외 발생)
        val userInfo = getOrCreateUser(oidcUserInfo.email, oidcUserInfo.name)
        
        // 소셜 계정 연결 (기존 연결이 있으면 활성화)
        socialAccountService.linkSocialAccount(
            LinkSocialAccountCommand(
                user = userInfo,
                provider = request.provider,
                socialId = oidcUserInfo.socialId,
                email = oidcUserInfo.email,
                name = oidcUserInfo.name,
                profileImageUrl = oidcUserInfo.profileImageUrl,
            ),
        )
        
        val authToken = authenticateService.issueOIDCUserAuthToken(oidcUserInfo)
        return LoginResponse(token = authToken.accessToken, refreshToken = authToken.refreshToken)
    }
    
    private fun getOrCreateUser(email: String, name: String): UserInfoDTO {
        val existingUser = userDomainPort.findActiveByEmail(email)
        if (existingUser != null) {
            return existingUser
        }
        
        // 비활성화된 유저가 있는지 확인
        val deactivatedUser = userDomainPort.findByEmail(email)
        if (deactivatedUser != null) {
            throw DeactivatedUserException(email)
        }
        
        return userDomainPort.create(email = email, name = name)
    }
}
```

### 3. 비활성화된 유저 예외 정의 [Pending]
**파일**: `tomo/auth/src/main/kotlin/place/tomo/auth/domain/exception/DeactivatedUserException.kt`

**변경 사항**:
- 비활성화된 유저에 대한 예외 클래스 생성
- HTTP 403 Forbidden 상태 코드 반환

**코드 예시**:
```kotlin
package place.tomo.auth.domain.exception

import org.springframework.http.HttpStatus
import place.tomo.common.exception.BaseHttpException

/**
 * 비활성화된 사용자로 인증을 시도할 때 발생하는 예외
 */
class DeactivatedUserException(
    email: String,
    cause: Throwable? = null,
) : BaseHttpException(
    status = HttpStatus.FORBIDDEN,
    errorCode = "DEACTIVATED_USER",
    message = "비활성화된 사용자입니다: {email}",
    parameters = mapOf("email" to email),
    cause = cause,
)
```

### 4. UserDomainPort 인터페이스 확장 [Pending]
**파일**: `tomo/contract/src/main/kotlin/place/tomo/contract/ports/UserDomainPort.kt`

**변경 사항**:
- `findByEmail()` 메서드 추가 (활성/비활성 상태와 관계없이 조회)

**코드 예시**:
```kotlin
interface UserDomainPort {
    fun findActiveByEmail(email: String): UserInfoDTO?
    
    fun findByEmail(email: String): UserInfoDTO? // 새로 추가
    
    fun create(
        email: String,
        name: String?,
    ): UserInfoDTO

    fun getOrCreate(
        email: String,
        name: String?,
    ): UserInfoDTO

    fun softDelete(userId: UserId)
}
```

### 5. UserDomainAdapter 구현 확장 [Pending]
**파일**: `tomo/user/src/main/kotlin/place/tomo/user/infra/adapters/UserDomainAdapter.kt`

**변경 사항**:
- `findByEmail()` 메서드 구현 추가
- UserRepository의 `findByEmail()` 메서드 활용

**코드 예시**:
```kotlin
@Component
class UserDomainAdapter(
    private val userRepository: UserRepository,
    private val userDomainService: UserDomainService,
) : UserDomainPort {
    override fun findActiveByEmail(email: String): UserInfoDTO? {
        val user = userRepository.findByEmailAndDeletedAtIsNull(email) ?: return null
        return UserInfoDTO(
            id = user.id,
            email = user.email,
            name = user.username,
        )
    }
    
    override fun findByEmail(email: String): UserInfoDTO? {
        val user = userRepository.findByEmail(email) ?: return null
        return UserInfoDTO(
            id = user.id,
            email = user.email,
            name = user.username,
        )
    }
    
    // ... 기존 메서드들
}
```

### 6. 불필요한 Request/Response 클래스 정리 [Pending]
**파일들**:
- `tomo/auth/src/main/kotlin/place/tomo/auth/ui/requests/LoginRequestBody.kt` (삭제)
- `tomo/auth/src/main/kotlin/place/tomo/auth/application/requests/AuthenticateRequest.kt` (OIDCAuthenticateRequest 제거)

**변경 사항**:
- `LoginRequestBody` 클래스 삭제
- `OIDCAuthenticateRequest` 클래스 삭제
- `EmailPasswordAuthenticateRequest`는 유지 (향후 확장 가능성)

### 7. Security 설정 업데이트 [Pending]
**파일**: `tomo/tomo/src/main/kotlin/place/tomo/infra/config/security/SecurityFilterChainConfig.kt`

**변경 사항**:
- `/api/auth/login` 엔드포인트 제거
- `/api/auth/signup`만 유지

**코드 예시**:
```kotlin
private val publicPostEndpoints = arrayOf("/api/auth/signup")
```

### 8. 테스트 설정 업데이트 [Pending]
**파일**: `tomo/common/src/main/kotlin/place/tomo/common/test/security/TestSecurityConfig.kt`

**변경 사항**:
- `/api/auth/login` 엔드포인트 제거
- `/api/oidc/login` 엔드포인트도 제거 (사용하지 않는 경우)

### 9. AuthControllerTest 리팩토링 [Pending]
**파일**: `tomo/auth/src/test/kotlin/place/tomo/auth/ui/controllers/AuthControllerTest.kt`

**변경 사항**:
- `OIDCLogin` 테스트 클래스 제거
- `OIDCAuthentication` 클래스명을 `OIDCSignup`으로 변경
- 기존 signup 테스트는 유지하되, 새로운 통합 로직에 맞게 수정
- 기존 사용자와 신규 사용자 시나리오 모두 테스트

**코드 예시**:
```kotlin
@Nested
@DisplayName("OIDC 회원가입/로그인 통합")
inner class OIDCSignup {
    @Test
    @DisplayName("신규 사용자 OIDC 인증 시 사용자 생성 후 토큰 반환")
    fun `signup when new user expect user created and tokens returned`() {
        // 신규 사용자 시나리오 테스트
    }
    
    @Test
    @DisplayName("기존 사용자 OIDC 인증 시 기존 사용자로 로그인 후 토큰 반환")
    fun `signup when existing user expect existing user login and tokens returned`() {
        // 기존 사용자 시나리오 테스트
    }
    
    @Test
    @DisplayName("기존 사용자에 새로운 소셜 계정 연결 시 계정 연결 후 토큰 반환")
    fun `signup when existing user with new social account expect account linked and tokens returned`() {
        // 기존 사용자 + 새로운 소셜 계정 시나리오 테스트
    }
}
```

### 10. OIDCApplicationServiceTest 리팩토링 [Pending]
**파일**: `tomo/auth/src/test/kotlin/place/tomo/auth/application/services/OIDCApplicationServiceTest.kt`

**변경 사항**:
- `AuthenticateWithOIDC` 테스트 클래스 제거
- `SignUpWithOIDC` 클래스명을 `SignUpWithOIDC`로 유지하되 테스트 케이스 개선
- 기존 사용자 처리 로직에 대한 테스트 추가
- 비활성화된 유저 처리 테스트 케이스 추가

**코드 예시**:
```kotlin
@Nested
@DisplayName("OIDC 회원가입/로그인 통합")
inner class SignUpWithOIDC {
    @Test
    @DisplayName("신규 사용자 OIDC 인증 시 사용자 생성 후 토큰 반환")
    fun `signup when new user expect user created and tokens returned`() {
        // 신규 사용자 시나리오 테스트
    }
    
    @Test
    @DisplayName("기존 활성 사용자 OIDC 인증 시 기존 사용자로 로그인 후 토큰 반환")
    fun `signup when existing active user expect existing user login and tokens returned`() {
        // 기존 활성 사용자 시나리오 테스트
    }
    
    @Test
    @DisplayName("비활성화된 사용자 OIDC 인증 시 403 Forbidden 예외 발생")
    fun `signup when deactivated user expect 403 forbidden exception`() {
        val email = faker.internet().emailAddress()
        val name = faker.name().fullName()
        
        val oidcInfo = OIDCUserInfo(
            OIDCProviderType.GOOGLE,
            socialId = faker.internet().uuid(),
            email = email,
            name = name,
            profileImageUrl = null,
        )
        
        every { authenticationService.getOidcUserInfo(any(), any()) } returns oidcInfo
        every { userDomainPort.findActiveByEmail(email) } returns null
        every { userDomainPort.findByEmail(email) } returns UserInfoDTO(1L, email, name)
        
        assertThatThrownBy {
            service.signUp(OIDCSignUpRequest(OIDCProviderType.GOOGLE, authorizationCode = faker.internet().password()))
        }.isInstanceOf(DeactivatedUserException::class.java)
            .extracting("status")
            .isEqualTo(HttpStatus.FORBIDDEN)
    }
}
```

## Progress Status
1. AuthController 리팩토링 [Pending]
2. OIDCApplicationService 리팩토링 [Pending]
3. 비활성화된 유저 예외 정의 [Pending]
4. UserDomainPort 인터페이스 확장 [Pending]
5. UserDomainAdapter 구현 확장 [Pending]
6. 불필요한 Request/Response 클래스 정리 [Pending]
7. Security 설정 업데이트 [Pending]
8. 테스트 설정 업데이트 [Pending]
9. AuthControllerTest 리팩토링 [Pending]
10. OIDCApplicationServiceTest 리팩토링 [Pending]

## Suggested Next Tasks
- OIDC 인증 실패 시 에러 처리 개선 (현재는 SocialAccountNotLinkedException만 처리)
- 토큰 갱신 API 구현 (refresh token을 이용한 access token 갱신)
- 로그아웃 API 구현 (토큰 무효화)
- 소셜 계정 연결 해제 API 구현
- OIDC 인증 로그 추가 (감사 추적을 위한 로깅)
- 비활성화된 유저 재활성화 API 구현
- 사용자 상태 변경 이력 추적 기능 구현
