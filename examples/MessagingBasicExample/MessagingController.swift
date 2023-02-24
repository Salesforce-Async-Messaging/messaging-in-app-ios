//
//  MessagingController.swift
//

import SwiftUI
import SMIClientUI

// TO DO: Replace this config value with a values from your Salesforce org.
enum Constants {
    static let organizationId: String = "TBD"
    static let developerName: String = "TBD"
    static let url: String = "https://TBD.salesforce-scrt.com"
}

class MessagingController: ObservableObject {

    @Published var uiConfig: UIConfiguration?

    init() {
        resetConfig()
    }
    
    func resetConfig() {
        let conversationID = UUID()

        guard let url = URL(string: Constants.url) else {
            return
        }

        uiConfig = UIConfiguration(serviceAPI: url,
                                   organizationId: Constants.organizationId,
                                   developerName: Constants.developerName,
                                   conversationId:conversationID )
        
        NSLog("Config created using conversation ID \(conversationID.description).")
    }
}
