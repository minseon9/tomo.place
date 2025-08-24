package place.tomo.gradle

import org.gradle.api.Plugin
import org.gradle.api.Project
import org.gradle.api.tasks.testing.Test
import org.gradle.api.tasks.testing.logging.TestExceptionFormat
import org.gradle.kotlin.dsl.withType

class TestConventionPlugin : Plugin<Project> {
    override fun apply(project: Project) {
        fun configureTestTasks(project: Project) {
            project.tasks.withType<Test> {
                useJUnitPlatform()

                testLogging {
                    events("started", "passed", "skipped", "failed", "standardOut", "standardError")
                    showStandardStreams = true
                    showCauses = true
                    showExceptions = true
                    showStackTraces = true
                    exceptionFormat = TestExceptionFormat.FULL
                }
            }
        }
    }
}
