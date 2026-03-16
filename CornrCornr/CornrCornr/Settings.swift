import Foundation
import ServiceManagement

final class Settings {
    static let shared = Settings()

    private let defaults = UserDefaults.standard

    private enum Keys {
        static let insetDistance = "insetDistance"
        static let outsetDistance = "outsetDistance"
        static let curveOpacity = "curveOpacity"
        static let curveSize = "curveSize"
        static let curveStrokeWidth = "curveStrokeWidth"
        static let arcSweep = "arcSweep"
        static let cornerOffset = "cornerOffset"
        static let enabled = "enabled"
        static let launchAtLogin = "launchAtLogin"
        static let showDebugZones = "showDebugZones"
        static let frontmostOnly = "frontmostOnly"

        static let all = [
            insetDistance, outsetDistance, curveOpacity, curveSize,
            curveStrokeWidth, arcSweep, cornerOffset, enabled,
            launchAtLogin, showDebugZones, frontmostOnly,
        ]
    }

    private init() {
        defaults.register(defaults: [
            Keys.insetDistance: 12.0,
            Keys.outsetDistance: 4.0,
            Keys.curveOpacity: 0.85,
            Keys.curveSize: 24.0,
            Keys.curveStrokeWidth: 6.0,
            Keys.arcSweep: 90.0,
            Keys.cornerOffset: -10.0,
            Keys.enabled: true,
            Keys.launchAtLogin: false,
            Keys.showDebugZones: false,
            Keys.frontmostOnly: false,
        ])
    }

    /// How far inside the window (from its corner) the activation zone extends
    var insetDistance: CGFloat {
        get { defaults.double(forKey: Keys.insetDistance) }
        set { defaults.set(newValue, forKey: Keys.insetDistance) }
    }

    /// How far outside the window corner the activation zone extends
    var outsetDistance: CGFloat {
        get { defaults.double(forKey: Keys.outsetDistance) }
        set { defaults.set(newValue, forKey: Keys.outsetDistance) }
    }

    var curveOpacity: CGFloat {
        get { defaults.double(forKey: Keys.curveOpacity) }
        set { defaults.set(newValue, forKey: Keys.curveOpacity) }
    }

    var curveSize: CGFloat {
        get { defaults.double(forKey: Keys.curveSize) }
        set { defaults.set(newValue, forKey: Keys.curveSize) }
    }

    var curveStrokeWidth: CGFloat {
        get { defaults.double(forKey: Keys.curveStrokeWidth) }
        set { defaults.set(newValue, forKey: Keys.curveStrokeWidth) }
    }

    var arcSweep: CGFloat {
        get { defaults.double(forKey: Keys.arcSweep) }
        set { defaults.set(newValue, forKey: Keys.arcSweep) }
    }

    var cornerOffset: CGFloat {
        get { defaults.double(forKey: Keys.cornerOffset) }
        set { defaults.set(newValue, forKey: Keys.cornerOffset) }
    }

    var enabled: Bool {
        get { defaults.bool(forKey: Keys.enabled) }
        set { defaults.set(newValue, forKey: Keys.enabled) }
    }

    var launchAtLogin: Bool {
        get { defaults.bool(forKey: Keys.launchAtLogin) }
        set {
            defaults.set(newValue, forKey: Keys.launchAtLogin)
            if #available(macOS 13.0, *) {
                do {
                    if newValue {
                        try SMAppService.mainApp.register()
                    } else {
                        try SMAppService.mainApp.unregister()
                    }
                } catch {
                    print("Failed to update launch at login: \(error)")
                }
            }
        }
    }

    var showDebugZones: Bool {
        get { defaults.bool(forKey: Keys.showDebugZones) }
        set { defaults.set(newValue, forKey: Keys.showDebugZones) }
    }

    var frontmostOnly: Bool {
        get { defaults.bool(forKey: Keys.frontmostOnly) }
        set { defaults.set(newValue, forKey: Keys.frontmostOnly) }
    }

    func resetToDefaults() {
        for key in Keys.all {
            defaults.removeObject(forKey: key)
        }
    }
}
