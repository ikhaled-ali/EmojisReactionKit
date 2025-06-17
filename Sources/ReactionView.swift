//
//  ReactionView.swift
//  EmojisReactionKit
//
//  Created by iKʜAʟED〆 on 07/05/2025.
//  Copyright © 2025. All rights reserved.
//

import UIKit

class ReactionView: UIView {
    
    var _emojis: [String] = []
    private var emojis: [String] = []
    private var selectedEmoji: String?
    var isAnimationEnabled:Bool = true
    var direction: ReactionDirection = .leading
    private var currentlyHighlightedIndex:IndexPath?
    private var isAnimationDone:Bool = false
    private var isPanChanged = false
    
    weak var delegate:ReactionViewDelegate?
    
    override var backgroundColor: UIColor? {
        didSet {
            super.backgroundColor = backgroundColor
            self.backButtonBg.backgroundColor = backgroundColor
        }
    }
    
    private let collectionContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.clipsToBounds = true
        return view
    }()
    
    private let backButtonBg: UIView = {
        let view = UIView()
        view.layer.cornerRadius = REACTION.ITEM_SIZE.height / 2
        return view
    }()
    
    private let moreButton: UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        button.layer.cornerRadius = REACTION.ITEM_SIZE.height / 2
        button.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        button.alpha = 0
        return button
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = RTLCollectionFlow()
        layout.scrollDirection = .horizontal
        layout.itemSize = REACTION.ITEM_SIZE
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.sectionInset = .zero
        
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(EmojiCellView.self, forCellWithReuseIdentifier: EmojiCellView.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.clipsToBounds = false
        return collectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
    }
    
    private func configureView() {
        setupView()
        buildView()
        makeConstraints()
    }
    
    private func setupView() {
        self.clipsToBounds = false
        moreButton.addTarget(self, action: #selector(didClickButton), for: .touchUpInside)
    }
    
    private func buildView() {
        self.addSubview(collectionContainerView)
        collectionContainerView.addSubview(collectionView)
        self.addSubview(backButtonBg)
        self.addSubview(moreButton)
    }
    
    
    private func makeConstraints() {
        collectionContainerView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        moreButton.translatesAutoresizingMaskIntoConstraints = false
        backButtonBg.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // collectionContainerView constraints
            collectionContainerView.topAnchor.constraint(equalTo: self.topAnchor, constant: -50),
            collectionContainerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            collectionContainerView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            collectionContainerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),

            // collectionView constraints
            collectionView.topAnchor.constraint(equalTo: collectionContainerView.topAnchor, constant: 50),
            collectionView.leadingAnchor.constraint(equalTo: collectionContainerView.leadingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: collectionContainerView.bottomAnchor),
            collectionView.trailingAnchor.constraint(equalTo: collectionContainerView.trailingAnchor, constant: -(8 + REACTION.ITEM_SIZE.width)),

            // moreButton constraints
            moreButton.leadingAnchor.constraint(equalTo: collectionView.trailingAnchor),
            moreButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            moreButton.widthAnchor.constraint(equalToConstant: REACTION.ITEM_SIZE.width),
            moreButton.heightAnchor.constraint(equalToConstant: REACTION.ITEM_SIZE.height),

            // backButtonBg constraints
            backButtonBg.leadingAnchor.constraint(equalTo: moreButton.leadingAnchor, constant: 2),
            backButtonBg.trailingAnchor.constraint(equalTo: moreButton.trailingAnchor),
            backButtonBg.topAnchor.constraint(equalTo: moreButton.topAnchor),
            backButtonBg.bottomAnchor.constraint(equalTo: moreButton.bottomAnchor)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // this mask allows us to make horizontal clipsToBounds only
        let maskLayer = CAShapeLayer()
        let horizontalClipRect = CGRect(x: 0, y: -200, width: bounds.width, height: bounds.height + 400)
        let cornerRadius: CGFloat = REACTION.ITEM_SIZE.height / 2

        let path = UIBezierPath(roundedRect: horizontalClipRect, cornerRadius: cornerRadius)
        maskLayer.path = path.cgPath
        layer.mask = maskLayer
        
        self.layer.cornerRadius = self.bounds.size.height / 2
    }
    
    deinit{}
    
    @objc private func didClickButton() {
        self.delegate?.didSelectMoreButton()
    }
    
    func startAnimating() {
        guard !direction.isCenter(), isAnimationEnabled else {
            self.moreButton.transform = .identity
            self.moreButton.alpha = 1
            self.loadData()
            return
        }
        self.moreButton.zoomInBounce(duration: direction.isLeading() ? 0.2 : 0.3, options: [.curveEaseInOut], delay: 0.1)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.loadData()
        }
        
    }
    
    func setupIcon(_ image: UIImage){
        self.moreButton.setImage(image, for: .normal)
    }
}

// MARK: - Load Data
extension ReactionView {
    func loadData(){
        self.emojis = _emojis
        self.collectionView.reloadData()
    }
}

