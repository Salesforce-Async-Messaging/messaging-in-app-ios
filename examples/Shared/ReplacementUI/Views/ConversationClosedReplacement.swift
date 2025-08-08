//
//  ConversationClosedReplacement.swift
//  MessagingUIExample
//
//  Created by Aaron Eisses on 2025-05-29.
//  Copyright © 2025 Salesforce.com. All rights reserved.
//

import SwiftUI
import SMIClientCore
import SMIClientUI

struct ConversationClosedReplacement: View {
    let model: ChatFeedModel
    
    init(_ model: ChatFeedModel) {
        self.model = model
    }
    
    var body: some View {
        VStack() {
            Text("This is a custom replacement for the conversation closed state. You can customize this view to match your app's design and UX requirements.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
} 
