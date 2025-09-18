package place.tomo.gradle.liquibase.utils

import jakarta.persistence.Entity
import jakarta.persistence.Table
import org.gradle.api.Project
import org.reflections.Reflections
import java.io.File
import java.net.URLClassLoader

object IncludeObjectResolver {
    fun getModuleIncludeObjects(
        project: Project,
        module: String,
    ): String {
        val moduleEntities = scanModuleEntities(project, module)

        return generateIncludeObjects(moduleEntities)
    }

    private fun getClassLoader(
        project: Project,
        module: String,
    ): ClassLoader {
        val classesDirs = mutableSetOf<File>()

        val subproject = project.rootProject.project(":$module")
        val subprojectSourceSets =
            subproject.extensions.getByName("sourceSets") as org.gradle.api.tasks.SourceSetContainer
        val subprojectMainSourceSet = subprojectSourceSets.getByName("main")
        classesDirs.addAll(subprojectMainSourceSet.output.classesDirs.files)

        val classLoaderUrls = classesDirs.map { it.toURI().toURL() }.toTypedArray()

        return URLClassLoader(classLoaderUrls, Thread.currentThread().contextClassLoader)
    }

    private fun scanModuleEntities(
        project: Project,
        module: String,
    ): Set<String> {
        val packageToScan = "place.tomo.$module.domain.entities"
        val classLoader = getClassLoader(project, module)

        val reflections =
            Reflections(
                org.reflections.util
                    .ConfigurationBuilder()
                    .setUrls(
                        org.reflections.util.ClasspathHelper
                            .forPackage(packageToScan, classLoader),
                    ).setScanners(
                        org.reflections.scanners.Scanners.SubTypes,
                        org.reflections.scanners.Scanners.TypesAnnotated,
                    ).setClassLoaders(arrayOf(classLoader)),
            )

        val entityClasses = reflections.getTypesAnnotatedWith(Entity::class.java)

        return entityClasses
            .mapNotNull {
                val loadedClass = classLoader.loadClass(it.name)
                extractTableName(loadedClass)
            }.toSet()
    }

    private fun extractTableName(loadedClass: Class<*>): String {
        val tableAnnotation = loadedClass.getAnnotation(Table::class.java)
        if (tableAnnotation != null && tableAnnotation.name.isNotEmpty()) {
            return tableAnnotation.name
        }

        // NOTE: Hibernate의 naming strategy(SpringPhysicalNamingStrategy)를 직접 사용하기에 복잡도가 있어, 단순히 snake case로 변환
        return loadedClass.simpleName
            .replace(Regex("([a-z])([A-Z])"), "$1_$2")
            .lowercase()
    }

    private fun generateIncludeObjects(tableNames: Set<String>): String = tableNames.joinToString(",") { "table:$it" }
}
