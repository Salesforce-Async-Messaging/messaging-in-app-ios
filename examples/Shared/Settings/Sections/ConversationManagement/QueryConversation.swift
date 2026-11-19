//
//  QueryConversation.swift
//

import SwiftUI
import SMIClientCore

struct QueryConversation: View {
    static let title = "Query Conversation"

    private enum QueryState {
        case idle
        case fetching
        case invalid(String)
        case failed(NSError)
        case loaded([any Conversation])
    }

    @Environment(\.dismiss) private var dismiss

    @StateObject var configStore: MIAWConfigurationStore = MIAWConfigurationStore()
    @StateObject var conversationManagementStore: ConversationManagementStore = ConversationManagementStore()

    @State private var queryState: QueryState = .idle

    var body: some View {
        List {
            parametersSection
            resultsSection
        }
        .navigationTitle(Self.title)
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: conversationManagementStore.queryLimit) { resetResults() }
        .onChange(of: conversationManagementStore.queryUseFromTimestamp) { _, isOn in
            if isOn {
                conversationManagementStore.queryFromTimestamp = Date()
            }
            resetResults()
        }
        .onChange(of: conversationManagementStore.queryFromTimestamp) { resetResults() }
        .onChange(of: conversationManagementStore.queryDirection) { resetResults() }
        .onChange(of: conversationManagementStore.queryIncludeClosed) { resetResults() }
        .onChange(of: conversationManagementStore.queryForceRefresh) { resetResults() }
    }

    private var isFetching: Bool {
        if case .fetching = queryState {
            return true
        }
        return false
    }

    private var queryTimestamp: Date? {
        guard conversationManagementStore.queryUseFromTimestamp else {
            return nil
        }
        let fromTimestamp = conversationManagementStore.queryFromTimestamp
        return Calendar.current.dateInterval(of: .minute, for: fromTimestamp)?.start ?? fromTimestamp
    }

    private var parametersSection: some View {
        Section(header: Text("Parameters"), footer: parametersFooter) {
            LabeledContent("Limit") {
                TextField("0", text: $conversationManagementStore.queryLimit)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .font(.system(.body, design: .monospaced))
                    .accessibilityLabel("Limit")
                    .accessibilityHint("The maximum number of conversations to return")
                    .accessibilityIdentifier("Query Limit.input")
            }

            SettingsToggle("Use From Timestamp", isOn: $conversationManagementStore.queryUseFromTimestamp)
                .accessibilityHint("Starts the query from the timestamp below instead of the newest or oldest conversation")
                .accessibilityIdentifier("Use From Timestamp.toggle")

            if conversationManagementStore.queryUseFromTimestamp {
                DatePicker("From Timestamp", selection: $conversationManagementStore.queryFromTimestamp, displayedComponents: [.date, .hourAndMinute])
                    .accessibilityHint("Conversations are compared to this creation time, inclusive")
                    .accessibilityIdentifier("From Timestamp.input")
            }

            Picker("Direction", selection: $conversationManagementStore.queryDirection) {
                Text("Descending").tag(ListAPIDirections.descending)
                Text("Ascending").tag(ListAPIDirections.ascending)
            }
            .accessibilityHint("Chooses conversations created before or after the starting point")
            .accessibilityIdentifier("Query Direction.picker")

            SettingsToggle("Include Closed", isOn: $conversationManagementStore.queryIncludeClosed)
                .accessibilityHint("Includes closed conversations in the results")
                .accessibilityIdentifier("Query Include Closed.toggle")

            SettingsToggle("Force Refresh", isOn: $conversationManagementStore.queryForceRefresh)
                .accessibilityHint("Always requests the conversation list from the network before returning results")
                .accessibilityIdentifier("Query Force Refresh.toggle")

            SettingsButton {
                fetch()
            } label: {
                Text("Fetch")
            }
            .disabled(isFetching)
            .accessibilityHint("Queries conversations using the parameters above")
            .accessibilityIdentifier("Query Fetch.button")
        }
    }

    private var parametersFooter: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Limit is the maximum number of conversations to return.")
            Text("Force Refresh off requests the list only when the cache can't satisfy the limit.")
            Text("From Timestamp is inclusive, starts at the beginning of the chosen minute, and compares each conversation's created date.")
        }
    }

    private var resultsFooter: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Shows the conversations the query call returned, newest created first, whichever direction is chosen.")
            Text("Only the current channel is included. A fetch under a different channel configuration moves the server's conversations to it.")
            Text("Network failures are not reported; cached conversations are returned instead.")
        }
    }

    private var resultsSection: some View {
        Section(header: resultsHeader, footer: resultsFooter) {
            switch queryState {
            case .idle:
                Text("Set the parameters above and tap Fetch to query conversations.")
                    .foregroundColor(.secondary)
                    .accessibilityIdentifier("Query Results.idle")
            case .fetching:
                HStack {
                    ProgressView()
                    Text("Loading...")
                        .foregroundColor(.secondary)
                }
                .accessibilityElement(children: .combine)
                .accessibilityIdentifier("Query Results.fetching")
            case .invalid(let message):
                Text(message)
                    .foregroundColor(.red)
                    .accessibilityIdentifier("Query Results.invalid")
            case .failed(let error):
                errorView(error)
            case .loaded(let conversations) where conversations.isEmpty:
                Text("No conversations returned")
                    .foregroundColor(.secondary)
                    .accessibilityIdentifier("Query Results.empty")
            case .loaded(let conversations):
                ForEach(conversations, id: \.identifier) { conversation in
                    conversationRow(conversation)
                }
            }
        }
    }

    private var resultsHeader: Text {
        if case .loaded(let conversations) = queryState {
            return Text("Results (\(conversations.count))")
        }
        return Text("Results")
    }

    private func errorView(_ error: NSError) -> some View {
        VStack(alignment: .leading) {
            Text("ERROR").foregroundColor(.red)
            Text("\(error.domain) \(error.code)")
            Text(error.localizedDescription)
                .foregroundColor(.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("Query Results.error")
    }

    private func conversationRow(_ conversation: any Conversation) -> some View {
        Button {
            configStore.conversationId = conversation.identifier.uuidString
            dismiss()
        } label: {
            ConversationView(conversation)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityHint("Sets this conversation as the active conversation")
        .accessibilityIdentifier("Query Conversation.\(conversation.identifier.uuidString)")
    }

    private func resetResults() {
        switch queryState {
        case .invalid, .failed, .loaded:
            queryState = .idle
        case .idle, .fetching:
            break
        }
    }

    private func fetch() {
        let trimmedLimit = conversationManagementStore.queryLimit.trimmingCharacters(in: .whitespaces)
        guard let limit = trimmedLimit.isEmpty ? 0 : UInt(trimmedLimit) else {
            queryState = .invalid("Limit must be a whole number, 0 or greater")
            return
        }

        let core = CoreFactory.create(withConfig: configStore.config)
        let completion: ConversationQueryCompletion = { conversations, error in
            DispatchQueue.main.async {
                withExtendedLifetime(core) {
                    if let error {
                        queryState = .failed(error as NSError)
                    } else {
                        queryState = .loaded(conversations ?? [])
                    }
                }
            }
        }

        queryState = .fetching
        GlobalCoreDelegateHandler.shared.registerDelegates(core)
        core.conversations(withLimit: limit,
                           fromTimestamp: queryTimestamp,
                           direction: conversationManagementStore.queryDirection,
                           includeClosed: conversationManagementStore.queryIncludeClosed,
                           forceRefresh: conversationManagementStore.queryForceRefresh,
                           completion: completion)
    }
}

#Preview {
    WrappedNavigationStack {
        QueryConversation()
    }
}
