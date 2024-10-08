//
//  FormResultReplacement.swift
//  IAMessagingTestApp
//
//  Created by Jeremy Wright on 2024-07-24.
//  Copyright © 2024 Salesforce.com. All rights reserved.
//

import SwiftUI
import SMIClientCore
import SMIClientUI

struct FormResultReplacement: View {
    @EnvironmentObject var chatFeedProxy: ChatFeedProxy

    let model: ChatFeedModel
    let client: ConversationClient?
    let origin: EntryContainerReplacement.Origin

    var entry: ConversationEntry {
        guard let model = model as? ConversationEntryModel else { fatalError("Incorrect Model") }
        return model.entry
    }

    var payload: FormResult {
        guard let payload = entry.payload as? FormResult else { fatalError("Incompatable Entry") }
        return payload
    }

    init(_ model: ChatFeedModel, origin: EntryContainerReplacement.Origin, client: ConversationClient?) {
        self.model = model
        self.client = client
        self.origin = origin
    }

    var body: some View {
        TextReplacement(text: payload.resultType == .formRecordsResult ? "Form Submission Successful" : "Form Error", origin: origin)
    }
}
