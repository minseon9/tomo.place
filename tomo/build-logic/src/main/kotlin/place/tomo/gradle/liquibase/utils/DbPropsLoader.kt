package place.tomo.gradle.liquibase.utils

import org.gradle.api.Project
import place.tomo.gradle.liquibase.constants.LiquibaseConstants

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
    fun load(project: Project): DbProps {
        val url = project.findProperty(LiquibaseConstants.DATASOURCE_URL_PROPERTY)!! as String
        val username = project.findProperty(LiquibaseConstants.DATASOURCE_USERNAME_PROPERTY)!! as String
        val password = project.findProperty(LiquibaseConstants.DATASOURCE_PASSWORD_PROPERTY)!! as String
        val driver = project.findProperty(LiquibaseConstants.DATASOURCE_DRIVER_CLASS_NAME_PROPERTY)!! as String

        return DbProps(url = url, username = username, password = password, driver = driver)
    }
}
