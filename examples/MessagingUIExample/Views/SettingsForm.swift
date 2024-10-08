//
//  SettingsForm.swift
//  SMITestApp
//
//  Created by Jeremy Wright on 2024-09-10.
//

import SwiftUI
import SMIClientCore

struct SettingsForm: View {
    private enum Constants {
        static let reset = "Reset"
    }

    static let title = "Settings"

    @StateObject var configStore: MIAWConfigurationStore = MIAWConfigurationStore()
    @StateObject var conversationManagementStore: ConversationManagementStore = ConversationManagementStore()
    @StateObject var uiOverrideStore: UIOverrideStore = UIOverrideStore()
    @StateObject var userVerificationStore: UserVerificationStore = UserVerificationStore()
    @StateObject var demoManagementStore: DemoManagementStore = DemoManagementStore()
    @StateObject var loggingStore: LoggingStore = LoggingStore()
    @StateObject var delegateManagementStore: DelegateManagementStore = DelegateManagementStore()
    @StateObject var remoteLocaleMapStore: RemoteLocaleStore = RemoteLocaleStore()
    @StateObject var uiReplacementStore: UIReplacementStore = UIReplacementStore()

    var body: some View {
        Form {
            MIAWConfigurationSettings()
            ConversationManagementSettings()
            DatabaseManagementSettings()
            DemoManagementSettings()
            DelegateManagementSettings()
            RemoteLocaleSettings()
            UIReplacementSettings()
            UIOverrideSettings()
            LoggingSettings()
        }
        .wrappedKeyboardDismiss()
        .navigationTitle(Self.title)
        .wrappedNavigationBarItems {
            Button(action: {
                configStore.reset()
                conversationManagementStore.reset()
                uiOverrideStore.reset()
                userVerificationStore.reset()
                demoManagementStore.reset()
                loggingStore.reset()
                delegateManagementStore.reset()
                remoteLocaleMapStore.reset()
                uiReplacementStore.reset()

                CoreFactory.create(withConfig: configStore.config).destroyStorage(andAuthorization: true) { _ in }
            }, label: {
                Text(Constants.reset)
            })
        }
    }
}

#Preview {
    WrappedNavigationStack {
        SettingsForm()
    }
}
