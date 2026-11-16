//
//  GlobalCoreDelegateHandler+UserVerification.swift
//  MessagingUIExample
//
//  Created by Jeremy Wright on 2024-09-12.
//  Copyright © 2024 Salesforce.com. All rights reserved.
//

import Foundation
import SMIClientCore
import SalesforceSDKCore

extension GlobalCoreDelegateHandler: UserVerificationDelegate {
    func core(_ core: CoreClient, userVerificationChallengeWith reason: ChallengeReason) async -> UserVerification? {
        if reason == .expired || reason == .malformed { return nil }

        if configStore.usePassthrough {
            await Self.salesforceLogin()
            return await Self.fetchMIAWJWT(core)
        }

        return UserVerification(customerIdentityToken: userVerificationStore.tokenJWT, type: .JWT)
    }
}

extension GlobalCoreDelegateHandler {
    @MainActor
    class func salesforceLogin() async {
        await withCheckedContinuation { continuation in
            // The SalesforceSDK loginIfRequired can sometimes call the completion multiple times
            // this safeguards agains the continuation being called multiple times resulting in a crash.
            var nillableContinuation: CheckedContinuation<Void, Never>? = continuation

            AuthHelper.loginIfRequired {
                if let continuation = nillableContinuation {
                    nillableContinuation = nil
                    continuation.resume()
                }
            }
        }
    }

    class func fetchMIAWJWT(_ core: CoreClient) async -> PassthroughVerification? {
        let isHybrid = GlobalCoreDelegateHandler.shared.configStore.authorizationMode == .hybridAuth
        let fetchTask = Task {
            let request = RestRequest(method: isHybrid ? .POST : .GET, serviceHostType:.custom, path:core.salesforceAuthenticationRequestPath, queryParams: nil)
            request.setCustomRequestBodyDictionary([:], contentType: "application/json")
            do {
                return try await RestClient.shared.send(request: request)
            }
        }

        let result = await fetchTask.result

        do {
            if let body = try result.get().asJson() as? Dictionary<String, Any> {
                guard let data = body["data"] as? Dictionary<String, Any> else { return nil }
                guard let accessToken = data["accessToken"] as? String else { return nil }
                guard let lastEventId = data["lastEventId"] as? String else { return nil }

                return PassthroughVerification(jwt: accessToken, lastEventId: lastEventId)
            }
        } catch {
            print("An error occurred: \(error)")
            return nil
        }

        return nil
    }
}
