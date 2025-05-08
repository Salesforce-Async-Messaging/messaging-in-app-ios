//
//  UIOverrideSettings.swift
//

import SwiftUI

typealias UIOverrideStore = SettingsStore<UIOverrideSettings.SettingsKeys>

struct UIOverrideSettings: View {
    static let header = "UI Override Settings"

    enum InterfaceStyle: String, CaseIterable, RawRepresentable, Identifiable, DeveloperToggle {
        public var id: String { rawValue }
        public var developerOnly: Bool { true }

        case system
        case dark
        case light
    }

    enum SettingsKeys: String, Settings {
        public var id: String { rawValue }

        static func handleReset() {
            let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
            window?.overrideUserInterfaceStyle = .unspecified
        }

        var defaultValue: Any {
            switch self {
            case .interfaceStyle: return InterfaceStyle.system.rawValue
            }
        }

        var resettable: Bool { true }

        case interfaceStyle
    }

    @StateObject var uiOverrideStore: UIOverrideStore = UIOverrideStore()

    var body: some View {
        SettingsSection(Self.header, developerOnly: true) {
            SettingsPicker("Choose Interface Style", value: $uiOverrideStore.interfaceStyle)
        }
    }
}

extension UIOverrideStore {
    var interfaceStyle: UIOverrideSettings.InterfaceStyle {
        get { userDefaults.string(forKey: Keys.interfaceStyle.rawValue).flatMap { UIOverrideSettings.InterfaceStyle(rawValue: $0) } ?? .system }
        set {
            userDefaults.set(newValue.rawValue, forKey: Keys.interfaceStyle.rawValue)
            updateUserInterfaceStyle()
        }
    }

    func updateUserInterfaceStyle() {
        let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
        switch interfaceStyle {
        case .system:
            window?.overrideUserInterfaceStyle = .unspecified
        case .light:
            window?.overrideUserInterfaceStyle = .light
        case .dark:
            window?.overrideUserInterfaceStyle = .dark
        }
    }
}

#Preview {
    Form {
        UIOverrideSettings()

        DeveloperStettings()
    }
}
