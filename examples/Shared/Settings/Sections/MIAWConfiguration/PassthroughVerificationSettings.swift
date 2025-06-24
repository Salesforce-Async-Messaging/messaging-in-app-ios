//
//  PassthroughVerificationSettings.swift
//  MessagingUIExample
//
//  Created by Jeremy Wright on 2025-06-17.
//

import Foundation
import SwiftUI
import SalesforceSDKCore

typealias PassthroughVerificationStore = SettingsStore<PassthroughVerificationSettings.SettingsKeys>

struct PassthroughVerificationSettings: View {
    static let header = "Passthrough Verification Settings"

    enum SettingsKeys: String, Settings {
        public var id: String { rawValue }

        var defaultValue: Any {
            switch self {
            case .passthroughJWT: return ""
            case .lastEventId: return "0"
            }
        }

        var resettable: Bool { false }

        static func handleReset() {}

        case passthroughJWT
        case lastEventId
    }

    @StateObject var passthroughVerificationStore: PassthroughVerificationStore = PassthroughVerificationStore()
    @StateObject var configStore: MIAWConfigurationStore = MIAWConfigurationStore()

    var body: some View {
        if configStore.authorizationMethod == .passthrough {
            Section(header: Text(Self.header)) {
                SettingsButton {
                    AuthHelper.loginIfRequired {}
                } label: {
                    Text("Login via Salesforce Mobile SDK")
                }

                SettingsButton {
                    UserAccountManager.shared.logout()
                } label: {
                    Text("Logout")
                }
            }
        }
    }
}

// MARK: - UserDefault Wrappers
extension PassthroughVerificationStore {
    var passthroughJWT: String {
        get { userDefaults.string(forKey: Keys.passthroughJWT.rawValue) ?? "" }
        set { userDefaults.set(newValue, forKey: Keys.passthroughJWT.rawValue) }
    }

    var lastEventId: String {
        get { userDefaults.string(forKey: Keys.lastEventId.rawValue) ?? "" }
        set { userDefaults.set(newValue, forKey: Keys.lastEventId.rawValue) }
    }
}
