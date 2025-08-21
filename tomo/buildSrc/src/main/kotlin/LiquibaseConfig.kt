import org.gradle.api.Project
import org.gradle.kotlin.dsl.configure
import org.gradle.kotlin.dsl.register
import org.liquibase.gradle.LiquibaseExtension
import java.io.File

object LiquibaseConfig {
    fun configureLiquibase(project: Project) {
        project.plugins.withId("org.liquibase.gradle") {
            configureLiquibaseTasks(project)
        }
    }

    private fun configureLiquibaseTasks(project: Project) {
        registerMainActivity(project)
        createInitMigrationTask(project)
        createAppendIncludeTask(project)
        createGenerateMigrationTask(project)
    }

    private fun registerMainActivity(project: Project) {
        val mainProjectName = project.rootProject.findProperty("mainProjectName") as String
        val isMainProject = project.name == mainProjectName
        val moduleBasePath = "${project.name}/src/main/resources/db/changelog"
        val moduleMainChangelog = "$moduleBasePath/db.changelog-${project.name}.yml"
        val mainAggregateChangelog = "$mainProjectName/src/main/resources/db/changelog/db.changelog-main.yml"
        val mainProps = project.rootProject.file("$mainProjectName/src/main/resources/application.properties")

        val cfg = DbPropsLoader.load(mainProps)
        val changeLogFilePath = if (isMainProject) mainAggregateChangelog else moduleMainChangelog

        val searchPaths: String =
            buildList {
                add(project.relativePath(project.rootProject.projectDir))
                if (isMainProject) {
                    val enabledModules =
                        project.rootProject.subprojects.filter {
                            (it.findProperty("liquibaseEnabled") as String?)?.toBoolean() == true
                        }
                    addAll(
                        enabledModules.map {
                            project.relativePath(it.projectDir.resolve("src/main/resources/db/changelog"))
                        },
                    )
                } else {
                    add(project.relativePath(project.projectDir.resolve("src/main/resources/db/changelog")))
                }
            }.joinToString(",")

        project.extensions.configure<LiquibaseExtension> {
            activities.register("main") {
                arguments =
                    mapOf(
                        "changeLogFile" to changeLogFilePath,
                        "url" to cfg.url,
                        "username" to cfg.username,
                        "password" to cfg.password,
                        "driver" to cfg.driver,
                        "logLevel" to "DEBUG",
                        "verbose" to "true",
                        "searchPath" to searchPaths,
                    )
            }
        }
    }

    private fun createInitMigrationTask(project: Project) {
        project.tasks.register<InitMigrationTask>("initMigration") {
            group = "liquibase"
            description = "Initialize Liquibase migration"

//            targetChangelogPath.set("src/main/resources/db/changelog/db.changelog-main.yml")
//            includeFilePath.set("src/main/resources/db/changelog/migrations")

            dependsOn("compileKotlin")
        }
    }

    private fun createGenerateMigrationTask(project: Project) {
        val ts = System.currentTimeMillis()
        val desc = (project.findProperty("desc") as String?) ?: "change"
        val outFile = File(project.projectDir, "src/main/resources/db/changelog/migrations/$ts-$desc-changelog-${project.name}.yml")
        val entityPkg =
            (project.findProperty("liquibaseEntityPackage") as String?)
                ?: "place.tomo.${project.name}.domain.entities"

        project.tasks.register<GenerateMigrationTask>("generateMigration") {
            group = "liquibase"
            description = "Generate Liquibase migration from Hibernate entities"
            liquibaseClasspath = configurations.getByName("liquibaseRuntime")
            entityPackage = entityPkg
            propertiesFile = mainProps
            changelogOutputFile = outFile

            dependsOn("compileKotlin")
            finalizedBy("appendInclude")
        }
    }

    private fun createAppendIncludeTask(project: Project) {
        project.tasks.register<AppendIncludeTask>("appendInclude") {
            group = "liquibase"
            description = "Append include statement to changelog"

            targetChangelogPath = File("src/main/resources/db/changelog/db.changelog-${project.name}.yml").absolutePath
            includeFilePath = "migrations/$ts-$desc-changelog-${project.name}.yml"

            dependsOn("compileKotlin")
        }
    }
}
