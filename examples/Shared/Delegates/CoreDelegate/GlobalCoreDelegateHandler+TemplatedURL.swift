//
//  GlobalCoreDelegateHandler+TemplatedURL.swift
//  SMITestApp
//
//  Created by Jeremy Wright on 2024-09-12.
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
