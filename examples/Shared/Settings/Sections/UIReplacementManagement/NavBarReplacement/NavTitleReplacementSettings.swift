//
//  NavTitleReplacementSettings.swift
//  MessagingUIExample
//
//  Created by Nigel Brown on 2025-06-24.
//

import SwiftUI
import SMIClientUI

typealias NavigationTitleReplacementStore = SettingsStore<NavTitleTimerReplacementSettings.SettingsKeys>

struct NavTitleTimerReplacementSettings: View {
    static let header: String = "Navigation Title Timer"

    enum SettingsKeys: String, Settings {
        public var id: String { rawValue }

        var defaultValue: Any {
            switch self {
            case .titleReplacementEnabled: return false
            }
        }

        var resettable: Bool { true }

        static func handleReset() {}

        case titleReplacementEnabled
    }

    @State var isOn: Bool = false
    @EnvironmentObject var navigationTitleReplacementManager: NavigationTitleReplacementManager
    @StateObject var navigationTitleReplacementStore: NavigationTitleReplacementStore = NavigationTitleReplacementStore()

    var body: some View {
        SettingsSection(Self.header) {
            Text("The navigation bar title will be replaced on a 5 second timer when turned on.")
            SettingsToggle("Title Timer", isOn: $isOn)
        }
        .onChange(of: isOn) { titleReplacementEnabled in
            navigationTitleReplacementStore.titleReplacementEnabled = titleReplacementEnabled

            titleReplacementEnabled ? navigationTitleReplacementManager.startTimer() : navigationTitleReplacementManager.stopTimer()
        }
        .onAppear(perform: {
            isOn = navigationTitleReplacementStore.titleReplacementEnabled
        })
    }
}
