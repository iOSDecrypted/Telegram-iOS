import UIKit
import Display 
import SwiftSignalKit 
import TelegramPresentationData 
import PresentationDataConfiguration 
import AccountContext 

public final class SGESettingsControllerParams {
    let accountContext: AccountContext 

    public init(accountContext: AccountContext) {
        self.accountContext = accountContext
    }
}

public class SGESettingsViewController: ViewController { // 'TableViewController' for a grouped table
    private var controllerNode: SGESettingsControllerNode {
        return self.displayNode as! SGESettingsControllerNode
    }

    private let params: SGESettingsControllerParams
    private var presentationData: PresentationData
    private var presentationDataDisposable: Disposable?

    static let showDeletedMessagesKey = "sge_showDeletedMessages_settings"
    static let notificationFixKey = "sge_notificationFix_settings" // Placeholder
    static let hideReadReceiptsKey = "sge_hideReadReceipts_settings" // Placeholder
    
    let sgeNewsChannelURL = "https://t.me/SGEnhance"
    let sgeIPAsChannelURL = "https://t.me/sgbeta_ipa"

    public init(params: SGESettingsControllerParams) {
        self.params = params
        self.presentationData = params.accountContext.sharedContext.currentPresentationData.with { $0 }
        
        super.init(navigationBarPresentationData: NavigationBarPresentationData(presentationData: self.presentationData))

        self.title = self.presentationData.strings.SGE_Settings_Title // TODO: add localization

        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: self.presentationData.strings.Common_Back, style: .plain, target: nil, action: nil)
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        self.presentationDataDisposable?.dispose()
    }

    override public func loadDisplayNode() {
        self.displayNode = SGESettingsControllerNode(controller: self, presentationData: self.presentationData)
        
        self.controllerNode.updateSettingsItems(self.settingsItems())

        self.presentationDataDisposable = (self.params.accountContext.sharedContext.presentationData
        |> deliverOnMainQueue).start(next: { [weak self] presentationData in
            guard let self = self else { return }
            let previousTheme = self.presentationData.theme
            let previousStrings = self.presentationData.strings
            
            self.presentationData = presentationData
            
            if previousTheme !== presentationData.theme || previousStrings !== presentationData.strings {
                self.updateThemeAndStrings()
                self.controllerNode.updateSettingsItems(self.settingsItems()) // Rebuild items if strings change
            }
        })
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Potentially reload items if values could have changed elsewhere, though UserDefaults should be source of truth for toggles
        self.controllerNode.updateSettingsItems(self.settingsItems())
    }
    
    private func updateThemeAndStrings() {
        self.statusBar.statusBarStyle = self.presentationData.theme.rootController.statusBarStyle.style
        self.navigationBar?.updatePresentationData(NavigationBarPresentationData(presentationData: self.presentationData))
        self.title = self.presentationData.strings.SGE_Settings_Title // Update title with new strings
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: self.presentationData.strings.Common_Back, style: .plain, target: nil, action: nil)
        // Update node with new presentationData if it holds it directly for item construction
        self.controllerNode.updatePresentationData(self.presentationData)
    }

    // Function to generate the list of settings items
    private func settingsItems() -> [SGESettingsItem] {
        var items: [SGESettingsItem] = []

        // Section: Links
        items.append(.header(title: self.presentationData.strings.SGE_Settings_SectionLinks))
        items.append(.button(title: self.presentationData.strings.SGE_Settings_NewsChannel, action: { [weak self] in
            self?.openURL(self?.sgeNewsChannelURL)
        }))
        items.append(.button(title: self.presentationData.strings.SGE_Settings_IPAsChannel, action: { [weak self] in
            self?.openURL(self?.sgeIPAsChannelURL)
        }))
        items.append(.spacer)

        // Section: Features
        items.append(.header(title: self.presentationData.strings.SGE_Settings_SectionFeatures))
        items.append(.toggle(title: self.presentationData.strings.SGE_Settings_ShowDeletedMessages,
                             isOn: UserDefaults.standard.bool(forKey: SGESettingsViewController.showDeletedMessagesKey),
                             action: { isOn in
                                UserDefaults.standard.set(isOn, forKey: SGESettingsViewController.showDeletedMessagesKey)
                             }))
        items.append(.toggle(title: self.presentationData.strings.SGE_Settings_NotificationFix,
                             isOn: UserDefaults.standard.bool(forKey: SGESettingsViewController.notificationFixKey),
                             action: { isOn in
                                UserDefaults.standard.set(isOn, forKey: SGESettingsViewController.notificationFixKey)
                                // TODO: Call function to enable/disable Notification Fix
                             }))
        items.append(.toggle(title: self.presentationData.strings.SGE_Settings_HideReadReceipts,
                             isOn: UserDefaults.standard.bool(forKey: SGESettingsViewController.hideReadReceiptsKey),
                             action: { isOn in
                                UserDefaults.standard.set(isOn, forKey: SGESettingsViewController.hideReadReceiptsKey)
                                // TODO: Call function to enable/disable Hide Read Receipts
                             }))
        items.append(.spacer)
        

        items.append(.notice(text: self.presentationData.strings.SGE_Settings_FooterText))


        return items
    }
    
    private func openURL(_ urlString: String?) {
        guard let urlString = urlString, let url = URL(string: urlString) else { return }
        self.params.accountContext.sharedContext.openUrl(
            url: url,
            concealed: false,
            forceExternal: true,
            presentationData: self.presentationData
        )
    }
}
