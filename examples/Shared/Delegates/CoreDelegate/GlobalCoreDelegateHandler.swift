//
//  GlobalCoreDelegateHandler.swift
//  SMITestApp
//
//  Created by Jeremy Wright on 2024-09-12.
//

import Foundation
import SMIClientCore

@objc class GlobalCoreDelegateHandler: NSObject {
    static let shared = GlobalCoreDelegateHandler()

    let viewBuilder: TestEntryViewBuilder = TestEntryViewBuilder()
    let prePopulatedPreChatProvider: TestPrePopulatedPreChatProvider = TestPrePopulatedPreChatProvider()
    let userVerificationStore: UserVerificationStore = UserVerificationStore()
    let uiReplacementStore: UIReplacementStore = UIReplacementStore()
    let delegateManagementStore: DelegateManagementStore = DelegateManagementStore()

    func registerDelegates(_ core: CoreClient) {
        core.setPreChatDelegate(delegate: self, queue: .main)
        core.setTemplatedUrlDelegate(delegate: self, queue: .main)
        core.setUserVerificationDelegate(delegate: self, queue: .main)
    }
}
