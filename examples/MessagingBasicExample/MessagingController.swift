//
//  MessagingController.swift
//

import SwiftUI
import SMIClientUI

class MessagingController: ObservableObject {
    @Published var uiConfig: UIConfiguration?
    
    init() {
        resetConfig()
    }
    
    func resetConfig() {
        NSLog("Initializing config file.")
        
        // TO DO: Replace the config file in this app (configFile.json)
        //        with the config file you downloaded from your Salesforce org.
        //        To learn more, see https://help.salesforce.com/s/articleView?id=sf.miaw_deployment_mobile.htm

        guard let configPath = Bundle.main.path(forResource: "configFile",
                                                ofType: "json") else {
            NSLog("Unable to find configFile.json file.")
            return
        }

        let conversationID = UUID()
        let configURL = URL(fileURLWithPath: configPath)
        uiConfig = UIConfiguration(url: configURL, conversationId: conversationID)
        NSLog("Config created using conversation ID \(conversationID.description).")
    }
}
