//
//  NavBarReplacementCategory.swift
//  MessagingUIExample
//
//  Created by Nigel Brown on 2025-06-19.
//

import SMIClientUI
import UIKit

extension NavigationScreenType {
    public var rawValue: String {
        switch self {
        case .chatFeed: "Chat Feed"
        case .form: "Secure Forms"
        case .confirmation: "Confirmation Screen"
        case .preChat: "PreChat"
        case .attachment: "Attachment Viewer"
        case .transcripts: "Transcripts"
        case .optionsMenu: "Options Menu"
        default: "Unknown"
        }
    }

    var defaultValue: NavBarReplacementModel {
        return NavBarReplacementModel(shouldReplace: false)
    }

    func updateNavigationItem(_ navigationItem: UINavigationItem) {
        switch self {
        case .chatFeed:
            navigationItem.title = "Chat Feed Replacement"
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
        default:
            return
        }

        if navigationItem.leftBarButtonItem != nil {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Left", style: .plain,
                                                               target: navigationItem.leftBarButtonItem?.target,
                                                               action: navigationItem.leftBarButtonItem?.action)
        }

        if navigationItem.rightBarButtonItem != nil {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Right", style: .plain,
                                                                target: navigationItem.rightBarButtonItem?.target,
                                                                action: navigationItem.rightBarButtonItem?.action)
        }
    }
}

struct NavBarReplacementModel: Codable {
    var shouldReplace: Bool
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

