package com.atulgaurav.processpaths

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import androidx.core.splashscreen.SplashScreen
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // Install Android 12+ splash screen
        val splashScreen = installSplashScreen()
        super.onCreate(savedInstanceState)

        // ⚡ Immediately hide the native splash once Flutter is ready
        splashScreen.setKeepOnScreenCondition { false }
    }
}

