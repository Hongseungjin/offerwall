import Flutter
import UIKit
import Toast_Swift

public class EumsPlugin: NSObject, FlutterPlugin, UNUserNotificationCenterDelegate {
    
    
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "eums", binaryMessenger: registrar.messenger())
        let instance = EumsPlugin()
        
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
        // Register the notification type.
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.setNotificationCategories([meetingInviteCategory])
        
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        
        if call.method == "getAppNameByPackageName"{
            let packageName = call.arguments as! String
            //            let packageName = "com.app.offerwall"
            let bundle = Bundle(identifier: packageName)
            let name = bundle?.object(forInfoDictionaryKey: kCFBundleNameKey as String)
            print(name ??  "")
            result(name)
        }
        
        //        let arguments = call.arguments as! Dictionary<String, String>
        //        switch call.method {
        //        case "showToast":
        //            let myView = UIView(frame: CGRect(x: 0.0, y: 0.0, width:
        //                      80.0, height: 400.0))
        //            myView.makeToast("This is a piece of toast on top for 3 seconds", duration: 3.0, position: .bottom)
        //            //                 self.initZoom(call: call, result: result)
        //            //             case "join":
        //            //                 self.joinMeeting(call: call, result: result)
        //            //             case "start":
        //            //                 self.startMeeting(call: call, result: result)
        //            //             case "meeting_status":
        //            //                 self.meetingStatus(call: call, result: result)
        //        default:
        //            result(FlutterMethodNotImplemented)
        //        }
        //        result("iOS " + UIDevice.current.systemVersion)
        
        result(FlutterMethodNotImplemented)
    }
    
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Get the meeting ID from the original notification.
           let userInfo = response.notification.request.content.userInfo
                
           if response.notification.request.content.categoryIdentifier ==
                      "MEETING_INVITATION" {
              // Retrieve the meeting details.
              let meetingID = userInfo["MEETING_ID"] as! String
              let userID = userInfo["USER_ID"] as! String
                    
              switch response.actionIdentifier {
              case "ACCEPT_ACTION":
//                 sharedMeetingManager.acceptMeeting(user: userID,
//                       meetingID: meetingID)
                 break
                        
              case "DECLINE_ACTION":
//                 sharedMeetingManager.declineMeeting(user: userID,
//                       meetingID: meetingID)
                 break
                        
              case UNNotificationDefaultActionIdentifier,
                   UNNotificationDismissActionIdentifier:
                 // Queue meeting-related notifications for later
                 //  if the user does not act.
//                 sharedMeetingManager.queueMeetingForDelivery(user: userID,
//                       meetingID: meetingID)
                 break
                        
              default:
                 break
              }
           }
           else {
              // Handle other notification types...
           }
                
           // Always call the completion handler when done.
           completionHandler()
    }
}
