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
    var client: ConversationClient?

    override init() {
        super.init()

        self.handleNavigation = { screenType, navigationItem in
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
        }
    }
}
