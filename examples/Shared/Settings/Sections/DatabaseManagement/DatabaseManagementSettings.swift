//
//  DatabaseManagementSettings.swift
//

import SwiftUI
import SMIClientCore

struct DatabaseManagementSettings: View {
    static let header = "Database Management"

    @StateObject var configStore: MIAWConfigurationStore = MIAWConfigurationStore()

    var body: some View {
        SettingsSection(Self.header, developerOnly: true) {
            SettingsButton {
                CoreFactory.create(withConfig: configStore.config).destroyStorage(andAuthorization: false) { _ in }
            } label: {
                Text("Clear Local Cache Only")
            }
        }
    }
}

#Preview {
    Form {
        DatabaseManagementSettings()

        DeveloperStettings()
    }
}
