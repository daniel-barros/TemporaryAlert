//
//  TemporaryAlertViewController.swift
//  TemporaryAlert
//
//  Created by Daniel Barros López on 11/24/16.
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


internal class TemporaryAlertViewController: UIViewController {
    
    var alertView: UIView
    fileprivate var imageLayer: CAShapeLayer?
    fileprivate var animatesImage = false
    
    init(image: TemporaryAlert.AlertImage?, title: String, message: String?) {
        alertView = UIView()
        super.init(nibName: nil, bundle: nil)
        alertView = self.alertView(image: image, title: title, message: message)
        if case .checkmark? = image {
            animatesImage = Configuration.animatesCheckmark
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(alertView)
        alertView.frame.origin.x = view.frame.width / 2 - alertView.frame.width / 2
        alertView.frame.origin.y = view.frame.height / 2 - alertView.frame.height / 2
        alertView.alpha = 0
        imageLayer?.isHidden = animatesImage
    }
    
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        alertView.frame.origin.x = view.frame.height / 2 - alertView.frame.width / 2
        alertView.frame.origin.y = view.frame.width / 2 - alertView.frame.height / 2
    }
    
    
    func showAlertView() {
        alertView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        alertView.alpha = 0
        imageLayer?.isHidden = animatesImage
        UIView.animate(withDuration: 0.3, delay: 0,
                       usingSpringWithDamping: 1, initialSpringVelocity: 0,
                       options: .curveEaseOut,
                       animations: {
                        self.alertView.transform = .identity
                        self.alertView.alpha = 1
        },
                       completion: { _ in
                        if self.animatesImage {
                            self.imageLayer?.isHidden = false
                            let animation = CABasicAnimation(keyPath:"strokeEnd")
                            animation.duration = 0.2
                            animation.fromValue = NSNumber(floatLiteral: 0)
                            animation.toValue = NSNumber(floatLiteral: 1)
                            self.imageLayer?.add(animation, forKey:"strokeEnd")
                        }
        })
    }
    
    
    func hideAlertView(completion: ((Bool) -> ())?) {
        UIView.animate(withDuration: 0.3, delay: 0,
                       usingSpringWithDamping: 1, initialSpringVelocity: 0,
                       options: .curveEaseIn,
                       animations: {
                        self.alertView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                        self.alertView.alpha = 0
        },
                       completion: completion)
    }
}


// MARK: - Helpers

fileprivate typealias Configuration = TemporaryAlert.Configuration
fileprivate typealias Constants = CGFloat

fileprivate extension Constants {
    static let alertViewWidth: CGFloat = 250
    static let alertViewMinHeight: CGFloat = 266
    static let alertViewPadding: CGFloat = 24
    static let verticalSpaceBetweenLabels: CGFloat = 8
    static let verticalSpaceBetweenImageAndTitle: CGFloat = 14
    static let imageHeight: CGFloat = 100
    static let imageWidth: CGFloat = 100
}


// MARK: -

