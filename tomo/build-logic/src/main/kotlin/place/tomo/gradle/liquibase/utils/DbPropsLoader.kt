package place.tomo.gradle.liquibase.utils

import java.lang.System.getenv

data class DbProps(
    val url: String,
    val username: String,
    val password: String,
    val driver: String,
) {
    init {
        require(url.isNotBlank()) { "url must not be blank" }
        require(username.isNotBlank()) { "username must not be blank" }
        require(password.isNotBlank()) { "password must not be blank" }
        require(driver.isNotBlank()) { "driver must not be blank" }
    }
}

object DbPropsLoader {
    fun load(): DbProps {
        val url = getenv("DATASOURCE_URL") as String
        val username = getenv("DATASOURCE_USERNAME") as String
        val password = getenv("DATASOURCE_PASSWORD") as String
        val driver = getenv("DATASOURCE_DRIVER_CLASS_NAME") as String

        return DbProps(url = url, username = username, password = password, driver = driver)
    }
}
