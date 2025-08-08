//
//  SettingsForm.swift
//  MessagingUIExample
//
//  Created by Jeremy Wright on 2024-09-10.
//  Copyright © 2024 Salesforce.com. All rights reserved.
//

import SwiftUI
import SMIClientCore

struct SettingsForm: View {
    private enum Constants {
        static let reset = "Reset"
    }

    static let title = "Settings"

    static var configStore: MIAWConfigurationStore = MIAWConfigurationStore()
    static var conversationManagementStore: ConversationManagementStore = ConversationManagementStore()
    static var uiOverrideStore: UIOverrideStore = UIOverrideStore()
    static var userVerificationStore: UserVerificationStore = UserVerificationStore()
    static var demoManagementStore: DemoManagementStore = DemoManagementStore()
    static var loggingStore: LoggingStore = LoggingStore()
    static var delegateManagementStore: DelegateManagementStore = DelegateManagementStore()
    static var remoteLocaleMapStore: RemoteLocaleStore = RemoteLocaleStore()
    static var uiReplacementStore: UIReplacementStore = UIReplacementStore()

    @State private var toast: Toast?

    static func reset() {
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
    }

    func resetAndToast() {
        Self.reset()
        toast = Toast(style: .success, message: "Database and UI Settings reset", width: 320)
    }

    var body: some View {
        Form {
            MIAWConfigurationSettings(reset: resetAndToast)
            ConversationManagementSettings()
            DatabaseManagementSettings()
            DemoManagementSettings()
            DelegateManagementSettings()
            RemoteLocaleSettings()
            ReplacementSettings()
            UIOverrideSettings()
            LoggingSettings()
        }
        .wrappedKeyboardDismiss()
        .navigationTitle(Self.title)
        .wrappedNavigationBarItems {
            Button(action: resetAndToast, label: {
                Text(Constants.reset)
            })
        }
        .toastView(toast: $toast)
    }
}

#Preview {
    WrappedNavigationStack {
        SettingsForm()
    }
}
