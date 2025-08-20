// buildSrc import 제거 - Liquibase 설정은 기존 로직 유지

plugins {
    alias(libs.plugins.spring.boot) apply false
    alias(libs.plugins.spring.dependency.management) apply false
    alias(libs.plugins.liquibase) apply false
    alias(libs.plugins.kotlin.jvm)
    alias(libs.plugins.kotlin.spring) apply false
    alias(libs.plugins.kotlin.jpa) apply false
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

    // buildSrc로 분리된 테스트 설정 적용
    TestConfig.configureTestTasks(this)

    dependencies {
        // buildSrc로 분리된 의존성 그룹 적용
        productionDependencies()
        testDependencies()
    }

    // Liquibase 활성화 여부 (모듈별 opt-in)
    val liquibaseEnabled: Boolean = (findProperty("liquibaseEnabled") as String?)?.toBoolean() == true

    if (liquibaseEnabled) {
        apply(plugin = "org.liquibase.gradle")

        dependencies {
            liquibaseDependencies()
            add("liquibaseRuntime", sourceSets.main.get().runtimeClasspath)
        }

        // buildSrc로 분리된 Liquibase 설정 적용
        LiquibaseConfig.configureLiquibase(this)
    }
}

tasks.register("runTomo") {
    dependsOn(":tomo:bootRun")
}
