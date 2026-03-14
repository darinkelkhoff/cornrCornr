import AppKit

final class StatusBarController {
    private var statusItem: NSStatusItem!
    private let menu = NSMenu()

    var onSettingsClicked: (() -> Void)?
    var onQuitClicked: (() -> Void)?
    var onToggleEnabled: ((Bool) -> Void)?

    private var enabledMenuItem: NSMenuItem!

    func setup() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem.button {
            if let img = NSImage(systemSymbolName: "square.resize", accessibilityDescription: "Cornr Cornr") {
                img.isTemplate = true
                button.image = img
            } else {
                button.title = "◢"
            }
        }

        enabledMenuItem = NSMenuItem(title: "Enabled", action: #selector(toggleEnabled), keyEquivalent: "")
        enabledMenuItem.target = self
        enabledMenuItem.state = Settings.shared.enabled ? .on : .off

        menu.addItem(enabledMenuItem)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Settings…", action: #selector(openSettings), keyEquivalent: ","))
        menu.items.last?.target = self
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit Cornr Cornr", action: #selector(quit), keyEquivalent: "q"))
        menu.items.last?.target = self

        statusItem.menu = menu
    }

    @objc private func toggleEnabled() {
        let newValue = !Settings.shared.enabled
        Settings.shared.enabled = newValue
        enabledMenuItem.state = newValue ? .on : .off
        onToggleEnabled?(newValue)
    }

    @objc private func openSettings() {
        onSettingsClicked?()
    }

    @objc private func quit() {
        onQuitClicked?()
    }
}
