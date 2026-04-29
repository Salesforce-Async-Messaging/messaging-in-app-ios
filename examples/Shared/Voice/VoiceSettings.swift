//
//  VoiceSettings.swift
//

import SwiftUI

typealias VoiceStore = SettingsStore<VoiceSettings.SettingsKeys>

struct VoiceSettings: View {
    static let header = "Voice Settings"

    enum SettingsKeys: String, Settings {
        public var id: String { rawValue }

        var defaultValue: Any {
            switch self {
            case .enableVoiceNavBarButton: return true
            }
        }

        var resettable: Bool {
            switch self {
            case .enableVoiceNavBarButton: return true
            }
        }

        static func handleReset() {}

        case enableVoiceNavBarButton
    }

    @StateObject var store: VoiceStore = VoiceStore()

    var body: some View {
        SettingsSection(Self.header, developerOnly: true) {
            SettingsToggle("Voice Nav Bar Button", developerOnly: true, isOn: $store.enableVoiceNavBarButton)
        }
    }
}

extension VoiceStore {
    var enableVoiceNavBarButton: Bool {
        get { userDefaults.bool(forKey: Keys.enableVoiceNavBarButton.rawValue) }
        set { userDefaults.set(newValue, forKey: Keys.enableVoiceNavBarButton.rawValue) }
    }
}

#Preview {
    Form {
        VoiceSettings()
    }
}
