//
//  NotificationManagementSettings.swift
//  SMITestApp
//
//  Created by Jeremy Wright on 2024-09-12.
//

import SwiftUI
import SMIClientCore

typealias NotificationManagementStore = SettingsStore<NotificationManagementSettings.SettingsKeys>

struct NotificationManagementSettings: View {
    static let header: String = "Notification Settings"

    enum SettingsKeys: String, Settings {
        public var id: String { rawValue }

        var defaultValue: Any {
            switch self {
            case .enableNotifications: return true
            case .deviceToken: return ""
            case .foregroundNotifications: return false
            }
        }

        var resettable: Bool {
            switch self {
            case .foregroundNotifications: return true
            default: return false
            }
        }

        static func handleReset() {}

        case enableNotifications
        case deviceToken
        case foregroundNotifications
    }

    @StateObject var notificationManagementStore: NotificationManagementStore = NotificationManagementStore()
    @StateObject var configurationStore: MIAWConfigurationStore = MIAWConfigurationStore()

    var body: some View {
        SettingsSection(Self.header, developerOnly: true) {
            SettingsTextField("Device Token", placeholder: "No Device Token", value: $notificationManagementStore.deviceToken, enabled: false, lineLimit: 5)
            SettingsToggle("Enable Notifications", isOn: $notificationManagementStore.enableNotifications)
                .onChange(of: notificationManagementStore.enableNotifications) { _, newValue in
                    if newValue == true {
                        provideDeviceToken()
                    }
                }

            SettingsToggle("Enable Foreground Notifications", isOn: $notificationManagementStore.foregroundNotifications)

            SettingsButton {
                revokeToken()
            } label: {
                Text("Revoke Token")
            }

            SettingsButton {
                deregister()
            } label: {
                Text("Deregister Device")
            }

            SettingsButton {
                provideDeviceToken()
            } label: {
                Text("Provide Device Token")
            }

            SettingsButton {
                register()
            } label: {
                Text("Register Device")
            }

        }
    }

    func revokeToken() {
        CoreFactory.create(withConfig: configurationStore.config).revokeToken { _ in }
    }

    func deregister() {
        CoreFactory.create(withConfig: configurationStore.config).deregisterDevice { _ in }
    }

    func provideDeviceToken() {
        if notificationManagementStore.enableNotifications {
            CoreFactory.provide(deviceToken: notificationManagementStore.deviceToken)
        }
    }

    func register() {
        CoreFactory.create(withConfig: configurationStore.config).register(deviceToken: notificationManagementStore.deviceToken) { _ in }
    }
}

extension NotificationManagementStore {
    var deviceToken: String {
        get { userDefaults.string(forKey: Keys.deviceToken.rawValue) ?? "" }
        set { userDefaults.set(newValue, forKey: Keys.deviceToken.rawValue) }
    }

    var foregroundNotifications: Bool {
        get { userDefaults.bool(forKey: Keys.foregroundNotifications.rawValue) }
        set { userDefaults.set(newValue, forKey: Keys.foregroundNotifications.rawValue) }
    }

    var enableNotifications: Bool {
        get { userDefaults.bool(forKey: Keys.enableNotifications.rawValue) }
        set { userDefaults.set(newValue, forKey: Keys.enableNotifications.rawValue) }
    }
}

#Preview {
    Form {
        NotificationManagementSettings()

        DeveloperStettings()
    }
}
