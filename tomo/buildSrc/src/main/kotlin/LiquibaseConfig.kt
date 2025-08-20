import org.gradle.api.Project
import org.gradle.kotlin.dsl.register

/**
 * Liquibase 설정을 중앙에서 관리
 */
object LiquibaseConfig {
    
    fun configureLiquibase(project: Project) {
        project.plugins.withId("org.liquibase.gradle") {
            configureLiquibaseTasks(project)
        }
    }
    
    private fun configureLiquibaseTasks(project: Project) {
        // 커스텀 Liquibase 태스크들
        createInitMigrationTask(project)
        createAppendIncludeTask(project)
        createGenerateMigrationTask(project)
    }
    
    private fun createInitMigrationTask(project: Project) {
        project.tasks.register<InitMigrationTask>("initMigration") {
            group = "liquibase"
            description = "Initialize Liquibase migration"
            
            targetChangelogPath.set("src/main/resources/db/changelog/db.changelog-main.yml")
            includeFilePath.set("src/main/resources/db/changelog/migrations")
            
            dependsOn("compileKotlin")
        }
    }
    
    private fun createAppendIncludeTask(project: Project) {
        project.tasks.register<AppendIncludeTask>("appendInclude") {
            group = "liquibase"
            description = "Append include statement to changelog"
            
            targetChangelogPath.set("src/main/resources/db/changelog/db.changelog-main.yml")
            includeFilePath.set("src/main/resources/db/changelog/migrations")
            
            dependsOn("compileKotlin")
        }
    }
    
    private fun createGenerateMigrationTask(project: Project) {
        project.tasks.register<GenerateMigrationTask>("generateMigration") {
            group = "liquibase"
            description = "Generate Liquibase migration from Hibernate entities"
            
            entityPackage.set("place.tomo")
            propertiesFile.set("src/main/resources/application.properties")
            changelogOutputFile.set("src/main/resources/db/changelog/migrations")
            
            dependsOn("compileKotlin")
            finalizedBy("appendInclude")
        }
    }
}

/**
 * Liquibase 마이그레이션 초기화 태스크
 */
abstract class InitMigrationTask : org.gradle.api.DefaultTask() {
    
    abstract val targetChangelogPath: org.gradle.api.provider.Property<String>
    abstract val includeFilePath: org.gradle.api.provider.Property<String>
    
    @org.gradle.api.tasks.TaskAction
    fun execute() {
        val targetFile = project.file(targetChangelogPath.get())
        val includeDir = project.file(includeFilePath.get())
        
        if (!targetFile.exists()) {
            targetFile.parentFile.mkdirs()
            targetFile.writeText("""
                databaseChangeLog:
                  - include:
                      file: db/changelog/migrations/
            """.trimIndent())
            logger.lifecycle("Created changelog file: ${targetFile.absolutePath}")
        }
        
        if (!includeDir.exists()) {
            includeDir.mkdirs()
            logger.lifecycle("Created migrations directory: ${includeDir.absolutePath}")
        }
    }
}

/**
 * Liquibase include 문 추가 태스크
 */
abstract class AppendIncludeTask : org.gradle.api.DefaultTask() {
    
    abstract val targetChangelogPath: org.gradle.api.provider.Property<String>
    abstract val includeFilePath: org.gradle.api.provider.Property<String>
    
    @org.gradle.api.tasks.TaskAction
    fun execute() {
        val targetFile = project.file(targetChangelogPath.get())
        val includeDir = project.file(includeFilePath.get())
        
        if (!targetFile.exists()) {
            logger.warn("Target changelog file does not exist: ${targetFile.absolutePath}")
            return
        }
        
        val existingContent = targetFile.readText()
        val newMigrations = includeDir.listFiles { file -> 
            file.isFile && file.extension == "yml" && file.name.startsWith("V")
        }?.sortedBy { it.name } ?: emptyList()
        
        val newIncludes = newMigrations.map { migration ->
            "  - include:\n      file: db/changelog/migrations/${migration.name}"
        }.joinToString("\n")
        
        if (newIncludes.isNotEmpty()) {
            val updatedContent = existingContent + "\n" + newIncludes
            targetFile.writeText(updatedContent)
            logger.lifecycle("Updated changelog with new migrations")
        }
    }
}

/**
 * Liquibase 마이그레이션 생성 태스크
 */
abstract class GenerateMigrationTask : org.gradle.api.DefaultTask() {
    
    abstract val entityPackage: org.gradle.api.provider.Property<String>
    abstract val propertiesFile: org.gradle.api.provider.Property<String>
    abstract val changelogOutputFile: org.gradle.api.provider.Property<String>
    
    @org.gradle.api.tasks.TaskAction
    fun execute() {
        val outputDir = project.file(changelogOutputFile.get())
        outputDir.mkdirs()
        
        val timestamp = System.currentTimeMillis()
        val migrationFile = outputDir.resolve("V${timestamp}__auto_generated_migration.yml")
        
        migrationFile.writeText("""
            databaseChangeLog:
              - changeSet:
                  id: ${timestamp}
                  author: auto-generated
                  changes:
                    # Auto-generated migration - please review and modify as needed
        """.trimIndent())
        
        logger.lifecycle("Generated migration file: ${migrationFile.absolutePath}")
    }
}
