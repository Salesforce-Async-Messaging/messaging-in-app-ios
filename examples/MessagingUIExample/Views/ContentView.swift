//
//  ContentView.swift
//

import SwiftUI
import SMIClientUI
import SMIClientCore

struct ContentView: View {
    @StateObject private var controller = MessagingController()
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Text("Messaging for In-App UI SDK Example")
                Spacer()
                VStack {
                    if let config = controller.uiConfig {
//                        NavigationLink(destination: Interface(config, preChatFieldValueProvider: setPreChatValues())) { // Set the pre populated pre-chat
                        NavigationLink(destination: Interface(config)) {
                            Text("Speak with an Agent")
                        }
                    }
                    Button("Reset Conversation ID") {
                        controller.resetConfig()
                    }
                }
                .buttonStyle(. bordered)
                .tint(.blue)
                Spacer()
            }
            .padding()
        }
    }

    // Pre set the pre-chat values
    private func setPreChatValues() -> (([PreChatField]) async throws -> [PreChatField]) { { prechatFields in
        prechatFields.enumerated().forEach { (index, value) in
            let currenPrechatName = value.name

            if currenPrechatName == "Name of the Pre-Chat field you would like to set" {
                prechatFields[index].value = "Set the value for the pre-chat fields"
                prechatFields[index].isEditable = false // Set it to true to make the pre-chat fields editable, or to false to make them non-editable
            }
        }

        return prechatFields
    }}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
