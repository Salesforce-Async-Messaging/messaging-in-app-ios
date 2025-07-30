//
//  ContentView.swift
//

import SwiftUI
import SMIClientUI
import SMIClientCore

struct ContentView: View {
    var body: some View {
        WrappedNavigationStack {
            List {
                Section(header: Text("Version Info")) {
                    Text("Core: \(CoreFactory.sdkVersion ?? "")")
                    Text("UI: \(Interface.sdkVersion ?? "")")
                }

                Section("Launch MIAW") {
                    NavigationLink("SwiftUI") {
                        MIAW()
                    }

                    NavigationLink("Custom URL Demo") {
                        UIKitMIAW()
                    }
                }
            }                
            .navigationTitle("Main Menu")
            .navigationBarTitleDisplayMode(.automatic)
            .wrappedNavigationBarItems {
                NavigationLink {
                    SettingsForm()
                } label: {
                    Text(SettingsForm.title)
                }
            }
        }
    }
}

struct MIAW: View {
    @StateObject var configStore: MIAWConfigurationStore = MIAWConfigurationStore()
    @StateObject var conversationManagementStore: ConversationManagementStore = ConversationManagementStore()
    @StateObject var uiReplacementStore: UIReplacementStore = UIReplacementStore()
    @StateObject var remoteLocaleStore: RemoteLocaleStore = RemoteLocaleStore()

    var body: some View {
        let config = UIConfiguration(configuration: configStore.config,
                                     conversationId: conversationManagementStore.conversationUUID,
                                     remoteLocaleMap: remoteLocaleStore.remoteLocaleMap,
                                     urlDisplayMode: configStore.URLDisplayMode)

        config.conversationOptionsConfiguration = ConversationOptionsConfiguration(allowEndChat: configStore.enableEndSessiontUI)
        config.transcriptConfiguration = TranscriptConfiguration(allowTranscriptDownload: configStore.enableTranscriptUI)
        config.attachmentConfiguration = AttachmentConfiguration(endUserToAgent: configStore.enableAttachmentUI)

        return Interface(config,
                         preChatFieldValueProvider: GlobalCoreDelegateHandler.shared.prePopulatedPreChatProvider.closure,
                         chatFeedViewBuilder: GlobalCoreDelegateHandler.shared.viewBuilder,
                         navigationBarBuilder: GlobalCoreDelegateHandler.shared.navBarBuilder)
        .onAppear(perform: {
            let client = CoreFactory.create(withConfig: config).conversationClient(with: conversationManagementStore.conversationUUID)
            GlobalCoreDelegateHandler.shared.registerDelegates(client)
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
