//
//  Capability.swift
//  SMITestApp
//
//  Created by Aaron Eisses on 2024-11-26.
//

enum Capability: String, RawRepresentable, CaseIterable, Identifiable {
    public var id: String { rawValue }

    case Lastest = "254"
    case TwoFortyEight = "248"
    case TwoFortySix = "246"
    case TwoForty = "240"
    case TwoThirtyEight = "238"
}

// MARK: - UserDefault Wrappers
extension MIAWConfigurationStore {
    var capabilityVersion: Capability {
        get {
            let defaultCapability = Capability.Lastest
            return Capability(rawValue: environments[connectionEnvironment.rawValue]?.capabilityVersion ?? defaultCapability.rawValue) ?? defaultCapability
        }
        set {
            guard var environment = environments[connectionEnvironment.rawValue] else { return }
            environment.capabilityVersion = newValue.rawValue
            environments[connectionEnvironment.rawValue] = environment
        }
    }
}
