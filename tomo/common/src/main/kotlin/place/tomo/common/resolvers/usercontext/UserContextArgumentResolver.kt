package place.tomo.common.resolvers.usercontext

import place.tomo.contract.ports.UserQueryPort
import org.springframework.core.MethodParameter
import org.springframework.security.core.Authentication
import org.springframework.security.core.context.SecurityContextHolder
import org.springframework.stereotype.Component
import org.springframework.web.bind.support.WebDataBinderFactory
import org.springframework.web.context.request.NativeWebRequest
import org.springframework.web.method.support.HandlerMethodArgumentResolver
import org.springframework.web.method.support.ModelAndViewContainer

@Component
class UserContextArgumentResolver(
    private val userQueryPort: UserQueryPort,
) : HandlerMethodArgumentResolver {
    override fun supportsParameter(parameter: MethodParameter): Boolean =
        parameter.parameterType == UserContext::class.java ||
            parameter.hasParameterAnnotation(CurrentUser::class.java)

    override fun resolveArgument(
        parameter: MethodParameter,
        mavContainer: ModelAndViewContainer?,
        webRequest: NativeWebRequest,
        binderFactory: WebDataBinderFactory?,
    ): UserContext? {
        val authentication = SecurityContextHolder.getContext().authentication

        return if (authentication != null) {
            resolveUserContext(authentication)
        } else {
            null
        }
    }

    private fun resolveUserContext(authentication: Authentication): UserContext {
        val email = authentication.name
        val user =
            userQueryPort.findByEmail(email)
                ?: throw IllegalStateException("인증된 사용자를 찾을 수 없습니다: $email")

        return UserContext.from(
            userId = user.id,
            email = user.email,
            name = user.name,
        )
    }
}
