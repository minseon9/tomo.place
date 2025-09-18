package place.tomo.infra.config.security

import com.nimbusds.jose.jwk.source.ImmutableSecret
import org.springframework.beans.factory.annotation.Value
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.core.convert.converter.Converter
import org.springframework.security.authentication.AbstractAuthenticationToken
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken
import org.springframework.security.oauth2.core.DelegatingOAuth2TokenValidator
import org.springframework.security.oauth2.core.OAuth2Error
import org.springframework.security.oauth2.core.OAuth2TokenValidator
import org.springframework.security.oauth2.core.OAuth2TokenValidatorResult
import org.springframework.security.oauth2.jose.jws.MacAlgorithm
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.security.oauth2.jwt.JwtDecoder
import org.springframework.security.oauth2.jwt.JwtEncoder
import org.springframework.security.oauth2.jwt.JwtValidators
import org.springframework.security.oauth2.jwt.NimbusJwtDecoder
import org.springframework.security.oauth2.jwt.NimbusJwtEncoder
import place.tomo.auth.domain.dtos.JwtPropertiesDTO
import place.tomo.auth.domain.exception.InvalidJwtSecretException
import place.tomo.common.exception.NotFoundActiveUserException
import place.tomo.contract.dtos.AuthorizedUserDTO
import place.tomo.contract.ports.UserDomainPort
import java.util.UUID
import javax.crypto.spec.SecretKeySpec

@Configuration
class JwtConfig(
    private val properties: JwtPropertiesDTO,
    @Value("\${security.jwt.secret}") private val jwtSecret: String,
) {
    companion object {
        const val SECRET_MIN_LENGTH = 32
    }

    @Bean
    fun jwtEncoder(): JwtEncoder {
        if (jwtSecret.length < SECRET_MIN_LENGTH) throw InvalidJwtSecretException()

        return NimbusJwtEncoder(ImmutableSecret(jwtSecret.toByteArray()))
    }

    @Bean
    fun jwtDecoder(): JwtDecoder {
        val algorithm = MacAlgorithm.HS256
        val key = SecretKeySpec(jwtSecret.toByteArray(), algorithm.toString())

        val decoder = NimbusJwtDecoder.withSecretKey(key).macAlgorithm(algorithm).build()

        val validator = createDecoderValidator()
        decoder.setJwtValidator(validator)

        return decoder
    }

    @Bean
    fun jwtAuthenticationConverter(userDomainPort: UserDomainPort): Converter<Jwt, out AbstractAuthenticationToken> =
        Converter { jwt ->
            val user =
                userDomainPort.findActiveByEntityId(jwt.subject)
                    ?: throw NotFoundActiveUserException(jwt.subject)

            val authorizedUser =
                AuthorizedUserDTO(
                    id = user.id,
                    entityId = jwt.subject,
                    email = user.email,
                )

            UsernamePasswordAuthenticationToken(authorizedUser, "n/a", emptyList())
        }

    private fun createDecoderValidator(): DelegatingOAuth2TokenValidator<Jwt> {
        val withIssuer: OAuth2TokenValidator<Jwt> =
            JwtValidators.createDefaultWithIssuer(properties.issuer)
        val audienceValidator = AudienceValidator(properties.audiences)

        return DelegatingOAuth2TokenValidator(withIssuer, audienceValidator)
    }

    private class AudienceValidator(
        private val audience: List<String>,
    ) : OAuth2TokenValidator<Jwt> {
        override fun validate(jwt: Jwt): OAuth2TokenValidatorResult {
            val validAudiences = jwt.audience.toSet() intersect audience.toSet()
            if (validAudiences.isNotEmpty()) {
                return OAuth2TokenValidatorResult.success()
            }

            return OAuth2TokenValidatorResult.failure(
                OAuth2Error(
                    "invalid_token",
                    "invalid audience is missing",
                    null,
                ),
            )
        }
    }
}
