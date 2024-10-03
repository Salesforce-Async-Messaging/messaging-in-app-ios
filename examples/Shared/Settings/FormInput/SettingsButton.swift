//
//  SettingsButton.swift
//  SMITestApp
//
//  Created by Jeremy Wright on 2024-09-11.
//

import SwiftUI

struct SettingsButton<Label: View>: View {
    let display: String?
    let label: () -> Label
    let action: () -> Void
    let developerOnly: Bool

    @StateObject private var developerStore: DeveloperStore = DeveloperStore()
    var shouldRender: Bool { !developerOnly || (developerOnly && developerStore.isDeveloperMode ) }

    public init(_ display: String? = nil, developerOnly: Bool = false, action: @escaping () -> Void, @ViewBuilder label: @escaping () -> Label) {
        self.action = action
        self.label = label
        self.display = display
        self.developerOnly = developerOnly
    }

    var body: some View {
        if shouldRender {
            HStack {
                if let display {
                    Text(display)
                    Spacer()
                }

                Button(action: action, label: label)
                    .buttonStyle(.plain)
                    .foregroundColor(.blue)
            }
        }
    }
}

struct SettingsButtonPreview: PreviewProvider {
    struct ContainerView: View {
        @State var buttonToggle: Bool = true

        var body: some View {
            Form {
                SettingsButton {
                    buttonToggle.toggle()
                } label: {
                    Text(buttonToggle ? "true": "false")
                }

                SettingsButton("Text Label") {
                    buttonToggle.toggle()
                } label: {
                    Image(.copyFilled)
                        .resizable()
                        .frame(width: 20, height: 20)
                }

                SettingsButton("Only Available in deeloper Mode", developerOnly: true) {
                    buttonToggle.toggle()
                } label: {
                    Image(.copyFilled)
                        .resizable()
                        .frame(width: 20, height: 20)
                }

                DeveloperStettings()
            }
        }
    }

    static var previews: some View {
        ContainerView()
    }
}
