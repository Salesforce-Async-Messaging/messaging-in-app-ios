//
//  MessaingViewModel+UserVerifictionDelegate.swift
//  MessagingCoreExample
//

import Foundation
import SMIClientCore

/**
 Implementation of UserVerificationDelegate for user verification.
 To learn more, see
 https://developer.salesforce.com/docs/service/messaging-in-app/guide/ios-user-verification.html
 */
extension MessagingViewModel: UserVerificationDelegate {

    /// Invoked automatically when credentials are required for authorizing a verified user.
    public func core(_ core: CoreClient,
              userVerificationChallengeWith reason: ChallengeReason,
              completionHandler completion: @escaping UserVerificationChallengeCompletion) {

        var token: String!

        // TO DO: Fill in all <YOUR_CUSTOMER_IDENTITY_TOKEN> fields with a valid identity token.
        switch reason {
            // Salesforce doesn't currently have your customer identity token.
            // Please provide one now.
        case .initial: token = "<YOUR_CUSTOMER_IDENTITY_TOKEN>"

            // Salesforce needs to renew this user's authorization token.
            // Please provide a customer identity token.
            // Note: If your current token is nearing expiry, it may make sense to issue a new token at this time.
        case .refresh: token = "<YOUR_CUSTOMER_IDENTITY_TOKEN>"

            // The current customer identity token you've provided has expired.
            // Please provide a newly issued customer identity token.
        case .expired: token = "<YOUR_NEW_CUSTOMER_IDENTITY_TOKEN>"

            // Something is wrong with the token you provided.
            // Log an error and perhaps retry with a newly issued customer identity token.
        case .malformed: token = "<YOUR_CORRECTED_CUSTOMER_IDENTITY_TOKEN>"

        default: print("nothing to do")
        }

        completion(UserVerification(customerIdentityToken: token, type: .JWT))
    }
}
