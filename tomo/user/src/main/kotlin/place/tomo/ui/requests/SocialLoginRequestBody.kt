package place.tomo.ui.requests

// FIXME: domain layer constant -> Contract 서브 모듈에 공통 constant 정의해서 사용
import place.tomo.domain.constant.OAuthProvider

data class SocialLoginRequestBody(
    val provider: OAuthProvider,
    val authorizationCode: String,
)
