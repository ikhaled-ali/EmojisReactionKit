//
//  ReactionPreviewView.swift
//  EmojisReactionKit
//
//  Created by iKʜAʟED〆 on 07/05/2025.
//  Copyright © 2025. All rights reserved.
//

import UIKit


public class ReactionPreviewView: UIView {
    
    /// Reference to the targeted view
    private weak var _hostingView: UIView?
    
    private var _config:ReactionConfig!
    
    private var _theme:ReactionTheme!
    
    /// container of views to control the translation
    private let container: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = true
        return view
    }()
    
    /// emojis view
    private var reactionView: ReactionView?
    
    /// menu blurry table view
    private var visualEffectView: UIVisualEffectView?
    private var menuTableView: UITableView?
    private var dataSource:UITableViewDiffableDataSource<UIMenu, UIAction>?
    
    /// haptic feedbacks
    private var feedbackGenerator:UIImpactFeedbackGenerator?
    private var selectionGenerator:UISelectionFeedbackGenerator?
    
    ///Used to power the "drag to select" functionality like the iOS version
    private let panGestureRecognizer: UIPanGestureRecognizer = UIPanGestureRecognizer()
    
    /// A blurred background view, applied only when Reduce Transparency is disabled in accessibility settings.
    private let blurBackgroundView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: nil)
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return view
    }()
    
    /// A snapshot for the targeted view.
    private var snapshotView:UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    //MARK: - Custom propertis to be used inside the class
    /// A property to save the last highlighted index in menuTableView - used for pan
    private var currentlyHighlightedIndex:IndexPath?
    /// Check the state where the targeted view is resized vertically
    private var isSnapshotResizedV: Bool = false
    /// Check the state where the targeted view is resized horizontally
    private var isSnapshotResizedH: Bool = false
    /// Animator for background blur effect
    private var animator: UIViewPropertyAnimator?
    private var isDismissing: Bool = false
    /// Original rect for  targeted view
    private var originalRect:CGRect?
    ///
    /// Target view initial alpha
    /// Don't worry we save your view initial alpha ;)
    private var initialAlpha:CGFloat?
    
    //MARK: - Container frame properties
    private var initialY:CGFloat?
    private var initialHeight:CGFloat?
    private let defaultMargin:CGFloat = 8
    
    weak var delegate: ReactionPreviewDelegate?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    deinit {}
    
    init(_ view: UIView, with config: ReactionConfig, theme: ReactionTheme? = .default) {
        super.init(frame: .zero)
        // view should be visible in the window!
        guard let window = view.window else { return }
        
        self._hostingView = view
        
        self._config = config
        
        self._theme = theme
        
        if let emojis = config.emojis, !emojis.isEmpty {
            self.setupReactionView()
        }
        
        if let menu = config.menu, !menu.options.isEmpty {
            self.setupMenuView()
        }
        
        if config.enableFeedbackGeneration {
            self.enableFeedback()
        }
        
        if config.enablePanGesture {
            self.enablePanGesture()
            if let continuedPanGesture = config.continuedPanGesture {
                self.panned(gestureRecognizer: continuedPanGesture)
            }
        }
        
        self.addTapToDismissGesture()
        
        self.setOriginalRect(view.convert(view.bounds, to: window))
        self.setSnapShot(view.snapshot())
        
        self.add(to: window)
        self.buildView()
        self.prepareLayout()
    }
    
    private func buildView() {
        self.addSubview(blurBackgroundView)
        self.addSubview(container)
        if let reactionView {
            container.addSubview(reactionView)
        }
        container.addSubview(snapshotView)
        
        if let visualEffectView, let menuTableView {
            container.addSubview(visualEffectView)
            visualEffectView.contentView.addSubview(menuTableView)
        }
    }
    
    private func prepareLayout() {
        
        blurBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            blurBackgroundView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            blurBackgroundView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            blurBackgroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
            blurBackgroundView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
        ])
        
        self.layout()
        
    }
    
    private func setSnapShot(_ image: UIImage?) {
        snapshotView.image = image
    }
    
    private func setOriginalRect(_ rect: CGRect?) {
        self.originalRect = rect
        self.vibrate(at: originalRect?.origin)
    }
    
    private func layout(){
        guard var originalRect else {return}
        self.shouldResizeImage()
        var y = originalRect.origin.y - (reactionView != nil ? (REACTION.SIZE.height + REACTION.MARGIN) : 0 )
        initialY = y
        
        // container initial frame
        container.frame = CGRect(x: 0, y: y, width: self.window?.bounds.width ?? 0, height: 0)
        
        // Reaction view frame
        let reactionWidth = REACTION.getWidth(count: (_config.emojis?.count ?? 0) + (_config.moreButton ? 1 : 0)) + 16 // 16 is the spacing
        let xReaction = _config.startFrom.isLeading() ? originalRect.origin.x : originalRect.origin.x + originalRect.width - reactionWidth
        y = 0
        reactionView?.frame = CGRect(x: xReaction, y: y, width: reactionWidth, height: REACTION.SIZE.height)
        
        // Message snapshot Frame
        y = reactionView != nil ? (reactionView!.bottom() + REACTION.MARGIN) : 0
        let snapshotSize = getImageSize()
        let xSanpshot = isSnapshotResizedV ? ( _config.startFrom.isLeading() ? originalRect.origin.x : originalRect.origin.x + originalRect.width - snapshotSize.width) : originalRect.origin.x
        snapshotView.frame = CGRect(x: xSanpshot, y: y, width: snapshotSize.width, height: snapshotSize.height)
        
        // Menu Frame
        let xMenu = _config.startFrom.isLeading() ? originalRect.origin.x : originalRect.origin.x + originalRect.width - MENU.WIDTH
        
        let menuHeight = height()
        // fisrt stage will draw the menu from the bottom
        var yMenu = getMaxBottom() - menuHeight - getMinTop()
        // here we are checking if we have space to move it to the bottom of snapshot
        let diff = yMenu - snapshotView.bottom()
        yMenu = diff > REACTION.MARGIN ? snapshotView.bottom() + REACTION.MARGIN : yMenu
        
        visualEffectView?.frame = CGRect(x: xMenu, y: yMenu, width: MENU.WIDTH, height: menuHeight)
        menuTableView?.frame = visualEffectView?.bounds ?? .zero
        
        container.frame.size.height = visualEffectView?.bottom() ?? snapshotView.bottom()
        
    }
    
    func dismiss(with action: UIAction? = nil, emoji: String? = nil, moreButton: Bool = false){
        guard !self.isDismissing else { return }
        self.isDismissing = true
        animator = UIViewPropertyAnimator(duration: 0.4, curve: .easeOut) { [weak self] in
            self?.blurBackgroundView.effect = nil
        }
        self.animator?.startAnimation()
        
        // Start state
        self.reactionView?.transform = .identity
        self.reactionView?.alpha = 1
        
        self.visualEffectView?.transform = .identity
        self.visualEffectView?.alpha = 1
        
        // Animate to final state
        UIView.animate(withDuration: 0.4,
                       delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.5,
                       options: [.curveEaseOut],
                       animations: {
            
            if !self.isSnapshotResizedV {
                self.container.frame.origin.y = self.initialY ?? 0
                if self._config.startFrom.isCenter() {
                    self.snapshotView.frame.origin.x = self.originalRect?.origin.x ?? 0
                }
            }
            if !self.isSnapshotResizedH {
                self.container.frame.origin.x = 0
            }
            
            let anchorX: CGFloat = self._config.startFrom.isLeading() ? 0.0 : self._config.startFrom.isTrailing() ? 1.0 : 0.5
            self.reactionView?.setCustomAnchorPoint(CGPoint(x: anchorX, y: 1.1))
            self.reactionView?.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)
            self.reactionView?.alpha = 0
            
            self.visualEffectView?.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            self.visualEffectView?.alpha = 0
        }, completion: { _ in
            if self._config.hideTargetWhenReact {
                self._hostingView?.alpha = self.initialAlpha ?? 1
            }
            self.delegate?.didDismiss(on: self._config.itemIdentifier, action: action, emoji: emoji, moreButton: moreButton)
            self.removeFromSuperview()
        })
    }
    
    private func add(to view: UIView) {
        view.addSubview(self)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            self.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
        ])
        
    }
    
    private func vibrate(at origin: CGPoint?) {
        if #available(iOS 17.5, *), let origin {
            feedbackGenerator?.impactOccurred(at: origin)
        } else {
            feedbackGenerator?.impactOccurred()
        }
    }
    
    
    
    func animate() {
        
        if _config.hideTargetWhenReact {
            self.initialAlpha = self._hostingView?.alpha ?? 1
            self._hostingView?.alpha = 0
        }
        delegate?.willReact?()
        
        animator = UIViewPropertyAnimator(duration: 0.4, curve: .linear) { [weak self] in
            if !UIAccessibility.isReduceTransparencyEnabled {
                self?.blurBackgroundView.effect = self?._theme.backgroundBlurEffectStyle
            }else {
                self?.blurBackgroundView.backgroundColor = self?._theme.backgroundFallbackColor
            }
        }
        
        animator?.startAnimation()
        
        // Pause the animation at 50% progress
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in // Half of duration
            self?.animator?.pauseAnimation()
            self?.animator?.fractionComplete = 0.5
            self?.animator?.stopAnimation(false)
            self?.animator?.finishAnimation(at: .current)
        }
        
        // we don't need animation when resizing happen
        UIView.animate(withDuration: (isSnapshotResizedH || isSnapshotResizedV) ? 0 : 0.2) { [weak self] in
            if self?._config.startFrom.isCenter() ?? false {
                self?.snapshotView.setCenterX()
                self?.reactionView?.setCenterX()
                self?.visualEffectView?.setCenterX()
            }
            self?.checkViewInSafeArea()
        }
        self.animateMenuAndReaction()
    }
    
    private func checkViewInSafeArea(){
        checkViewInVerticalSafeArea()
        checkViewInHorizontalSafeArea()
    }
    
    private func checkViewInVerticalSafeArea(){
        let topOffset = container.top() - getMinTop()
        let bottomOffset = getMaxBottom() - container.bottom()
        guard topOffset < 0 || bottomOffset < 0  else { return }
        // the view is outside the safe area
        if topOffset < 0, !isSnapshotResizedV {
            if abs(topOffset) <= abs(bottomOffset) {
                // we can move down
                self.container.frame.origin.y += abs(topOffset)
            }else  {
                self.container.frame.origin.y = getMinTop()
            }
        }
        else if bottomOffset < 0 , abs(bottomOffset) <= abs(topOffset) {
            // we can move top
            self.container.frame.origin.y -= abs(bottomOffset)
        }else if isSnapshotResizedV {
            self.container.frame.origin.y = getMinTop()
        }
    }
    
    private func checkViewInHorizontalSafeArea(){
        let x0 = _config.startFrom.isLeading() ? self.snapshotView.left() : min(self.snapshotView.left(), self.reactionView?.left() ?? self.snapshotView.left(), self.visualEffectView?.left() ?? self.snapshotView.left())
        let x1 = max(self.snapshotView.width(), self.reactionView?.width() ?? self.snapshotView.width(), self.visualEffectView?.width() ?? self.snapshotView.width())
        
        if x0 < getMinLeft() {
            self.container.frame.origin.x += abs(x0) + getMinLeft()
        }else if x0 + x1 > getMaxAvailableWidth() {
            self.container.frame.origin.x = getMaxAvailableWidth() - x0 - x1 + getMinLeft()
        }
    }
    
    private func animateMenuAndReaction(){
        self.reactionView?.animateScaleAndFadeIn(startingFrom:CGAffineTransform(scaleX: 0.1, y: 0.4), startFrom: _config.startFrom)
        self.reactionView?.startAnimating()
        self.visualEffectView?.animateScaleAndFadeIn(startingFrom:  CGAffineTransform(scaleX: 0.2, y: 0.2), startFrom: _config.startFrom, isFromTop: true)
    }
    
    private func getImageSize() -> CGSize {
        guard let image = snapshotView.image else {return .zero}
        return image.size
    }
    
    private func shouldResizeImage() {
        guard let image = snapshotView.image else {return}
        let maxAvailableHeight = getMaxAvailableHeight()
        let maxAvailableWidth = getMaxAvailableWidth()
        if image.size.height > maxAvailableHeight {
            isSnapshotResizedV = true
        }
        if image.size.width > maxAvailableWidth {
            isSnapshotResizedH = true
        }
        if isSnapshotResizedH || isSnapshotResizedV {
            snapshotView.image = image.resizedToFit(in: CGSize(width: isSnapshotResizedH ? maxAvailableWidth : image.size.width, height: isSnapshotResizedV ? maxAvailableHeight : image.size.height))
        }
         
    }
    
    // vertically
    private func getMaxAvailableHeight() -> CGFloat {
        return getMaxBottom() - getMinTop() - REACTION.SIZE.height - REACTION.MARGIN
    }
    
    // horizontally
    private func getMaxAvailableWidth() -> CGFloat {
        return (self.window?.bounds.width ?? 0) - 2 * defaultMargin
    }
    
    private func getMinTop() -> CGFloat {
        let safeAreaTopInset:CGFloat = self.window?.safeAreaInsets.top ?? 0
        return REACTION.MARGIN + (self.window?.frame.origin.y ?? 0) + (safeAreaTopInset > 0 ? safeAreaTopInset : REACTION.MARGIN)
    }
    
    private func getMaxBottom() -> CGFloat {
        let height = self.window?.frame.height ?? 0
        let safeAreaBottomInset:CGFloat = self.window?.safeAreaInsets.bottom ?? 0
        return height - REACTION.MARGIN - (safeAreaBottomInset > 0 ? safeAreaBottomInset : REACTION.MARGIN)
    }
    
    private func getMinLeft() -> CGFloat {
        return defaultMargin
    }
    
    private func addInitialData() {
        guard let menu = _config.menu else {return}
        var snapshot = NSDiffableDataSourceSnapshot<UIMenu, UIAction>()

        if let actionChildren = menu.children as? [UIAction] {
            // To keep a consistent data structure, wrap actions in a UIMenu so we can still have menus at the top level to have support for secttions
            let wrapperMenu = UIMenu(title: "", image: nil, identifier: nil, options: [.displayInline], children: actionChildren)
            
            let menuChildren: [UIMenu] = [wrapperMenu]
            snapshot.appendSections(menuChildren)
            
            menuChildren.forEach {
                snapshot.appendItems($0.children as! [UIAction], toSection: $0)
            }
        } else if let menuChildren = menu.children as? [UIMenu] {
            snapshot.appendSections(menuChildren)
            
            menuChildren.forEach {
                snapshot.appendItems($0.children as! [UIAction], toSection: $0)
            }
        }
        
        (menuTableView?.dataSource as? UITableViewDiffableDataSource<UIMenu, UIAction>)?.apply(snapshot, animatingDifferences: false, completion: nil)
    }
    
    @objc private func didTapView(){
        self.dismiss()
    }
    
    func height() -> CGFloat {
        let tableHeight = menuTableView?.sizeThatFits(CGSize(width: MENU.WIDTH, height: CGFloat.greatestFiniteMagnitude)).height.rounded()
        return tableHeight ?? 0
    }
    
}

