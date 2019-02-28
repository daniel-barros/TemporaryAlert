//
//  TemporaryAlert.swift
//  TemporaryAlert
//
//  Created by Daniel Barros López on 11/22/16.
/*
 MIT License
 
 Copyright (c) 2016 Daniel Barros
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
*/


import UIKit

/// Show an alert using `show(image:title:message:)`.
///
/// Customize your alerts modifying the variables in `TemporaryAlert.Configuration`, including fonts, colors and the alerts life span.
public struct TemporaryAlert {
    
    public enum AlertImage {
        case checkmark, cross, custom(UIView)
    }

    public enum Configuration {
        /// The color used to draw the default alert images. This does not apply if you provide a custom image.
        ///
        /// By default this is the same as `titleColor`.
        
        public static var imageColor:Any? = [UIColor.darkGray, UIColor.lightGray]
        public static var backgroundColor = #colorLiteral(red: 0.9529411765, green: 0.9529411765, blue: 0.9529411765, alpha: 0.8)
        public static var blurEnabled = true
        public static var blurStyle: UIBlurEffect.Style = .light
        public static var titleColor:Any? = [UIColor.darkGray, UIColor.lightGray]
        public static var messageColor:Any? = [UIColor.lightGray, UIColor.lightText]
        public static var titleFont = UIFont.systemFont(ofSize: 22, weight: .semibold)
        public static var messageFont = UIFont.systemFont(ofSize: 16, weight: .semibold)
        /// The number of seconds alerts are visible.
        public static var lifeSpan: Double = 1.5
        /// If `true` the checkmark image animates when the alert is shown. This does not apply if you choose a different image.
        ///
        /// The default value is `true`.
        public static var animatesCheckmark = true
    }
    
    // An independent window makes sure the alert is shown above everything else.
    fileprivate static var window: UIWindow?
    

    /// Shows an alert with the specified image, title and message.
    ///
    /// If you want to change the alert life span or customize the alert appearance use the variables in `TemporaryAlert.Configuration`.
    public static func show(image: AlertImage?, title: String, message: String?) {
        window = alertWindow()
        let vc = TemporaryAlertViewController(image: image, title: title, message: message)
        window?.rootViewController = vc
        DispatchQueue.main.async {
            vc.showAlertView()
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Configuration.lifeSpan) { [weak vc] in
            vc?.hideAlertView(completion: { _ in
                window = nil
            })
        }
    }
    
    private init() {}
}


// MARK: - Helpers

fileprivate extension TemporaryAlert {

    static func alertWindow() -> UIWindow {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.windowLevel = UIWindow.Level(rawValue: CGFloat.greatestFiniteMagnitude)
        window.backgroundColor = nil
        window.isHidden = false
        window.isUserInteractionEnabled = false
        return window
    }    
}
