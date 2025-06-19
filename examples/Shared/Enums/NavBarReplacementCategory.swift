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
    case confirmation = "Confrimation Screen"
    case information = "Information Screen"
    case preChat = "Pre-Chat"
    case attachment = "Attachement Viewer"
    case transcripts = "Transcripts"
    case optionsMenu = "Options Menu"

    var defaultValue: NavBarReplacementModel {
        return NavBarReplacementModel(shouldReplace: false)
    }

    func replacementNavItem(_ type: NavigationScreenType) -> UINavigationItem {
        switch type{
        case .chatFeed:
            let navigationItem = UINavigationItem()
            navigationItem.title = "Chat Feed Replacement"
            return navigationItem
        case .confirmation:
            let navigationItem = UINavigationItem()
            navigationItem.title = "Confirmation Replacement"
            return navigationItem
        case .information:
            let navigationItem = UINavigationItem()
            navigationItem.title = "Information Replacement"
            return navigationItem
        case .preChat:
            let navigationItem = UINavigationItem()
            navigationItem.title = "Prechat Replacement"
            return navigationItem
        case .attachment:
            let navigationItem = UINavigationItem()
            navigationItem.title = "Attachment Replacement"
            return navigationItem
        case .transcripts:
            let navigationItem = UINavigationItem()
            navigationItem.title = "Transcript Replacement"
            return navigationItem
        case .optionsMenu:
            let navigationItem = UINavigationItem()
            navigationItem.title = "Options Menu Replacement"
            return navigationItem
        case .form:
            let navigationItem = UINavigationItem()
            navigationItem.title = "Form Replacement"
            return navigationItem
        @unknown default:
            let navigationItem = UINavigationItem()
            return navigationItem
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
