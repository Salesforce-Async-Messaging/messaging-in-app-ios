//
//  TestNavBarBuilder.swift
//  MessagingUIExample
//
//  Created by Nigel Brown on 2025-06-19.
//  Copyright © 2025 Salesforce.com. All rights reserved.
//

import SwiftUI
import SMIClientCore
import SMIClientUI

class TestNavBarBuilder: NavigationBarBuilder {
    private let navBarReplacementStore: NavBarReplacementStore = NavBarReplacementStore()
    private let voiceHandler = VoiceNavBarButtonHandler()

    var client: ConversationClient? {
        didSet {
            voiceHandler.client = client
        }
    }

    override init() {
        super.init()

        self.handleNavigation = { [weak self] screenType, navigationItem in
            guard let self = self else { return }

            if let shouldReplace = self.navBarReplacementStore.navBarReplacements[screenType.rawValue]?.shouldReplace, shouldReplace {
                screenType.updateNavigationItem(navigationItem)

                if screenType == .chatFeed && self.navBarReplacementStore.dynamicTitleReplacement {
                    self.client?.conversation { conversation, _ in
                        DispatchQueue.main.async {
                            if let participant = conversation?.activeParticipants.first(where: { $0.role == .agent || $0.role == .chatbot }) {
                                navigationItem.title = participant.displayName
                            } else {
                                navigationItem.title = "Unknown"
                            }
                        }
                    }
                }
            }

            if screenType == .chatFeed && VoiceStore().enableVoiceNavBarButton {
                self.voiceHandler.addButton(to: navigationItem)
            }
        }
    }
}
