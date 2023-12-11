import Flutter
import UIKit
import UserNotifications

private enum ActionIdentifier: String {
    case keep, open
}

public class EumsPlugin: NSObject, FlutterPlugin {
    
    public static  var channelCallBackMain : FlutterMethodChannel?;
    public static  var channelCallBack : String = "eums_call_back";
    private let categoryIdentifier = "EUMS_OFFERWALL"
    
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
        result(FlutterMethodNotImplemented)
    }
    
    
    
    
}

