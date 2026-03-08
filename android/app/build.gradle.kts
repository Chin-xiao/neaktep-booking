import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

// 1. LOAD LOCAL PROPERTIES: Using a direct import to avoid the "util" error
val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localPropertiesFile.inputStream().use { 
        localProperties.load(it) 
    }
}

android {
    namespace = "com.example.neak_booking_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17 // Changed from 8
        targetCompatibility = JavaVersion.VERSION_17 // Changed from 8
    }

    kotlin {
        compilerOptions {
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17) // Ensure this is 17
        }
    }

    defaultConfig {
        applicationId = "com.example.neak_booking_app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // 2. INJECT KEY INTO MANIFEST: Resolves the placeholder error
        manifestPlaceholders["mapsApiKey"] = localProperties.getProperty("mapsApiKey") ?: ""
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}