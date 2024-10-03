//
//  TypingIndicatorReplacement.swift
//  IAMessagingTestApp
//
//  Created by Jeremy Wright on 2024-07-22.
//  Copyright © 2024 Salesforce.com. All rights reserved.
//

import SwiftUI
import SMIClientCore
import SMIClientUI

struct TypingIndicatorReplacement: View {
    @EnvironmentObject var chatFeedProxy: ChatFeedProxy

    let model: ChatFeedModel

    var payloads: [ConversationEntry] {
        guard let typingModel = model as? TypingIndicatorModel else { fatalError("Incorrect Model") }
        return typingModel.entries
    }

    var text: String {
        "\(payloads.first?.sender.displayName ?? "Unknown") is typing..."
    }

    init(_ model: ChatFeedModel) {
        self.model = model
    }

    var body: some View {
        TextReplacement(text: text, origin: .system).padding(10)
    }
}
