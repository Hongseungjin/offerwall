import Flutter
import UIKit
import Toast_Swift

public class EumsPlugin: NSObject, FlutterPlugin {
    
    
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "eums", binaryMessenger: registrar.messenger())
        let instance = EumsPlugin()
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
}
