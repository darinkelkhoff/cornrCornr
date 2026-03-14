import AppKit

enum Corner: CaseIterable, Hashable {
    case topLeft, topRight, bottomLeft, bottomRight
}

struct WindowCorner {
    let corner: Corner
    let point: CGPoint
}

final class WindowCornerResolver {
    private let overlayWindowNumbers: () -> Set<Int>

    init(overlayWindowNumbers: @escaping () -> Set<Int>) {
        self.overlayWindowNumbers = overlayWindowNumbers
    }

    func allVisibleCorners(frontmostOnly: Bool) -> [WindowCorner] {
        guard let windowList = CGWindowListCopyWindowInfo(
            [.optionOnScreenOnly, .excludeDesktopElements],
            kCGNullWindowID
        ) as? [[String: Any]] else {
            return []
        }

        let excludedNumbers = overlayWindowNumbers()
        var corners: [WindowCorner] = []
        // Track rects of windows we've already processed (front-to-back order),
        // so we can check if a deeper window's corner is occluded
        var occludingRects: [CGRect] = []

        for info in windowList {
            guard let layer = info[kCGWindowLayer as String] as? Int,
                  layer == 0,
                  let boundsRef = info[kCGWindowBounds as String],
                  let rect = CGRect(dictionaryRepresentation: boundsRef as! CFDictionary),
                  rect.width > 50, rect.height > 50
            else { continue }

            // Skip our overlay windows (but not other Cornr windows like Settings)
            if let windowNumber = info[kCGWindowNumber as String] as? Int,
               excludedNumbers.contains(windowNumber) {
                continue
            }

            let cornerPoints: [(Corner, CGPoint)] = [
                (.topLeft, CGPoint(x: rect.minX, y: rect.minY)),
                (.topRight, CGPoint(x: rect.maxX, y: rect.minY)),
                (.bottomLeft, CGPoint(x: rect.minX, y: rect.maxY)),
                (.bottomRight, CGPoint(x: rect.maxX, y: rect.maxY)),
            ]

            for (corner, point) in cornerPoints {
                // Only add this corner if it's not hidden behind a window in front
                let occluded = occludingRects.contains { $0.contains(point) }
                if !occluded {
                    corners.append(WindowCorner(corner: corner, point: point))
                }
            }

            // This window's rect now occludes corners of windows behind it
            occludingRects.append(rect)

            if frontmostOnly {
                break
            }
        }

        return corners
    }
}
