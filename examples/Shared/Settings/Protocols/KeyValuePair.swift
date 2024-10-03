//
//  KeyValuePair.swift
//

import Foundation

protocol KeyValuePair: Codable, Identifiable {
    var key: String { get }
    var value: String { get }
}