// MARK: - UITableViewDelegate


extension ReactionPreviewView: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard section != tableView.numberOfSections - 1 else { return nil }

        let footerView = UIView()
        footerView.backgroundColor = UIColor(white: 0.0, alpha: 0.1)
        return footerView
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let sectionDividerHeight: CGFloat = 8.0

        // If it's the last section, don't show a divider, otherwise do
        return section == tableView.numberOfSections - 1 ? 0.0 : sectionDividerHeight
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectionGenerator?.selectionChanged()
        self.dismiss(with: getActionAtIndexPath(indexPath))
    }
}

// MARK: - UIGestureRecognizerDelegate

extension ReactionPreviewView : UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let isInTableView:Bool = (menuTableView?.bounds.contains(touch.location(in: menuTableView))) ?? false
        if let reactionView {
           return !isInTableView && !reactionView.bounds.contains(touch.location(in: reactionView))
        }
        return !isInTableView
    }
}

// MARK: - Target Action

extension ReactionPreviewView {
    @objc func panned(gestureRecognizer: UIGestureRecognizer) {
        let panPoint = gestureRecognizer.location(in: menuTableView)
        guard let indexPath = menuTableView?.indexPathForRow(at: panPoint) else {
            // If we pan outside the table and there's a cell selected, unselect it
            if let currentlyHighlightedIndex  {
                highlightCell(false, at: currentlyHighlightedIndex)
            }
            if let point = reactionView?.panned(gestureRecognizer: gestureRecognizer){
                self.onSelectionChanged(at: point)
            }
            self.currentlyHighlightedIndex = nil
            return
        }
        
        if gestureRecognizer.isFinished(), currentlyHighlightedIndex == nil {
            return
        }
        
        guard indexPath != currentlyHighlightedIndex else {
            if gestureRecognizer.isFinished() {
                highlightCell(false, at: indexPath)
                self.dismiss(with: getActionAtIndexPath(indexPath))
            }
            return
        }
        
        if let currentlyHighlightedIndex  {
            highlightCell(false, at: currentlyHighlightedIndex)
        }
        self.onSelectionChanged(at: panPoint)
        self.currentlyHighlightedIndex = indexPath
        
        if gestureRecognizer.isFinished() {
            // Treat is as a tap
            self.dismiss(with: getActionAtIndexPath(indexPath))
        } else {
            highlightCell(true, at: indexPath)
        }
    }
    
