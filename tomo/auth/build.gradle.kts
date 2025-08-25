dependencies {
    implementation(project(":contract"))
    implementation(project(":common"))

    // 번들 그룹 활용
    implementation(libs.bundles.auth.core)
    implementation(libs.bundles.kotlinx.coroutines)

    // JWT 전용 의존성
    implementation(libs.jjwt.api)
    runtimeOnly(libs.jjwt.impl)
    runtimeOnly(libs.jjwt.jackson)
    testImplementation(libs.kotlinx.coroutines.test)
}
