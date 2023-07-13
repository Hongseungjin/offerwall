import Flutter
import UIKit
import TnkRwdSdk
import adlibrary
import IveOfferwallFramework



public class SdkEumsPlugin: NSObject, FlutterPlugin{
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "sdk_eums", binaryMessenger: registrar.messenger())
        let instance = SdkEumsPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        IveSdk.initSdk(appCode: "6MI2mnMjKb")
        
        
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
       
        
        let controller: UIViewController =
        (UIApplication.shared.delegate?.window??.rootViewController)!;
        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
        case "tkn":
            TnkSession.initInstance("b0e0a0e0-6021-9877-7789-120504090d02")
            TnkSession.sharedInstance().setUserName(call.arguments as? String)
            TnkSession.sharedInstance().showAdList(asModal: controller, title: "")
        case "appall":
            AppAllOfferwallSDK.getInstance().initOfferWall(self, offerkey: "f3603a2a4d1a6f72fefba18e09a80698ec2a004e", userid: call.arguments as? String)
            AppAllOfferwallSDK.getInstance().showAppAllOfferwallPop(controller)
        case "iveKorea":
            IveSdk.setUser(user: UserModel(userId: call.arguments as! String))
            IveSdk.open(controller: controller)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
