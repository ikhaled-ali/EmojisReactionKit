//
//  NewsViewController.swift
//  Demo
//
//  Created by iKʜAʟED〆 on 17/06/2025.
//

import UIKit
import EmojisReactionKit

struct NewsItem {
    let title: String
    let subtitle: String
}

class NewsListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let tableView = UITableView()
    
    private let news: [NewsItem] = [
        NewsItem(title: "Apple WWDC 2025 Highlights", subtitle: "New iOS 19 features revealed"),
        NewsItem(title: "Stock Markets Rise", subtitle: "Tech leads gains as investors eye AI boom"),
        NewsItem(title: "NASA Launch Successful", subtitle: "Next-gen telescope reaches orbit"),
        NewsItem(title: "Swift 6 Released", subtitle: "Major improvements in performance and safety"),
        NewsItem(title: "Electric Cars Break Records", subtitle: "EV sales double in Q2 2025")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "News"
        view.backgroundColor = .systemBackground
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "NewsCell")
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return news.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = news[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath)
        cell.selectionStyle = .none
        var config = cell.defaultContentConfiguration()
        config.text = item.title
        config.secondaryText = item.subtitle
        cell.contentConfiguration = config
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        let reactConfig = ReactionConfig(itemIdentifier: indexPath, emojis: ["👍🏼", "😂", "❤️", "💻"], startFrom: .center)
    
        cell.contentView.react(with: reactConfig, delegate: self)
    }
}

extension NewsListViewController : ReactionPreviewDelegate {
    func didDismiss(on identifier: Any?, action: UIAction?, emoji: String?, moreButton: Bool) {
        if let emoji = emoji {
            print("User reacted with: \(emoji)")
        } else if let action = action {
            print("User selected Action: \(action.identifier.rawValue)")
        }else if moreButton {
            print("more button clicked")
        }
    }
}
