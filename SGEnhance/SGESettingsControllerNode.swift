import UIKit
import AsyncDisplayKit 
import Display
import TelegramPresentationData
import ItemListUI 

final class SGESettingsControllerNode: ASDisplayNode, ASScrollViewDelegate {
    private weak var controller: SGESettingsViewController?
    private var presentationData: PresentationData
    
    private let listNode: ListView 
    private var items: [SGESettingsItem] = []

    init(controller: SGESettingsViewController, presentationData: PresentationData) {
        self.controller = controller
        self.presentationData = presentationData
        self.listNode = ListView()
        self.listNode.verticalScrollIndicatorColor = presentationData.theme.list.scrollIndicatorColor
        self.listNode.accessibilityPageScrolledString = { row, count in
            return presentationData.strings.VoiceOver_ScrollStatus(row, count).string
        }

        super.init()

        self.setViewBlock({
            ASScrollView(frame: .zero) 
        })
        
        self.backgroundColor = presentationData.theme.list.plainBackgroundColor
        self.addSubnode(self.listNode)
        self.listNode.delegate = self
        self.listNode.scrollView.delegate = self 
    }
    
    func updatePresentationData(_ presentationData: PresentationData) {
        self.presentationData = presentationData
        self.backgroundColor = presentationData.theme.list.plainBackgroundColor
        self.listNode.verticalScrollIndicatorColor = presentationData.theme.list.scrollIndicatorColor
        self.updateSettingsItems(self.items, animated: false)
    }

    func updateSettingsItems(_ newItems: [SGESettingsItem], animated: Bool = true) {
        self.items = newItems
        
        var entries: [ListViewEntry] = []
        var idCounter: Int = 0

        for item in newItems {
            switch item {
            case let .header(title):
                entries.append(ItemListSectionHeaderEntry(presentationData: self.presentationData, text: title, sectionId: idCounter))
            case let .button(title, action):
                entries.append(ItemListActionEntry(presentationData: self.presentationData, title: title, kind: .generic, icon: nil, action: action, sectionId: idCounter, confirmationAction: nil))
            case let .toggle(title, isOn, action):
                entries.append(ItemListSwitchEntry(presentationData: self.presentationData, title: title, text: "", enabled: true, value: isOn, sectionId: idCounter, style: .blocks, updated: action))
            case let .notice(text):
                entries.append(ItemListTextCommentEntry(presentationData: self.presentationData, text: .plain(text), sectionId: idCounter))
            case .spacer:
                // Add a plain entry or a specific spacer entry if ItemListUI provides one
                // For now, a small text comment can act as a spacer or adjust section IDs
                entries.append(ItemListTextCommentEntry(presentationData: self.presentationData, text: .plain(" "), sectionId: idCounter)) // Minimal height
            }
            idCounter += 1
        }
        
        let transaction = ListViewUpdateTransition. zarówno(.animated(duration: 0.3, curve: .spring), .animated(duration: 0.3, curve: .spring)) 
        self.listNode.transaction(
            deleteIndices: [],
            insertIndicesAndItems: entries.enumerated().map { ($0.offset, $0.element, transaction.preferredInsertionPosition) },
            updateIndicesAndItems: [],
            options: [.Synchronous],
            animated: animated,
            stationaryMovableItems: Set<Int>(),
            updateOpaqueState: nil,
            completion: { _ in }
        )
    }


    override func layout() {
        super.layout()
        let bounds = self.bounds
        let topInset = self.safeAreaInsets.top + (self.controller?.navigationHeight ?? 0)
        let bottomInset = self.safeAreaInsets.bottom
        
        self.listNode.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
        self.listNode.transaction(deleteIndices: [], insertIndicesAndItems: [], updateIndicesAndItems: [], options: [.Synchronous, .LowLatency], scrollToItem: nil, updateOpaqueState: nil, completion: { _ in })
    }
    
    // MARK: - ASScrollViewDelegate (if listNode.delegate = self)
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    }
}
