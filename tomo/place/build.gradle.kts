dependencies {
    implementation(project(":contract"))
    implementation(project(":common"))

    // 번들 그룹 활용
    implementation(libs.bundles.auth.core)
    implementation(libs.bundles.kotlinx.coroutines)
    implementation(libs.bundles.postgresql)
}
