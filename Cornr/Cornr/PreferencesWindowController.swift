import AppKit

final class PreferencesWindowController: NSWindowController {
    init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 380, height: 600),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Cornr Cornr Settings"
        window.center()
        window.isReleasedWhenClosed = false
        window.minSize = NSSize(width: 340, height: 450)

        super.init(window: window)

        let contentView = NSView(frame: window.contentView!.bounds)
        contentView.autoresizingMask = [.width, .height]
        window.contentView = contentView

        setupUI(in: contentView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI(in container: NSView) {
        let settings = Settings.shared
        var yOffset: CGFloat = 560

        // Enable toggle
        let enableCheck = NSButton(checkboxWithTitle: "Enabled", target: nil, action: nil)
        enableCheck.state = settings.enabled ? .on : .off
        enableCheck.frame = NSRect(x: 20, y: yOffset, width: 200, height: 20)
        enableCheck.target = self
        enableCheck.action = #selector(enableToggled(_:))
        container.addSubview(enableCheck)
        yOffset -= 40

        // Inset Distance
        yOffset = addSliderRow(
            to: container,
            label: "Inset (into window):",
            value: settings.insetDistance,
            min: 0, max: 25,
            y: yOffset,
            action: #selector(insetDistanceChanged(_:)),
            tag: 1,
            format: "%.0f"
        )

        // Outset Distance
        yOffset = addSliderRow(
            to: container,
            label: "Outset (outside window):",
            value: settings.outsetDistance,
            min: 0, max: 20,
            y: yOffset,
            action: #selector(outsetDistanceChanged(_:)),
            tag: 2,
            format: "%.0f"
        )

        // Curve Opacity
        yOffset = addSliderRow(
            to: container,
            label: "Curve Opacity:",
            value: settings.curveOpacity,
            min: 0.3, max: 1.0,
            y: yOffset,
            action: #selector(curveOpacityChanged(_:)),
            tag: 3,
            format: "%.2f"
        )

        // Curve Size (radius)
        yOffset = addSliderRow(
            to: container,
            label: "Curve Size:",
            value: settings.curveSize,
            min: 10, max: 40,
            y: yOffset,
            action: #selector(curveSizeChanged(_:)),
            tag: 4,
            format: "%.0f"
        )

        // Stroke Width
        yOffset = addSliderRow(
            to: container,
            label: "Stroke Width:",
            value: settings.curveStrokeWidth,
            min: 1.0, max: 12.0,
            y: yOffset,
            action: #selector(strokeWidthChanged(_:)),
            tag: 5,
            format: "%.1f"
        )

        // Arc Length (sweep angle)
        yOffset = addSliderRow(
            to: container,
            label: "Arc Length:",
            value: settings.arcSweep,
            min: 30, max: 180,
            y: yOffset,
            action: #selector(arcSweepChanged(_:)),
            tag: 6,
            format: "%.0f°"
        )

        // Corner Offset
        yOffset = addSliderRow(
            to: container,
            label: "Corner Offset:",
            value: settings.cornerOffset,
            min: -20, max: 10,
            y: yOffset,
            action: #selector(cornerOffsetChanged(_:)),
            tag: 7,
            format: "%.1f"
        )

        // Frontmost window only
        let frontmostCheck = NSButton(checkboxWithTitle: "Active window only", target: nil, action: nil)
        frontmostCheck.state = settings.frontmostOnly ? .on : .off
        frontmostCheck.frame = NSRect(x: 20, y: yOffset, width: 250, height: 20)
        frontmostCheck.target = self
        frontmostCheck.action = #selector(frontmostToggled(_:))
        container.addSubview(frontmostCheck)
        yOffset -= 30

        // Debug zones toggle
        let debugCheck = NSButton(checkboxWithTitle: "Show Debug Activation Zones", target: nil, action: nil)
        debugCheck.state = settings.showDebugZones ? .on : .off
        debugCheck.frame = NSRect(x: 20, y: yOffset, width: 250, height: 20)
        debugCheck.target = self
        debugCheck.action = #selector(debugToggled(_:))
        container.addSubview(debugCheck)
        yOffset -= 30

        // Launch at Login
        let loginCheck = NSButton(checkboxWithTitle: "Launch at Login", target: nil, action: nil)
        loginCheck.state = settings.launchAtLogin ? .on : .off
        loginCheck.frame = NSRect(x: 20, y: yOffset, width: 200, height: 20)
        loginCheck.target = self
        loginCheck.action = #selector(launchAtLoginToggled(_:))
        container.addSubview(loginCheck)
        yOffset -= 40

        // Reset to Defaults button
        let resetButton = NSButton(title: "Reset to Defaults", target: self, action: #selector(resetToDefaults))
        resetButton.bezelStyle = .rounded
        resetButton.frame = NSRect(x: 20, y: yOffset, width: 150, height: 24)
        container.addSubview(resetButton)
    }

    private func addSliderRow(to container: NSView, label: String, value: CGFloat, min: Double, max: Double, y: CGFloat, action: Selector, tag: Int, format: String) -> CGFloat {
        let labelView = NSTextField(labelWithString: label)
        labelView.frame = NSRect(x: 20, y: y, width: 180, height: 17)
        container.addSubview(labelView)

        let slider = NSSlider(value: Double(value), minValue: min, maxValue: max, target: self, action: action)
        slider.frame = NSRect(x: 20, y: y - 25, width: 260, height: 21)
        slider.tag = tag
        slider.isContinuous = true
        container.addSubview(slider)

        let valueLabel = NSTextField(labelWithString: String(format: format, value))
        valueLabel.frame = NSRect(x: 290, y: y - 25, width: 60, height: 17)
        valueLabel.tag = tag + 100
        container.addSubview(valueLabel)

        return y - 55
    }

    private func valueLabel(tag: Int) -> NSTextField? {
        window?.contentView?.viewWithTag(tag + 100) as? NSTextField
    }

    @objc private func enableToggled(_ sender: NSButton) {
        Settings.shared.enabled = sender.state == .on
    }

    @objc private func insetDistanceChanged(_ sender: NSSlider) {
        Settings.shared.insetDistance = CGFloat(sender.doubleValue)
        valueLabel(tag: 1)?.stringValue = String(format: "%.0f", sender.doubleValue)
    }

    @objc private func outsetDistanceChanged(_ sender: NSSlider) {
        Settings.shared.outsetDistance = CGFloat(sender.doubleValue)
        valueLabel(tag: 2)?.stringValue = String(format: "%.0f", sender.doubleValue)
    }

    @objc private func curveOpacityChanged(_ sender: NSSlider) {
        Settings.shared.curveOpacity = CGFloat(sender.doubleValue)
        valueLabel(tag: 3)?.stringValue = String(format: "%.2f", sender.doubleValue)
    }

    @objc private func curveSizeChanged(_ sender: NSSlider) {
        Settings.shared.curveSize = CGFloat(sender.doubleValue)
        valueLabel(tag: 4)?.stringValue = String(format: "%.0f", sender.doubleValue)
    }

    @objc private func strokeWidthChanged(_ sender: NSSlider) {
        Settings.shared.curveStrokeWidth = CGFloat(sender.doubleValue)
        valueLabel(tag: 5)?.stringValue = String(format: "%.1f", sender.doubleValue)
    }

    @objc private func arcSweepChanged(_ sender: NSSlider) {
        Settings.shared.arcSweep = CGFloat(sender.doubleValue)
        valueLabel(tag: 6)?.stringValue = String(format: "%.0f°", sender.doubleValue)
    }

    @objc private func cornerOffsetChanged(_ sender: NSSlider) {
        Settings.shared.cornerOffset = CGFloat(sender.doubleValue)
        valueLabel(tag: 7)?.stringValue = String(format: "%.1f", sender.doubleValue)
    }

    @objc private func frontmostToggled(_ sender: NSButton) {
        Settings.shared.frontmostOnly = sender.state == .on
    }

    @objc private func debugToggled(_ sender: NSButton) {
        Settings.shared.showDebugZones = sender.state == .on
    }

    @objc private func launchAtLoginToggled(_ sender: NSButton) {
        Settings.shared.launchAtLogin = sender.state == .on
    }

    @objc private func resetToDefaults() {
        Settings.shared.resetToDefaults()
        // Rebuild the UI with fresh values
        guard let contentView = window?.contentView else { return }
        contentView.subviews.forEach { $0.removeFromSuperview() }
        setupUI(in: contentView)
    }
}
