plugins {
    id("org.liquibase.gradle") version "2.2.0"
}

dependencies {
    implementation(project(":member"))
    implementation(project(":auth"))
    implementation("org.springframework.boot:spring-boot-starter-actuator")
    implementation("org.springframework.boot:spring-boot-starter-security")
    developmentOnly("org.springframework.boot:spring-boot-devtools")
    testImplementation("org.springframework.security:spring-security-test")

    // liquibase CLI용 의존성만 남김
    liquibaseRuntime("org.liquibase:liquibase-core")
    liquibaseRuntime("org.postgresql:postgresql")
    liquibaseRuntime("info.picocli:picocli:4.7.5")
}

tasks.bootJar {
    enabled = true
    archiveClassifier = "" // 기본 jar로 설정
}

liquibase {
    activities.register("main") {
        this.arguments =
            mapOf(
                "changelogFile" to "mapa/src/main/resources/db/changelog/db.changelog-master.xml",
                "url" to "jdbc:postgresql://localhost:5432/mapa",
                "username" to "postgres",
                "password" to "postgres",
                "driver" to "org.postgresql.Driver",
            )
    }
    runList = "main"
}
