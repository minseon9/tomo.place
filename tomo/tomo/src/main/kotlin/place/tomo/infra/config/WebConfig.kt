package place.tomo.infra.config

import org.springframework.context.annotation.Configuration
import org.springframework.web.method.support.HandlerMethodArgumentResolver
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer
import place.tomo.common.resolvers.usercontext.UserContextArgumentResolver

@Configuration
class WebConfig(
    private val userContextArgumentResolver: UserContextArgumentResolver,
) : WebMvcConfigurer {
    override fun addArgumentResolvers(resolvers: MutableList<HandlerMethodArgumentResolver>) {
        resolvers.add(userContextArgumentResolver)
    }
}
