//
//  MessageViewModel+TemplatedUrlDelegate.swift
//  MessagingCoreExample
//

import Foundation
import SMIClientCore

/**
 Implementation of TemplatedUrlDelegate for the auto-response component.
 To learn more, see
 https://developer.salesforce.com/docs/service/messaging-in-app/guide/ios-auto-response.html
 */
extension MessagingViewModel: TemplatedUrlDelegate {

    /// Invoked automatically when values are needed for a given TemplatedUrl.
    public func core(_ core: CoreClient,
                     didRequestTemplatedValues templatable: SMITemplateable,
                     completionHandler: URLParameterValueCompletion) {

        for key in templatable.keys {
            switch key {
            case "<YOUR_PATH_KEY>": templatable.setValue("<YOUR_PATH_VALUE>", forKey: key)
            case "<YOUR_QUERY_KEY>": templatable.setValue("<YOUR_QUERY_VALUE>", forKey: key)
            default: print("Unknown template key: \(key)")
            }
        }

        completionHandler(templatable)
    }
}
