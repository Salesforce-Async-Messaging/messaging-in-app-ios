//
//  SettingsToggle.swift
//  SMITestApp
//
//  Created by Jeremy Wright on 2024-09-11.
//

import SwiftUI

struct SettingsToggle: View {
    let label: String
    let isOn: Binding<Bool>
    let developerOnly: Bool

    @StateObject private var developerStore: DeveloperStore = DeveloperStore()
    var shouldRender: Bool { !developerOnly || (developerOnly && developerStore.isDeveloperMode ) }

    init(_ label: String, developerOnly: Bool = false, isOn: Binding<Bool>) {
        self.label = label
        self.developerOnly = developerOnly
        self.isOn = isOn
    }

    var body: some View {
        if shouldRender {
            Toggle(isOn: isOn, label: {
                Text(label)
            })
        }
    }
}

struct SettingsTogglePreview: PreviewProvider {
    struct ContainerView: View {
        @State var toggle: Bool = true

        var body: some View {
            Form {
                SettingsToggle("This is a test field with a toggle. Please Click", isOn: $toggle)
                SettingsToggle("Only available in developer mode", developerOnly: true, isOn: $toggle)
                DeveloperStettings()
            }
        }
    }

    static var previews: some View {
        ContainerView()
    }
}
