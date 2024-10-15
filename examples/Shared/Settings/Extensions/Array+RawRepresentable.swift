//
//  Array+RawRepresentable.swift
//

import Foundation

extension Array: @retroactive RawRepresentable where Element: Codable {

    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8) else { return nil }
        guard let result = try? JSONDecoder().decode([Element].self, from: data) else { return nil }

        self = result
    }

    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self) else { return ""}
        guard let result = String(data: data, encoding: .utf8) else { return "" }

        return result
    }
}
