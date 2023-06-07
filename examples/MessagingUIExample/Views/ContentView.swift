//
//  ContentView.swift
//

import SwiftUI
import SMIClientUI

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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
