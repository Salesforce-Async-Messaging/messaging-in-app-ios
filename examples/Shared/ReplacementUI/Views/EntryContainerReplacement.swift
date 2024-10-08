//
//  EntryContainerReplacement.swift
//  IAMessagingTestApp
//
//  Created by Jeremy Wright on 2024-07-26.
//  Copyright © 2024 Salesforce.com. All rights reserved.
//

import SwiftUI
import SMIClientCore
import SMIClientUI

struct EntryContainerReplacement: View {
    @EnvironmentObject var chatFeedProxy: ChatFeedProxy

    let model: ChatFeedModel
    let client: ConversationClient?

    var entry: ConversationEntry {
        guard let model = model as? ConversationEntryModel else { fatalError("Incorrect Model") }
        return model.entry
    }

    var origin: Origin {
        if entry.sender.role == .system {
            return .system
        } else if entry.sender.isLocal {
            return .local
        } else {
            return .remote
        }
    }

    var body: some View {
        HStack {
            if origin == .local {
                Spacer()
            }

            VStack(alignment: origin.horizontalAlignment) {
                resolveView
                    .frame(width: chatFeedProxy.screenSize.width * origin.widthModifier, alignment: origin.alignment)
            }

            if origin == .remote {
                Spacer()
            }
        }
        .padding([.bottom], 5)
    }

    @ViewBuilder var resolveView: some View {
        if entry.format == .unspecified {
            viewWithType(entry.type, origin: origin)
        } else {
            viewWithFormat(entry.format, origin: origin)
        }
    }

    // swiftlint:disable cyclomatic_complexity
    @ViewBuilder func viewWithFormat(_ format: ConversationFormatTypes, origin: Origin) -> some View {
        switch format {
        case .attachments: AttachmentReplacement(model, origin: origin, client: client)
        case .carousel: CarouselReplacement(model, origin: origin, client: client)
        case .inputs: FormInputsReplacement(model, origin: origin, client: client)
        case .result: FormResultReplacement(model, origin: origin, client: client)
        case .listPicker: ListPickerReplacement(model, origin: origin, client: client)
        case .quickReplies: QuickReplyReplacement(model, origin: origin, client: client)
        case .richLink: RichLinkReplacement(model, origin: origin, client: client)
        case .selections: ChoiceResponseReplacement(model, origin: origin, client: client)
        case .textMessage: TextMessageReplacement(model, origin: origin)
        case .webView: WebViewReplacement(model, origin: origin, client: client)
        default: EmptyView()
        }
    }

    @ViewBuilder func viewWithType(_ type: ConversationEntryTypes, origin: Origin) -> some View {
        switch type {
        case .participantChanged: ParticipantChangedReplacement(model, origin: origin, client: client)
        default: EmptyView()
        }
    }
}

extension EntryContainerReplacement {
    enum Origin {
        case system
        case local
        case remote

        var color: Color {
            switch self {
            case .system: Color(.systemGray)
            case .local: Color(.systemGreen)
            case .remote: Color(.systemBlue)
            }
        }

        var horizontalAlignment: HorizontalAlignment {
            switch self {
            case .system: .center
            case .local: .trailing
            case .remote: .leading
            }
        }

        var alignment: Alignment {
            switch self {
            case .system: .center
            case .local: .trailing
            case .remote: .leading
            }
        }

        var widthModifier: CGFloat {
            switch self {
            case .system: 0.8
            case .local: 0.6
            case .remote: 0.6
            }
        }
    }
}
