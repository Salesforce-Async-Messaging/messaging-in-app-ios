//
//  GlobalCoreDelegateHandler+TemplatedURL.swift
//  MessagingUIExample
//
//  Created by Jeremy Wright on 2024-09-12.
//  Copyright © 2024 Salesforce.com. All rights reserved.
//

import Foundation
import SMIClientCore

extension GlobalCoreDelegateHandler: TemplatedUrlDelegate {
    func core(_ core: CoreClient, didRequestTemplatedValues values: SMITemplateable) async -> SMITemplateable {
        for pair in delegateManagementStore.templatedURLValues {
            values.setValue(pair.value, forKey: pair.key)
        }

        return values
    }
}
