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

        var defaultValue: Any {
            switch self {
            case .conversationId: ""
            case .conversationLabel: ""
            case .queryLimit: "10"
            case .queryUseFromTimestamp: false
            case .queryFromTimestamp: Date.distantPast
            case .queryDirection: ListAPIDirections.descending.rawValue
            case .queryIncludeClosed: true
            case .queryForceRefresh: false
            }
        }

        var resettable: Bool {
            switch self {
            case .queryFromTimestamp: return false
            default: return true
            }
        }

        static func handleReset() {
            UserDefaults.standard.removeObject(forKey: Self.queryFromTimestamp.rawValue)
        }

        case conversationId
        case conversationLabel
        case queryLimit
        case queryUseFromTimestamp
        case queryFromTimestamp
        case queryDirection
        case queryIncludeClosed
        case queryForceRefresh
    }

    @StateObject var configStore: MIAWConfigurationStore = MIAWConfigurationStore()
    @StateObject var contextEventStore: ContextEventStore = ContextEventStore()
    @StateObject var conversationManagementStore: ConversationManagementStore = ConversationManagementStore()

    var body: some View {
        SettingsSection(Self.header, developerOnly: true) {
            NavigationLink {
                ConversationPicker()
            } label: {
                Text("Choose Conversation")
            }

            NavigationLink {
                QueryConversation()
            } label: {
                Text(QueryConversation.title)
            }
            .accessibilityHint("Queries conversations using every query parameter")
            .accessibilityIdentifier("Query Conversation.link")

            SettingsTextField("Default Conversation Label", placeholder: "No Label", value: $conversationManagementStore.conversationLabel)

            SettingsButton {
                let uUID = UUID()
                configStore.conversationId = uUID.uuidString

                let client = CoreFactory.create(withConfig: configStore.config).conversationClient(with: uUID)
                GlobalCoreDelegateHandler.shared.registerDelegates(client)

                if contextEventStore.contextEvent {
                    ContextEventStore.applySampleSessionContext(to: client)
                }

                client.core?.retrieveRemoteConfiguration(completion: { remoteConfig, _ in
                    let label = conversationManagementStore.conversationLabel.isEmpty ? nil : conversationManagementStore.conversationLabel
                    if let remoteConfig = remoteConfig {
                        if let preChatConfiguration = remoteConfig.preChatConfiguration?.first {
                            preChatConfiguration.preChatFields.forEach { $0.value = "Test Value" }
                            client.create(remoteConfig: remoteConfig, label: label)
                        } else {
                            client.create(label: label)
                        }
                    } else {
                        client.create(label: label)
                    }
                })
            } label: {
                Text("Create Conversation")
            }

            SettingsButton {
                let uuid = UUID(uuidString: configStore.conversationId)
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

    var conversationLabel: String {
        get { userDefaults.string(forKey: Keys.conversationLabel.rawValue) ?? "" }
        set { userDefaults.set(newValue, forKey: Keys.conversationLabel.rawValue) }
    }

    var queryLimit: String {
        get { userDefaults.string(forKey: Keys.queryLimit.rawValue) ?? "" }
        set { userDefaults.set(newValue, forKey: Keys.queryLimit.rawValue) }
    }

    var queryUseFromTimestamp: Bool {
        get { userDefaults.bool(forKey: Keys.queryUseFromTimestamp.rawValue) }
        set { userDefaults.set(newValue, forKey: Keys.queryUseFromTimestamp.rawValue) }
    }

    var queryFromTimestamp: Date {
        get { userDefaults.object(forKey: Keys.queryFromTimestamp.rawValue) as? Date ?? .distantPast }
        set { userDefaults.set(newValue, forKey: Keys.queryFromTimestamp.rawValue) }
    }

    var queryDirection: ListAPIDirections {
        get { userDefaults.string(forKey: Keys.queryDirection.rawValue) == ListAPIDirections.ascending.rawValue ? .ascending : .descending }
        set { userDefaults.set(newValue.rawValue, forKey: Keys.queryDirection.rawValue) }
    }

    var queryIncludeClosed: Bool {
        get { userDefaults.bool(forKey: Keys.queryIncludeClosed.rawValue) }
        set { userDefaults.set(newValue, forKey: Keys.queryIncludeClosed.rawValue) }
    }

    var queryForceRefresh: Bool {
        get { userDefaults.bool(forKey: Keys.queryForceRefresh.rawValue) }
        set { userDefaults.set(newValue, forKey: Keys.queryForceRefresh.rawValue) }
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
