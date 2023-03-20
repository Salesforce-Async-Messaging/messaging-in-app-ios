//
//  MessagingController.swift
//

import SwiftUI
import SMIClientUI
import SMIClientCore

class MessagingController: NSObject, ObservableObject {

    @Published var uiConfig: UIConfiguration?

    override init() {
        super.init()
        self.resetConfig()
    }
    
    func resetConfig() {
        print("Initializing config file.")

        // This code uses a random UUID for the conversation ID, but
        // be sure to use the same ID if you want to continue the
        // same conversation after a restart.
        let conversationID = UUID()

        // TO DO: Replace the config file in this app (configFile.json)
        //        with the config file you downloaded from your Salesforce org.
        //        To learn more, see:
        // https://help.salesforce.com/s/articleView?id=sf.miaw_deployment_mobile.htm

        guard let configPath = Bundle.main.path(forResource: "configFile", ofType: "json") else {
            NSLog("Unable to find configFile.json file.")
            return
        }

        let configURL = URL(fileURLWithPath: configPath)

        // TO DO: Change the userVerificationRequired flag match the verification
        //        requirements of the endpoint.
        //        To learn more, see:
        // https://salesforce-async-messaging.github.io/messaging-in-app-ios/Classes/SMICoreConfiguration.html#/c:objc(cs)SMICoreConfiguration(py)userVerificationRequired
        // https://developer.salesforce.com/docs/service/messaging-in-app/guide/ios-user-verification.html
        let userVerificationRequired = false
        uiConfig = UIConfiguration(url: configURL,
                                   userVerificationRequired: userVerificationRequired,
                                   conversationId: conversationID)

        guard let config = uiConfig else { return }
        
        // Handle pre-chat requests with a HiddenPreChatDelegate implementation.
        CoreFactory.create(withConfig: config).setPreChatDelegate(delegate: self, queue: DispatchQueue.main)
        
        // Handle auto-response component requests with a TemplatedUrlDelegate implementation.
        CoreFactory.create(withConfig: config).setTemplatedUrlDelegate(delegate: self, queue: DispatchQueue.main)
        
        // Handle user verification requests with a UserVerificationDelegate implementation.
        CoreFactory.create(withConfig: config).setUserVerificationDelegate(delegate: self, queue: DispatchQueue.main)

        print("Config created using conversation ID \(conversationID.description).")
    }
}

/**
 Implementation of HiddenPreChatDelegate for hidden pre-chat.
 To learn more, see
 https://developer.salesforce.com/docs/service/messaging-in-app/guide/ios-pre-chat.html
 */
extension MessagingController: HiddenPreChatDelegate {
    // Invoked automatically when hidden pre-chat fields are being sent
    func core(_ core: CoreClient!,
              conversation: Conversation!,
              didRequestPrechatValues hiddenPreChatFields: [HiddenPreChatField]!,
              completionHandler: HiddenPreChatValueCompletion!) {

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

/**
 Implementation of TemplatedUrlDelegate for the auto-response component.
 To learn more, see
 https://developer.salesforce.com/docs/service/messaging-in-app/guide/ios-auto-response.html
 */
extension MessagingController: TemplatedUrlDelegate {
    // Invoked automatically when values are needed for a given TemplatedUrl
    func core(_ core: CoreClient!,
              didRequestTemplatedValues templatable: SMITemplateable!,
              completionHandler: URLParameterValueCompletion!) {

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

/**
 Implementation of UserVerificationDelegate for user verification.
 To learn more, see
 https://developer.salesforce.com/docs/service/messaging-in-app/guide/ios-user-verification.html
 */
extension MessagingController: UserVerificationDelegate {
    // Invoked automatically when credentials are required for authorizing a verified user
    func core(_ core: CoreClient,
              userVerificationChallengeWith reason: ChallengeReason,
              completionHandler completion: @escaping UserVerificationChallengeCompletion) {

        var token: String!

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

        completion(UserVerification(customerIdentityToken: token, type: .SMIAuthorizationTypeJWT))
    }
}
