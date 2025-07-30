//
//  GlobalCoreDelegateHandler+ConversationClient.swift
//  SMITestApp
//
//  Created by Jeremy Wright on 2025-07-25.
//

import Foundation
import SMIClientCore

extension GlobalCoreDelegateHandler: ConversationClientDelegate {
    func client(_ client: any ConversationClient, didUpdateActiveParticipants activeParticipants: [any Participant]) {

        if navBarReplacementStore.dynamicTitleReplacement {
            navBarBuilder.updateNavigation { screen, navigationItem in
                if screen == .chatFeed {
                    if let participant = activeParticipants.first(where: { $0.role == .agent || $0.role == .chatbot }) {
                        navigationItem.title = participant.displayName
                    } else {
                        navigationItem.title = "Unknown"
                    }
                }
            }
        }
    }
}
