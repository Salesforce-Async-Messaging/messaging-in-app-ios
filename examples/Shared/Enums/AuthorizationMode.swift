import Foundation
import SMIClientCore

enum AuthorizationMode: String, Identifiable, CaseIterable, Codable, DeveloperToggle {
    public var id: String { rawValue }
    var developerOnly: Bool { true }

    case unAuth = "Unverified"
    case auth = "User Verified"
    case hybridAuth = "Hybrid (Unverified, Elevatable)"

    var authMode: AuthMode {
        switch self {
        case .unAuth: return .unAuth
        case .auth: return .auth
        case .hybridAuth: return .hybridAuth
        }
    }
}
