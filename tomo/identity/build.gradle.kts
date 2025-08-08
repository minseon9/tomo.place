dependencies {
    // Common module
    implementation(project(":common"))
    implementation(project(":contract"))

    // JWT
    implementation("io.jsonwebtoken:jjwt-api:0.12.5")
    runtimeOnly("io.jsonwebtoken:jjwt-impl:0.12.5")
    runtimeOnly("io.jsonwebtoken:jjwt-jackson:0.12.5")

    // WebFlux for configuration
    implementation("org.springframework.boot:spring-boot-starter-webflux")

    // Coroutines
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-reactor")

    // FIXME: feign client 사용하지 않을 것임
    // Spring Cloud OpenFeign
//    implementation("org.springframework.cloud:spring-cloud-starter-openfeign")
//    implementation("org.springframework.cloud:spring-cloud-openfeign-core")

//    implementation("org.liquibase.ext:liquibase-hibernate6:4.33.0") // 추가
//    runtimeOnly("org.postgresql:postgresql")
//    runtimeOnly("org.liquibase:liquibase-core") // 추가
//
//    liquibaseRuntime("org.springframework.boot:spring-boot-starter-data-jpa")
//    liquibaseRuntime("org.springframework:spring-context")
//    // liquibase CLI용 의존성만 남김
//    liquibaseRuntime("org.liquibase:liquibase-core")
//    liquibaseRuntime("org.liquibase.ext:liquibase-hibernate6:4.33.0")
//    liquibaseRuntime("org.postgresql:postgresql")
//    liquibaseRuntime("info.picocli:picocli:4.7.5")
//
//    liquibaseRuntime(sourceSets.main.get().runtimeClasspath)
}

// liquibase {
//    activities.register("main") {
//        this.arguments =
//            mapOf(
//                "changelogFile" to "identity/src/main/resources/db/changelog/migrations/db.changelog-user.yml",
//                "url" to "jdbc:postgresql://localhost:5432/tomo",
//                "username" to "postgres",
//                "password" to "postgres",
//                "driver" to "org.postgresql.Driver",
//                "referenceUrl" to
//                    "hibernate:spring:place.tomo.user.domain.entities?dialect=org.hibernate.dialect.PostgreSQLDialect&hibernate.physical_naming_strategy=org.hibernate.boot.model.naming.CamelCaseToUnderscoresNamingStrategy&hibernate.implicit_naming_strategy=org.springframework.boot.orm.jpa.hibernate.SpringImplicitNamingStrategy",
//                "referenceDriver" to "liquibase.ext.hibernate.database.connection.HibernateDriver",
//                "logLevel" to "DEBUG", // 디버그 로깅 추가
//                "verbose" to "true", // 상세 출력 추가
//            )
//    }
//    runList = "main"
// }

// 컴파일 후 diffChangeLog 실행하는 태스크
// tasks.register("generateMigration") {
//    group = "liquibase"
//    description = "Generate migration from entity changes"
//
//    dependsOn("compileKotlin", "compileJava")
//
//    doLast {
//        println("=== Starting Migration Generation ===")
//
//        // 현재 상태 확인
//        providers.exec {
//            commandLine("./gradlew", ":identity:diffChangeLog")
//        }
//
//        println("=== Migration Generated ===")
//        println("Check: identity/src/main/resources/db/changelog/migrations/db.changelog-user.yml")
//    }
// }
