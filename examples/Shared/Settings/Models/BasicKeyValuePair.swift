//
//  BasicKeyValuePair.swift
//

import Foundation

struct BasicKeyValuePair: KeyValuePair {
    public var id: UUID = UUID()

    var key: String
    var value: String
}
