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
                NavigationScreenType.allCases.forEach {
                    result[$0.rawValue] = $0.defaultValue
                }

                return result.rawValue

            case .dynamicTitleReplacement: return false
            }
        }

        var resettable: Bool { false }

        static func handleReset() {}

        public var id: String { rawValue }

        case navBarReplacements
        case dynamicTitleReplacement
    }

    @StateObject var navBarReplacementStore: NavBarReplacementStore = NavBarReplacementStore()

    var body: some View {
        NavigationLink {
            Form {
                SettingsSection("Dynamic Title Replacement") {
                    Instructions(instructions:"This will enable dynamic replacement of the title with the current agent/bot name",
                                 note: "This will only occur on the chat feed",
                                 section: false)

                    SettingsToggle("Replace Title with Agent Name", isOn: $navBarReplacementStore.dynamicTitleReplacement)
                }
                SettingsSection(Self.header) {
                    ForEach(NavigationScreenType.allCases) { category in
                        NavBarReplacementRow(category: category)
                    }
                }
            }
        } label: {
            Text("Configure Navbar Replacements")
        }
    }

    private struct NavBarReplacementRow: View {
        let category: NavigationScreenType

        @State var isOn: Bool = false
        @StateObject var navBarReplacementStore: NavBarReplacementStore = NavBarReplacementStore()

        var body: some View {
            SettingsToggle(category.rawValue, isOn: $isOn)
                .onChange(of: isOn) { old, new in
                    var navBarReplacements = navBarReplacementStore.navBarReplacements

                    navBarReplacements[category.rawValue]?.shouldReplace = new

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


extension NavBarReplacementStore {
    var dynamicTitleReplacement: Bool {
        get { userDefaults.bool(forKey: Keys.dynamicTitleReplacement.rawValue) }
        set { userDefaults.set(newValue, forKey: Keys.dynamicTitleReplacement.rawValue) }
    }
}
