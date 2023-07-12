package com.app.abeeofferwal

import android.os.Bundle
import android.widget.Toast
import androidx.annotation.NonNull
import com.kyad.adlibrary.AppAllOfferwallSDK
import com.yanzhenjie.permission.AndPermission
import com.yanzhenjie.permission.PermissionListener
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity(), AppAllOfferwallSDK.AppAllOfferwallSDKListener {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        checkPermission()
    }


    private fun checkPermission(){
        AndPermission.with(this).requestCode(300).permission(
            android.Manifest.permission.READ_PHONE_STATE,
            android.Manifest.permission.GET_ACCOUNTS,
        ).callback(permissionListener).start()
    }

    private val permissionListener: PermissionListener = object : PermissionListener {
        override fun onSucceed(requestCode: Int, @NonNull grantPermissions: List<String>) {
            if (requestCode == 300) {
                AppAllOfferwallSDK.getInstance().initOfferWall(this@MainActivity, "1251d48b4dded2649324974594a27e7bd84cac68", null)
            }
        }

        override fun onFailed(requestCode: Int, @NonNull deniedPermissions: List<String>) {
            if (requestCode == 300) {
            }
        }
    }

    override fun AppAllOfferwallSDKCallback(p0: Int) {
        when (p0) {
            AppAllOfferwallSDK.AppAllOfferwallSDK_SUCCES -> Toast.makeText(
                this,
                "성공",
                Toast.LENGTH_SHORT
            ).show()

            AppAllOfferwallSDK.AppAllOfferwallSDK_INVALID_USER_ID -> Toast.makeText(
                this,
                "잘못 된 유저아이디입니다.",
                Toast.LENGTH_SHORT
            ).show()

            AppAllOfferwallSDK.AppAllOfferwallSDK_INVALID_KEY -> Toast.makeText(
                this,
                "오퍼월 KEY를 확인해주세요.",
                Toast.LENGTH_SHORT
            ).show()

            AppAllOfferwallSDK.AppAllOfferwallSDK_NOT_GET_ADID -> Toast.makeText(
                this,
                "고객님의 폰으로는 무료충전소를 이용하실 수 없습니다. 고객센터에 문의해주세요.",
                Toast.LENGTH_SHORT
            ).show()
        }
    }

}
