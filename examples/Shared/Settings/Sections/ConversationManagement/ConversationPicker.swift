//
//  ConversationPicker.swift
//

import SwiftUI
import SMIClientCore

struct ConversationPicker: View {
    static var title: String = "Conversation List"

    @Environment(\.presentationMode) var presentationMode

    @StateObject var configStore: MIAWConfigurationStore = MIAWConfigurationStore()
    @StateObject var conversationManagementStore: ConversationManagementStore = ConversationManagementStore()

    @State private var isFetching: Bool = false
    @State private var isError: Bool = false
    @State private var conversations: [Conversation]?
    @State private var error: NSError?
    @State private var isLocal = true
    @State private var limit: UInt = 0

    var body: some View {
        List {
            Group {
                Section(header: Text("Behaviour")) {
                    SettingsToggle("Use Local Cache", isOn: $isLocal)
                        .onChange(of: isLocal) { _ in
                            fetch()
                        }
                }

                if isError {
                    handleError
                } else if isFetching {
                    handleFetching
                } else if conversations != nil {
                    handleData
                }
            }
        }
        .onAppear(perform: fetch)
        .navigationTitle(Self.title)
    }

    private func fetch() {
        isFetching = true
        isError = false
        error = nil
        conversations = nil

        let core = CoreFactory.create(withConfig: configStore.config)
        let closure: ConversationQueryCompletion = { (conversations, error) in
            if error != nil {
                isError = true
                self.error = error as NSError?
                return
            }

            isFetching = false
            self.conversations = conversations
        }

        if isLocal {
            core.conversations(withLimit: limit, sortedByActivityDirection: .descending, completion: closure)
        } else {
            core.conversations(withLimit: limit, olderThanConversation: nil, completion: closure)
        }
    }

    private var handleError: some View {
        VStack {
            Text("ERROR").foregroundColor(.red)
            if let error = error {
                let body = error.userInfo["body"] as? String
                Text("\(error.code): \(body ?? "")")
            }
        }
    }

    private var handleFetching: some View {
        HStack {
            Text("FETCHING")
        }
    }

    private var handleData: some View {
        Section(header: Text(isLocal ? "Local Conversation Cache" : "Remote Conversation List")) {
            ForEach(conversations ?? [], id: \.identifier) { conversation in
                ConversationView(conversation)
                    .onTapGesture {
                        conversationManagementStore.conversationId = conversation.identifier.uuidString
                        presentationMode.wrappedValue.dismiss()
                    }
            }
        }
    }
}

private struct ConversationView: View {
    let conversation: Conversation

    init(_ conversation: Conversation) {
        self.conversation = conversation
    }

    private func row(_ label: String, value: String) -> some View {
        HStack(alignment: .top) {
            Text("\(label) ").fontWeight(.bold).font(.system(.body, design: .monospaced))
            Text(value).font(.system(.body, design: .monospaced))
        }
    }

    var body: some View {
        VStack(alignment: .leading) {
            row("Identifier :", value: conversation.identifier.uuidString)
            row("Last Active:", value: conversation.lastActiveEntry?.timestamp.description ?? "")
        }
    }
}

#Preview {
    ConversationPicker()
}
