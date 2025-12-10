//
//  MessagingSessionWidget.swift
//  MessagingUIExample
//
//  Created on 2025-11-25.
//  Copyright © 2025 Salesforce.com. All rights reserved.
//

import Foundation
import SwiftUI
import SMIClientCore

// A widget that displays real-time messaging session information in floating views.
// Provides three widget views: queue position, session status, and agent name with unread counter.
public class MessagingSessionWidget: NSObject, ObservableObject {
    
    // MARK: - Properties

    // The conversation client to monitor
    private let conversationClient: ConversationClient

    // Closure to call when opening the chat feed
    private let openChatFeed: () -> Void

    var messagingSessionWidgetView: MessagingSessionWidgetView?

    // MARK: - Initialization
    
    // Initializes a new MessagingSessionWidget
    // - Parameters:
    //   - conversationClient: The conversation client to monitor
    //   - closeConversation: Closure to call when closing the conversation
    //   - openChatFeed: Closure to call when opening the chat feed
    public init(conversationClient: ConversationClient,
                openChatFeed: @escaping () -> Void) {
        self.conversationClient = conversationClient
        self.openChatFeed = openChatFeed
        super.init()
    }
    
    // MARK: - Public Methods
    
    // Returns a view displaying the queue position
    public func queuePositionView() -> some View {
        messagingSessionWidgetView = MessagingSessionWidgetView(
                                        conversationClient: conversationClient,
                                        widgetType: .queuePosition,
                                        openChatAction: openChatFeed
                                    )
        return messagingSessionWidgetView
    }
    
    // Returns a view displaying the session status
    public func sessionStatusView() -> some View {
        messagingSessionWidgetView = MessagingSessionWidgetView(
                                        conversationClient: conversationClient,
                                        widgetType: .sessionStatus,
                                        openChatAction: openChatFeed
                                    )
        return messagingSessionWidgetView
    }
    
    // Returns a view displaying the agent name with unread counter
    public func agentNameView() -> some View {
        messagingSessionWidgetView = MessagingSessionWidgetView(
                                        conversationClient: conversationClient,
                                        widgetType: .agentName,
                                        openChatAction: openChatFeed
                                    )
        return messagingSessionWidgetView
    }

    // Passes the feed visibility to the messageSessionWidgetView
    public func feedVisibillity(_ visible: Bool) {
        messagingSessionWidgetView?.feedVisibillity(visible)
    }
}

// MARK: - Widget Type
enum MessagingSessionWidgetType {
    case queuePosition
    case sessionStatus
    case agentName
}

