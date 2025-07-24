//
//  QueuePositionReplacement.swift
//  SMITestApp
//
//  Created by Aaron Eisses on 2025-07-23.
//

import SwiftUI
import SMIClientCore
import SMIClientUI

struct QueuePositionReplacement: View {
    @EnvironmentObject var chatFeedProxy: ChatFeedProxy

    let model: ChatFeedModel

    var entry: ConversationEntry {
        guard let queueModel = model as? QueuePositionModel else { fatalError("Incorrect Model") }
        return queueModel.entry
    }

    var text: String {
        if let entry = entry.payload as? QueuePosition {
            let progress = entry.position
            return "Position: " + String(progress)
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
