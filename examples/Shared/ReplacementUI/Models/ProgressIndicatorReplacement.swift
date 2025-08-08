//
//  ProgressIndictorReplacement.swift
//  MessagingUIExample
//
//  Created by Aaron Eisses on 2025-01-22.
//  Copyright © 2025 Salesforce.com. All rights reserved.
//

import SwiftUI
import SMIClientCore
import SMIClientUI

struct ProgressIndicatorReplacement: View {
    @EnvironmentObject var chatFeedProxy: ChatFeedProxy

    let model: ChatFeedModel

    var entry: ConversationEntry {
        guard let progressModel = model as? ProgressIndicatorModel else { fatalError("Incorrect Model") }
        return progressModel.entry
    }

    var text: String {
        if let entry = entry.payload as? ProgressIndicator {
            if let progressMessage = entry.progressMessage as? EntryFormatText {
                return progressMessage.text as String
            }
        }
        return "Unknown"
    }

    init(_ model: ChatFeedModel) {
        self.model = model
    }

    var body: some View {
        TextReplacement(text: text, origin: .system).padding(10)
    }
}
