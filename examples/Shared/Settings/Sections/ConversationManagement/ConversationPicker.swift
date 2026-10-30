//
//  ConversationPicker.swift
//

import SwiftUI
import SMIClientCore

struct ConversationPicker: View {
    static var title: String = "Conversation List"

    @Environment(\.presentationMode) var presentationMode

    @StateObject var configStore: MIAWConfigurationStore = MIAWConfigurationStore()

    @State private var isFetching: Bool = false
    @State private var isError: Bool = false
    @State private var conversations: [Conversation]?
    @State private var error: NSError?
    @State private var isLocal = true
    @State private var isForceRefresh = false
    @State private var limit: UInt = 0
    @State private var labelConversation: Conversation?
    @State private var labelText = ""
    @State private var isEditingLabel = false
    @State private var toast: Toast?

    var body: some View {
        List {
            Group {
                Section(header: Text("Behaviour")) {
                    SettingsToggle("Use Local Cache", isOn: $isLocal)
                        .onChange(of: isLocal) {
                            fetch()
                        }
                    if !isLocal {
                        SettingsButton {
                            isForceRefresh = true
                            fetch()
                        } label: {
                            Text("Force Refresh")
                        }
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
        .onAppear(perform: {
            GlobalCoreDelegateHandler.shared.registerDelegates(CoreFactory.create(withConfig: configStore.config))
            fetch()
        })
        .navigationTitle(Self.title)
        .toastView(toast: $toast)
        .alert("Update Label", isPresented: $isEditingLabel, presenting: labelConversation) { conversation in
            TextField("Conversation Label", text: $labelText)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .accessibilityIdentifier("Conversation Label.input")

            Button("Cancel", role: .cancel) {}
                .accessibilityIdentifier("Cancel Label.button")

            Button("Update") {
                updateLabel(conversation)
            }
            .accessibilityIdentifier("Update Label.button")
        }
    }

    private func editLabel(_ conversation: Conversation) {
        labelConversation = conversation
        labelText = conversation.label ?? ""
        isEditingLabel = true
    }

    private func updateLabel(_ conversation: Conversation) {
        let client = CoreFactory.create(withConfig: configStore.config).conversationClient(with: conversation.identifier)
        if !labelText.isEmpty {
            client.update(label: labelText) { error in
                DispatchQueue.main.async {
                    if let error {
                        toast = Self.errorToast(for: error)
                    } else {
                        fetch()
                    }
                }
            }
        }
    }

    private static func errorToast(for error: Error) -> Toast {
        let nsError = error as NSError
        let underlyingError = nsError.userInfo[NSUnderlyingErrorKey] as? NSError
        let httpStatus = nsError.userInfo[errorNetworkHTTPResponseCode] as? Int
            ?? underlyingError?.userInfo[errorNetworkHTTPResponseCode] as? Int
        let httpText = httpStatus.map { String($0) } ?? "None"

        return Toast(style: .error, message: "\(nsError.domain) \(nsError.code)\nHTTP Status: \(httpText)", width: 320)
    }

    private func fetch() {
        isFetching = true
        isError = false
        error = nil
        conversations = nil

        let core = CoreFactory.create(withConfig: configStore.config)
        GlobalCoreDelegateHandler.shared.registerDelegates(core)
        let closure: ConversationQueryCompletion = { (conversations, error) in
            if error != nil {
                isError = true
                self.error = error as NSError?
                return
            }

            isFetching = false
            isForceRefresh = false
            self.conversations = conversations
        }

        if isLocal {
            core.conversations(withLimit: limit, sortedByActivityDirection: .descending, completion: closure)
        } else {
            core.conversations(withLimit: limit, olderThanConversation: nil, forceRefresh: isForceRefresh, completion: closure)
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
                VStack(alignment: .leading) {
                    ConversationView(conversation)
                        .onTapGesture {
                            configStore.conversationId = conversation.identifier.uuidString
                            presentationMode.wrappedValue.dismiss()
                        }

                    SettingsButton {
                        editLabel(conversation)
                    } label: {
                        Text("Edit Label")
                    }
                    .accessibilityHint("Updates the label on this conversation")
                    .accessibilityIdentifier("Edit Label.\(conversation.identifier.uuidString)")
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
    
    var conversationStatus: String {
        switch conversation.status {
        case .open:
            return "Active"
        case .closed:
            return "Closed"
        case .unknown:
            return "Unknown"
        @unknown default:
            return "Unknown"
        }
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
            row("Status:", value: conversation.status.description)
            row("Status:", value: conversationStatus)
            row("Label:", value: conversation.label ?? "")
        }
    }
}

#Preview {
    ConversationPicker()
}

extension ConversationStatus {
    var description: String {
        switch self {
        case .open:
            return "Active"
        case .closed:
            return "Closed"
        case .unknown:
            return "Unknown"
        @unknown default:
            return "Unknown"
        }
    }
}
