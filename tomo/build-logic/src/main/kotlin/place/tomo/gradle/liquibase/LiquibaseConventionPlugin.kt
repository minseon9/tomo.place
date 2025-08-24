package place.tomo.gradle.liquibase

import place.tomo.gradle.liquibase.config.LiquibaseConfig
import place.tomo.gradle.liquibase.constants.LiquibaseConstants
import org.gradle.api.Plugin
import org.gradle.api.Project
import org.gradle.api.artifacts.VersionCatalogsExtension
import org.gradle.api.plugins.JavaPluginExtension
import org.gradle.kotlin.dsl.getByType

class LiquibaseConventionPlugin : Plugin<Project> {
    override fun apply(project: Project) {
        // 기존과 동일한 조건 체크
        val liquibaseEnabled =
            project
                .findProperty(LiquibaseConstants.LIQUIBASE_ENABLED_PROPERTY)
                ?.toString()
                ?.toBoolean() ?: false

        if (!liquibaseEnabled) {
            project.logger.info("Liquibase is disabled for ${project.name}")
            return
        }

        // libs 카탈로그를 통해 liquibase plugin 적용
        val libs =
            project.rootProject.extensions
                .getByType<VersionCatalogsExtension>()
                .named("libs")
        project.plugins.apply(
            libs
                .findPlugin("liquibase")
                .get()
                .get()
                .pluginId,
        )

        // 기존 의존성 추가 로직 - libs 카탈로그 사용
        project.dependencies.apply {
            add("liquibaseRuntime", libs.findLibrary("spring.boot.starter.data.jpa").get())
            add("liquibaseRuntime", libs.findLibrary("spring.context").get())
            add("liquibaseRuntime", libs.findLibrary("liquibase.core").get())
            add("liquibaseRuntime", libs.findLibrary("liquibase.hibernate6").get())
            add("liquibaseRuntime", libs.findLibrary("postgresql").get())
            add("liquibaseRuntime", libs.findLibrary("picocli").get())
            add(
                "liquibaseRuntime",
                project.extensions
                    .getByType<JavaPluginExtension>()
                    .sourceSets
                    .getByName("main")
                    .runtimeClasspath,
            )
        }

        // 기존 LiquibaseConfig.configureLiquibase 로직 적용
        LiquibaseConfig.configureLiquibase(project)
    }
}
