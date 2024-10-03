//
//  TextMessageReplacement.swift
//  IAMessagingTestApp
//
//  Created by Jeremy Wright on 2024-07-11.
//  Copyright © 2024 Salesforce.com. All rights reserved.
//

import SwiftUI
import SMIClientCore
import SMIClientUI

struct TextMessageReplacement: View {
    let model: ChatFeedModel
    let origin: EntryContainerReplacement.Origin

    var entry: ConversationEntry {
        guard let model = model as? ConversationEntryModel else { fatalError("Incorrect Model") }
        return model.entry
    }

    var payload: TextMessage {
        guard let payload = entry.payload as? TextMessage else { fatalError("Incompatable Entry") }
        return payload
    }

    init(_ model: ChatFeedModel, origin: EntryContainerReplacement.Origin) {
        self.model = model
        self.origin = origin
    }

    var body: some View {
        TextReplacement(text: payload.text, origin: origin)
    }
}
