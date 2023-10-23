//
//  AppDelegate.swift
//  IOSExampleV2
//
//  Created by Coi on 19/10/2023.
//

import UIKit
import FirebaseCore
import flutter_local_notifications
import FlutterPluginRegistrant
import Flutter



@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    public var flutterEngine:FlutterEngine!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
            GeneratedPluginRegistrant.register(with: registry)
        }
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
        }
        
        let flutterDependencies = FlutterDependencies()
        
        flutterEngine=flutterDependencies.flutterEngine
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
}



class FlutterDependencies: ObservableObject {
    let flutterEngine = FlutterEngine(name: "Offerwall")
    init(){
        // Runs the default Dart entrypoint with a default Flutter route.
//        flutterEngine.run()
        flutterEngine.run(withEntrypoint: nil)
        // Connects plugins with iOS platform code to this app.
        GeneratedPluginRegistrant.register(with: self.flutterEngine);
    }
}
