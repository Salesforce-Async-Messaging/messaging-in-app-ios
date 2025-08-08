//
//  RichLinkReplacement.swift
//  MessagingUIExample
//
//  Created by Jeremy Wright on 2024-07-11.
//  Copyright © 2024 Salesforce.com. All rights reserved.
//

import SwiftUI
import SMIClientCore
import SMIClientUI

struct RichLinkReplacement: View {
    let model: ChatFeedModel
    let client: ConversationClient?
    let origin: EntryContainerReplacement.Origin

    var entry: ConversationEntry {
        guard let model = model as? ConversationEntryModel else { fatalError("Incorrect Model") }
        return model.entry
    }

    var payload: RichLinkMessage {
        guard let payload = entry.payload as? RichLinkMessage else { fatalError("Incompatible Entry") }
        return payload
    }

    init(_ model: ChatFeedModel, origin: EntryContainerReplacement.Origin, client: ConversationClient?) {
        self.model = model
        self.client = client
        self.origin = origin
    }

    var body: some View {
        VStack(spacing: 0) {
            if let asset = payload.asset {
                ImageReplacement(asset: asset, borderColor: origin.color)
            }

            TextReplacement(text: payload.title, origin: origin)
            TextReplacement(text: payload.url?.host ?? "", origin: origin)
        }
    }
}
