//
//  PreChatReceiptReplacement.swift
//  MessagingUIExample
//
//  Created by Jeremy Wright on 2024-07-24.
//  Copyright © 2024 Salesforce.com. All rights reserved.
//

import SwiftUI
import SMIClientCore
import SMIClientUI

struct PreChatReceiptReplacement: View {
    @EnvironmentObject var chatFeedProxy: ChatFeedProxy

    let model: ChatFeedModel

    init(_ model: ChatFeedModel) {
        self.model = model
    }

    var body: some View {
        let origin = EntryContainerReplacement.Origin.local
        HStack {
            Spacer()
            Text("PreChat Receipt. Tap to view")
                .padding(5)
                .foregroundColor(Color(.systemRed))
                .overlay(
                    Border().stroke(Color(.systemRed), lineWidth: 1)
                )
                .frame(width: chatFeedProxy.screenSize.width * origin.widthModifier, alignment: origin.alignment)
        }
    }
}
