//
//  SettingNavigationLink.swift
//  SMITestApp
//
//  Created by Aaron Eisses on 2025-09-08.
//  Copyright © 2025 Salesforce.com. All rights reserved.
//

import SwiftUI

struct SettingsNavigationLink<Content: View>: View {
    let label: String
    let developerOnly: Bool
    let content: () -> Content

    @StateObject private var developerStore: DeveloperStore = DeveloperStore()
    var shouldRender: Bool { !developerOnly || (developerOnly && developerStore.isDeveloperMode ) }

    init(_ label: String, developerOnly: Bool = false, content: @escaping () -> Content) {
        self.label = label
        self.developerOnly = developerOnly
        self.content = content
    }

    var body: some View {
        if shouldRender {
            NavigationLink {
                content()
            } label: {
                Text(label)
            }
        }
    }
}

struct SettingsNavigationLinkPreview: PreviewProvider {
    struct ContainerView: View {

        var body: some View {
            Form {
                SettingsNavigationLink("This is a test field with an empty view. Please Click") { EmptyView() }
                SettingsNavigationLink("Only available in developer mode", developerOnly: true) { EmptyView() }
                DeveloperStettings()
            }
        }
    }

    static var previews: some View {
        ContainerView()
    }
}
