//
//  ContentView.swift
//

import SwiftUI
import SMIClientUI

struct ContentView: View {
    @StateObject private var controller = MessagingController()
    
    var body: some View {
        
        NavigationView {
            VStack(spacing: 16.0) {
                if controller.uiConfig != nil {
                    NavigationLink(destination: Interface(controller.uiConfig!)) {
                        Text("Speak with an Agent")
                    }
                }
                Button("Reset Conversation ID") {
                    controller.resetConfig()
                }
            }
            .navigationTitle("Messaging Example")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
