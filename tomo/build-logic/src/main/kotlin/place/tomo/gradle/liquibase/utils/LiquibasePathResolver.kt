package place.tomo.gradle.liquibase.utils

import org.gradle.api.Project
import place.tomo.gradle.liquibase.constants.LiquibaseConstants
import java.io.File

class LiquibasePathResolver(
    private val project: Project,
) {
    fun getChangeLogFilePath(): String = LiquibaseConstants.SCHEMA_CHANGELOG

    fun getMigrationsAbsolutePath(): String {
        val module = project.findProperty("module") as String? ?: "main"
        return project.rootProject.file("$module/${LiquibaseConstants.MIGRATIONS_DIR}").absolutePath
    }

    fun getMigrationOutputFileAbsolutePath(outputFileName: String): String {
        val migrationsPath = getMigrationsAbsolutePath()
        return File(migrationsPath, outputFileName).absolutePath
    }

    fun getMigrationOutputFileName(
        timestamp: Long,
        description: String,
    ): String {
        val module = project.findProperty("module") as String? ?: "main"
        return "$timestamp-$description-changelog-$module.sql"
    }

    fun getSearchPaths(): String = project.rootProject.projectDir.absolutePath
}
