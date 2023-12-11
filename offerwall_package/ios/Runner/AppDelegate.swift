import UIKit
import Flutter
import FirebaseCore
import FirebaseMessaging
import flutter_background_service_ios
import UserNotifications
import flutter_local_notifications
import eums
//
private enum ActionIdentifier: String {
    case keep, open
}

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate
{
    
    private let categoryIdentifier = "EUMS_OFFERWALL"
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        FirebaseApp.configure()
        // This is required to make any communication available in the action isolate.
        FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
            GeneratedPluginRegistrant.register(with: registry)
        }
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
        }
        
        
        //      registerCustomActions()
        
//        SwiftFlutterBackgroundServicePlugin.taskIdentifier = "com.app.offerwall"
        SwiftFlutterBackgroundServicePlugin.taskIdentifier = "workmanager.background.task"
        
        GeneratedPluginRegistrant.register(with: self)
        
        UIApplication.shared.setMinimumBackgroundFetchInterval(TimeInterval(UIApplication.backgroundFetchIntervalMinimum))
        
        guard let controller = window?.rootViewController as? FlutterViewController else {
            return super.application(application, didFinishLaunchingWithOptions: launchOptions)
        }
//        EumsPlugin.channelCallBackMain = FlutterMethodChannel(name: EumsPlugin.channelCallBack,
//                                                              binaryMessenger: controller.binaryMessenger)
//        Messaging.messaging().isAutoInitEnabled = true
        
        
        application.registerForRemoteNotifications()
        
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    
//    override func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
//        
//        defer { completionHandler() }
//        print("response.notification.request.identifier===> \(response.notification.request.identifier)")
//        if(response.notification.request.identifier == "999") {
//            completionHandler()
//            return
//        }
//        
//        
//        let identity = response.notification
//            .request.content.categoryIdentifier
//        
//        guard identity == categoryIdentifier,
//              let action = ActionIdentifier(rawValue: response.actionIdentifier) else {
//            return
//        }
//        
//        let userInfo = response.notification.request.content.userInfo
//        
//        
//        if(ActionIdentifier.open.rawValue == response.actionIdentifier){
//            print(userInfo["data"])
//            EumsPlugin.channelCallBackMain?.invokeMethod(ActionIdentifier.open.rawValue, arguments: userInfo["data"])
//        }else {
//            if(ActionIdentifier.keep.rawValue == response.actionIdentifier){
//                let userInfo = response.notification.request.content.userInfo
//                print(userInfo["data"])
//                EumsPlugin.channelCallBackMain?.invokeMethod(ActionIdentifier.keep.rawValue, arguments: userInfo["data"])
//            }
//        }
//        
//        print("You pressed \(response.actionIdentifier)")
//        //        defer { completionHandler() }
//    }
//    
    
    //        override func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) async -> UIBackgroundFetchResult {
    //            //                Messaging.messaging().appDidReceiveMessage(userInfo)
    //            EumsPlugin.channelCallBackMain?.invokeMethod(EumsPlugin.channelCallBack, arguments: userInfo)
    //            //        Messaging.messaging().appDidReceiveMessage(userInfo)
    //                    return UIBackgroundFetchResult.newData
    //        }
    
    
            
    
//            override func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
//                //        Messaging.messaging().appDidReceiveMessage(userInfo)
//    //            print(userInfo)
////                registerCustomActions();
//    //            EumsPlugin.channelCallBackMain?.invokeMethod(EumsPlugin.channelCallBack, arguments: userInfo)
////                if #available(iOS 10.0, *) {
////                    UNUserNotificationCenter.current().removeAllDeliveredNotifications()
////                    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
////                }
////                completionHandler(UIBackgroundFetchResult.newData)
//            }
    
    
    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken : Data){
        //        print("X__APNS: \(String(describing: deviceToken))")
        Messaging.messaging().apnsToken = deviceToken;
        Messaging.messaging().isAutoInitEnabled = true
        //        Messaging.messaging().setAPNSToken(deviceToken, type:MessagingAPNSTokenType.unknown )
        
        
        FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
            GeneratedPluginRegistrant.register(with: registry)
        }
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
        }
        
        //        registerCustomActions()
        
        
        //        application.registerForRemoteNotifications()
        
    }
    
    //    private func registerCustomActions() {
    //        let accept = UNNotificationAction(
    //            identifier: ActionIdentifier.keep.rawValue,
    //            title: "KEEP 하기", options: [])
    //
    //        let reject = UNNotificationAction(
    //            identifier: ActionIdentifier.open.rawValue,
    //            title: "광고 시청하기", options: [UNNotificationActionOptions.foreground])
    //
    //        let category = UNNotificationCategory(
    //            identifier: categoryIdentifier,
    //            actions: [accept, reject],
    //            intentIdentifiers: [],
    //            options: .customDismissAction)
    //
    //        UNUserNotificationCenter.current()
    //            .setNotificationCategories([category])
    //    }
    
    
}

