import AppKit

final class CursorMonitor {
    private let resolver: WindowCornerResolver
    private let settings = Settings.shared

    private var overlayWindows: [Corner: OverlayWindow] = [:]
    private var activeCorners: Set<Corner> = []
    private var globalMonitor: Any?
    private var pollTimer: Timer?

    init(resolver: WindowCornerResolver) {
        self.resolver = resolver
        for corner in Corner.allCases {
            overlayWindows[corner] = OverlayWindow()
        }
    }

    var overlayWindowNumbers: Set<Int> {
        Set(overlayWindows.values.map { $0.windowNumber })
    }

    func start() {
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.mouseMoved, .leftMouseDragged, .rightMouseDragged]) { [weak self] _ in
            self?.update()
        }

        pollTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 30.0, repeats: true) { [weak self] _ in
            self?.update()
        }

        update()
    }

    func stop() {
        if let monitor = globalMonitor {
            NSEvent.removeMonitor(monitor)
            globalMonitor = nil
        }
        pollTimer?.invalidate()
        pollTimer = nil
        hideAll()
    }

    private func update() {
        guard settings.enabled else {
            hideAll()
            return
        }

        let mouseLocation = NSEvent.mouseLocation
        guard let mainScreen = NSScreen.screens.first else { return }
        let screenHeight = mainScreen.frame.height
        let cgMouseY = screenHeight - mouseLocation.y
        let cgMouse = CGPoint(x: mouseLocation.x, y: cgMouseY)

        let corners = resolver.allVisibleCorners(frontmostOnly: settings.frontmostOnly)
        let inset = settings.insetDistance
        let outset = settings.outsetDistance
        let curveSize = settings.curveSize
        let curveOpacity = settings.curveOpacity
        let strokeWidth = settings.curveStrokeWidth
        let arcSweep = settings.arcSweep
        let cornerOffset = settings.cornerOffset
        let debugZone = settings.showDebugZones

        var newActiveCorners = Set<Corner>()
        var cornerPositions: [Corner: CGPoint] = [:]

        for wc in corners {
            let dx = cgMouse.x - wc.point.x
            let dy = cgMouse.y - wc.point.y

            // For each corner, "inside the window" and "outside" are different directions.
            // dx/dy signs relative to the corner:
            //   topLeft:     inside = +dx, +dy    outside = -dx, -dy
            //   topRight:    inside = -dx, +dy    outside = +dx, -dy
            //   bottomLeft:  inside = +dx, -dy    outside = -dx, +dy
            //   bottomRight: inside = -dx, -dy    outside = +dx, +dy
            let inZone: Bool
            switch wc.corner {
            case .topLeft:
                inZone = dx >= -outset && dx <= inset && dy >= -outset && dy <= inset
            case .topRight:
                inZone = dx >= -inset && dx <= outset && dy >= -outset && dy <= inset
            case .bottomLeft:
                inZone = dx >= -outset && dx <= inset && dy >= -inset && dy <= outset
            case .bottomRight:
                inZone = dx >= -inset && dx <= outset && dy >= -inset && dy <= outset
            }

            if inZone {
                newActiveCorners.insert(wc.corner)
                let appKitY = screenHeight - wc.point.y
                cornerPositions[wc.corner] = CGPoint(x: wc.point.x, y: appKitY)
            }
        }

        for corner in newActiveCorners {
            if let pos = cornerPositions[corner], let overlay = overlayWindows[corner] {
                overlay.showAtCorner(corner, position: pos, size: curveSize, opacity: curveOpacity, strokeWidth: strokeWidth, arcSweep: arcSweep, cornerOffset: cornerOffset, debugZone: debugZone, inset: inset, outset: outset)
            }
        }

        for corner in activeCorners.subtracting(newActiveCorners) {
            overlayWindows[corner]?.fadeOut()
        }

        activeCorners = newActiveCorners
    }

    private func hideAll() {
        for overlay in overlayWindows.values {
            overlay.fadeOut()
        }
        activeCorners.removeAll()
    }
}