    @objc func emojiPanned(gestureRecognizer: UIGestureRecognizer) {
        if let point = reactionView?.panned(gestureRecognizer: gestureRecognizer){
            self.onSelectionChanged(at: point)
        }
    }
    
    private func highlightCell(_ bool: Bool, at indexPath: IndexPath){
        guard let cell = self.menuTableView?.cellForRow(at: indexPath) as? ReactionMenuTableViewCell else { return }
        cell.highlight(bool, animated: false)
    }
    
    private func onSelectionChanged(at point: CGPoint){
        if #available(iOS 17.5, *) {
            selectionGenerator?.selectionChanged(at: point)
        } else {
            selectionGenerator?.selectionChanged()
        }
    }
}

// MARK: - ReactionViewDelegate

extension ReactionPreviewView : ReactionViewDelegate {
    func didSelectEmoji(_ emoji: String) {
        self.dismiss(emoji: emoji)
    }
    
    func didSelectMoreButton() {
        self.dismiss(moreButton: true)
    }

}

// MARK: - Setup helper
extension ReactionPreviewView {
    
    private func setupReactionView() {
        self.reactionView = ReactionView()
        self.reactionView!._emojis = _config.emojis!
        self.reactionView!.direction = _config.startFrom
        self.reactionView!.isAnimationEnabled = _config.emojiEnteranceAnimated
        self.reactionView!.setupIcon(_theme.moreButtonIcon)
        self.reactionView!.backgroundColor = _theme.reactionBackgroundColor
        self.reactionView!.alpha = 0
        self.reactionView!.delegate = self
    }
    
