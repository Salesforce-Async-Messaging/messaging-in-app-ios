//
//  GlobalCoreDelegateHandler+UserVerification.swift
//  SMITestApp
//
//  Created by Jeremy Wright on 2024-09-12.
//

import Foundation
import SMIClientCore

extension GlobalCoreDelegateHandler: UserVerificationDelegate {
    func core(_ core: CoreClient, userVerificationChallengeWith reason: ChallengeReason) async -> UserVerification? {
        if reason == .expired || reason == .malformed { return nil }

        let tokenJWT = userVerificationStore.tokenJWT
        let userVerification = UserVerification(customerIdentityToken: tokenJWT, type: .JWT)
        return userVerification
    }
}
