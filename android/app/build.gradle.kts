plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.buldm"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "28.0.13004108"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.buldm"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 23
        targetSdk = 33
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
            // Ensure R8/ProGuard keeps required classes (e.g., TensorFlow Lite GPU)
            isMinifyEnabled = true
            // Remove unused resources alongside code shrinking to reduce APK size
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                file("proguard-rules.pro")
            )
        }
    }

    // Generate smaller, per-ABI APKs instead of a single fat APK
    splits {
        abi {
            isEnable = true
            reset()
            // Include common ABIs for both device (ARM) and emulator (x86_64)
            include("armeabi-v7a", "arm64-v8a", "x86_64")
            // Keep a universal APK in debug runs to avoid missing libflutter.so
            isUniversalApk = true
        }
    }

    // Exclude unnecessary META-INF artifacts to slightly reduce size
    packaging {
        resources {
            excludes += "/META-INF/{AL2.0,LGPL2.1,LICENSE*,NOTICE*,*.kotlin_module}"
        }
    }
}

flutter {
    source = "../.."
}
dependencies {
}