    private func setupMenuView() {
        visualEffectView = UIVisualEffectView(effect: nil)
        if !UIAccessibility.isReduceTransparencyEnabled {
            visualEffectView!.effect = _theme.menuBlurEffectStyle
        }else {
            visualEffectView!.backgroundColor = _theme.menuBlurFallbackColor
        }
        visualEffectView!.layer.masksToBounds = true
        visualEffectView!.layer.cornerRadius = 13.0
        visualEffectView!.isUserInteractionEnabled = true
        visualEffectView!.alpha = 0
        
        menuTableView = UITableView(frame: .zero, style: .plain)
        menuTableView!.register(ReactionMenuTableViewCell.self, forCellReuseIdentifier: ReactionMenuTableViewCell.identifier)
        menuTableView!.separatorInset = .zero
        menuTableView!.translatesAutoresizingMaskIntoConstraints = false
        menuTableView!.backgroundColor = .clear
        menuTableView!.isUserInteractionEnabled = true
        menuTableView!.isScrollEnabled = false
        menuTableView!.verticalScrollIndicatorInsets = UIEdgeInsets(top: 13.0, left: 0.0, bottom: 13.0, right: 0.0)
        
        
        // Required to not get whacky spacing
        menuTableView!.estimatedSectionHeaderHeight = 0.0
        menuTableView!.estimatedRowHeight = 0.0
        menuTableView!.estimatedSectionFooterHeight = 0.0
        
        // This hack still seems to be the best way to hide the last separator in a UITableView
        let fauxTableFooterView = UIView()
        fauxTableFooterView.frame = CGRect(x: 0.0, y: 0.0, width: CGFloat.leastNormalMagnitude, height: CGFloat.leastNormalMagnitude)
        menuTableView!.tableFooterView = fauxTableFooterView
        
        self.dataSource = makeDataSource()
        menuTableView!.delegate = self
        self.addInitialData()
    }
    
