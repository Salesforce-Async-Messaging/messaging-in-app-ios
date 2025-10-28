//
//  GlobalCoreDelegateHandler.swift
//  MessagingUIExample
//
//  Created by Jeremy Wright on 2024-09-12.
//  Copyright © 2024 Salesforce.com. All rights reserved.
//

import Foundation
import SMIClientCore
import SalesforceSDKCore

@objc class GlobalCoreDelegateHandler: NSObject {
    static let shared = GlobalCoreDelegateHandler()

    let viewBuilder: TestEntryViewBuilder = TestEntryViewBuilder()
    let navBarBuilder: TestNavBarBuilder = TestNavBarBuilder()
    let prePopulatedPreChatProvider: TestPrePopulatedPreChatProvider = TestPrePopulatedPreChatProvider()
    let userVerificationStore: UserVerificationStore = UserVerificationStore()
    let passthroughVerificationStore: PassthroughVerificationStore = PassthroughVerificationStore()
    let uiReplacementStore: UIReplacementStore = UIReplacementStore()
    let navBarReplacementStore: NavBarReplacementStore = NavBarReplacementStore()
    let delegateManagementStore: DelegateManagementStore = DelegateManagementStore()
    let configStore: MIAWConfigurationStore = MIAWConfigurationStore()
    var client: ConversationClient?

    func registerDelegates(_ core: CoreClient?) {
        core?.setPreChatDelegate(delegate: self, queue: .main)
        core?.setTemplatedUrlDelegate(delegate: self, queue: .main)
        core?.setUserVerificationDelegate(delegate: self, queue: .main)
    }

    func registerDelegates(_ client: ConversationClient) {
        registerDelegates(client.core)

        self.client = client
        navBarBuilder.client = client
        self.client?.addDelegate(delegate: self, queue: .main)
    }
}
