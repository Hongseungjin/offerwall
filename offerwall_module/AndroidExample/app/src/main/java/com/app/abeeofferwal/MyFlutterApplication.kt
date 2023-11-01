package com.app.abeeofferwal

import android.app.Application
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor


class MyFlutterApplication : Application() {
    companion object {
        const val ENGINE_ID = "offerwall_engine"
    }
    private lateinit var flutterEngine: FlutterEngine
    override fun onCreate() {
        super.onCreate()
        // This application reuses a single FlutterEngine instance throughout.
        // Create the FlutterEngine on application start.
        flutterEngine = FlutterEngine(this).apply{
            dartExecutor.executeDartEntrypoint(DartExecutor.DartEntrypoint.createDefault())
        }

        FlutterEngineCache.getInstance().put(ENGINE_ID, flutterEngine)

    }

}
