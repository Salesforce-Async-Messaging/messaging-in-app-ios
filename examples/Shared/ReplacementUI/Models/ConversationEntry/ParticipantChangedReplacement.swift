//
//  ParticipantChangedReplacement.swift
//  IAMessagingTestApp
//
//  Created by Jeremy Wright on 2024-07-11.
//  Copyright © 2024 Salesforce.com. All rights reserved.
//

import SwiftUI
import SMIClientCore
import SMIClientUI

struct ParticipantChangedReplacement: View {
    let model: ChatFeedModel
    let client: ConversationClient?
    let origin: EntryContainerReplacement.Origin

    var entry: ConversationEntry {
        guard let model = model as? ConversationEntryModel else { fatalError("Incorrect Model") }
        return model.entry
    }

    var payload: ParticipantChanged {
        guard let payload = entry.payload as? ParticipantChanged else { fatalError("Incompatable Entry") }
        return payload
    }

    var text: String {
        guard let operation = payload.operations.first else { return "" }
        let action = operation.type == .add ? "joined" : "left"
        return "\(operation.displayName) has \(action) the conversation."
    }

    init(_ model: ChatFeedModel, origin: EntryContainerReplacement.Origin, client: ConversationClient?) {
        self.model = model
        self.client = client
        self.origin = origin
    }

    var body: some View {
        TextReplacement(text: text, origin: .system).padding(10)
    }
}
