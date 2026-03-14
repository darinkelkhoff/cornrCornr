import AppKit

final class OverlayWindow: NSWindow {
    let curveView = CurveView()
    private var wantsVisible = false

    init() {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 40, height: 40),
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )

        backgroundColor = .clear
        isOpaque = false
        hasShadow = false
        ignoresMouseEvents = true
        level = .floating
        collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary]
        animationBehavior = .none

        let contentView = NSView(frame: .zero)
        contentView.wantsLayer = true
        self.contentView = contentView

        curveView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(curveView)
        NSLayoutConstraint.activate([
            curveView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            curveView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            curveView.topAnchor.constraint(equalTo: contentView.topAnchor),
            curveView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])

        alphaValue = 0
    }

    override func constrainFrameRect(_ frameRect: NSRect, to screen: NSScreen?) -> NSRect {
        return frameRect
    }

    func showAtCorner(_ corner: Corner, position: CGPoint, size: CGFloat, opacity: CGFloat, strokeWidth: CGFloat, arcSweep: CGFloat, cornerOffset: CGFloat, debugZone: Bool, inset: CGFloat, outset: CGFloat) {
        wantsVisible = true

        let zoneSize = inset + outset
        let curveWindowSize = (size + cornerOffset) * 2 + strokeWidth + 4
        let windowSize = max(curveWindowSize, zoneSize)

        curveView.corner = corner
        curveView.curveOpacity = opacity
        curveView.curveSize = size
        curveView.strokeWidth = strokeWidth
        curveView.arcSweep = arcSweep
        curveView.cornerOffset = cornerOffset
        curveView.showDebugZone = debugZone
        curveView.insetDistance = inset
        curveView.outsetDistance = outset

        let half = windowSize / 2
        let frame = NSRect(
            x: position.x - half,
            y: position.y - half,
            width: windowSize,
            height: windowSize
        )

        setFrame(frame, display: true)

        // Cancel any in-flight fade-out and snap to visible
        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = wantsVisible && alphaValue > 0.5 ? 0 : 0.15
            self.animator().alphaValue = 1
        }

        orderFrontRegardless()
    }

    func fadeOut() {
        wantsVisible = false

        NSAnimationContext.runAnimationGroup({ ctx in
            ctx.duration = 0.15
            self.animator().alphaValue = 0
        }, completionHandler: { [weak self] in
            guard let self = self else { return }
            // Only orderOut if we still want to be hidden
            if !self.wantsVisible {
                self.orderOut(nil)
            }
        })
    }
}
