//
//  UIReplacementCategory.swift
//  SMITestApp
//
//  Created by Jeremy Wright on 2024-09-17.
//

import SwiftUI
import SMIClientUI
import SMIClientCore

enum UIReplacementCategory: String, CaseIterable, Identifiable {
    public var id: String { rawValue }

    case entry = "Conversation Entry Model"
    case typingIndicator = "Typing Indicator Model"
    case dateBreak = "Date Break Model"
    case preChatReceipt = "PreChat Submission Receipt"
    case unknown = "Unknown"

    func view(_ model: ChatFeedModel, client: ConversationClient?) -> any View {
        switch self {
        case .preChatReceipt: PreChatReceiptReplacement(model)
        case .typingIndicator: TypingIndicatorReplacement(model)
        case .dateBreak: DateBreakReplacement(model)
        case .entry: EntryContainerReplacement(model: model, client: client)
        default: EmptyView()
        }
    }

    var renderMode: ChatFeedRenderMode {
        switch self {
        case .preChatReceipt: .replace
        case .typingIndicator: .replace
        case .dateBreak: .replace
        case .entry: .replace
        default: .existing
        }
    }

    var defaultValue: UIReplacementModel {
        switch self {
        case .unknown: return UIReplacementModel(renderMode: ChatFeedRenderMode.none.rawValue)
        default: return UIReplacementModel(renderMode: ChatFeedRenderMode.existing.rawValue)
        }
    }

    static func category(_ model: ChatFeedModel) -> UIReplacementCategory {
        switch model {
        case _ as ConversationEntryModel: return .entry
        case _ as PreChatReceiptModel: return .preChatReceipt
        case _ as TypingIndicatorModel: return .typingIndicator
        case _ as DateBreakModel: return .dateBreak
        default: return .unknown
        }
    }
}

// MARK: - UserDefault Wrappers
extension UIReplacementStore {
    var uiReplacements: [String: UIReplacementModel] {
        get {
            guard let dictionary = [String: UIReplacementModel](rawValue: userDefaults.string(forKey: Keys.uiReplacements.rawValue) ?? "") else {
                clearUserDefaults()
                return [:]
            }

            return dictionary
        }

        set { userDefaults.set(newValue.rawValue, forKey: Keys.uiReplacements.rawValue) }
    }
}
