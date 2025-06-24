//
//  GlobalCoreDelegateHandler.swift
//  SMITestApp
//
//  Created by Jeremy Wright on 2024-09-12.
//

import Foundation
import SMIClientCore
import SalesforceSDKCore

@objc class GlobalCoreDelegateHandler: NSObject {
    static let shared = GlobalCoreDelegateHandler()

    let viewBuilder: TestEntryViewBuilder = TestEntryViewBuilder()
    let navBarBuilder: TestNavBarBuilder = TestNavBarBuilder()
    let prePopulatedPreChatProvider: TestPrePopulatedPreChatProvider = TestPrePopulatedPreChatProvider()
    let userVerificationStore: UserVerificationStore = UserVerificationStore()
    let passthroughVerificationStore: PassthroughVerificationStore = PassthroughVerificationStore()
    let uiReplacementStore: UIReplacementStore = UIReplacementStore()
    let delegateManagementStore: DelegateManagementStore = DelegateManagementStore()
    let configStore: MIAWConfigurationStore = MIAWConfigurationStore()

    func registerDelegates(_ core: CoreClient) {
        if delegateManagementStore.hiddenPreChatDelegateEnabled {
            core.setPreChatDelegate(delegate: self, queue: .main)
        }

        if delegateManagementStore.templatedURLDelgateEnabled {
            core.setTemplatedUrlDelegate(delegate: self, queue: .main)
        }

        core.setUserVerificationDelegate(delegate: self, queue: .main)
    }

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
        let fetchTask = Task {
            let request = RestRequest(method: .GET, serviceHostType:.custom, path:core.salesforceAuthenticationRequestPath, queryParams: nil)
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
            return nil
        }

        return nil
    }
}
