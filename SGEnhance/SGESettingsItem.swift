import UIKit
import TelegramPresentationData

enum SGESettingsItem {
    case header(title: String)
    case button(title: String, action: () -> Void)
    case toggle(title: String, isOn: Bool, action: (Bool) -> Void)
    case notice(text: String)
    case spacer
}
