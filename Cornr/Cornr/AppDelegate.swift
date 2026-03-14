import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    private let statusBarController = StatusBarController()
    private var cursorMonitor: CursorMonitor!
    private var preferencesWindowController: PreferencesWindowController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Prompt for accessibility permission
        let options = [kAXTrustedCheckOptionPrompt.takeRetainedValue(): true] as CFDictionary
        AXIsProcessTrustedWithOptions(options)

        // Set up window corner resolver and cursor monitor
        var monitorRef: CursorMonitor?
        let resolver = WindowCornerResolver {
            monitorRef?.overlayWindowNumbers ?? []
        }
        cursorMonitor = CursorMonitor(resolver: resolver)
        monitorRef = cursorMonitor

        if Settings.shared.enabled {
            cursorMonitor.start()
        }

        // Set up status bar
        statusBarController.setup()
        statusBarController.onSettingsClicked = { [weak self] in
            self?.showSettings()
        }
        statusBarController.onQuitClicked = {
            NSApplication.shared.terminate(nil)
        }
        statusBarController.onToggleEnabled = { [weak self] enabled in
            if enabled {
                self?.cursorMonitor.start()
            } else {
                self?.cursorMonitor.stop()
            }
        }
    }

    private func showSettings() {
        if preferencesWindowController == nil {
            preferencesWindowController = PreferencesWindowController()
        }
        preferencesWindowController?.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
