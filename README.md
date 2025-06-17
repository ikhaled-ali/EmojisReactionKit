![EmojisReactionKit](https://private-user-images.githubusercontent.com/18719370/455957489-67f489ad-3be1-490f-9279-7278fe3b55b6.png?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3NTAxNTgwMzIsIm5iZiI6MTc1MDE1NzczMiwicGF0aCI6Ii8xODcxOTM3MC80NTU5NTc0ODktNjdmNDg5YWQtM2JlMS00OTBmLTkyNzktNzI3OGZlM2I1NWI2LnBuZz9YLUFtei1BbGdvcml0aG09QVdTNC1ITUFDLVNIQTI1NiZYLUFtei1DcmVkZW50aWFsPUFLSUFWQ09EWUxTQTUzUFFLNFpBJTJGMjAyNTA2MTclMkZ1cy1lYXN0LTElMkZzMyUyRmF3czRfcmVxdWVzdCZYLUFtei1EYXRlPTIwMjUwNjE3VDEwNTUzMlomWC1BbXotRXhwaXJlcz0zMDAmWC1BbXotU2lnbmF0dXJlPWM0MzkxZWY5MTY3M2Y5Y2I5NjEyMDBkNjJlOGZhOGExNTc4ZmU2ZDU1NzAyYmQ2MzEwYzNiMDkyMWZmNmEzOGYmWC1BbXotU2lnbmVkSGVhZGVycz1ob3N0In0.eRAIMpDd655adPnA_qvIjFCu6zcyKFVMjVp9s51RQqA)

# EmojisReactionKit 👍🏼 ❤️ 😂 👌🏼

A modern, lightweight drop-in replacement for iOS context menus — with emoji reactions, animated transitions, haptic feedback, and full theme customization.
Perfect for messaging apps, comments, or any UI that could benefit from emoji-based interaction.

Built from scratch to offer a familiar yet customizable interaction — ideal for chat interfaces, social feeds, and interactive content.

---

## ✨ Features

- 🧩 **Attach to any UIView** — just call `.react(...)`
- 🎨 **Customizable UI**:
  - Show/hide emoji reactions
  - Show/hide Menu actions
- 💬 **Smart gesture handling**:
  - Works with any guester you want
  - Pan-to-select emoji or action with haptic feedback
- 💥 **Smooth transitions**
- 🛠️ **Fully themeable** — light/dark styles, blur options, more icon etc.

---

## 📷 Preview

![EmojisReactionKit](https://private-user-images.githubusercontent.com/18719370/455955723-b92ab4dc-e792-4a06-9f83-c48eb938cc30.png?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3NTAxNTc3NzQsIm5iZiI6MTc1MDE1NzQ3NCwicGF0aCI6Ii8xODcxOTM3MC80NTU5NTU3MjMtYjkyYWI0ZGMtZTc5Mi00YTA2LTlmODMtYzQ4ZWI5MzhjYzMwLnBuZz9YLUFtei1BbGdvcml0aG09QVdTNC1ITUFDLVNIQTI1NiZYLUFtei1DcmVkZW50aWFsPUFLSUFWQ09EWUxTQTUzUFFLNFpBJTJGMjAyNTA2MTclMkZ1cy1lYXN0LTElMkZzMyUyRmF3czRfcmVxdWVzdCZYLUFtei1EYXRlPTIwMjUwNjE3VDEwNTExNFomWC1BbXotRXhwaXJlcz0zMDAmWC1BbXotU2lnbmF0dXJlPThmM2NlM2IyNzNiMTk1ZDliY2M5NGJmOTVkODJjNzNhNzhkMDFlZWUzNzU3NDllNmVkNDkwOTczMmM0ODUxODQmWC1BbXotU2lnbmVkSGVhZGVycz1ob3N0In0.GdDHKBSvyamF5SVOQLx3giY3wnbmuwR_3TcSk5ZtgTQ)

---

## ⚙️ Requirements

- iOS 13+

---

## 📦 Installation

Use **Swift Package Manager**:

In Xcode:

- Go to **File > Add Packages**
- Enter the repository URL:
- Choose the latest version and add the package.

---

## 🛠️ Usage

### Full Reaction + Menu

```swift
import EmojisReactionKit

let reactConfig = ReactionConfig(
 itemIdentifier: indexPath,
 emojis: ["👍🏼", "😂", "❤️", "👌🏼"],
 menu: UIMenu(title: "", children: [
     UIAction(identifier: "reply", title: "Reply", image: UIImage(systemName: "arrowshape.turn.up.left")) { _ in // ⛔️ Keep it empty and Handle action in delegate! 
     }
 ]),
 startFrom: .center
)

reactionPreview = yourView.react(with: reactConfig, delegate: self)
```

### Only Emoji Reaction?

```swift
ReactionConfig(
    itemIdentifier: indexPath,
    emojis: ["👍🏼", "😂", "❤️", "👌🏼"]
)
yourView.react(with: config, delegate: self)
```

### 🧩 Delegate Callback
```swift
func didDismiss(on identifier: Any, action: UIAction?, emoji: String?, moreButton: Bool) {
    if let emoji = emoji {
        print("User reacted with: \(emoji)")
    } else if let action = action {
        print("User selected action: \(action.identifier)")
    }else if moreButton {
        print("more button clicked")
    }
}
```

## 📚 FAQ

#### Does it support RTL layouts?
✅ Yes, RTL is supported out of the box.
#### Can I disable the emoji reaction or menu?
✅ Yes. Just pass an empty emojis array or set menu: nil.
#### How do I theme it?
Use the ReactionTheme to customize blur, background, and icon appearance.

## 📄 License
MIT License. See LICENSE for more info.

## 😎 Author

Made with ❤️ by iKʜAʟED〆
