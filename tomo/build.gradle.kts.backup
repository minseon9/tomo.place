import buildsrc.liquibase.AppendIncludeTask
import buildsrc.liquibase.DbPropsLoader
import buildsrc.liquibase.GenerateMigrationTask
import buildsrc.liquibase.InitMigrationTask

plugins {
    id("org.springframework.boot") version "3.5.0" apply false
    id("io.spring.dependency-management") version "1.1.7" apply false
    id("org.liquibase.gradle") version "2.2.2" apply false
    kotlin("jvm") version "2.1.21"
    kotlin("plugin.spring") version "2.1.21" apply false
    kotlin("plugin.jpa") version "2.1.21" apply false
}

allprojects {
    group = "place.tomo"
    version = "1.0.0-SNAPSHOT"

    repositories {
        mavenCentral()
    }
}

subprojects {
    apply(plugin = "kotlin")
    apply(plugin = "kotlin-spring")
    apply(plugin = "kotlin-jpa")
    apply(plugin = "org.springframework.boot")
    apply(plugin = "io.spring.dependency-management")

    java {
        toolchain {
            languageVersion = JavaLanguageVersion.of(21)
        }
    }

    kotlin {
        compilerOptions {
            freeCompilerArgs.addAll("-Xjsr305=strict")
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_21)
        }
    }

    tasks.getByName<org.springframework.boot.gradle.tasks.bundling.BootJar>("bootJar") {
        enabled = false
    }

    tasks.getByName<Jar>("jar") {
        enabled = true
    }

    tasks.withType<Test> {
        useJUnitPlatform()

        testLogging {
            events("started", "passed", "skipped", "failed", "standardOut", "standardError")
            showStandardStreams = true
            showCauses = true
            showExceptions = true
            showStackTraces = true
            exceptionFormat = org.gradle.api.tasks.testing.logging.TestExceptionFormat.FULL
        }
    }

    dependencies {
        implementation("org.jetbrains.kotlin:kotlin-reflect")
        implementation("org.jetbrains.kotlin:kotlin-stdlib")
        implementation("org.springframework.boot:spring-boot-starter")
        implementation("org.springframework.boot:spring-boot-starter-web")
        implementation("org.springframework.boot:spring-boot-starter-web-services")
        implementation("org.springframework.boot:spring-boot-starter-security")
        implementation("org.springframework.boot:spring-boot-starter-data-jpa")
        implementation("org.springframework.boot:spring-boot-starter-validation")

        runtimeOnly("org.postgresql:postgresql")

        testImplementation("org.springframework.boot:spring-boot-starter-data-jpa")
        testImplementation("org.springframework.boot:spring-boot-starter-test")
        testImplementation("org.springframework.security:spring-security-test")
        testImplementation("org.jetbrains.kotlin:kotlin-test-junit5")
        testImplementation("io.mockk:mockk:1.13.11")
        testImplementation("org.mockito:mockito-core")
        testImplementation("org.mockito:mockito-junit-jupiter")
        testImplementation("com.h2database:h2")
        testImplementation("net.datafaker:datafaker:2.0.1")

        testRuntimeOnly("org.junit.platform:junit-platform-launcher")
    }

    // Liquibase 활성화 여부 (모듈별 opt-in)
    val liquibaseEnabled: Boolean = (findProperty("liquibaseEnabled") as String?)?.toBoolean() == true

    if (liquibaseEnabled) {
        apply(plugin = "org.liquibase.gradle")

        dependencies {
            add("liquibaseRuntime", "org.springframework.boot:spring-boot-starter-data-jpa")
            add("liquibaseRuntime", "org.springframework:spring-context")
            add("liquibaseRuntime", "org.liquibase:liquibase-core")
            add("liquibaseRuntime", "org.liquibase.ext:liquibase-hibernate6:4.33.0")
            add("liquibaseRuntime", "org.postgresql:postgresql")
            add("liquibaseRuntime", "info.picocli:picocli:4.7.5")
            add("liquibaseRuntime", sourceSets.main.get().runtimeClasspath)
        }

        plugins.withId("org.liquibase.gradle") {
            val mainProjectName = rootProject.findProperty("mainProjectName")
            val isMainProject = project.name == mainProjectName
            val moduleBasePath = "${project.name}/src/main/resources/db/changelog"
            val moduleMainChangelog = "$moduleBasePath/db.changelog-${project.name}.yml"
            val mainAggregateChangelog = "$mainProjectName/src/main/resources/db/changelog/db.changelog-main.yml"
            val mainProps = rootProject.file("$mainProjectName/src/main/resources/application.properties")

            configure<org.liquibase.gradle.LiquibaseExtension> {
                val cfg = DbPropsLoader.load(mainProps)

                val changeLogFilePath = if (isMainProject) mainAggregateChangelog else moduleMainChangelog

                // searchPath: 루트 + (메인프로젝트인 경우 모든 활성 모듈의 changelog 디렉토리, 그 외는 해당 모듈)
                val searchPaths: String =
                    buildList {
                        add(project.relativePath(rootProject.projectDir))
                        if (isMainProject) {
                            val enabledModules =
                                rootProject.subprojects.filter {
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

            // 메인 changelog에 현재 모듈의 changelog include 추가 (init 이후)
            val initMigration = tasks.register<InitMigrationTask>("initMigration")
            if (!isMainProject) {
                val appendMain =
                    tasks.register<AppendIncludeTask>("appendMainInclude") {
                        // Include module changelog in aggregate changelog
                        targetChangelogPath = rootProject.file(mainAggregateChangelog).absolutePath
                        includeFilePath = moduleMainChangelog
                        mustRunAfter(initMigration)
                    }
                initMigration.configure { finalizedBy(appendMain) }
            }

            val ts = System.currentTimeMillis()
            val desc = (project.findProperty("desc") as String?) ?: "change"
            val outFile = File(project.projectDir, "src/main/resources/db/changelog/migrations/$ts-$desc-changelog-${project.name}.yml")
            val entityPkg =
                (project.findProperty("liquibaseEntityPackage") as String?)
                    ?: "place.tomo.${project.name}.domain.entities"

            val generateMigration =
                tasks.register<GenerateMigrationTask>("generateMigration") {
                    liquibaseClasspath = configurations.getByName("liquibaseRuntime")
                    entityPackage = entityPkg
                    propertiesFile = mainProps
                    changelogOutputFile = outFile
                }
            generateMigration.configure { dependsOn(tasks.named("classes"), initMigration) }
            val appendModule =
                tasks.register<AppendIncludeTask>("appendMigrationInclude") {
                    // Include generated migration file in module changelog
                    targetChangelogPath = file("src/main/resources/db/changelog/db.changelog-${project.name}.yml").absolutePath
                    includeFilePath = "migrations/$ts-$desc-changelog-${project.name}.yml"
                    mustRunAfter(generateMigration)
                }
            generateMigration.configure { finalizedBy(appendModule) }
        }
    }
}

tasks.register("runTomo") {
    dependsOn(":tomo:bootRun")
}
