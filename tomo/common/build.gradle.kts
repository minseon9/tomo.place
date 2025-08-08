plugins {
    kotlin("jvm")
    kotlin("plugin.spring")
    id("org.springframework.boot")
    id("io.spring.dependency-management")
}

dependencies {
    implementation(project(":contract"))
    implementation("org.springframework.boot:spring-boot-starter-webflux")
    implementation("org.springframework:spring-context")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-reactor")
} 
