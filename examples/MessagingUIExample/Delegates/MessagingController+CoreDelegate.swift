//
//  MessagingController+CoreDelegate.swift
//

import Foundation
import SMIClientCore

/**
 Implementation of the CoreDelegate
 To learn more, see
 https://developer.salesforce.com/docs/service/messaging-in-app/guide/ios-core-sdk.html#listen-for-events
 */
extension MessagingController: CoreDelegate {
    // Called when errors are returned from the SDK.
    func core(_ core: CoreClient, didError error: Error) {
        print("ERROR: " + error.localizedDescription)
    }
}
