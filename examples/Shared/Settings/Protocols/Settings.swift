//
//  Settings.swift
//

import Foundation

protocol Settings: CaseIterable, Identifiable, RawRepresentable {
    var defaultValue: Any { get }
    var resettable: Bool { get }
    static func handleReset()
}
