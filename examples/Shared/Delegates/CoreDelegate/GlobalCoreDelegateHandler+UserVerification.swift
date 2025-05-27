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

        switch configStore.authorizationMethod {
        case .userVerified:
            return UserVerification(customerIdentityToken: userVerificationStore.tokenJWT, type: .JWT)

        case .passthrough:
            await Self.salesforceLogin()
            return await Self.fetchMIAWJWT(core)

        default: return nil
        }
    }
}
