//
//  ContentView.swift
//  MessagingCoreExample
//

import SwiftUI
import SMIClientCore

class ObserveableConversationEntries: ObservableObject {
    @Published var conversationEntries: [ConversationEntry] = []
}

struct ContentView: View {
    @State private var isChatFeedHidden = true
    @State private var messageInputText: String
    @State private var businessHoursMessage: String?
    @State private var shouldHideBusinessHoursBanner: Bool = true
    @State private var isWithinBusinessHours: Bool = false
    @ObservedObject var observeableConversationData: ObserveableConversationEntries
    var viewModel: MessagingViewModel

    init(isChatFeedHidden: Bool = true, messageInputText: String = "") {
        self.isChatFeedHidden = isChatFeedHidden
        self.messageInputText = messageInputText
        let observableEntries = ObserveableConversationEntries()
        self.observeableConversationData = observableEntries
        self.viewModel = MessagingViewModel(observeableConversationData: observableEntries)
    }

    var body: some View {
        if !isChatFeedHidden {
            ChatFeed
        } else {
            ChatMenu
        }
    }

    private var ChatMenu: some View {
        VStack {
            Spacer()
            Text("Messaging for In-App Core SDK Example")
            Spacer()
            VStack {
                Button("Speak with an Agent") {
                    isChatFeedHidden.toggle()
                    viewModel.fetchAndUpdateConversation()
                }
                Button("Reset Conversation ID") {
                    viewModel.resetChat()
                }
                Button("Retrieve Transcript") {
                    viewModel.retrieveTranscript()
                }
            }
            .buttonStyle(. bordered)
            .tint(.blue)
            Spacer()
        }
        .padding()
    }

    private var ChatFeed: some View {
        VStack {
            VStack {
                Text(businessHoursMessage ?? "Not within business hours")
                .frame(maxWidth: .infinity, alignment: .center)
                .background(isWithinBusinessHours ? Color.green : Color.red)
            }
            .isHidden(shouldHideBusinessHoursBanner, remove: shouldHideBusinessHoursBanner)

            ChatFeedList
            .onAppear {
                viewModel.checkIfWithinBusinessHours(completion: { (isWithinBusinessHours, isBusinessHoursConfigured) in
                    self.shouldHideBusinessHoursBanner = !isBusinessHoursConfigured
                    self.isWithinBusinessHours = isWithinBusinessHours
                    businessHoursMessage = isWithinBusinessHours ? "You are within business hours" : "You are not within business hours"
                })
            }
            HStack {
                TextField("Type a Message", text: $messageInputText)
                Button("SEND") {
                    viewModel.sendTextMessage(message: messageInputText.description)
                    messageInputText = ""
                }.disabled(messageInputText.count == 0)
            }
            .padding([.leading, .trailing], 5)
            .buttonStyle(.bordered)
            .tint(.blue)
            Button("BACK") {
                isChatFeedHidden.toggle()
            }
            .buttonStyle(.bordered)
            .tint(.blue)
        }
    }

    private var ChatFeedList: some View {
        ScrollView {
            LazyVStack {
                ForEach(observeableConversationData.conversationEntries, id: \.identifier) { message in
                    // TO DO: Handle each messaging type that applies to your implementation here.
                    switch message.format {
                    case .attachments:
                        Text("Handle attachments")
                    case .imageMessage:
                        Text("Handle image messages")
                    case .listPicker:
                        Text("Handle list pickers")
                    case .quickReplies:
                        Text("Handle quick replies")
                    case .richLink:
                        Text("Handle rich links")
                    case .selections:
                        Text("Handle selections")
                    case .unspecified:
                        switch message.type {
                        case .participantChanged:
                            Text("Handle participantChanged")
                        case .typingIndicator:
                            Text("Handle typingIndicator")
                        case .routingResult:
                            Text("Handle routingResult")
                        default:
                            Text("Handle unspecified")
                        }
                    case .webView:
                        Text("Handle webView")
                    case .textMessage:
                        if let textMessage = message.payload as? TextMessage {
                            TextMessageCell(text: textMessage.text, role: message.sender.role)
                        }
                    default:
                        Text("Unhandled type")
                    }
                }
            }
        }.padding(.top, 1)
    }

    private struct TextMessageCell: View {
        @State var text: String
        @State var role: ParticipantRole

        var body: some View {
            TextMessage
        }

        @ViewBuilder
        var TextMessage: some View {
            VStack {
                switch role {
                case .agent, .chatbot:
                    Text(role.rawValue + ": " + text)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding([.all], 5)
                case .user:
                    Text(role.rawValue + ": " + text)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding([.all], 5)
                default:
                    Text(text)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding([.all], 5)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension View {
    @ViewBuilder func isHidden(_ hidden: Bool, remove: Bool = false) -> some View {
        if hidden {
            if !remove {
                self.hidden()
            }
        } else {
            self
        }
    }
}
