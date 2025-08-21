import org.gradle.api.GradleException
import java.io.File
import java.util.Properties

data class DbProps(
    val url: String,
    val username: String,
    val password: String,
    val driver: String,
)

object DbPropsLoader {
    fun load(propsFile: File): DbProps {
        if (!propsFile.exists()) {
            throw GradleException("DB properties not found: ${propsFile.absolutePath}")
        }

        val props = Properties().apply { propsFile.inputStream().use(::load) }

        val url = System.getProperty("liquibase.url") ?: props.getProperty("spring.datasource.url").orEmpty()
        val username = System.getProperty("liquibase.username") ?: props.getProperty("spring.datasource.username").orEmpty()
        val password = System.getProperty("liquibase.password") ?: props.getProperty("spring.datasource.password").orEmpty()
        val driver =
            System.getProperty("liquibase.driver")
                ?: props.getProperty("spring.datasource.driver-class-name")
                ?: "org.postgresql.Driver"

        if (url.isBlank() || username.isBlank()) {
            throw GradleException("DB properties missing (url/username)")
        }

        return DbProps(url = url, username = username, password = password, driver = driver)
    }
}
