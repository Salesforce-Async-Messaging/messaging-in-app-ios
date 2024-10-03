//
//  TextReplacement.swift
//  IAMessagingTestApp
//
//  Created by Jeremy Wright on 2024-07-22.
//  Copyright © 2024 Salesforce.com. All rights reserved.
//

import SwiftUI
import SMIClientCore
import SMIClientUI

struct TextReplacement: View {
    @EnvironmentObject var chatFeedProxy: ChatFeedProxy

    let text: String
    let origin: EntryContainerReplacement.Origin

    var body: some View {
        Text(text)
            .padding(5)
            .foregroundColor(origin.color)
            .overlay(
                Border().stroke(origin.color, lineWidth: 1)
            )
    }
}

