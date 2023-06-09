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
        self.setDebugLogging()
    }
    
    func resetConfig() {
        print("Initializing config file.")


        // TO DO: Replace the config file in this app (configFile.json)
        //        with the config file you downloaded from your Salesforce org.
        //        To learn more, see:
        // https://help.salesforce.com/s/articleView?id=sf.miaw_deployment_mobile.htm

        guard let configPath = Bundle.main.path(forResource: "configFile", ofType: "json") else {
            print("Unable to find configFile.json file.")
            return
        }

        let configURL = URL(fileURLWithPath: configPath)

        // This code uses a random UUID for the conversation ID, but
        // be sure to use the same ID if you want to continue the
        // same conversation after a restart.
        let conversationID = UUID()
        
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

        // Handle error messages from the SDK.
        CoreFactory.create(withConfig: config).addDelegate(delegate: self)

        print("Config created using conversation ID \(conversationID.description).")
    }

    /// Sets the debug level to see more logs in the console.
    private func setDebugLogging() {
        #if DEBUG
            Logging.level = .debug
        #endif
    }
}
