//
//  ViewController.swift
//  IOSExampleV2
//
//  Created by Coi on 19/10/2023.
//

import UIKit
import Flutter


class ViewController: UIViewController, BKHostBookApi {
    
    private var api: BKFlutterBookApi!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.navigationItem.title = "AppIOS"
        // Do any additional setup after loading the view.
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        BKHostBookApiSetup(appDelegate.flutterEngine.binaryMessenger, self)
        api = BKFlutterBookApi.init(binaryMessenger: appDelegate.flutterEngine.binaryMessenger)
        
        
        let button = UIButton(frame: CGRect(x: 200, y: 200, width: 100, height: 50))
        button.backgroundColor = .green
        button.setTitle("Test Button", for: .normal)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        
        self.view.addSubview(button)
    }
    @objc func buttonAction(sender: UIButton!) {
        print("Button tapped")
        //        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //        let flutterViewController = FlutterViewController.init(
        //            engine: appDelegate.flutterEngine, nibName: nil, bundle: nil)
        
        
        let dataParam: BKBook = BKBook.init()
        dataParam.memBirth="2000-01-01"
        dataParam.memGen="w"
        dataParam.memRegion="인천_서"
        dataParam.memId="abee997"
        dataParam.firebaseKey="AAAArCrKtcY:APA91bHDmRlnGIMV9TUWHBgdx_cW59irrr6GssIkX45DUSHiTXcfHV3b0MynCOxwUdm6VTTxhp7lz3dIqAbi0SnoUFnkXlK-0ncZMX-3a3oWV8ywqaEm9A9aGnX-k50SI19hzqOgprRp"
        
        api.displayBookDetailsBook(dataParam) { (error) in
            if let error = error {
                print(error)
            }
        }
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let flutterViewController = FlutterViewController(engine: appDelegate.flutterEngine, nibName: nil, bundle: nil)
        flutterViewController.modalPresentationStyle = .overCurrentContext
        flutterViewController.isViewOpaque = false
        self.present(flutterViewController, animated: true)
        
        //self.present(flutterViewController, animated: true, completion: nil)
    }
    
    
    func cancelWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    //    func finishEditingBook(_ book: BKBook, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
    //        self.dismiss(animated: true, completion: nil)
    //    }
    
}

