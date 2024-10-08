//
//  UIReplacementSettings.swift
//  SMITestApp
//
//  Created by Jeremy Wright on 2024-09-17.
//

import SwiftUI
import SMIClientUI

typealias UIReplacementStore = SettingsStore<UIReplacementSettings.SettingsKeys>

struct UIReplacementSettings: View {
    static let header: String = "UI Replacement Settings"

    enum SettingsKeys: String, Settings {
        var defaultValue: Any {
            switch self {
            case .replaceAll: return false
            case .uiReplacements:
                var result: [String: UIReplacementModel] = [:]
                UIReplacementCategory.allCases.forEach {
                    result[$0.rawValue] = $0.defaultValue
                }

                return result.rawValue
            }
        }

        var resettable: Bool { true }

        static func handleReset() {}

        public var id: String { rawValue }

        case uiReplacements
        case replaceAll
    }

    @StateObject var uiReplacementStore: UIReplacementStore = UIReplacementStore()

    var body: some View {
        SettingsSection(Self.header, developerOnly: true) {
            NavigationLink {
                Form {
                    SettingsSection("Options") {
                        SettingsToggle("Replace All", isOn: $uiReplacementStore.replaceAll)
                    }

                    if uiReplacementStore.replaceAll == false {
                        SettingsSection("Replacements") {
                            ForEach(UIReplacementCategory.allCases.filter {$0 != .unknown }) { category in
                                ReplacementRow(category: category)
                            }
                        }
                    }
                }
            } label: {
                Text("Configure Replacements")
            }
        }
    }
}

private struct ReplacementRow: View {
    let category: UIReplacementCategory

    @State var renderMode: ChatFeedRenderMode = .existing
    @StateObject var uiReplacementStore: UIReplacementStore = UIReplacementStore()

    var body: some View {
        SettingsPicker(category.rawValue, value: $renderMode)
            .onChange(of: renderMode) { newValue in
                var uiReplacements = uiReplacementStore.uiReplacements

                uiReplacements[category.rawValue]?.renderMode = newValue.rawValue

                uiReplacementStore.uiReplacements = uiReplacements
            }
            .onAppear(perform: {
                let rawValueString = uiReplacementStore.uiReplacements[category.rawValue]?.renderMode
                renderMode = ChatFeedRenderMode(rawValue: rawValueString ?? "") ?? .existing
            })
    }
}

extension UIReplacementStore {
    var replaceAll: Bool {
        get { userDefaults.bool(forKey: Keys.replaceAll.rawValue) }
        set { userDefaults.set(newValue, forKey: Keys.replaceAll.rawValue) }
    }
}

#Preview {
    WrappedNavigationStack {
        Form {
            UIReplacementSettings()

            DeveloperStettings()
        }.navigationTitle(SettingsForm.title)
    }
}
