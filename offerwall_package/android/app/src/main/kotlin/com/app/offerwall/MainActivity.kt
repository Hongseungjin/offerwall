package com.app.abeeofferwal

//import android.widget.Toast
//import com.kyad.adlibrary.AppAllOfferwallSDK
import android.os.Bundle
import android.view.KeyEvent
import android.widget.Toast
import com.example.eums.EumsPlugin
import flutter.overlay.window.flutter_overlay_window.OverlayConstants
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel


class MainActivity : FlutterActivity(), MethodChannel.MethodCallHandler {

//    private var flutterChannel: MethodChannel? = null
//    private var CHANNEL = "com.app.abeeofferwal"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

    }



    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
//         channel = MethodChannel(flutterEngine?.dartExecutor!!.binaryMessenger, CHANNEL)

//        flutterChannel = MethodChannel(
//            flutterEngine?.dartExecutor!!.binaryMessenger,
//            CHANNEL
//        )
//        channel.setMethodCallHandler { call, result ->
//            val data = call.arguments
//
//            if (call.arguments == "dataUser"){
//                println("myIdUser1231237618237 $data" )
//            }
//
//        }
    }

    //    override fun dispatchKeyEvent(event: KeyEvent?): Boolean {
//        if(event?.keyCode == KeyEvent.KEYCODE_BACK){
//            Toast.makeText(this@MainActivity, "dispatchKeyEvent KeyEvent.KEYCODE_BACK", Toast.LENGTH_SHORT).show()
//        }
//        return super.dispatchKeyEvent(event)
//
//    }
//
    override fun onKeyDown(keyCode: Int, event: KeyEvent?): Boolean {
        super.onKeyDown(keyCode, event)
        if (keyCode == KeyEvent.KEYCODE_BACK) {
//            try {
//                if (OverlayService.isRunning) {
//                    val i = Intent(context, OverlayService::class.java)
//                    i.putExtra(OverlayService.INTENT_EXTRA_IS_CLOSE_WINDOW, true)
//                    context.startService(i)
//                }
//            } catch (error: Exception) {
//            }
//            flutterChannel?.invokeMethod("KEYCODE_BACK", null)
//            Toast.makeText(
//                this@MainActivity,
//                "dispatchKeyEvent KeyEvent.KEYCODE_BACK",
//                Toast.LENGTH_SHORT
//            ).show()
        }
        return true;

    }

    override fun onUserLeaveHint() {
        super.onUserLeaveHint()
//        flutterChannel?.invokeMethod("KEYCODE_HOME", null)
//
//        Toast.makeText(
//            this@MainActivity,
//            "dispatchKeyEvent KeyEvent.HOME",
//            Toast.LENGTH_SHORT
//        ).show()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        EumsPlugin.channelCallBackMain = MethodChannel(
            flutterEngine?.dartExecutor!!.binaryMessenger,
            EumsPlugin.channelCallBack
        )
//        flutterChannel = MethodChannel(
//            flutterEngine?.dartExecutor!!.binaryMessenger,
//            CHANNEL
//        )

    }

//    override fun AppAllOfferwallSDKCallback(p0: Int) {
//        when (p0) {
//            AppAllOfferwallSDK.AppAllOfferwallSDK_SUCCES -> Toast.makeText(
//                this.activity,
//                "성공",
//                Toast.LENGTH_SHORT
//            ).show()
//
//            AppAllOfferwallSDK.AppAllOfferwallSDK_INVALID_USER_ID -> Toast.makeText(
//                this.activity,
//                "잘못 된 유저아이디입니다.",
//                Toast.LENGTH_SHORT
//            ).show()
//
//            AppAllOfferwallSDK.AppAllOfferwallSDK_INVALID_KEY -> Toast.makeText(
//                this.activity,
//                "오퍼월 KEY를 확인해주세요.",
//                Toast.LENGTH_SHORT
//            ).show()
//
//            AppAllOfferwallSDK.AppAllOfferwallSDK_NOT_GET_ADID -> Toast.makeText(
//                this.activity,
//                "고객님의 폰으로는 무료충전소를 이용하실 수 없습니다. 고객센터에 문의해주세요.",
//                Toast.LENGTH_SHORT
//            ).show()
//        }
//    }

}
