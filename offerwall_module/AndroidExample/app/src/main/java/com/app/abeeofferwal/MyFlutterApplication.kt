package com.app.abeeofferwal

import android.app.Activity
import android.app.Application
import androidx.multidex.MultiDexApplication
import androidx.navigation.NavController
import androidx.navigation.findNavController
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel


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
//
//        var data: Api.Offerwall = Api.Offerwall()
//        data.memId= "abee997"
//        data.memGen= "w"
//        data.memBirth= "2000-01-01"
//        data.memRegion= "인천_서"
//        data.firebaseKey= "key=AAAArCrKtcY:APA91bHDmRlnGIMV9TUWHBgdx_cW59irrr6GssIkX45DUSHiTXcfHV3b0MynCOxwUdm6VTTxhp7lz3dIqAbi0SnoUFnkXlK-0ncZMX-3a3oWV8ywqaEm9A9aGnX-k50SI19hzqOgprRp"
//
//        Api.FlutterOfferwallApi(flutterEngine.dartExecutor).displayOfferwallDetails(data) {
//            // We don't care about the callback
//        }

        FlutterEngineCache.getInstance().put(ENGINE_ID, flutterEngine)

    }

}
