package place.tomo.auth.domain.services

import org.springframework.security.oauth2.jose.jws.MacAlgorithm
import org.springframework.security.oauth2.jwt.JwsHeader
import org.springframework.security.oauth2.jwt.JwtClaimsSet
import org.springframework.security.oauth2.jwt.JwtEncoder
import org.springframework.security.oauth2.jwt.JwtEncoderParameters
import org.springframework.stereotype.Service
import place.tomo.auth.domain.dtos.JwtPropertiesDTO
import java.time.Instant

@Service
class JwtProvider(
    private val properties: JwtPropertiesDTO,
    private val jwtEncoder: JwtEncoder,
) {
    fun issueAccessToken(subject: String): String = issueToken(subject, properties.accessTtlSeconds)

    fun issueRefreshToken(subject: String): String = issueToken(subject, properties.refreshTtlSeconds)

    private fun issueToken(
        subject: String,
        expiration: Long,
    ): String {
        val nowInstant = Instant.now()

        val jwtClaims =
            JwtClaimsSet
                .builder()
                .subject(subject)
                .audience(properties.audiences)
                .issuer(properties.issuer)
                .issuedAt(nowInstant)
                .expiresAt(nowInstant.plusSeconds(expiration))
                .build()

        val jwsHeader = JwsHeader.with(MacAlgorithm.HS256).build()

        return jwtEncoder.encode(JwtEncoderParameters.from(jwsHeader, jwtClaims)).tokenValue
    }
}
