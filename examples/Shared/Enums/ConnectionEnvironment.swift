//
//  ConnectionEnvironment.swift
//  SMITestApp
//
//  Created by Jeremy Wright on 2024-09-10.
//

import Foundation
import SMIClientCore

enum ConnectionEnvironment: String, CaseIterable, Identifiable {
    public var id: String { rawValue }
    case config1
    case config2
    case config3

    var editableDomain: Bool { true }
    var editableOrganizationId: Bool { true }
    var displaySSLToggle: Bool { false }

    var defaultValue: ConnectionConfigurationModel {
        switch self {
        case .config1:
            return ConnectionConfigurationModel(domain: "config1.my.salesforce-scrt.com",
                                                organizationId: "",
                                                developerName: "",
                                                userVerificationRequired: false)
        case .config2:
            return ConnectionConfigurationModel(domain: "config2.my.salesforce-scrt.com",
                                                organizationId: "",
                                                developerName: "",
                                                userVerificationRequired: false)
        case .config3:
            return ConnectionConfigurationModel(domain: "config3.salesforce-scrt.com",
                                                organizationId: "",
                                                developerName: "",
                                                userVerificationRequired: false)
        }
    }
}

// MARK: - UserDefault Wrappers
extension MIAWConfigurationStore {
    var environments: [String: ConnectionConfigurationModel] {
        get {
            guard let dictionary = [String: ConnectionConfigurationModel](rawValue: userDefaults.string(forKey: Keys.environments.rawValue) ?? "") else {
                return [:]
            }

            return dictionary
        }

        set { userDefaults.set(newValue.rawValue, forKey: Keys.environments.rawValue) }
    }
}
