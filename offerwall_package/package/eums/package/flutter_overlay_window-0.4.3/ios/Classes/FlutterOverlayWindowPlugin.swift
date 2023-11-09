import Flutter
import UIKit
import Toast_Swift

public class FlutterOverlayWindowPlugin: NSObject, FlutterPlugin {
    
    private var window: UIWindow? = UIWindow(frame: UIScreen.main.bounds)
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "x-slayer/overlay_channel", binaryMessenger: registrar.messenger())
        let instance = FlutterOverlayWindowPlugin()
        
        
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as! Dictionary<String, String>
        switch call.method {
        case "showToast":
            Toast.showToast(arguments["message"], image: nil, duration: 3)
        default:
            result(FlutterMethodNotImplemented)
        }
        //        result("iOS " + UIDevice.current.systemVersion)
    }
}
