package place.tomo.auth.domain.services.jwt

import org.springframework.security.oauth2.jose.jws.MacAlgorithm
import org.springframework.security.oauth2.jwt.JwsHeader
import org.springframework.security.oauth2.jwt.JwtClaimsSet
import org.springframework.security.oauth2.jwt.JwtEncoder
import org.springframework.security.oauth2.jwt.JwtEncoderParameters
import org.springframework.stereotype.Service
import place.tomo.auth.domain.constants.JwtType
import place.tomo.auth.domain.dtos.JwtPropertiesDTO
import place.tomo.auth.domain.dtos.JwtToken
import java.time.Instant

@Service
class JwtProvider(
    private val properties: JwtPropertiesDTO,
    private val jwtEncoder: JwtEncoder,
) {
    fun issueAccessToken(subject: String): JwtToken = issueToken(subject, JwtType.ACCESS, properties.accessTtlSeconds)

    fun issueRefreshToken(subject: String): JwtToken = issueToken(subject, JwtType.REFRESH, properties.refreshTtlSeconds)

    private fun issueToken(
        subject: String,
        type: JwtType,
        expiration: Long,
    ): JwtToken {
        val expiresAt = Instant.now().plusSeconds(expiration)

        val jwtClaims =
            JwtClaimsSet
                .builder()
                .subject(subject)
                .audience(properties.audiences)
                .issuer(properties.issuer)
                .expiresAt(expiresAt)
                .claim("type", type)
                .build()

        val jwsHeader = JwsHeader.with(MacAlgorithm.HS256).build()

        val token = jwtEncoder.encode(JwtEncoderParameters.from(jwsHeader, jwtClaims)).tokenValue

        return JwtToken(token = token, expiresAt = expiresAt)
    }
}
