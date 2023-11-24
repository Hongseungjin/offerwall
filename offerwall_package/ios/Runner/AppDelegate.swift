//import UIKit
////import adlibrary
////import Firebase
//import FirebaseCore
//import Flutter
//import UserNotifications
////import flutter_local_notifications

import UIKit
import Flutter
import FirebaseCore
import FirebaseMessaging
//import UserNotifications
import flutter_local_notifications
import flutter_background_service_ios

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate
//, AppAllOfferwallSDKListener
{
    //    public func appAllOfferwallSDKCallback(_ result: Int32) {
    //        switch(result) {
    //        case AppAllOfferwallSDK_SUCCES:
    //            AppAllOfferwallSDK.getInstance().showToast("성공")
    //            break;
    //
    //        case AppAllOfferwallSDK_INVALID_USER_ID:
    //            AppAllOfferwallSDK.getInstance().showToast("잘못된 유저 ID 입니다.")
    //            break;
    //
    //        case AppAllOfferwallSDK_INVALID_KEY:
    //            AppAllOfferwallSDK.getInstance().showToast("오퍼월 KEY를 확인해 주세요.")
    //            break;
    //
    //        case AppAllOfferwallSDK_NOT_GET_ADID:
    //            AppAllOfferwallSDK.getInstance().showToast("고객님의 폰으로는 무료충전소를 이용하실 수 없습니다. 고객센터에 문의해주세요.")
    //            break;
    //
    //        default:
    //            print("ERROR")
    //        }
    //    }
    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken : Data){
//        print("X__APNS: \(String(describing: deviceToken))")
        Messaging.messaging().apnsToken = deviceToken;
        Messaging.messaging().setAPNSToken(deviceToken, type:MessagingAPNSTokenType.unknown )
    }
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        FirebaseApp.configure()
        FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
            GeneratedPluginRegistrant.register(with: registry)
        }
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
        }
        SwiftFlutterBackgroundServicePlugin.taskIdentifier = "com.app.offerwall"
        
        GeneratedPluginRegistrant.register(with: self)
        UIApplication.shared.setMinimumBackgroundFetchInterval(TimeInterval(UIApplication.backgroundFetchIntervalMinimum))
        //    AppAllOfferwallSDK.initialize()
//        UIApplication.shared.setMinimumBackgroundFetchInterval(5)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    //   override func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    //        print(error)
    //    }
}
