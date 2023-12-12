package com.example.sdk_eums

import android.widget.Toast
import com.kyad.adlibrary.AppAllOfferwallSDK

interface SdkEumsAppAll: AppAllOfferwallSDK.AppAllOfferwallSDKListener {
    override fun AppAllOfferwallSDKCallback(p0: Int) {
        when (p0) {
            AppAllOfferwallSDK.AppAllOfferwallSDK_SUCCES -> Toast.makeText(
                SdkEumsPlugin.activity,
                "성공",
                Toast.LENGTH_SHORT
            ).show()

            AppAllOfferwallSDK.AppAllOfferwallSDK_INVALID_USER_ID -> Toast.makeText(
                SdkEumsPlugin.activity,
                "잘못 된 유저아이디입니다.",
                Toast.LENGTH_SHORT
            ).show()

            AppAllOfferwallSDK.AppAllOfferwallSDK_INVALID_KEY -> Toast.makeText(
                SdkEumsPlugin.activity,
                "오퍼월 KEY를 확인해주세요.",
                Toast.LENGTH_SHORT
            ).show()

            AppAllOfferwallSDK.AppAllOfferwallSDK_NOT_GET_ADID -> Toast.makeText(
                SdkEumsPlugin.activity,
                "고객님의 폰으로는 무료충전소를 이용하실 수 없습니다. 고객센터에 문의해주세요.",
                Toast.LENGTH_SHORT
            ).show()
        }
    }
}