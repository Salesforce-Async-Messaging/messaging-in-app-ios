//
//  NavBarReplacementSettings.swift
//  MessagingUIExample
//
//  Created by Nigel Brown on 2025-06-19.
//

import SwiftUI
import SMIClientUI

typealias NavBarReplacementStore = SettingsStore<NavBarReplacementSettings.SettingsKeys>

struct NavBarReplacementSettings: View {
    static let header: String = "Navigation Bar Replacements"

    enum SettingsKeys: String, Settings {
        var defaultValue: Any {
            switch self {
            case .navBarReplacements:
                var result: [String: NavBarReplacementModel] = [:]
                NavBarReplacementCategory.allCases.forEach {
                    result[$0.rawValue] = $0.defaultValue
                }

                return result.rawValue
            }
        }

        var resettable: Bool { true }

        static func handleReset() {}

        public var id: String { rawValue }

        case navBarReplacements
    }

    var body: some View {
        NavigationLink {
            Form {
                NavTitleTimerReplacementSettings()

                SettingsSection(Self.header) {
                    ForEach(NavBarReplacementCategory.allCases) { category in
                        NavBarReplacementRow(category: category)
                    }
                }
            }
        } label: {
            Text("Configure Navbar Replacements")
        }
    }

    private struct NavBarReplacementRow: View {
        let category: NavBarReplacementCategory

        @State var isOn: Bool = false
        @StateObject var navBarReplacementStore: NavBarReplacementStore = NavBarReplacementStore()

        var body: some View {
            SettingsToggle(category.rawValue, isOn: $isOn)
                .onChange(of: isOn) { shouldReplace in
                    var navBarReplacements = navBarReplacementStore.navBarReplacements

                    navBarReplacements[category.rawValue]?.shouldReplace = shouldReplace

                    navBarReplacementStore.navBarReplacements = navBarReplacements
                }
                .onAppear(perform: {
                    if let shouldReplace = navBarReplacementStore.navBarReplacements[category.rawValue]?.shouldReplace {
                        isOn = shouldReplace
                    }
                })
        }
    }
}
