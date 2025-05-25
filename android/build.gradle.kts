buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.7.0")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:2.0.20")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
        // Add jcenter as fallback (some plugins may still need it)
        maven { url = uri("https://jcenter.bintray.com") }
        // Add mavenLocal for local dependencies (if any)
        mavenLocal()
    }
}