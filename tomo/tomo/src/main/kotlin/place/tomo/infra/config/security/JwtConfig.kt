package place.tomo.infra.config.security

import com.nimbusds.jose.jwk.source.ImmutableSecret
import org.springframework.beans.factory.annotation.Value
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.security.oauth2.jose.jws.MacAlgorithm
import org.springframework.security.oauth2.jwt.JwtDecoder
import org.springframework.security.oauth2.jwt.JwtEncoder
import org.springframework.security.oauth2.jwt.NimbusJwtDecoder
import org.springframework.security.oauth2.jwt.NimbusJwtEncoder
import place.tomo.auth.domain.exception.InvalidJwtSecretException
import javax.crypto.spec.SecretKeySpec

@Configuration
class JwtConfig(
    @Value("\${security.jwt.secret}") private val jwtSecret: String,
) {
    @Bean
    fun jwtEncoder(): JwtEncoder {
        if (jwtSecret.length < 32) throw InvalidJwtSecretException()

        return NimbusJwtEncoder(ImmutableSecret(jwtSecret.toByteArray()))
    }

    @Bean
    fun jwtDecoder(): JwtDecoder {
        val algorithm = MacAlgorithm.HS256
        val key = SecretKeySpec(jwtSecret.toByteArray(), algorithm.toString())

        return NimbusJwtDecoder.withSecretKey(key).macAlgorithm(algorithm).build()
    }
}
