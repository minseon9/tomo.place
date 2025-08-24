package place.tomo.gradle.liquibase.utils

import org.gradle.api.Project
import place.tomo.gradle.liquibase.constants.LiquibaseConstants

data class LiquibaseProjectContext(
    val pathResolver: LiquibasePathResolver,
    val dbProps: DbProps,
    val entityPackage: String,
) {
    companion object {
        fun create(project: Project): LiquibaseProjectContext {
            val pathResolver = LiquibasePathResolver(project)
            val dbProps = DbPropsLoader.load()
            val entityPackage =
                project.findProperty(LiquibaseConstants.LIQUIBASE_ENTITY_PACKAGE_PROPERTY) as String?
                    ?: "${LiquibaseConstants.DEFAULT_ENTITY_PACKAGE_PREFIX}.${project.name}.domain.entities"

            return LiquibaseProjectContext(pathResolver, dbProps, entityPackage)
        }
    }
}
