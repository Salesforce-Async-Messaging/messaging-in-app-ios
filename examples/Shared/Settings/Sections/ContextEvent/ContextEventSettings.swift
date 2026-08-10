//
//  ContextEventSettings.swift
//  SMITestApp
//
//  Created by Aaron Eisses on 2025-09-17.
//

import SwiftUI
import SMIClientCore

typealias ContextEventStore = SettingsStore<ContextEventSettings.SettingsKeys>

struct ContextEventSettings: View {
    static let header = "Context Event Settings"

    enum SettingsKeys: String, Settings {
        public var id: String { rawValue }

        var defaultValue: Any {
            switch self {
            case .contextEvent: return false
            }
        }

        var resettable: Bool {
            switch self {
            case .contextEvent: return false
            }
        }

        static func handleReset() {}

        case contextEvent
    }

    @StateObject var store: ContextEventStore = ContextEventStore()

    var body: some View {
        SettingsSection(Self.header, developerOnly: true) {
            SettingsToggle("Context Event", developerOnly: true, isOn: $store.contextEvent)
        }
    }
}

// MARK: - UserDefault Wrappers
extension ContextEventStore {
    var contextEvent: Bool {
        get { userDefaults.bool(forKey: Keys.contextEvent.rawValue) }
        set { userDefaults.set(newValue, forKey: Keys.contextEvent.rawValue) }
    }

    static func applySampleSessionContext(to conversationClient: ConversationClient) {
        let structuredPayload: [String: Any] = [
            "currentPage": "My Page",
            "search": [
                "result": "My Result",
                "filters": ["filter 1", "filter 2"],
                "facets": ["facet 1", "facet 2"]
            ]
        ]

        let listPayload: [AbstractValueProtocol] = [
            TextValue(value: "item1"),
            TextValue(value: "item2"),
            TextValue(value: "item3")
        ]

        let listValue = ListValue(value: listPayload)
        let nestedListValue = ListValue(value: [listValue])

        let namedValues = [
            NamedValue(name: "textValue", value: TextValue(value: "Bob")),
            NamedValue(name: "booleanValue", value: BooleanValue(value: true)),
            NamedValue(name: "integerValue", value: IntegerValue(value: 10)),
            NamedValue(name: "doubleValue", value: DoubleValue(value: 22.0)),
            NamedValue(name: "dateValue", value: DateValue(value: .now)),
            NamedValue(name: "dateTimeValue", value: DateTimeValue(value: .now)),
            NamedValue(name: "listValue", value: nestedListValue),
            NamedValue(name: "structuredValue", value: StructuredValue(value: structuredPayload))
        ]

        let sessionContextSet = SessionContextSet(contextVariables: namedValues)
        let sessionContext = SessionContext(sessionContext: sessionContextSet)

        conversationClient.set(sessionContext: sessionContext)
    }
}

#Preview {
    Form {
        ContextEventSettings()
    }
}
