import UIKit
import Flutter
import FirebaseCore
import FirebaseMessaging
import flutter_background_service_ios
import UserNotifications
import flutter_local_notifications

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate
{
    
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
        SwiftFlutterBackgroundServicePlugin.taskIdentifier = "com.app.offerwall"
        
        GeneratedPluginRegistrant.register(with: self)
        UIApplication.shared.setMinimumBackgroundFetchInterval(TimeInterval(UIApplication.backgroundFetchIntervalMinimum))
        
        
//        // Define the custom actions.
//        let acceptAction = UNNotificationAction(identifier: "ACCEPT_ACTION",
//                                                title: "Accept",
//                                                options: [])
//        let declineAction = UNNotificationAction(identifier: "DECLINE_ACTION",
//                                                 title: "Decline",
//                                                 options: [])
//        // Define the notification type
//        let meetingInviteCategory =
//        UNNotificationCategory(identifier: "MEETING_INVITATION",
//                               actions: [acceptAction, declineAction],
//                               intentIdentifiers: [],
//                               hiddenPreviewsBodyPlaceholder: "",
//                               options: .customDismissAction)
//        
//        let notificationCenter = UNUserNotificationCenter.current()
//        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
//        notificationCenter.requestAuthorization(options: options) { (granted, error) in
//            if granted {
//                application.registerForRemoteNotifications()
//            }
//        }
//        // Register the notification type.
//        notificationCenter.setNotificationCategories([meetingInviteCategory])
        
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken : Data){
        //        print("X__APNS: \(String(describing: deviceToken))")
        Messaging.messaging().apnsToken = deviceToken;
        Messaging.messaging().setAPNSToken(deviceToken, type:MessagingAPNSTokenType.unknown )
        Messaging.messaging().isAutoInitEnabled = true
    }
    
    override func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        let userInfo = notification.request.content.userInfo
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Define the custom actions.
        let acceptAction = UNNotificationAction(identifier: "ACCEPT_ACTION",
                                                title: "Accept",
                                                options: [])
        let declineAction = UNNotificationAction(identifier: "DECLINE_ACTION",
                                                 title: "Decline",
                                                 options: [])
        // Define the notification type
        let meetingInviteCategory =
        UNNotificationCategory(identifier: "MEETING_INVITATION",
                               actions: [acceptAction, declineAction],
                               intentIdentifiers: [],
                               hiddenPreviewsBodyPlaceholder: "",
                               options: .customDismissAction)
        
       
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        center.requestAuthorization(options: options) { (granted, error) in
            if granted {
                DispatchQueue.main.async {
                  UIApplication.shared.registerForRemoteNotifications()
                }
//                application.registerForRemoteNotifications()
            }
        }
        // Register the notification type.
        center.setNotificationCategories([meetingInviteCategory])
        
        // Print full message.
        print(userInfo)
        // Change this to your preferred presentation option
        return [[.alert, .sound]]
    }
    
    override func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        let userInfo = response.notification.request.content.userInfo
        
        // ...
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print full message.
        print(userInfo)
    }
    
}

