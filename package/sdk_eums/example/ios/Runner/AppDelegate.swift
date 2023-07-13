import UIKit
import Flutter
import adlibrary
// import Firebase

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, AppAllOfferwallSDKListener{
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
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        //  FirebaseApp.configure()
        GeneratedPluginRegistrant.register(with: self)
        AppAllOfferwallSDK.initialize()
        AppAllOfferwallSDK.getInstance().initOfferWall(self, offerkey: "f3603a2a4d1a6f72fefba18e09a80698ec2a004e", userid: "abeeTest")
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
