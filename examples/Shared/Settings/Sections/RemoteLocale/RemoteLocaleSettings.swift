//
//  RemoteLocaleSettings.swift
//

import SwiftUI

typealias RemoteLocaleStore = SettingsStore<RemoteLocaleSettings.SettingsKeys>

struct RemoteLocaleSettings: View {

    let instructions = "Enter a device locale, and it's accompanying mapped value."
    let header = "Remote Locale Input"
    let keyLabel = "Device Locale"
    let valueLabel = "Mapped Remote Locale"

    enum SettingsKeys: String, Settings {
        var id: String { rawValue }

        var defaultValue: Any {
            switch self {
            case .remoteLocaleValues: return [] as [BasicKeyValuePair]
            }
        }

        var resettable: Bool { false }

        static func handleReset() {}

        case remoteLocaleValues
    }

    @StateObject var remoteLocaleStore: RemoteLocaleStore = RemoteLocaleStore()

    var body: some View {
        SettingsSection("Remote Locale Settings", developerOnly: true) {
            NavigationLink {
                Form {
                    SettingsKeyValueManager(pairs: $remoteLocaleStore.remoteLocaleValues,
                                            instructions: instructions,
                                            header: header,
                                            keyLabel: keyLabel,
                                            valueLabel: valueLabel) { key, value in

                        BasicKeyValuePair(key: key, value: value)
                    } row: { index, element in

                        KeyValuePairRow(pair: element, keyLabel: keyLabel, valueLabel: valueLabel, header: index == 0)
                    }

                }
            } label: {
                Text("Configure Remote Locale Map")
            }
        }
    }
}

extension RemoteLocaleStore {
    var remoteLocaleValues: [BasicKeyValuePair] {
        get {
            guard let array = [BasicKeyValuePair](rawValue: userDefaults.string(forKey: Keys.remoteLocaleValues.rawValue) ?? "") else {
                return []
            }

            return array
        }

        set { userDefaults.set(newValue.rawValue, forKey: Keys.remoteLocaleValues.rawValue) }
    }

    var remoteLocaleMap: [String: String] {
        var result: [String: String] = [:]
        for pair in remoteLocaleValues {
            result[pair.key] = pair.value
        }

        return result
    }
}

#Preview {
    WrappedNavigationStack {
        Form {
            RemoteLocaleSettings()

            DeveloperStettings()
        }.navigationTitle(SettingsForm.title)
    }
}
