//
//  SettingsSection.swift
//  SMITestApp
//
//  Created by Jeremy Wright on 2024-09-17.
//

import SwiftUI

struct SettingsSection<Content: View>: View {
    let label: String
    let developerOnly: Bool
    let content: () -> Content

    init(_ label: String, developerOnly: Bool = false, @ViewBuilder content: @escaping () -> Content) {
        self.label = label
        self.developerOnly = developerOnly
        self.content = content
    }

    @StateObject private var developerStore: DeveloperStore = DeveloperStore()
    var shouldRender: Bool { !developerOnly || (developerOnly && developerStore.isDeveloperMode ) }

    var body: some View {
        if shouldRender {
            Section(header: Text(label)) {
                content()
            }
        }
    }
}

#Preview {
    Form {
        SettingsSection("This is a section") {
            Text("Some content")
        }

        SettingsSection("Developer Only Section", developerOnly: true) {
            Text("Some Content")
        }

        DeveloperStettings()
    }
}
