//
//  GlobalCoreDelegateHandler+HiddenPreChat.swift
//  SMITestApp
//
//  Created by Jeremy Wright on 2024-09-12.
//

import Foundation
import SMIClientCore

extension GlobalCoreDelegateHandler: HiddenPreChatDelegate {
    func core(_ core: CoreClient, conversation: Conversation, didRequestPrechatValues hiddenPreChatFields: [HiddenPreChatField]) async -> [HiddenPreChatField] {
        return hiddenPreChatFields
    }
}
