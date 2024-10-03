//
//  ListPickerReplacement.swift
//  IAMessagingTestApp
//
//  Created by Jeremy Wright on 2024-07-11.
//  Copyright © 2024 Salesforce.com. All rights reserved.
//

import SwiftUI
import SMIClientCore
import SMIClientUI

struct ListPickerReplacement: View {
    @EnvironmentObject var chatFeedProxy: ChatFeedProxy

    let model: ChatFeedModel
    let client: ConversationClient?
    let origin: EntryContainerReplacement.Origin

    var entry: ConversationEntry {
        guard let model = model as? ConversationEntryModel else { fatalError("Incorrect Model") }
        return model.entry
    }

    var payload: ListPicker {
        guard let payload = entry.payload as? ListPicker else { fatalError("Incompatable Entry") }
        return payload
    }

    var disabled: Bool { payload.selected != nil }
    var foregroundColor: Color { disabled ? Color(.lightGray) : origin.color }

    init(_ model: ChatFeedModel, origin: EntryContainerReplacement.Origin, client: ConversationClient?) {
        self.model = model
        self.client = client
        self.origin = origin
    }

    var body: some View {
        HStack {
            VStack(alignment: origin.horizontalAlignment, spacing: 0) {
                header
                ForEach(payload.choices, id: \.optionId) { choice in
                    row(choice)
                }
            }
            .frame(maxWidth: chatFeedProxy.screenSize.width * origin.widthModifier)
            .overlay(
                Border().stroke(foregroundColor, lineWidth: 1)
            )
            Spacer()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(payload.text)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)
                .foregroundColor(origin.color)
                .padding([.all], 5)

            Divider()
                .frame(height: 1)
                .background(foregroundColor)
        }
    }

    private func row(_ choice: Choice) -> some View {
        let selected = disabled && payload.selected?.contains(where: {$0.optionId == choice.optionId}) ?? false

        let backgroundColor: Color = {
            return selected ? Color(.lightGray) : .clear
        }()

        let fontColor = {
            return selected ? .white : foregroundColor
        }()

        return VStack(spacing: 0) {
            Button(action: {
                client?.send(reply: choice)
            }) {
                Text(choice.title)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity)
                    .padding([.all], 5)
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 40)
            .disabled(disabled)
            .background(backgroundColor)
            .foregroundColor(fontColor)

            Divider()
                .frame(height: 1)
                .background(fontColor)
        }
    }
}
