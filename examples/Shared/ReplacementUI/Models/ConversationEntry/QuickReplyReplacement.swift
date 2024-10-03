//
//  QuickReplyReplacement.swift
//  IAMessagingTestApp
//
//  Created by Jeremy Wright on 2024-07-11.
//  Copyright © 2024 Salesforce.com. All rights reserved.
//

import SwiftUI
import SMIClientCore
import SMIClientUI

struct QuickReplyReplacement: View {
    @EnvironmentObject var chatFeedProxy: ChatFeedProxy

    let model: ChatFeedModel
    let client: ConversationClient?
    let origin: EntryContainerReplacement.Origin

    var entry: ConversationEntry {
        guard let model = model as? ConversationEntryModel else { fatalError("Incorrect Model") }
        return model.entry
    }

    var payload: QuickReply {
        guard let payload = entry.payload as? QuickReply else { fatalError("Incompatible Entry") }
        return payload
    }

    init(_ model: ChatFeedModel, origin: EntryContainerReplacement.Origin, client: ConversationClient?) {
        self.model = model
        self.client = client
        self.origin = origin
    }

    var body: some View {
        VStack(alignment: origin.horizontalAlignment, spacing: 5) {
            TextReplacement(text: payload.text, origin: .remote)

            Divider().frame(width: chatFeedProxy.screenSize.width * origin.widthModifier)

            if payload.selected == nil {
                ScrollView(.horizontal) {
                    HStack(spacing: 10) {
                        ForEach(payload.choices, id: \.optionId) { choice in
                            Button(action: {
                                client?.send(reply: choice)
                            }) {
                                TextReplacement(text: choice.title, origin: origin)
                            }
                        }
                    }
                }
            }
        }
    }
}
