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
    var useProgressIndicatorForAgents: Bool = true
    var enableEndSessionUI: Bool = true
    var URLDisplayMode: String = UrlDisplayMode.inlineBrowser.rawValue
    var useSSL: Bool = true
    var capabilityVersion: String = Capability.Lastest.rawValue
}
