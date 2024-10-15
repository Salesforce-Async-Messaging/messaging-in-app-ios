//
//  Dictionary+RawRepresentable.swift
//

import Foundation

extension Dictionary: @retroactive RawRepresentable where Key: Codable, Value: Codable {

    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8) else { return nil }
        guard let result = try? JSONDecoder().decode([Key: Value].self, from: data) else { return nil }

        self = result
    }

    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self) else { return "{}"}
        guard let result = String(data: data, encoding: .utf8) else { return "{}" }

        return result
    }
}
