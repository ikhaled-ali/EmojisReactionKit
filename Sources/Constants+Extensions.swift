//
//  Extensions.swift
//  EmojisReactionKit
//
//  Created by iKʜAʟED〆 on 10/05/2025.
//

import UIKit

//MARK: - extension UIImage
extension UIImage {
    func resizedToFit(in targetSize: CGSize) -> UIImage? {
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        let scaleFactor = min(widthRatio, heightRatio)

        let newSize = CGSize(
            width: size.width * scaleFactor,
            height: size.height * scaleFactor
        )

        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}

//MARK: - extension UIApplication

extension UIApplication {
    var keyWindow: UIWindow? {
        // For iOS 13 and above using scenes
        return self.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }
}


//MARK: - extension UIGestureRecognizer
extension UIGestureRecognizer {
    func isFinished() -> Bool {
        return state == .ended || state == .cancelled || state == .failed
    }
    
    func isChanged() -> Bool {
        return state == .changed
    }
}

//MARK: - extension UIView
extension UIView {
    
    static var identifier: String {
        return String(describing: self)
    }
    
    func setCenterX() {
        self.center.x = self.window?.frame.midX ?? 0
    }
    
    func bottom() -> CGFloat {
        self.frame.origin.y + self.frame.size.height
    }
    
    func top() -> CGFloat {
        self.frame.origin.y
    }
    
    func left() -> CGFloat {
        self.frame.origin.x
    }
    
    func right() -> CGFloat {
        self.frame.origin.x + self.frame.size.width
    }
    
    func width() -> CGFloat {
        self.frame.size.width
    }
    
    @objc public func snapshot() -> UIImage {
        guard let screen = self.window?.screen else {return UIImage()}
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, screen.scale)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? UIImage()
    }
    
    ///
    ///animateScaleAndFadeIn
    /// Start showing the view from startingFrom to the identity transform with animation
    ///  - Parameters:
    ///    - startingFrom: CGAffineTransform of the start point
    ///    - fromLeading: ture means start the animation from leading or from trailing
    ///
    func animateScaleAndFadeIn(duration: TimeInterval = 0.4, startingFrom: CGAffineTransform, startFrom: ReactionDirection, isFromTop: Bool = false, completion: ((Bool) -> Void)? = nil) {
        // Set anchor point
        let anchorX: CGFloat = startFrom.isLeading() ? 0.0 : startFrom.isTrailing() ? 1.0 : 0.5
        setCustomAnchorPoint(CGPoint(x: anchorX, y: isFromTop ? 0.0 : 0.5))

        // Start state
        self.transform = startingFrom
        self.alpha = 0
        self.isHidden = false

        // Animate to final state
        UIView.animate(withDuration: duration,
                       delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.5,
                       options: [.curveEaseInOut],
                       animations: {
            self.transform = .identity
            self.alpha = 1
        }, completion: completion)
    }
    
    func animateScaleAndFadeOut(duration: TimeInterval = 0.4, endingAt: CGAffineTransform, fromLeading: Bool, isFromTop: Bool = false, completion: ((Bool) -> Void)? = nil) {
        // Set anchor point
        let anchorX: CGFloat = fromLeading ? 0.0 : 1.0
        setCustomAnchorPoint(CGPoint(x: anchorX, y: isFromTop ? 0.0 : 0.5))

        // Start state
        self.transform = .identity
        self.alpha = 1
        self.isHidden = false

        // Animate to final state
        UIView.animate(withDuration: duration,
                       delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.5,
                       options: [.curveEaseInOut],
                       animations: {
            self.transform = endingAt
            self.alpha = 0
        }, completion: completion)
    }
    
    func setCustomAnchorPoint(_ point: CGPoint) {
        let oldOrigin = self.frame.origin
        self.layer.anchorPoint = point
        let newOrigin = self.frame.origin

        let transition = CGPoint(x: newOrigin.x - oldOrigin.x, y: newOrigin.y - oldOrigin.y)
        self.center = CGPoint(x: self.center.x - transition.x, y: self.center.y - transition.y)
    }
    
    func zoomInBounce(duration: TimeInterval = 0.15, options : UIView.AnimationOptions = [.curveLinear], delay: TimeInterval = 0, completion: ((Bool) -> Void)? = nil) {
        self.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        self.alpha = 0.0

        UIView.animateKeyframes(withDuration: duration, delay: delay, options: [], animations: {
            // Step 2: Slight overshoot (e.g. scale up to 1.1)
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.75) {
                self.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                self.alpha = 1.0
            }
            // Step 3: Back to identity
            UIView.addKeyframe(withRelativeStartTime: 0.75, relativeDuration: 0.25) {
                self.transform = CGAffineTransform.identity
            }
        }, completion: completion)
    }
    
    /// Displays the reaction preview view.
    ///
    /// - Parameters:
    ///   - config: The `ReactionConfig` used to configure the preview content.
    ///   - theme: The `ReactionTheme` used to configure the preview appearence.
    ///   - delegate: An optional delegate that receives a callback when the preview is dismissed with a selected available options.
    ///
    /// - Returns: A `ReactionPreviewView` if the given view is valid; otherwise, returns `nil`.
    @discardableResult
    public func react(with config: ReactionConfig, theme: ReactionTheme? = .default, delegate: ReactionPreviewDelegate?) -> ReactionPreviewView?{
        let reactionPreviewView = ReactionPreviewView(self, with: config, theme: theme)
        reactionPreviewView.delegate = delegate
        reactionPreviewView.animate()
        return reactionPreviewView
    }
}




struct MENU {
    static let WIDTH: CGFloat = 250.0
}


struct REACTION {
    static let ITEM_SIZE:CGSize = CGSize(width: 42, height: 42)
    static let TOUCH_AREA_MARGIN: CGFloat = ITEM_SIZE.height - 8
    static let SIZE:CGSize = CGSize(width: 280, height: 52) // this the max width
    static let MARGIN:CGFloat = 8
    
    static func getWidth(count:Int) -> CGFloat {
        return CGFloat(min(count, 7)) * ITEM_SIZE.width
    }
}

class RTLCollectionFlow: UICollectionViewFlowLayout {
    override var flipsHorizontallyInOppositeLayoutDirection: Bool {
        return true
    }
}
