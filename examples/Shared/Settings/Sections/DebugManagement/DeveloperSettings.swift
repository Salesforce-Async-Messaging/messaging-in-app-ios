//
//  DeveloperSettings.swift
//  SMITestApp
//
//  Created by Aaron Eisses on 2024-09-16.
//

import SwiftUI

typealias DeveloperStore = SettingsStore<DeveloperStettings.SettingsKeys>

struct DeveloperStettings: View {
    static let header: String = "Developer Settings"

    enum SettingsKeys: String, Settings {
        public var id: String { rawValue }

        var defaultValue: Any {
            switch self {
            case .isDeveloperMode:
                #if DEBUG
                return true
                #else
                return false
                #endif
            }
        }

        var resettable: Bool {
            switch self {
            case .isDeveloperMode: false
            }
        }

        static func handleReset() {}

        case isDeveloperMode

    }

    @StateObject var developerManagementStore: DeveloperStore = DeveloperStore()

    var body: some View {
        Section(header: Text(Self.header)) {
            SettingsToggle("Developer Mode", isOn: $developerManagementStore.isDeveloperMode)
        }
    }
}

extension DeveloperStore {
    var isDeveloperMode: Bool {
        get { userDefaults.bool(forKey: Keys.isDeveloperMode.rawValue) }
        set { userDefaults.set(newValue, forKey: Keys.isDeveloperMode.rawValue) }
    }
}

#Preview {
    Form {
        DeveloperStettings()
    }
}
