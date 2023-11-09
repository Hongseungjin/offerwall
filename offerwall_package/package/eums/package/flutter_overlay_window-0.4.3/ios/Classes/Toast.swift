//
//  Toast.swift
//  YZTCommon
//
//  Created by tianjing on 2016/10/20.
//  Copyright © 2016年 TJ. All rights reserved.
//

import UIKit
import Foundation

var toastKey: UInt8 = 0
var timerKey: UInt8 = 0

public final class Toast {
    
    public static func showToast(_ message: String?, image: UIImage? = nil, duration: Double! = 1.0) {
        currentWindow()?.showToast(message, image: image, duration: duration)
    }
    
    public static func showLoading(_ message: String? = nil, block: Bool = true) {
        currentWindow()?.showLoading(message, block: block)
    }
    
    public static func hideLoading() {
        currentWindow()?.hideLoading()
    }
    
    static func currentWindow() -> UIWindow? {
       return UIApplication.shared.delegate?.window ?? nil
    }
}

public final class WeakReference {
    public weak var object: AnyObject?
    public init(_ object: AnyObject?) {
        self.object = object
    }
}

extension UIView {
    private var toastView: ToastView {
        get {
            if let toastView = objc_getAssociatedObject(self, &toastKey) as? ToastView {
                return toastView
            } else {
                let view = ToastView(frame:self.bounds)
                objc_setAssociatedObject(self, &toastKey, view, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return view
            }
        }
    }
    
    private var toastTimer: Timer {
        get {
            if let timer = (objc_getAssociatedObject(self,&timerKey) as? WeakReference)?.object {
                return timer as! Timer
            } else {
                let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { (timer) in
                    self.toastView.hide()
                })
                timer.fireDate = Date.distantFuture
                objc_setAssociatedObject(self, &timerKey, WeakReference(timer), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return timer
            }
        }
    }
    
    public func showToast(_ message: String?, image: UIImage? = nil, duration: Double! = 1.0) {
        if message != nil || image != nil {
            toastView.setToastWith(message, image: image)
            toastView.show(onView: self)
            toastTimer.fireDate = Date(timeIntervalSinceNow: duration)

        }
    }
    
    public func showLoading(_ message: String? = nil, block: Bool = true) {
        toastView.setLoadingWith(message, block: block)
        toastTimer.fireDate = Date.distantFuture
        toastView.show(onView: self)
    }
    
    public func hideLoading() {
        toastView.hide()
    }
}

fileprivate class ToastView: UIView {
    
    lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16.0)
        return label
    }()
    
    lazy var imageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    lazy var backgroudView: UIView = {
        let view = UIView(frame:self.bounds)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        view.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        view.layer.cornerRadius = 10.0
        return view
    }()
    
    lazy var activityIndicatorView: UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.whiteLarge)
        indicatorView.startAnimating()
        return indicatorView
    }()

     override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        self.backgroundColor = .clear
        self.alpha = 0;
        self.addSubview(backgroudView)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setLoadingWith(_ message: String? = nil, block: Bool = true) {
          removeView()
          setWith(message, view: activityIndicatorView)
          isUserInteractionEnabled = block
    }
    
    public func setToastWith(_ message: String?, image: UIImage? = nil) {
        removeView()
        if let image = image {
            imageView.image = image
            let width = image.size.width > bounds.size.width * 0.8 ? bounds.size.width * 0.8 : image.size.width;
            let height = image.size.height > bounds.size.height * 0.8 ? bounds.size.height * 0.8 : image.size.height;
            imageView.frame = CGRect(x: 0.0, y: 0.0, width: width, height: height)
            setWith(message, view: imageView)
        } else {
            setWith(message, view: nil)
        }
    }
    
    private func removeView() {
        for subView in backgroudView.subviews {
            subView.removeFromSuperview()
        }
    }
    
    private func setWith(_ message: String?, view: UIView?) {
        if let message = message, let view = view {
            let viewSize = view.bounds.size
            let messageLabelSize = sizeOfText(message, maxWidth: self.bounds.size.width * 0.8, maxHeight: self.bounds.size.width - viewSize.height - 50)
            let viewWidth = messageLabelSize.width > viewSize.width ? messageLabelSize.width + 40 : viewSize.width + 40
            backgroudView.frame = CGRect(x: 0, y: 0, width: viewWidth, height: 50 + messageLabelSize.height + viewSize.height)
            backgroudView.center = center
            view.center = CGPoint(x: backgroudView.bounds.size.width / 2 , y: 20 + viewSize.height / 2)
            messageLabel.text = message
            messageLabel.frame = CGRect(x: 0.0, y: 0.0, width: messageLabelSize.width, height: messageLabelSize.height)
            messageLabel.center = CGPoint(x: backgroudView.bounds.size.width / 2, y: 30 + viewSize.height + messageLabelSize.height / 2)
            backgroudView.addSubview(view)
            backgroudView.addSubview(messageLabel)
        } else if let message = message {
            let messageLabelSize = sizeOfText(message, maxWidth: self.bounds.size.width * 0.8, maxHeight: self.bounds.size.height - 40)
            backgroudView.frame = CGRect(x: 0.0, y: 0.0, width: messageLabelSize.width + 40, height: 40 + messageLabelSize.height)
            backgroudView.center = center
            messageLabel.text = message
            messageLabel.frame = CGRect(x: 0, y: 0, width: messageLabelSize.width, height: messageLabelSize.height)
            messageLabel.center = CGPoint(x: backgroudView.bounds.size.width / 2, y: backgroudView.bounds.size.height / 2)
            backgroudView.addSubview(messageLabel)
        } else if let view = view {
            let viewSize = view.bounds.size
            backgroudView.frame = CGRect(x: 0.0, y: 0.0, width: viewSize.width / 0.6, height: viewSize.height / 0.6 )
            backgroudView.center = center
            view.center = CGPoint(x: backgroudView.bounds.size.width / 2, y: backgroudView.bounds.size.height / 2)
            backgroudView.addSubview(view)
        }
    }
    
    public func show(onView: UIView) {
        onView.addSubview(self)
        if onView === Toast.currentWindow() {
            if (onView.frame.size == self.frame.size) {
                var frame = self.frame
                frame.origin.y = frame.origin.y + 64
                frame.size.height = frame.size.height - 64
                self.frame = frame
            }
            backgroudView.center = CGPoint(x:frame.size.width / 2, y:frame.size.height / 2 - 32)
        }
        onView.bringSubviewToFront(self)
        isHidden = false
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 1.0
        }) { (completed) in
            self.isHidden = false
        }
    }
    
    public func hide() {
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0
            }) { (completed) in
            self.isHidden = true
        }
    }
}

func sizeOfText(_ text: String?, maxWidth: CGFloat, maxHeight: CGFloat) -> CGSize {
    if let titleString = text {
        let maxTitleSize = CGSize(width: maxWidth, height: maxHeight)
        let titleSize = titleString.boundingRect(with: maxTitleSize, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16.0)], context: nil)
        return titleSize.size
    }
    return CGSize(width: 0,height: 0);
}
