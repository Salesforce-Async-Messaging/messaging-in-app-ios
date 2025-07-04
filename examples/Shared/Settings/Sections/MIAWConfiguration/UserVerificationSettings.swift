//
//  UserVerificationSettings.swift
//

import SwiftUI

typealias UserVerificationStore = SettingsStore<UserVerificationSettings.SettingsKeys>

struct UserVerificationSettings: View {
    static let header = "User Verification Settings"

    enum SettingsKeys: String, Settings {
        public var id: String { rawValue }

        var defaultValue: Any {
            switch self {
            case .tokenJWT: return ""
            }
        }

        var resettable: Bool { false }

        static func handleReset() {}

        case tokenJWT
    }

    @StateObject var userVerificationStore: UserVerificationStore = UserVerificationStore()
    @StateObject var configStore: MIAWConfigurationStore = MIAWConfigurationStore()

    @State var isFetching: Bool = false

    var body: some View {
        if configStore.userVerificationRequired {
            Section(header: Text(Self.header)) {
                SettingsTextField("Customer Identity Token", placeholder: "No Token: Please Add Here", value: $userVerificationStore.tokenJWT, enabled: true, lineLimit: 12)
            }
        }
    }
}

extension UserVerificationStore {
    var tokenJWT: String {
        get { userDefaults.string(forKey: Keys.tokenJWT.rawValue) ?? "" }
        set { userDefaults.set(newValue, forKey: Keys.tokenJWT.rawValue) }
    }
}

#Preview {
    WrappedNavigationStack {
        Form {
            UserVerificationSettings()
                .navigationTitle("Settings")
        }
    }
}
