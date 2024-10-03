//
//  TestPrePopulatedPreChatProvider.swift
//  SMITestApp
//
//  Created by Jeremy Wright on 2024-09-25.
//

import Foundation
import SMIClientUI

struct TestPrePopulatedPreChatProvider {

    let delegateManagementStore: DelegateManagementStore = DelegateManagementStore()

    var closure: Interface.PreChatFieldValueClosure {
        return { preChatFields in
            for pair in self.delegateManagementStore.prePopPreChatValues {
                let field = preChatFields.first(where: { $0.name == pair.key })
                field?.value = pair.value
                field?.isEditable = pair.isEditable
            }

            return preChatFields
        }
    }
}
