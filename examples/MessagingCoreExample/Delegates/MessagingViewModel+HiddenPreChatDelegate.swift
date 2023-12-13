//
//  MessagingViewModel+HiddenPreChatDelegate.swift
//  MessagingCoreExample
//

import Foundation
import SMIClientCore

/**
 Implementation of HiddenPreChatDelegate for hidden pre-chat.
 To learn more, see
 https://developer.salesforce.com/docs/service/messaging-in-app/guide/ios-pre-chat.html
 */
extension MessagingViewModel: HiddenPreChatDelegate {

    /// Invoked automatically when hidden pre-chat fields are being sent.
    public func core(_ core: CoreClient,
                     conversation: Conversation,
                     didRequestPrechatValues hiddenPreChatFields: [HiddenPreChatField],
                     completionHandler: HiddenPreChatValueCompletion) {

        for it in hiddenPreChatFields {
            switch it.name {
            case "<YOUR_HIDDEN_FIELD1": it.value = "<YOUR_HIDDEN_VALUE1>"
            case "<YOUR_HIDDEN_FIELD2>": it.value = "<YOUR_HIDDEN_VALUE2>"
            default: print("Unknown hidden prechat field: \(it.name)")
            }
        }

        completionHandler(hiddenPreChatFields)
    }
}
