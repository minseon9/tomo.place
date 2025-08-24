plugins {
    alias(libs.plugins.spring.boot) apply false
    alias(libs.plugins.spring.dependency.management) apply false
    alias(libs.plugins.kotlin.jvm)
    alias(libs.plugins.kotlin.spring) apply false
    alias(libs.plugins.kotlin.jpa) apply false

    id("place.tomo.gradle.test-convention") apply false
    id("place.tomo.gradle.liquibase-convention") apply false
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

    apply(plugin = "place.tomo.gradle.test-convention")
    apply(plugin = "place.tomo.gradle.liquibase-convention")

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

    val libs = rootProject.libs
    dependencies {
        implementation(libs.bundles.kotlin.basic)
        implementation(libs.bundles.spring.boot.core)
        implementation(libs.bundles.spring.boot.web.services)
        implementation(libs.bundles.spring.boot.data)
        runtimeOnly(libs.postgresql)

        testImplementation(libs.bundles.testing.core)
        testImplementation(libs.bundles.testing.mock)
        testImplementation(libs.bundles.testing.utils)
        testImplementation(libs.spring.boot.starter.data.jpa)

        testRuntimeOnly(libs.junit.platform.launcher)
    }
}

tasks.register("runTomo") {
    dependsOn(":tomo:bootRun")
}
