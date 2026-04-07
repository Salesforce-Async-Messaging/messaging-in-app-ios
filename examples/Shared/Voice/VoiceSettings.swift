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
            case .enableVoiceFAB: return false
            }
        }

        var resettable: Bool {
            switch self {
            case .enableVoiceFAB: return true
            }
        }

        static func handleReset() {}

        case enableVoiceFAB
    }

    @StateObject var store: VoiceStore = VoiceStore()

    var body: some View {
        SettingsSection(Self.header, developerOnly: true) {
            SettingsToggle("Voice FAB", developerOnly: true, isOn: $store.enableVoiceFAB)
        }
    }
}

extension VoiceStore {
    var enableVoiceFAB: Bool {
        get { userDefaults.bool(forKey: Keys.enableVoiceFAB.rawValue) }
        set { userDefaults.set(newValue, forKey: Keys.enableVoiceFAB.rawValue) }
    }
}

#Preview {
    Form {
        VoiceSettings()
    }
}
