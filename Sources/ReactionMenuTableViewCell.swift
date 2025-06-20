//
//  ReactionMenuTableViewCell.swift
//  EmojisReactionKit
//
//  Created by iKʜAʟED〆 on 07/05/2025.
//  Copyright © 2025 example. All rights reserved.
//

import UIKit

class ReactionMenuTableViewCell: UITableViewCell {
    var menuTitle: String = "" {
        didSet {
            menuTitleLabel.text = menuTitle
        }
    }
    
    var isDestructive: Bool = false {
        didSet {
            let color: UIColor = isDestructive ? .systemRed : .label
            menuTitleLabel.textColor = color
            iconImageView.tintColor = color
        }
    }
    
    var iconImage: UIImage? {
        didSet {
            iconImageView.image = iconImage
        }
    }
    
    override var accessibilityHint: String? {
        get {
            return menuTitle
        } set {
            super.accessibilityHint = newValue
        }
    }
    
    private let stackView: UIStackView = UIStackView()
    private let menuTitleLabel: UILabel = UILabel()
    private let iconImageView: UIImageView = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none
        accessibilityTraits = [.button]
        
        menuTitleLabel.font = UIFont.systemFont(ofSize: 17.0, weight: .regular)
        menuTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        menuTitleLabel.numberOfLines = 0
        
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(menuTitleLabel)
        contentView.addSubview(iconImageView)
        
        let horizontalPadding: CGFloat = 17.0
        let verticalPadding: CGFloat = 12.0
        let iconTrailingOffset: CGFloat = 27.0
        let titleToIconMinSpacing: CGFloat = -16.0
        
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: menuTitleLabel.leadingAnchor, constant: -horizontalPadding),
            contentView.topAnchor.constraint(equalTo: menuTitleLabel.topAnchor, constant: -verticalPadding),
            contentView.bottomAnchor.constraint(equalTo: menuTitleLabel.bottomAnchor, constant: verticalPadding),
            menuTitleLabel.trailingAnchor.constraint(equalTo: iconImageView.leadingAnchor, constant: titleToIconMinSpacing),
            
            contentView.trailingAnchor.constraint(equalTo: iconImageView.centerXAnchor, constant: iconTrailingOffset),
            contentView.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor),
        ])
        
        backgroundColor = .clear
    }

    required init?(coder aDecoder: NSCoder) { fatalError("\(#file) does not implement coder.") }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        backgroundColor = selected ? UIColor(white: 0.5, alpha: 0.2) : .clear
    }
    
    func highlight(_ highlighted: Bool, animated: Bool) {
        backgroundColor = highlighted ? UIColor(white: 0.5, alpha: 0.2) : .clear
    }
}
