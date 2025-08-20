import org.gradle.api.Project
import org.gradle.api.tasks.testing.Test
import org.gradle.api.tasks.testing.logging.TestExceptionFormat
import org.gradle.kotlin.dsl.withType

/**
 * 테스트 설정을 중앙에서 관리
 */
object TestConfig {
    
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
