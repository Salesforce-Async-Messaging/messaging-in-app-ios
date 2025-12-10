//
//  MessagingSessionWidget+ConversationClientDelegate.swift
//  MessagingUIExample
//
//  Created on 2025-11-25.
//  Copyright © 2025 Salesforce.com. All rights reserved.
//

import Foundation
import SMIClientCore

extension WidgetViewController: ConversationClientDelegate {
    
    public func client(_ client: any ConversationClient, didUpdateActiveParticipants activeParticipants: [any Participant]) {
        // Find the agent or chatbot participant
        if let participant = activeParticipants.first(where: { $0.role == .agent || $0.role == .chatbot }) {
            self.agentName = participant.displayName
        } else {
            self.agentName = nil
        }
        updateContent()
    }

    public func client(_ client: ConversationClient, didReceiveEvents events: [ConversationEntry]) {
        // Check for queue position updates
        for event in events {
            if event.type == .queuePosition {
                if let queuePosition = event.payload as? QueuePosition {
                    self.queuePosition = queuePosition.position
                }
            }
        }
        updateContent()
    }

    func client(_ client: ConversationClient, didReceiveEntries entries: [ConversationEntry], paged: Bool) {
        // Track unread messages when chat feed is not visible
        if !self.isChatFeedVisible {
            // Count only remote messages (from agent/bot)
            let remoteMessages = entries.filter { entry in
                !entry.sender.isLocal && entry.sender.role != .system
            }
            self.unreadCount += remoteMessages.count
        }

        // Check for queue position updates
        for entry in entries {
            if let queuePosition = entry.payload as? QueuePosition {
                self.queuePosition = queuePosition.position
            }

            // Check for session status changes
            if let payload = entry.payload as? SessionStatusChanged {
                self.sessionStatus = self.readableSessionStatus(sessionStatus: payload.sessionStatus)
            }
        }
        updateContent()
    }
}
