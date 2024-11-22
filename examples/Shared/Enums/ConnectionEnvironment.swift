//
//  ConnectionEnvironment.swift
//  SMITestApp
//
//  Created by Jeremy Wright on 2024-09-10.
//

import Foundation
import SMIClientCore

enum ConnectionEnvironment: String, EnvironmentSettings {
    public var id: String { rawValue }

    case config1
    case config2
    case config3
    case config4
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
