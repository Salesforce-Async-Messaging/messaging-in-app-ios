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
            case .callKitEnabled: return true
            }
        }

        var resettable: Bool {
            switch self {
            case .enableVoiceNavBarButton: return true
            case .callKitEnabled: return true
            }
        }

        static func handleReset() {}

        case enableVoiceNavBarButton
        case callKitEnabled
    }

    @StateObject var store: VoiceStore = VoiceStore()

    var body: some View {
        SettingsSection(Self.header, developerOnly: true) {
            SettingsToggle("Voice Nav Bar Button", developerOnly: true, isOn: $store.enableVoiceNavBarButton)
            SettingsToggle("CallKit", isOn: $store.callKitEnabled)
        }
    }
}

extension VoiceStore {
    var enableVoiceNavBarButton: Bool {
        get { userDefaults.bool(forKey: Keys.enableVoiceNavBarButton.rawValue) }
        set { userDefaults.set(newValue, forKey: Keys.enableVoiceNavBarButton.rawValue) }
    }

    var callKitEnabled: Bool {
        get { userDefaults.bool(forKey: Keys.callKitEnabled.rawValue) }
        set { userDefaults.set(newValue, forKey: Keys.callKitEnabled.rawValue) }
    }
}

#Preview {
    Form {
        VoiceSettings()
    }
}
