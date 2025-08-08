//
//  GlobalCoreDelegateHandler+HiddenPreChat.swift
//  MessagingUIExample
//
//  Created by Jeremy Wright on 2024-09-12.
//  Copyright © 2024 Salesforce.com. All rights reserved.
//

import Foundation
import SMIClientCore

extension GlobalCoreDelegateHandler: HiddenPreChatDelegate {
    func core(_ core: CoreClient, conversation: Conversation, didRequestPrechatValues hiddenPreChatFields: [HiddenPreChatField]) async -> [HiddenPreChatField] {
        for pair in delegateManagementStore.hiddenPreChatValues {
            hiddenPreChatFields.first(where: { $0.name == pair.key })?.value = pair.value
        }

        return hiddenPreChatFields
    }
}
