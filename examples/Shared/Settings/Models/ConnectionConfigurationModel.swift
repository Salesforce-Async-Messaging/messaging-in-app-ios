//
//  ConnectionConfigurationModel.swift
//

import Foundation
import SMIClientUI

struct ConnectionConfigurationModel: Codable {
    var domain: String
    var organizationId: String
    var developerName: String
    var userVerificationRequired: Bool = false
    var enableAttachmentUI: Bool = true
    var enableTranscriptUI: Bool = true
    var URLDisplayMode: String = UrlDisplayMode.inlineBrowser.rawValue
    var useSSL: Bool = true

    enum CodingKeys: String, CodingKey {
        case domain
        case organizationId
        case developerName
        case userVerificationRequired
        case enableAttachmentUI
        case enableTranscriptUI
        case useProgressIndicatorForAgents
        case enableEndSessionUI
        case URLDisplayMode
        case useSSL
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        domain = try container.decode(String.self, forKey: .domain)
        organizationId = try container.decode(String.self, forKey: .organizationId)
        developerName = try container.decode(String.self, forKey: .developerName)
        userVerificationRequired = try container.decodeIfPresent(Bool.self, forKey: .userVerificationRequired) ?? false
        enableAttachmentUI = try container.decodeIfPresent(Bool.self, forKey: .enableAttachmentUI) ?? true
        enableTranscriptUI = try container.decodeIfPresent(Bool.self, forKey: .enableTranscriptUI) ?? true
        useProgressIndicatorForAgents = try container.decodeIfPresent(Bool.self, forKey: .useProgressIndicatorForAgents) ?? true
        enableEndSessionUI = try container.decodeIfPresent(Bool.self, forKey: .enableEndSessionUI) ?? true
        URLDisplayMode = try container.decodeIfPresent(String.self, forKey: .URLDisplayMode) ?? UrlDisplayMode.inlineBrowser.rawValue
        useSSL = try container.decodeIfPresent(Bool.self, forKey: .useSSL) ?? true
    }

    init(domain: String,
        organizationId: String,
        developerName: String,
        userVerificationRequired: Bool = false,
        enableAttachmentUI: Bool = true,
        enableTranscriptUI: Bool = true,
        useProgressIndicatorForAgents: Bool = true,
        enableEndSessionUI: Bool = true,
        URLDisplayMode: String = UrlDisplayMode.inlineBrowser.rawValue,
        useSSL: Bool = true) {
        self.domain = domain
        self.organizationId = organizationId
        self.developerName = developerName
        self.userVerificationRequired = userVerificationRequired
        self.enableAttachmentUI = enableAttachmentUI
        self.enableTranscriptUI = enableTranscriptUI
        self.useProgressIndicatorForAgents = useProgressIndicatorForAgents
        self.enableEndSessionUI = enableEndSessionUI
        self.URLDisplayMode = URLDisplayMode
        self.useSSL = useSSL
    }
}
