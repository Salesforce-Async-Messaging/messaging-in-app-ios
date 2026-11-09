//
//  VoiceSettings.swift
//

import SwiftUI

typealias VoiceStore = SettingsStore<VoiceSettings.SettingsKeys>

struct VoiceSettings: View {
    static let header = "Voice Settings"

    enum VoiceProvider: String, CaseIterable, Identifiable, DeveloperToggle {
        public var id: String { rawValue }
        public var developerOnly: Bool { true }

        case liveKit = "LiveKit"
        case gateway = "Gateway"
        case thunderbird = "Thunderbird"
    }

    enum SettingsKeys: String, Settings {
        public var id: String { rawValue }

        var defaultValue: Any {
            switch self {
            case .enableVoiceNavBarButton: return true
            case .callKitEnabled: return true
            case .voiceProvider: return VoiceProvider.liveKit.rawValue
            }
        }

        var resettable: Bool {
            switch self {
            case .enableVoiceNavBarButton: return true
            case .callKitEnabled: return true
            case .voiceProvider: return true
            }
        }

        static func handleReset() {}

        case enableVoiceNavBarButton
        case callKitEnabled
        case voiceProvider
    }

    @StateObject var store: VoiceStore = VoiceStore()

    var body: some View {
        SettingsSection(Self.header, developerOnly: true) {
            SettingsToggle("Voice Nav Bar Button", developerOnly: true, isOn: $store.enableVoiceNavBarButton)
            SettingsToggle("CallKit Enabled", developerOnly: true, isOn: $store.callKitEnabled)
            SettingsPicker("Voice Provider", developerOnly: true, value: $store.voiceProvider)
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

    var voiceProvider: VoiceSettings.VoiceProvider {
        get {
            userDefaults.string(forKey: Keys.voiceProvider.rawValue)
                .flatMap { VoiceSettings.VoiceProvider(rawValue: $0) } ?? .liveKit
        }
        set { userDefaults.set(newValue.rawValue, forKey: Keys.voiceProvider.rawValue) }
    }
}

#Preview {
    Form {
        VoiceSettings()
    }
}
