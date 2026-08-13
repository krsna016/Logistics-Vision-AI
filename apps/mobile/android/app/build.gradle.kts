plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val releaseStoreFile = System.getenv("SMARTLOAD_KEYSTORE_PATH")
val releaseStorePassword = System.getenv("SMARTLOAD_KEYSTORE_PASSWORD")
val releaseKeyAlias = System.getenv("SMARTLOAD_KEY_ALIAS")
val releaseKeyPassword = System.getenv("SMARTLOAD_KEY_PASSWORD")
val isReleaseTask = gradle.startParameter.taskNames.any {
    it.contains("release", ignoreCase = true)
}

android {
    namespace = "com.vinayak.smartload"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.vinayak.smartload"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (releaseStoreFile != null) storeFile = file(releaseStoreFile)
            storePassword = releaseStorePassword
            keyAlias = releaseKeyAlias
            keyPassword = releaseKeyPassword
        }
    }

    buildTypes {
        release {
            if (isReleaseTask && listOf(
                    releaseStoreFile,
                    releaseStorePassword,
                    releaseKeyAlias,
                    releaseKeyPassword,
                ).any { it.isNullOrBlank() }
            ) {
                throw GradleException(
                    "Release signing requires SMARTLOAD_KEYSTORE_PATH, " +
                        "SMARTLOAD_KEYSTORE_PASSWORD, SMARTLOAD_KEY_ALIAS, and " +
                        "SMARTLOAD_KEY_PASSWORD."
                )
            }
            signingConfig = signingConfigs.getByName("release")
            // ML Kit's current dependency graph is not safe to shrink with R8.
            // Keep release builds functional until the ML Kit package is upgraded.
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
