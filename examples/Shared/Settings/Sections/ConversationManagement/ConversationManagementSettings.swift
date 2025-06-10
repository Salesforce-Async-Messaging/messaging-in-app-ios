//
//  ConversationManagementSettings.swift
//

import SwiftUI
import SMIClientCore

typealias ConversationManagementStore = SettingsStore<ConversationManagementSettings.SettingsKeys>

struct ConversationManagementSettings: View {
    static let header = "Conversation Management"

    enum SettingsKeys: String, Settings {
        public var id: String { rawValue }

        var defaultValue: Any { "" }
        var resettable: Bool { true }

        static func handleReset() {}

        case conversationId
    }

    @StateObject var store: ConversationManagementStore = ConversationManagementStore()
    @StateObject var configStore: MIAWConfigurationStore = MIAWConfigurationStore()

    var body: some View {
        SettingsSection(Self.header, developerOnly: true) {
            SettingsTextField("Current Conversation Id", placeholder: "Enter your Conversation Id", value: $store.conversationId, enabled: false)

            NavigationLink {
                ConversationPicker()
            } label: {
                Text("Choose Conversation")
            }

            SettingsButton {
                store.conversationId = UUID().uuidString
            } label: {
                Text("New Conversation Id")
            }

            SettingsButton {
                let uUID = UUID()
                store.conversationId = uUID.uuidString

                let client = CoreFactory.create(withConfig: configStore.config).conversationClient(with: uUID)
                client.core?.retrieveRemoteConfiguration(completion: { remoteConfig, _ in
                    if let remoteConfig = remoteConfig {
                        if let preChatConfiguration = remoteConfig.preChatConfiguration?.first {
                            preChatConfiguration.preChatFields.forEach { $0.value = "Test Value" }
                            client.create(remoteConfig: remoteConfig)
                        } else {
                            client.create()
                        }
                    } else {
                        client.create()
                    }
                })
            } label: {
                Text("Create Conversation")
            }

            SettingsButton {
                let uuid = UUID(uuidString: store.conversationId)
                let client = CoreFactory.create(withConfig: configStore.config).conversationClient(with: uuid)
                client.closeConversation(completion: { error in
                    if error != nil {
                        print(error ?? "")
                    }
                })
            } label: {
                Text("Close Conversation")
            }
        }
    }
}

extension ConversationManagementStore {
    var conversationUUID: UUID { UUID(uuidString: conversationId) ?? UUID() }

    var conversationId: String {
        get {
            let result = userDefaults.string(forKey: Keys.conversationId.rawValue) ?? ""

            // We have a chicken & egg situation here where we need to determine when
            // to automatically generate a new conversationId if the old one is reset.
            if result.isEmpty {
                let newValue = UUID().uuidString
                userDefaults.set(newValue, forKey: Keys.conversationId.rawValue)

                return newValue
            }

            return result
        }
        set { userDefaults.set(newValue, forKey: Keys.conversationId.rawValue) }
    }
}

#Preview {
    WrappedNavigationStack {
        Form {
            ConversationManagementSettings()

            DeveloperStettings()
        }.navigationTitle(SettingsForm.title)
    }
}
