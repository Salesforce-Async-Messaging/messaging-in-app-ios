//
//  CarouselReplacement.swift
//  IAMessagingTestApp
//
//  Created by Jeremy Wright on 2024-07-11.
//  Copyright © 2024 Salesforce.com. All rights reserved.
//

import SwiftUI
import SMIClientCore
import SMIClientUI

struct CarouselReplacement: View {
    let model: ChatFeedModel
    let client: ConversationClient?
    let origin: EntryContainerReplacement.Origin

    var entry: ConversationEntry {
        guard let model = model as? ConversationEntryModel else { fatalError("Incorrect Model") }
        return model.entry
    }

    var payload: Carousel {
        guard let payload = entry.payload as? Carousel else { fatalError("Incompatable Entry") }
        return payload
    }

    var items: [TitleLinkItem] { payload.items ?? [] }

    init(_ model: ChatFeedModel, origin: EntryContainerReplacement.Origin, client: ConversationClient?) {
        self.model = model
        self.client = client
        self.origin = origin
    }

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 10) {
                ForEach(Array(items.enumerated()), id: \.offset) { _, content in
                    Text(content.titleItem.title)
                }
            }
        }
    }
}
