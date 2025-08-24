plugins {
    `kotlin-dsl`
    `java-gradle-plugin`
}

dependencies {
    implementation(libs.liquibase.gradle.plugin)
    implementation("org.yaml:snakeyaml:2.2")
}

gradlePlugin {
    plugins {
        create("testConvention") {
            id = "place.tomo.gradle.test-convention"
            implementationClass = "place.tomo.gradle.TestConventionPlugin"
        }
        create("liquibaseConvention") {
            id = "place.tomo.gradle.liquibase-convention"
            implementationClass = "place.tomo.gradle.liquibase.LiquibaseConventionPlugin"
        }
    }
}
