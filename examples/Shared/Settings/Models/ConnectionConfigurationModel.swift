//
//  ConnectionConfigurationModel.swift
//

import Foundation
import SMIClientUI

struct ConnectionConfigurationModel: Codable {
    var domain: String
    var organizationId: String
    var developerName: String
    var authorizationMethod: AuthorizationMethod = .unverified
    var enableAttachmentUI: Bool = true
    var enableTranscriptUI: Bool = true
    var useProgressIndicatorForAgents: Bool = true
    var useHumanAgentAvatar: Bool = false
    var enableEndSessionUI: Bool = true
    var URLDisplayMode: String = UrlDisplayMode.inlineBrowser.rawValue
    var useSSL: Bool = true
    var enableImages: Bool = true
    var enableVideos: Bool = true
    var enableAudio: Bool = true
    var enableText: Bool = true
    var enableOther: Bool = true
}
