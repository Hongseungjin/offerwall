package com.example.sdk_eums

import android.Manifest
import android.app.Activity
import android.app.ActivityManager
import android.content.Context
import android.content.Intent
import android.widget.Toast
import androidx.annotation.NonNull
import com.fpang.lib.FpangSession
import com.igaworks.adpopcorn.Adpopcorn
import com.kyad.adlibrary.AppAllOfferwallActivity
import com.kyad.adlibrary.AppAllOfferwallSDK
import com.nextapps.naswall.NASWall
import com.ohc.ohccharge.OhcChargeActivity
import com.tnkfactory.ad.AdListType
import com.tnkfactory.ad.TnkSession
import com.yanzhenjie.permission.AndPermission
import com.yanzhenjie.permission.PermissionListener
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kr.ive.offerwall_sdk.IveOfferwall


/** SdkEumsPlugin */
class SdkEumsPlugin: FlutterPlugin, MethodCallHandler, ActivityAware,
    AppAllOfferwallSDK.AppAllOfferwallSDKListener
{
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var context: Context
  private lateinit var activity:Activity
  private lateinit var myIdUser: String




  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "sdk_eums")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
  }

    override fun AppAllOfferwallSDKCallback(p0: Int) {
        when (p0) {
            AppAllOfferwallSDK.AppAllOfferwallSDK_SUCCES -> Toast.makeText(
                this.activity,
                "성공",
                Toast.LENGTH_SHORT
            ).show()

            AppAllOfferwallSDK.AppAllOfferwallSDK_INVALID_USER_ID -> Toast.makeText(
                this.activity,
                "잘못 된 유저아이디입니다.",
                Toast.LENGTH_SHORT
            ).show()

            AppAllOfferwallSDK.AppAllOfferwallSDK_INVALID_KEY -> Toast.makeText(
                this.activity,
                "오퍼월 KEY를 확인해주세요.",
                Toast.LENGTH_SHORT
            ).show()

            AppAllOfferwallSDK.AppAllOfferwallSDK_NOT_GET_ADID -> Toast.makeText(
                this.activity,
                "고객님의 폰으로는 무료충전소를 이용하실 수 없습니다. 고객센터에 문의해주세요.",
                Toast.LENGTH_SHORT
            ).show()
        }
    }

    private fun checkPermission(){
        AndPermission.with(activity).requestCode(300).permission(
            Manifest.permission.READ_PHONE_STATE,
            // Manifest.permission.GET_ACCOUNTS,
        ).callback(permissionListener).start()
    }


    private val permissionListener: PermissionListener = object : PermissionListener {

        override fun onSucceed(requestCode: Int, @NonNull grantPermissions: List<String>) {
            if (requestCode == 300) {

                println("myIdUser+ $myIdUser" )
                if(myIdUser != null){
                    try{

//                        AppAllOfferwallSDK().initOfferWall(activity , "1251d48b4dded2649324974594a27e7bd84cac68" , myIdUser)
                        AppAllOfferwallSDK.getInstance().initOfferWall(activity, "1251d48b4dded2649324974594a27e7bd84cac68", "$myIdUser")
                           println(" 1231231231231")
                    }
                    catch (ex : Exception){
                        println("vao day$ex")
                    }

                }

            }
        }

        override fun onFailed(requestCode: Int, @NonNull deniedPermissions: List<String>) {
            if (requestCode == 300) {
                println("myIdUser faaaa+ ${myIdUser}" )
            }
        }
    }


  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    
    if (call.method == "getPlatformVersion") {
      result.success("Android ${android.os.Build.VERSION.RELEASE}")
    }

    else {
        if (call.method == "dataUser") {
            myIdUser = call.arguments.toString()
            if(myIdUser != null){
                checkPermission()
            }

        }
     if(call.method == "adsync"){
         FpangSession.init(activity)
         FpangSession.setUserId(call.arguments.toString()) // 사용자 ID 설정
         FpangSession.setDebug(true) // 배포시 false 로 설정
//         FpangSession.setAge(25) // 0 이면 값없음
//         FpangSession.setGender("M")
         FpangSession.showAdsyncList(activity, "무료충전소")
     }
      if(call.method == "Adpopcorn"){
          Adpopcorn.setUserId(context , call.arguments.toString())
            Adpopcorn.openOfferWall(context)
     }
        if(call.method == "appall"){
            println("vao day khong + ${call.arguments}" )
            try{
            AppAllOfferwallSDK.getInstance().showAppAllOfferwall(activity)
                println("vao day khon123213g")
            }
            catch (ex : Exception){
                println(ex)
            }

        }
        if(call.method == "ohc"){
            val intent = Intent(
                context,
                OhcChargeActivity::class.java
            )
            intent.putExtra("mId", call.arguments.toString())
            intent.putExtra("etc2",call.arguments.toString())
            intent.putExtra("etc3", "")
            intent.putExtra("age", "")
            intent.putExtra("gender", "")
            intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            context.startActivity(intent)
        }
        if(call.method == "mafin"){
            NASWall.open(activity , call.arguments.toString())
        }
        if(call.method == "tkn"){
            TnkSession.setUserName(this.activity, call.arguments.toString())
            TnkSession.showAdListByType(activity, AdListType.ALL, AdListType.PPI, AdListType.CPS);
        }
        if(call.method == "iveKorea"){
            IveOfferwall.openActivity(activity , IveOfferwall.UserData(call.arguments.toString()))
        }
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)

  }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        this.activity = binding.activity
        NASWall.init(this.activity, false)
        TnkSession.applicationStarted(this.activity)
        TnkSession.setCOPPA(this.activity, false)
    }



    override fun onDetachedFromActivityForConfigChanges() {

    
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)


    }



    override fun onDetachedFromActivity() {
        // TODO("Not yet implemented")

    }
}
