//
//  ConnectionEnvironment+Example.swift
//

import Foundation

extension ConnectionEnvironment {
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
        case .config4:
            return ConnectionConfigurationModel(domain: "config4.salesforce-scrt.com",
                                                organizationId: "",
                                                developerName: "",
                                                userVerificationRequired: false)
        }
    }
}
