//
//  DateBreakReplacement.swift
//  MessagingUIExample
//
//  Created by Jeremy Wright on 2024-07-22.
//  Copyright © 2024 Salesforce.com. All rights reserved.
//

import SwiftUI
import SMIClientCore
import SMIClientUI

struct DateBreakReplacement: View {
    @EnvironmentObject var chatFeedProxy: ChatFeedProxy

    let model: ChatFeedModel

    var date: Date {
        model.timestamp
    }

    init(_ model: ChatFeedModel) {
        self.model = model
    }

    var body: some View {
        TextReplacement(text: date.description, origin: .system).padding(10)
    }
}
