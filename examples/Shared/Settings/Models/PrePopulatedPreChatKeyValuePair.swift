//
//  PrePopulatedPreChatKeyValuePair.swift
//

import Foundation

struct PrePopulatedPreChatKeyValuePair: KeyValuePair {
    public var id: UUID = UUID()

    var key: String
    var value: String
    var isEditable: Bool = true
}
