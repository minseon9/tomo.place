package place.tomo.gradle.liquibase.constants

object LiquibaseConstants {
    const val CHANGELOG_DIR = "src/main/resources/db/changelog"
    const val MIGRATIONS_DIR = "migrations"

    const val MAIN_PROJECT_NAME_PROPERTY = "mainProjectName"
    const val LIQUIBASE_ENABLED_PROPERTY = "liquibaseEnabled"
    const val LIQUIBASE_ENTITY_PACKAGE_PROPERTY = "liquibaseEntityPackage"
    const val DESC_PROPERTY = "desc"

    const val DEFAULT_ENTITY_PACKAGE_PREFIX = "place.tomo"
    const val DEFAULT_DESC = "change"

    const val ACTIVITY_NAME = "main"
    const val LOG_LEVEL = "DEBUG"
    const val VERBOSE = "true"
}
