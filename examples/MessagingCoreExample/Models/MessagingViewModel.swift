//
//  MessagingViewModel.swift
//  MessagingCoreExample
//

import Foundation
import SMIClientCore
import SwiftUI

public class MessagingViewModel: NSObject {

    // Conversation client object
    var conversationClient: ConversationClient?

    // This code uses a random UUID for the conversation ID, but
    // be sure to use the same ID if you want to continue the
    // same conversation after a restart.
    var conversationID = UUID()
    
    // Core object
    private var coreClient: CoreClient?
    
    // Contains all the conversation entries
    @Published var observeableConversationData: ObserveableConversationEntries?

    init(observeableConversationData: ObserveableConversationEntries) {
        super.init()
        self.observeableConversationData = observeableConversationData
        
        // Turn on debug logging
        setDebugLogging()
        
        // Create a conversation client object
        createConversationClient()
    }

    // MARK: Public Functions

    /// Fetches all the conversation entries and updates the view.
    public func fetchAndUpdateConversation() {
        retrieveAllConversationEntries(completion: { messages in
            if let messages = messages {
                DispatchQueue.main.async {
                    self.observeableConversationData?.conversationEntries = []
                    for message in messages.reversed() {
                        self.observeableConversationData?.conversationEntries.append(message)
                    }
                }
            }
        })
    }

    /// Sends a message to the agent.
    public func sendTextMessage(message: String) {
        conversationClient?.send(message: message)
    }

    /// Sends an image to the agent.
    public func sendImageMessage(image: Data, fileName: String) {
        conversationClient?.send(image: image, fileName: fileName)
    }

    /// Sends a PDF file to the agent.
    public func sendPDFMessage(pdf: PDFDocument) {
        conversationClient?.send(pdf: pdf)
    }

    /// Sends a choice reply to the agent.
    public func sendChoiceReply(choice: Choice) {
        conversationClient?.send(reply: choice)
    }

    /// Sends a request to get the chat transcript.
    public func retreiveTranscript() {
        conversationClient?.retrieveTranscript { document, error in
            if error != nil {
                print("Failed to retreive the chat transcript")
                return
            }

            guard let pdfData = document?.dataRepresentation() else {
                return
            }
            let activityViewController = UIActivityViewController(activityItems: [pdfData], applicationActivities: nil)
            let keyWindow = UIApplication.shared.windows.first(where: {$0.isKeyWindow})

            if var topController = keyWindow?.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                topController.present(activityViewController, animated: true)
            }
        }
    }

    /// Resets the conversation ID and creates a new conversation.
    public func resetChat() {
        self.conversationID = UUID()
        observeableConversationData?.conversationEntries = []
        createConversationClient()
    }

    /// This is an example on how you would retrieve the business hours from your config,
    /// you can then check if your current time is within the retrieved business hours.
    public func checkIfWithinBusinessHours(completion: @escaping (Bool, Bool) -> ()) {
        coreClient?.retrieveBusinessHours(completion: { (businessHours, error) in
            guard let isWithinBusinessHours = businessHours?.isWithinBusinessHours(comparisonTime: Date()),
                  error == nil else {
                print("Business hours may not be configured!")
                completion(false, false)
                return
            }
            completion(isWithinBusinessHours, true)
        })
    }

    /// This method allows you to retrieve all conversations from core.
    public func retrieveConversationList(completion: @escaping ([Conversation]) -> ()) {
        coreClient?.conversations(withLimit: 0, sortedByActivityDirection: .descending) { (conversations, error) in
            guard let conversations = conversations else { return }
            completion(conversations)
        }
    }

    // MARK: Private Functions

    /// Creates a conversation client object after setting up the config object.
    private func createConversationClient() {
        
        // TO DO: Replace the config file in this app (configFile.json)
        //        with the config file you downloaded from your Salesforce org.
        //        To learn more, see:
        // https://help.salesforce.com/s/articleView?id=sf.miaw_deployment_mobile.htm

        guard let configPath = Bundle.main.path(forResource: "configFile", ofType: "json") else {
            print("Unable to find configFile.json file.")
            return
        }
        
        let configURL = URL(fileURLWithPath: configPath)

        // TO DO: Change the userVerificationRequired flag match the verification
        //        requirements of the endpoint.
        //        To learn more, see:
        // https://developer.salesforce.com/docs/service/messaging-in-app/guide/ios-user-verification.html
        let userVerificationRequired = false
        
        guard let config = Configuration(url: configURL,
                                         userVerificationRequired: userVerificationRequired) else {
            print("Unable to create Configuration object.")
            return
        }

        // Create core client
        coreClient = CoreFactory.create(withConfig: config)

        // Start listening for events
        coreClient?.start()

        // Handle pre-chat requests with a HiddenPreChatDelegate implementation
        CoreFactory.create(withConfig: config).setPreChatDelegate(delegate: self, queue: DispatchQueue.main)

        // Handle auto-response component requests with a TemplatedUrlDelegate implementation
        CoreFactory.create(withConfig: config).setTemplatedUrlDelegate(delegate: self, queue: DispatchQueue.main)

        // Handle user verification requests with a UserVerificationDelegate implementation
        CoreFactory.create(withConfig: config).setUserVerificationDelegate(delegate: self, queue: DispatchQueue.main)

        // Handle error messages from the SDK
        CoreFactory.create(withConfig: config).addDelegate(delegate: self)

        // Create the conversation client
        conversationClient = coreClient?.conversationClient(with: self.conversationID)

        // Retrieve and submit any PreChat fields
        getPreChatFieldsFromConfig(completion: { preChatFields in
            self.submitPreChatFields(preChatFields: preChatFields)
        })
    }

    /// Retrieves all conversation entries from the current conversation.
    private func retrieveAllConversationEntries(completion: @escaping ([ConversationEntry]?) -> ()) {
        conversationClient?.entries(withLimit: 0, fromTimestamp: nil, direction: .descending, behaviour: .localWithNetwork, completion: { messages, _, _ in
            completion(messages)
        })
    }

    /// Retrieves pre-chat fields from the remote config.
    private func getPreChatFieldsFromConfig(completion: @escaping ([PreChatField]?) -> ()) {
        coreClient?.retrieveRemoteConfiguration(completion: { remoteConfig, error in
            if let preChatFields = remoteConfig?.preChatConfiguration?.first?.preChatFields {
                completion(preChatFields)
            }
        })
    }

    /// This is an example of how you would assign values to
    /// your pre-chat fields. You would need to create your own
    /// UI to get values from a user and then map them to the
    /// pre-chat values. You would then submit the pre-chat
    /// fields to Salesforce.
    private func submitPreChatFields(preChatFields: [PreChatField]?) {
        guard let preChatFields = preChatFields else { return }

        for preChatField in preChatFields {
            if preChatField.isRequired {
                preChatField.value = "value"
            }
        }

        // You can choose to create the conversation when submiting
        // pre-chat values, otherwise the conversation will be started
        // after sending the first message.
        self.conversationClient?.submit(preChatFields: preChatFields, hiddenPreChatFields: [], createConversationOnSubmit: true)
    }

    /// Sets the debug level to see more logs in the console.
    private func setDebugLogging() {
        #if DEBUG
            Logging.level = .debug
        #endif
    }
}
