![EmojisReactionKit](https://i.postimg.cc/LsFdKB2G/image-new.png)

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

![EmojisReactionKit](https://i.postimg.cc/mrBdydbZ/Untitled-1.png)

---

## ⚙️ Requirements

- iOS 13+

---

## 📦 Installation

Use **Swift Package Manager**:

In Xcode:

- Go to **File > Add Package Dependencies**
- Enter the repository URL: https://github.com/ikhaled-ali/EmojisReactionKit.git
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
MIT License. See <a target="_blank" href="https://github.com/ikhaled-ali/EmojisReactionKit/blob/main/LICENSE">LICENSE</a> for more info.

## 😎 Author

Made with ❤️ by iKʜAʟED〆
