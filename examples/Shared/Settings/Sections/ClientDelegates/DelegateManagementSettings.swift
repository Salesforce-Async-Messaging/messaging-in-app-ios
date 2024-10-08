//
//  DelegateManagementStore.swift
//

import SwiftUI

typealias DelegateManagementStore = SettingsStore<DelegateManagementSettings.SettingsKeys>

struct DelegateManagementSettings: View {
    static let header: String = "Delegate & Closure Management"

    enum SettingsKeys: String, Settings {
        var id: String { rawValue }

        var defaultValue: Any {
            switch self {
            case .templatedURLValues: return [] as [BasicKeyValuePair]
            case .hiddenPreChatValues: return [] as [BasicKeyValuePair]
            case .prePopPreChatValues: return [] as [PrePopulatedPreChatKeyValuePair]
            default: return true
            }
        }

        var resettable: Bool { false }

        static func handleReset() {}

        case templatedURLDelgateEnabled
        case templatedURLValues

        case hiddenPreChatDelegateEnabled
        case hiddenPreChatValues

        case prePopPreChatClosureEnabled
        case prePopPreChatValues
    }

    @StateObject var delegateManagementStore: DelegateManagementStore = DelegateManagementStore()

    var body: some View {
        SettingsSection(Self.header, developerOnly: true) {

            DelegateManagementSettingsRow(label: "Templated URL", toggle: $delegateManagementStore.templatedURLDelgateEnabled) {
                TemplateURLDelegateConfiguration()
            }

            DelegateManagementSettingsRow(label: "Hidden PreChat", toggle: $delegateManagementStore.hiddenPreChatDelegateEnabled) {
                HiddenPreChatDelegateConfiguration()
            }

            DelegateManagementSettingsRow(label: "Pre-Populated PreChat", type: .closure, toggle: $delegateManagementStore.prePopPreChatClosureEnabled) {
                PrePopulatedPreChatClosureConfiguration()
            }
        }
    }
}

private struct DelegateManagementSettingsRow<Content: View>: View {
    enum ReceiverType: String {
        case delegate = "Delegate"
        case closure = "Closure"
    }

    let label: String
    var type: ReceiverType = .delegate
    let toggle: Binding<Bool>

    @ViewBuilder let content: () -> Content

    var body: some View {
        Group {
            VStack(alignment: .leading) {
                Text(label)
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.bold)

                SettingsToggle("\(type == .delegate ? "Delegate" : "Closure") Provided", isOn: toggle)
            }
        }

        Group {
            if toggle.wrappedValue {
                NavigationLink {
                    content()
                } label: {
                    Text("Configure")
                }
            }
        }
    }
}

extension DelegateManagementStore {
    var templatedURLDelgateEnabled: Bool {
        get { userDefaults.bool(forKey: Keys.templatedURLDelgateEnabled.rawValue) }
        set { userDefaults.set(newValue, forKey: Keys.templatedURLDelgateEnabled.rawValue) }
    }

    var templatedURLValues: [BasicKeyValuePair] {
        get {
            guard let array = [BasicKeyValuePair](rawValue: userDefaults.string(forKey: Keys.templatedURLValues.rawValue) ?? "") else {
                return []
            }

            return array
        }

        set { userDefaults.set(newValue.rawValue, forKey: Keys.templatedURLValues.rawValue) }
    }

    var hiddenPreChatValues: [BasicKeyValuePair] {
        get {
            guard let array = [BasicKeyValuePair](rawValue: userDefaults.string(forKey: Keys.hiddenPreChatValues.rawValue) ?? "") else {
                return []
            }

            return array
        }

        set { userDefaults.set(newValue.rawValue, forKey: Keys.hiddenPreChatValues.rawValue) }
    }

    var prePopPreChatValues: [PrePopulatedPreChatKeyValuePair] {
        get {
            guard let array = [PrePopulatedPreChatKeyValuePair](rawValue: userDefaults.string(forKey: Keys.prePopPreChatValues.rawValue) ?? "") else {
                return []
            }

            return array
        }

        set { userDefaults.set(newValue.rawValue, forKey: Keys.prePopPreChatValues.rawValue) }
    }

    var hiddenPreChatDelegateEnabled: Bool {
        get { userDefaults.bool(forKey: Keys.hiddenPreChatDelegateEnabled.rawValue) }
        set { userDefaults.set(newValue, forKey: Keys.hiddenPreChatDelegateEnabled.rawValue) }
    }

    var prePopPreChatClosureEnabled: Bool {
        get { userDefaults.bool(forKey: Keys.prePopPreChatClosureEnabled.rawValue) }
        set { userDefaults.set(newValue, forKey: Keys.prePopPreChatClosureEnabled.rawValue) }
    }
}

#Preview {
    WrappedNavigationStack {
        Form {
            DelegateManagementSettings()
            DeveloperStettings()
        }.navigationTitle(SettingsForm.title)
    }
}