    private func enableFeedback() {
        self.feedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
        self.feedbackGenerator!.prepare()
        
        self.selectionGenerator = UISelectionFeedbackGenerator()
        self.selectionGenerator!.prepare()
    }
    
    private func enablePanGesture() {
        panGestureRecognizer.addTarget(self, action: #selector(panned(gestureRecognizer:)))
        panGestureRecognizer.cancelsTouchesInView = false
         self.container.addGestureRecognizer(panGestureRecognizer)
    }
    
    private func addTapToDismissGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        tap.cancelsTouchesInView = false
        tap.delegate = self
        self.addGestureRecognizer(tap)
    }
    
}

// MARK: - Helpers
extension ReactionPreviewView {
    private func makeDataSource() -> UITableViewDiffableDataSource<UIMenu, UIAction> {
        let dataSource = UITableViewDiffableDataSource<UIMenu, UIAction>(tableView: menuTableView!) { (tableView, indexPath, action) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: ReactionMenuTableViewCell.identifier, for: indexPath) as! ReactionMenuTableViewCell
            cell.menuTitle = action.title
            cell.iconImage = action.image
            cell.isDestructive = action.attributes.contains(.destructive)
            return cell
        }
        
        return dataSource
    }
    
    private func getActionAtIndexPath(_ indexPath: IndexPath) -> UIAction? {
        return (menuTableView?.dataSource as? UITableViewDiffableDataSource<UIMenu, UIAction>)?.itemIdentifier(for: indexPath)
    }
}