fileprivate extension TemporaryAlertViewController {
    
    func alertView(image: TemporaryAlert.AlertImage?, title: String, message: String?) -> UIView {
        // background
        let view = backgroundView()
        
        // image
        let imageView: UIView?
        switch image {
        case .checkmark?: imageView = checkmarkView()
        case .cross?: imageView = crossView()
        case .custom(let customImage)?: imageView = customImage
        case nil: imageView = nil
        }
        if let imageView = imageView {
            view.contentView.addSubview(imageView)
        }
        
        // title
        let titleLabel = self.titleLabel(with: title)
        view.contentView.addSubview(titleLabel)
        
        // message
        let messageLabel: UILabel?
        if let message = message {
            messageLabel = self.messageLabel(with: message)
            view.contentView.addSubview(messageLabel!)
        } else {
            messageLabel = nil
        }
        
        // frames
        positionViews(image: imageView, title: titleLabel, message: messageLabel, in: view)
        
        return view
    }
    
    
    private func positionViews(image: UIView?, title: UILabel, message: UILabel?, in view: UIView) {
        // heights
        let contentMaxWidth = .alertViewWidth - .alertViewPadding * 2
        let titleLabelHeight = Configuration.titleFont.sizeOfString(string: title.text!, withMaximumWidth: contentMaxWidth).height
        let messageLabelHeight = (message == nil) ? 0 : Configuration.messageFont.sizeOfString(string: message!.text!, withMaximumWidth: contentMaxWidth).height
        let viewHeight = .alertViewPadding * 2
            + ((image?.frame.height == nil) ? 0 : image!.frame.height + .verticalSpaceBetweenImageAndTitle)
            + titleLabelHeight
            + ((message == nil) ? 0 : .verticalSpaceBetweenLabels + messageLabelHeight)
        let fixedViewHeight = max(viewHeight, .alertViewMinHeight)
        
        view.frame.size.height = fixedViewHeight
        
        // image
        let imagePosY = .alertViewPadding + (fixedViewHeight - viewHeight) / 2
        if let image = image {
            image.frame.origin = CGPoint(x: (.alertViewWidth - image.frame.width) / 2, y: imagePosY)
        }
        
        // title
        let titleLabelPosY: CGFloat
        if let imageHeight = image?.frame.height {
            titleLabelPosY = imagePosY + imageHeight + .verticalSpaceBetweenImageAndTitle
        } else {
            titleLabelPosY = imagePosY
        }
        title.frame = CGRect(x: .alertViewPadding, y: titleLabelPosY, width: contentMaxWidth, height: titleLabelHeight)
        
        // message
        if let message = message {
            let messageLabelPosY = titleLabelPosY + titleLabelHeight + .verticalSpaceBetweenLabels
            message.frame = CGRect(x: .alertViewPadding, y: messageLabelPosY, width: contentMaxWidth, height: messageLabelHeight)
        }
    }
    
    // MARK: -
    
    private func backgroundView() -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        view.frame = CGRect(x: 0, y: 0,
                            width: .alertViewWidth,
                            height: .alertViewMinHeight)
        view.backgroundColor = Configuration.backgroundColor
        view.isUserInteractionEnabled = false
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    
    private func titleLabel(with title: String) -> UILabel {
        let label = UILabel()
        label.text = title
        label.font = Configuration.titleFont
        label.textColor = Configuration.titleColor
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }
    
    
    private func messageLabel(with message: String) -> UILabel {
        let label = UILabel()
        label.text = message
        label.font = Configuration.messageFont
        label.textColor = Configuration.messageColor
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }
    
    private func checkmarkView() -> UIView {
        let size = CGSize(width: 90, height: 58)
        let path = checkmarkPath(with: CGSize(width: size.width, height: size.height))
        let position = CGPoint(x: max(.imageWidth - size.width, 10), y: (.imageHeight - size.height)/2)
        return alertImageView(withSize: size, position: position, path: path)
    }
    
    
    private func crossView() -> UIView {
        let size = CGSize(width: 58, height: 58)
        let path = crossPath(with: CGSize(width: size.width, height: size.height))
        let position = CGPoint(x: (.imageWidth - size.width)/2, y: (.imageHeight - size.height)/2)
        return alertImageView(withSize: size, position: position, path: path)
    }
    
    
    /// Creates a view and assigns the `imageLayer` property.
    private func alertImageView(withSize size: CGSize, position: CGPoint, path: UIBezierPath) -> UIView {
        let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: .imageWidth, height: .imageHeight)))
        let layer = CAShapeLayer()
        layer.path = path.cgPath
        layer.position = position
        layer.strokeColor = Configuration.imageColor.cgColor
        layer.fillColor = nil
        layer.lineWidth = 9
        layer.lineJoin = CAShapeLayerLineJoin.round
        layer.lineCap = CAShapeLayerLineCap.round
        view.layer.addSublayer(layer)
        imageLayer = layer
        return view
    }
    
    
    private func checkmarkPath(with size: CGSize) -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: size.height/2))
        path.addLine(to: CGPoint(x: size.width * 0.35, y: size.height))
        path.addLine(to: CGPoint(x: size.width - 1, y: 1))
        return path
    }
    
    
    private func crossPath(with size: CGSize) -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: size.width, y: size.height))
        path.move(to: CGPoint(x: 0, y: size.height))
        path.addLine(to: CGPoint(x: size.width, y: 0))
        return path
    }
}
