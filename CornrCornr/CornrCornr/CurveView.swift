import AppKit

final class CurveView: NSView {
    var corner: Corner = .bottomRight {
        didSet { needsDisplay = true }
    }

    var curveOpacity: CGFloat = 0.7 {
        didSet { needsDisplay = true }
    }

    var curveSize: CGFloat = 18 {
        didSet { needsDisplay = true }
    }

    var strokeWidth: CGFloat = 4.0 {
        didSet { needsDisplay = true }
    }

    var arcSweep: CGFloat = 90 {
        didSet { needsDisplay = true }
    }

    var cornerOffset: CGFloat = 0 {
        didSet { needsDisplay = true }
    }

    var showDebugZone: Bool = false {
        didSet { needsDisplay = true }
    }

    var insetDistance: CGFloat = 5 {
        didSet { needsDisplay = true }
    }

    var outsetDistance: CGFloat = 14 {
        didSet { needsDisplay = true }
    }

    override var isFlipped: Bool { false }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // The window corner point is at the center of our bounds
        let center = CGPoint(x: bounds.midX, y: bounds.midY)

        // Draw debug activation zone rectangle
        if showDebugZone {
            // The zone goes from -outset to +inset relative to the corner,
            // but direction depends on which corner. In our coordinate system
            // the corner is at center, so draw the zone rect accordingly.
            let zoneSize = insetDistance + outsetDistance
            let zoneRect: NSRect
            switch corner {
            case .topLeft:
                // In AppKit coords (y-up): outside is left+up, inside is right+down
                zoneRect = NSRect(x: center.x - outsetDistance, y: center.y - insetDistance, width: zoneSize, height: zoneSize)
            case .topRight:
                zoneRect = NSRect(x: center.x - insetDistance, y: center.y - insetDistance, width: zoneSize, height: zoneSize)
            case .bottomLeft:
                zoneRect = NSRect(x: center.x - outsetDistance, y: center.y - outsetDistance, width: zoneSize, height: zoneSize)
            case .bottomRight:
                zoneRect = NSRect(x: center.x - insetDistance, y: center.y - outsetDistance, width: zoneSize, height: zoneSize)
            }

            NSColor.red.withAlphaComponent(0.15).setFill()
            NSBezierPath.fill(zoneRect)
            NSColor.red.withAlphaComponent(0.4).setStroke()
            let border = NSBezierPath(rect: zoneRect.insetBy(dx: 0.5, dy: 0.5))
            border.lineWidth = 1
            border.stroke()
        }

        // Offset the arc center away from the window corner
        let offsetCenter: CGPoint
        switch corner {
        case .topLeft:
            offsetCenter = CGPoint(x: center.x - cornerOffset, y: center.y + cornerOffset)
        case .topRight:
            offsetCenter = CGPoint(x: center.x + cornerOffset, y: center.y + cornerOffset)
        case .bottomLeft:
            offsetCenter = CGPoint(x: center.x - cornerOffset, y: center.y - cornerOffset)
        case .bottomRight:
            offsetCenter = CGPoint(x: center.x + cornerOffset, y: center.y - cornerOffset)
        }

        let lineWidth = strokeWidth
        let radius = curveSize - lineWidth

        let path = NSBezierPath()

        let halfSweep = arcSweep / 2
        let midAngle: CGFloat
        switch corner {
        case .topLeft:     midAngle = 135
        case .topRight:    midAngle = 45
        case .bottomLeft:  midAngle = 225
        case .bottomRight: midAngle = 315
        }

        path.appendArc(withCenter: offsetCenter, radius: radius, startAngle: midAngle - halfSweep, endAngle: midAngle + halfSweep)
        path.lineWidth = lineWidth
        path.lineCapStyle = .round

        let shadow = NSShadow()
        shadow.shadowColor = NSColor.black.withAlphaComponent(0.3)
        shadow.shadowBlurRadius = 2
        shadow.shadowOffset = NSSize(width: 0, height: -1)

        NSGraphicsContext.saveGraphicsState()
        shadow.set()
        NSColor.white.withAlphaComponent(curveOpacity).setStroke()
        path.stroke()
        NSGraphicsContext.restoreGraphicsState()
    }
}
