//
//  LoggingSettings.swift
//

import SwiftUI
import SMIClientCore
import SMIClientUI

typealias LoggingStore = SettingsStore<LoggingSettings.SettingsKeys>

struct LoggingSettings: View {
    static let header: String = "Demo Settings"

    enum SettingsKeys: String, Settings {
        public var id: String { rawValue }

        var defaultValue: Any {
            switch self {
            case .coreLoggingEnabled: return true
            case .uiLoggingEnabled: return true
            }
        }

        var resettable: Bool { true }

        static func handleReset() {
            SMIClientCore.Logging.level = .debug

            // JWRIGHT Update after production release
//            SMIClientUI.Logging.level = .debug
        }

        case coreLoggingEnabled
        case uiLoggingEnabled
    }

    @StateObject var loggingStore: LoggingStore = LoggingStore()

    var body: some View {
        SettingsSection(Self.header, developerOnly: true) {
            SettingsToggle("Core Logging Enabled", isOn: $loggingStore.coreLoggingEnabled)
            SettingsToggle("UI Logging Enabled", isOn: $loggingStore.uiLoggingEnabled)
        }
    }
}

extension LoggingStore {
    var coreLoggingEnabled: Bool {
        get { userDefaults.bool(forKey: Keys.coreLoggingEnabled.rawValue) }
        set {
            userDefaults.set(newValue, forKey: Keys.coreLoggingEnabled.rawValue)
            updateLoggingSettings()
        }
    }

    var uiLoggingEnabled: Bool {
        get { userDefaults.bool(forKey: Keys.uiLoggingEnabled.rawValue) }
        set {
            userDefaults.set(newValue, forKey: Keys.uiLoggingEnabled.rawValue)
            updateLoggingSettings()
        }
    }

    func updateLoggingSettings() {
        SMIClientCore.Logging.level = coreLoggingEnabled ? .debug : .none

        // JWRIGHT Update after production release
//        SMIClientUI.Logging.level = uiLoggingEnabled ? .debug : .none
    }
}

extension SMIClientCore.LoggingLevel: @retroactive CaseIterable, @retroactive Identifiable {
    public static var allCases: [LoggingLevel] = [.debug, .none]
    public var id: UInt { rawValue }
}

#Preview {
    Form {
        LoggingSettings()

        DeveloperStettings()
    }
}
