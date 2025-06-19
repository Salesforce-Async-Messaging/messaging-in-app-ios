//
//  ReplacementSettings.swift
//  MessagingUIExample
//
//  Created by Nigel Brown on 2025-06-19.
//

import SwiftUI

struct ReplacementSettings: View {
    static let header: String = "Replacement Settings"

    var body: some View {
        SettingsSection(Self.header, developerOnly: true) {
            UIReplacementSettings()
            NavBarReplacementSettings()
        }
    }
}
