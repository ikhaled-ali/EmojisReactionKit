//
//  EmojiCellView.swift
//  EmojisReactionKit
//
//  Created by iKʜAʟED〆 on 30/05/2025.
//

import UIKit

class EmojiCellView: UICollectionViewCell {
    
    let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 28)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    let selectedView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.masksToBounds = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        buildView()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSub(view: UIView) {
        self.contentView.addSubview(view)
    }
    
    private func buildView() {
        self.addSub(view: selectedView)
        self.addSub(view: emojiLabel)
    }
    
    private func makeConstraints() {
        
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        selectedView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor, constant: 0),
            emojiLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor, constant: 0),
            emojiLabel.widthAnchor.constraint(equalToConstant: REACTION.ITEM_SIZE.width),
            emojiLabel.heightAnchor.constraint(equalToConstant: REACTION.ITEM_SIZE.height),
            selectedView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0),
            selectedView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0),
            selectedView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0),
            selectedView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0),
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        selectedView.layer.cornerRadius = contentView.bounds.width/2
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        emojiLabel.attributedText = nil
        selectedView.backgroundColor = .clear
    }
    
    //MARK: - Methods
    
    func animate() {
        UIView.animate(withDuration: 0.15, delay: 0, options: [.curveLinear], animations: {
            // Slight zoom and lift upward
            self.emojiLabel.transform = CGAffineTransform(scaleX: 2.0, y: 2.0).concatenating(
                CGAffineTransform(translationX: 0, y: -25)
            )
        }, completion: nil)
    }
    
    func reset() {
        UIView.animate(withDuration: 0.15, delay: 0, options: [.curveLinear], animations: {
            self.emojiLabel.transform = .identity
        }, completion: nil)
    }
    
    func setEmoji(emoji: String, selectedEmoji: String?){
        let isSelected = emoji == selectedEmoji
        
        emojiLabel.text = emoji
        
        selectedView.backgroundColor = isSelected ? .systemGray : .clear
    }
}
