//
//  EnvironmentSettings.swift
//

import Foundation

protocol EnvironmentSettings: RawRepresentable, CaseIterable, Identifiable {
    var editableDomain: Bool { get }
    var editableOrganizationId: Bool { get }
    var displaySSLToggle: Bool { get }
    var defaultValue: ConnectionConfigurationModel { get }
}
