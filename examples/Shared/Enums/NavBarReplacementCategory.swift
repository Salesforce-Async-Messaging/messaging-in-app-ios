//
//  NavBarReplacementCategory.swift
//  MessagingUIExample
//
//  Created by Nigel Brown on 2025-06-19.
//

import SMIClientUI
import UIKit

enum NavBarReplacementCategory: String, CaseIterable, Identifiable {
    public var id: String { rawValue }

    case chatFeed = "Chat Feed"
    case form = "Secure Forms"
    case confirmation = "Confirmation Screen"
    case information = "Information Screen"
    case preChat = "Pre-Chat"
    case attachment = "Attachement Viewer"
    case transcripts = "Transcripts"
    case optionsMenu = "Options Menu"

    var defaultValue: NavBarReplacementModel {
        return NavBarReplacementModel(shouldReplace: false)
    }

    func updateNavigationItem(_ navigationItem: UINavigationItem) {
        switch self {
        case .chatFeed:
            navigationItem.title = "Chat Feed Replacement"
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "blah", style: .plain, target: nil, action: nil)
        case .confirmation:
            navigationItem.title = "Confirmation Replacement"
        case .information:
            navigationItem.title = "Information Replacement"
        case .preChat:
            navigationItem.title = "Prechat Replacement"
        case .attachment:
            navigationItem.title = "Attachment Replacement"
        case .transcripts:
            navigationItem.title = "Transcript Replacement"
        case .optionsMenu:
            navigationItem.title = "Options Menu Replacement"
        case .form:
            navigationItem.title = "Form Replacement"
        }
    }

    static func type(_ type: NavigationScreenType) -> NavBarReplacementCategory {
        switch type {
        case .chatFeed: return .chatFeed
        case .confirmation: return .confirmation
        case .information: return .information
        case .preChat: return .preChat
        case .attachment: return .attachment
        case .transcripts: return .transcripts
        case .optionsMenu: return .optionsMenu
        case .form: return .form
        @unknown default:
            fatalError()
        }
    }
}

// MARK: - UserDefault Wrappers
extension NavBarReplacementStore {
    var navBarReplacements: [String: NavBarReplacementModel] {
        get {
            guard let dictionary = [String: NavBarReplacementModel](rawValue: userDefaults.string(forKey: Keys.navBarReplacements.rawValue) ?? "") else {
                return [:]
            }

            return dictionary
        }

        set { userDefaults.set(newValue.rawValue, forKey: Keys.navBarReplacements.rawValue) }
    }
}


struct NavBarReplacementModel: Codable {
    var shouldReplace: Bool
}
