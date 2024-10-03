//
//  AttachmentReplacement.swift
//  IAMessagingTestApp
//
//  Created by Jeremy Wright on 2024-07-11.
//  Copyright © 2024 Salesforce.com. All rights reserved.
//

import Foundation

import SwiftUI
import SMIClientCore
import SMIClientUI

struct AttachmentReplacement: View {
    @EnvironmentObject var chatFeedProxy: ChatFeedProxy
    @State var image: UIImage?

    let model: ChatFeedModel
    let client: ConversationClient?
    let origin: EntryContainerReplacement.Origin

    var entry: ConversationEntry {
        guard let model = model as? ConversationEntryModel else { fatalError("Incorrect Model") }
        return model.entry
    }

    var payload: AttachmentEntry {
        guard let payload = entry.payload as? AttachmentEntry else { fatalError("Incompatible Entry") }
        return payload
    }

    init(_ model: ChatFeedModel, origin: EntryContainerReplacement.Origin, client: ConversationClient?) {
        self.model = model
        self.client = client
        self.origin = origin
    }

    var body: some View {
        if let asset = payload.attachments.first as? ImageAsset {
            VStack(alignment: entry.sender.isLocal ? .trailing : .leading) {
                HStack {
                    let borderColor = entry.sender.isLocal ? Color(.systemGreen) : Color(.systemBlue)

                    if entry.sender.isLocal {
                        Spacer()
                    }

                    ImageReplacement(asset: asset, borderColor: borderColor)

                    if !entry.sender.isLocal {
                        Spacer()
                    }
                }
            }
        }
    }
}
