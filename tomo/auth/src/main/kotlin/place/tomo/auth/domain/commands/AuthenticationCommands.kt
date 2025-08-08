
import place.tomo.contract.constant.AuthenticationType
import place.tomo.contract.constant.OIDCProviderType

sealed class AuthCredentials

data class OAuthCredentials(
    val provider: OIDCProviderType,
    val code: String,
) : AuthCredentials()

data class EmailPasswordCredentials(
    val email: String,
    val password: String,
) : AuthCredentials()

sealed class AuthenticationCommand {
    abstract fun getAuthType(): AuthenticationType

    abstract fun toCredentials(): AuthCredentials
}

data class EmailLoginCommand(
    val email: String,
    val password: String,
) : AuthenticationCommand() {
    override fun getAuthType() = AuthenticationType.EMAILPASSWORD

    override fun toCredentials() = EmailPasswordCredentials(email, password)
}

data class OAuthLoginCommand(
    val provider: OIDCProviderType,
    val code: String,
) : AuthenticationCommand() {
    override fun getAuthType() = AuthenticationType.OAUTH

    override fun toCredentials() = OAuthCredentials(provider, code)
}
