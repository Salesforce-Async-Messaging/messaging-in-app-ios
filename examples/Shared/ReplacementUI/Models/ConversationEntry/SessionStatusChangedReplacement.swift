//
//  SesssionStatusChangedReplacement.swift
//  MessagingUIExample
//
//  Created by Aaron Eisses on 2025-07-23.
//  Copyright © 2025 Salesforce.com. All rights reserved.
//

import SwiftUI
import SMIClientCore
import SMIClientUI

struct SesssionStatusChangedReplacement: View {
    let model: ChatFeedModel
    let client: ConversationClient?
    let origin: EntryContainerReplacement.Origin

    var entry: ConversationEntry {
        guard let model = model as? ConversationEntryModel else { fatalError("Incorrect Model") }
        return model.entry
    }

    var payload: SessionStatusChanged {
        guard let payload = entry.payload as? SessionStatusChanged else { fatalError("Incompatable Entry") }
        return payload
    }

    var text: String {
        return "CHAT ENDED!"
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
