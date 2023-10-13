package com.app.abeeofferwal

import android.os.Bundle
import android.widget.Toast
//import com.kyad.adlibrary.AppAllOfferwallSDK
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity(), MethodChannel.MethodCallHandler
//    AppAllOfferwallSDK.AppAllOfferwallSDKListener
{

    private var CHANNEL = "sdk_eums"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val channel = MethodChannel(flutterEngine?.dartExecutor!!.binaryMessenger, CHANNEL)

        channel.setMethodCallHandler { call, result ->
            val data = call.arguments

            if (call.arguments == "dataUser"){
                println("myIdUser1231237618237 $data" )
            }

        }
    }


    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)


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
