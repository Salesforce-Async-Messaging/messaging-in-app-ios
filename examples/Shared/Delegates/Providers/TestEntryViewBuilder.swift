//
//  TestEntryViewBuilder.swift
//  MessagingUIExample
//
//  Created by Jeremy Wright on 2024-09-17.
//  Copyright © 2024 Salesforce.com. All rights reserved.
//

import SwiftUI
import SMIClientCore
import SMIClientUI

struct TestEntryViewBuilder: ChatFeedViewBuilder {
    private let uiReplacementStore: UIReplacementStore = UIReplacementStore()

    var renderMode: RenderModeClosure? {
        return { model in
            if uiReplacementStore.replaceAll { return .replace }

            let category = UIReplacementCategory.category(model).rawValue
            return ChatFeedRenderMode(rawValue: uiReplacementStore.uiReplacements[category]?.renderMode ?? "") ?? .existing
        }
    }

    var completeView: CompleteViewClosure? {
        return { model, client in
            UIReplacementCategory.category(model).view(model, client: client)
        }
    }
}
