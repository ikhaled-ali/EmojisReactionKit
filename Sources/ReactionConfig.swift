//
//  ReactionConfig.swift
//  EmojisReactionKit
//
//  Created by iKʜAʟED〆 on 30/05/2025.
//

import UIKit

/// Configuration for displaying a reaction view with emojis and optional menu actions.
public struct ReactionConfig {
    
    /// A value used to identify the target view.
    /// This identifier will be returned through the delegate for context (e.g., `indexPath`, `cellID`, etc.).
    public let itemIdentifier: Any?
    
    /// A list of emojis to display at the top of the target `UIView`.
    /// Set to `nil`/empty  to hide the emoji bar.
    /// - Note: Displays up to 5–6 emojis before enabling horizontal scrolling.
    public let emojis: [String]?
    
    /// Decide if you want to enable emoji entrance animation or not
    /// - Important: Applicable only for `ReactionDirection.leading` and `ReactionDirection.trailing`
    public let emojiEnteranceAnimated:Bool
    
    /// Determines whether to show a "more" (`+`) button at the end of the emoji list.
    public let moreButton: Bool
    
    /// A context menu to display at the bottom of the target `UIView`.
    /// Set to `nil` to hide the menu.
    /// - Important: Only `UIAction` instances are supported in the `UIMenu`.
    public let menu: UIMenu?
    
    /// The direction from which the reaction animation should start.
    public let startFrom: ReactionDirection
    
    /// Enables haptic feedback when a reaction item or a menu item is selected.
    public let enableFeedbackGeneration: Bool
    
    /// Enables pan to select emoji/menu
    public let enablePanGesture: Bool
    
    /// If `enablePanGesture` is `true` and you want to continue the current gesture (e.g., a long press) as a pan gesture
    /// to interact with the emoji reaction list, provide that initial gesture here.
    /// This allows the reaction view to seamlessly take over the gesture and continue tracking it as a pan.
    ///
    /// Example use case: You begin with a long press and want to transition into a pan gesture to select a reaction.
    public let continuedPanGesture: UIGestureRecognizer?
    
    /// hide the target view when reaction done and show it again after dismiss
    public let hideTargetWhenReact:Bool
    
    public init(itemIdentifier: Any? = nil, emojis: [String]? = nil, moreButton: Bool = true, menu: UIMenu? = nil, startFrom: ReactionDirection = .center, enableFeedbackGeneration: Bool = true, enablePanGesture: Bool = true, hideTargetWhenReact: Bool = true, continuedPanGesture: UIGestureRecognizer? = nil, emojiEnteranceAnimated: Bool = true) {
        self.itemIdentifier = itemIdentifier
        self.emojis = emojis
        self.moreButton = moreButton
        self.menu = menu
        self.startFrom = startFrom
        self.enableFeedbackGeneration = enableFeedbackGeneration
        self.enablePanGesture = enablePanGesture
        self.hideTargetWhenReact = hideTargetWhenReact
        self.continuedPanGesture = continuedPanGesture
        self.emojiEnteranceAnimated = emojiEnteranceAnimated
    }
}

/// A theme configuration struct that defines the visual appearance of the reaction UI.
public struct ReactionTheme {
    
    /// default values
    @MainActor public static let `default` = ReactionTheme(backgroundFallbackColor: .systemBackground.withAlphaComponent(0.8), backgroundBlurEffectStyle: UIBlurEffect(style: .regular), reactionBackgroundColor: .systemBackground, moreButtonIcon: .init(systemName: "plus.circle.fill") ?? .add, menuBlurEffectStyle: UIBlurEffect(style: .systemMaterial), menuBlurFallbackColor: .secondarySystemBackground)
    
    /// The background color of the reaction component when "Reduce Transparency" is enabled in accessibility settings.
    public let backgroundFallbackColor: UIColor

    /// The blur effect used for the background (when transparency is enabled).
    public let backgroundBlurEffectStyle: UIVisualEffect

    /// The background color used specifically for reaction list.
    public let reactionBackgroundColor: UIColor

    /// The icon image used for the "more" button in the reaction list.
    public let moreButtonIcon: UIImage

    /// The blur effect used for the reaction menu.
    public let menuBlurEffectStyle: UIVisualEffect

    /// A fallback solid background color for the menu when "Reduce Transparency" is enabled in accessibility settings.
    public let menuBlurFallbackColor: UIColor
}

/// Represents the direction from which the reaction view animation originates.
public enum ReactionDirection {
    case leading
    case trailing
    case center
}

extension ReactionDirection {
    func isLeading() -> Bool {
        return self == .leading
    }
    
    func isTrailing() -> Bool {
        return self == .trailing
    }
    
    func isCenter() -> Bool {
        return self == .center
    }
}

// MARK: - ReactionPreviewDelegate Protocol
@objc public protocol ReactionPreviewDelegate: AnyObject {
    
    /// Called when the animation starts.
    @objc optional func willReact()
    
    /// Called after the dismiss animation completes with:
    /// `identifier`: The identifier you provided in the `ReactionConfig`.
    /// + the selection event with one of the following:
    /// - `action`: The selected `UIAction`, if any.
    /// - `emoji`: The selected emoji string, if any.
    /// - `moreButton`: `true` if the "more" button was tapped.
    func didDismiss(on identifier: Any?, action: UIAction?, emoji: String?, moreButton: Bool)
}
