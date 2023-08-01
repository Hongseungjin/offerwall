import Flutter
import UIKit
import TnkRwdSdk
import adlibrary
import IveOfferwallFramework



public class SdkEumsPlugin: NSObject, FlutterPlugin, AppAllOfferwallSDKListener{
    public func appAllOfferwallSDKCallback(_ result: Int32) {
        switch (result) {
                       case AppAllOfferwallSDK_SUCCES:
                       AppAllOfferwallSDK.getInstance().showToast("성공")
                       break;
                   case AppAllOfferwallSDK_INVALID_USER_ID:
                       AppAllOfferwallSDK.getInstance().showToast("잘못 된 유저아이디입니다.")
                       break;
                   case AppAllOfferwallSDK_INVALID_KEY:
                       AppAllOfferwallSDK.getInstance().showToast("오퍼월 KEY를 확인해주세요.")
                       break;
                   case AppAllOfferwallSDK_NOT_GET_ADID:
                       AppAllOfferwallSDK.getInstance().showToast("고객님의 폰으로는 무료충전소를 이용하실 수 없습니다. 고객센터에 문의해주세요.")
                       break;
                   default:
                       print("error")
                   }
    }
    
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
