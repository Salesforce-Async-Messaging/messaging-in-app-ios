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
            guard let jsonString = userDefaults.string(forKey: Keys.environments.rawValue),
                  let jsonData = jsonString.data(using: .utf8) else {
                return [:]
            }

            do {
                let dictionary = try JSONDecoder().decode([String: ConnectionConfigurationModel].self, from: jsonData)
                return dictionary
            } catch {
                print("Error decoding environments from UserDefaults: \(error)")
                return [:]
            }
        }

        set {
            do {
                let jsonData = try JSONEncoder().encode(newValue)

                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    userDefaults.set(jsonString, forKey: Keys.environments.rawValue)
                } else {
                    print("Failed to convert JSON data to a string.")
                }
            } catch {
                print("Error encoding environments to UserDefaults: \(error)")
            }
        }
    }
}