// MARK: - Receive pan gesture
extension ReactionView {
    func panned(gestureRecognizer: UIGestureRecognizer) -> CGPoint? {
        if gestureRecognizer.isChanged(){
            isPanChanged = true
        }
        guard isPanChanged else { return nil } // pan should be changed one time before proceeding
        let exactPanPoint = gestureRecognizer.location(in: collectionView)
        // i give some margin to the touch area so the emoji start highlighted before reaching its exact area
        let marginPanPoint = CGPoint(x: exactPanPoint.x, y: exactPanPoint.y - REACTION.TOUCH_AREA_MARGIN)

        guard let indexPath = collectionView.indexPathForItem(at: marginPanPoint) ?? collectionView.indexPathForItem(at: exactPanPoint), collectionView.indexPathsForVisibleItems.contains(indexPath) else {
            // If we pan outside the table and there's a cell selected, unselect it
            if let currentlyHighlightedIndex  {
                highlightCell(false, at: currentlyHighlightedIndex)
            }
            self.currentlyHighlightedIndex = nil
            return checkButtonHighlight(gestureRecognizer: gestureRecognizer)
        }
        highlightButton(false)
        if gestureRecognizer.isFinished(), currentlyHighlightedIndex == nil {
            return nil
        }
        
        guard indexPath != currentlyHighlightedIndex else {
            if gestureRecognizer.isFinished() {
                highlightCell(false, at: indexPath)
                selectEmoji(atIndex: indexPath)
            }
            return nil
        }
        
        if let currentlyHighlightedIndex  {
            highlightCell(false, at: currentlyHighlightedIndex)
        }
        
        self.currentlyHighlightedIndex = indexPath
        
        if gestureRecognizer.isFinished() {
            // Treat is as a tap
            selectEmoji(atIndex: indexPath)
        } else {
            highlightCell(true, at: indexPath)
        }
        return exactPanPoint
    }
    
    private func checkButtonHighlight(gestureRecognizer: UIGestureRecognizer) -> CGPoint?{
        let exactPanPoint = gestureRecognizer.location(in: moreButton)
        // i give some margin to the touch area so the emoji start highlighted before reaching its exact area
        let marginPanPoint = CGPoint(x: exactPanPoint.x, y: exactPanPoint.y - REACTION.TOUCH_AREA_MARGIN)
        let isHighlighted = moreButton.isHighlighted()
        if moreButton.bounds.contains(exactPanPoint) || moreButton.bounds.contains(marginPanPoint){
            highlightButton(true)
            if gestureRecognizer.isFinished() {
                highlightButton(false)
                self.didClickButton()
            }
            return isHighlighted ? nil : marginPanPoint
        }
        highlightButton(false)
        return nil
    }
    
    private func highlightCell(_ bool: Bool, at indexPath: IndexPath){
        guard let cell = self.collectionView.cellForItem(at: indexPath) as? EmojiCellView else { return }
        if bool { cell.animate() }
        else { cell.reset() }
    }
    
    private func highlightButton(_ bool: Bool){
        if bool { moreButton.animate() }
        else { moreButton.reset() }
    }
    
    private func selectEmoji(atIndex indexPath: IndexPath){
        let emoji = emojis[indexPath.item]
        self.delegate?.didSelectEmoji(emoji)
    }
}


// MARK: - UICollectionViewDataSource , UICollectionViewDelegate
extension ReactionView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emojis.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCellView.identifier, for: indexPath) as? EmojiCellView else {
            return UICollectionViewCell()
        }
        cell.setEmoji(emoji: emojis[indexPath.item], selectedEmoji: selectedEmoji)
        if !withoutAnimation() {
            cell.contentView.alpha = 0
            cell.contentView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectEmoji(atIndex: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if !withoutAnimation() {
            let delay = direction.isLeading() ? 0.03 * Double(indexPath.item) : 0.03 * Double(emojis.count - 1 - indexPath.item)
            cell.contentView.zoomInBounce(delay: delay)
        }else {
            cell.contentView.alpha = 1
            cell.contentView.transform = .identity
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !withoutAnimation(), scrollView == collectionView else {return}
        isAnimationDone = true
    }
    
    private func withoutAnimation() -> Bool {
        return !isAnimationEnabled || isAnimationDone || direction.isCenter()
    }
}

// MARK: - Emoji Protocol
protocol ReactionViewDelegate: AnyObject {
   @MainActor func didSelectEmoji(_ emoji: String)
    @MainActor func didSelectMoreButton()
}

// MARK: - private BaseUIButton extension
fileprivate extension UIButton {
    func animate() {
        guard self.transform == .identity else {return}
        self.backgroundColor = .clear
        UIView.animate(withDuration: 0.15, delay: 0, options: [.curveLinear], animations: {
            // Slight zoom and lift upward
            self.transform = CGAffineTransform(scaleX: 1.5, y: 1.5).concatenating(
                CGAffineTransform(translationX: 0, y: -25)
            )
        }, completion: nil)
    }
    
    func reset(duration: TimeInterval = 0.15, options : UIView.AnimationOptions = [.curveLinear], delay: TimeInterval = 0 ) {
        guard self.transform != .identity else {return}
        UIView.animate(withDuration: duration, delay: delay, options: options, animations: {
            self.transform = .identity
            self.alpha = 1
        }, completion: { _ in
            self.backgroundColor = self.superview?.backgroundColor
        })
    }
    
    func isHighlighted() -> Bool {
        return self.transform != .identity
    }
}

