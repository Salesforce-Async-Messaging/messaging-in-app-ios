
import Foundation

enum AuthorizationMethod: String, Identifiable, CaseIterable, Codable, DeveloperToggle {
    public var id: String { rawValue }
    var developerOnly: Bool { true }

    case unverified = "Unverified"
    case passthrough = "Passthrough"
    case userVerified = "User Verified"
}
