plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.jarpay" 
    compileSdk = flutter.compileSdkVersion

    defaultConfig {
        applicationId = "com.example.jarpay" 
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        versionCode = 1      
        versionName = "1.0"   
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    // Fix mergeJavaResource conflict (Stripe + BouncyCastle)
    packagingOptions {
        resources {
            excludes += setOf(
                "org/bouncycastle/x509/CertPathReviewerMessages.properties",
                "org/bouncycastle/x509/CertPathReviewerMessages_de.properties",
                "META-INF/DEPENDENCIES",
                "META-INF/LICENSE",
                "META-INF/LICENSE.txt",
                "META-INF/NOTICE",
                "META-INF/NOTICE.txt"
            )
        }
    }

    // Suppress Java 8 warnings
    tasks.withType<JavaCompile> {
        options.compilerArgs.add("-Xlint:-options")
        options.compilerArgs.add("-Xlint:-deprecation")
    }

    buildTypes {
        debug {
            signingConfig = signingConfigs.getByName("debug")
        }
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}
