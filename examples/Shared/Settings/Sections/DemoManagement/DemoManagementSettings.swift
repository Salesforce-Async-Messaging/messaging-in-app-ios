//
//  DemoManagementSettings.swift
//

import SwiftUI

typealias DemoManagementStore = SettingsStore<DemoManagementSettings.SettingsKeys>

struct DemoManagementSettings: View {
    static let header: String = "UIKit Demo Settings"

    enum SettingsKeys: String, Settings {
        public var id: String { rawValue }

        var defaultValue: Any {
            switch self {
            case .demoDomain: "salesforce.com"
            case .isModal: true
            case .modalPresentationStyle: ModalPresentationStyle.popover.rawValue
            case .replaceDismissButton: false
            case .dismissButtonTitle: "Back"
            }
        }

        var resettable: Bool {
            switch self {
            case .demoDomain: return false
            case .isModal: return true
            case .modalPresentationStyle: return true
            case .replaceDismissButton: return true
            case .dismissButtonTitle: return true
            }
        }

        static func handleReset() {}

        case demoDomain
        case isModal
        case modalPresentationStyle
        case replaceDismissButton
        case dismissButtonTitle
    }

    public enum ModalPresentationStyle: String, CaseIterable, Identifiable, DeveloperToggle {
        // Required for compliance to Identifiable
        public var id: String { rawValue }

        case automatic
        case fullScreen
        case popover

        var systemValue: UIModalPresentationStyle {
            switch self {
            case .fullScreen: return .fullScreen
            case .popover: return .popover
            default: return .automatic
            }
        }

        var developerOnly: Bool { true }
    }

    @StateObject var demoManagementStore: DemoManagementStore = DemoManagementStore()

    var body: some View {
        SettingsSection(Self.header, developerOnly: false) {
            Instructions(instructions: "This setting will change the background web page in the Custom URL Demo on the main page.",
                         note: nil,
                         section: false)

            SettingsTextField("Demo Domain", placeholder: "Enter URL Domain", value: $demoManagementStore.demoDomain)
            SettingsToggle("Modal Presentation", developerOnly: true, isOn: $demoManagementStore.isModal)

            if demoManagementStore.isModal {
                SettingsPicker("Modal Presentation Style", developerOnly: true, value: $demoManagementStore.modalPresentationStyle)
                SettingsToggle("Replace Dismiss Button", developerOnly: true, isOn: $demoManagementStore.replaceDismissButton)

                if demoManagementStore.replaceDismissButton {
                    SettingsTextField("Button Title",
                                      developerOnly: true,
                                      placeholder: "Enter Dismiss Button Title",
                                      value: $demoManagementStore.dismissButtonTitle)
                }
            }
        }
    }
}

extension DemoManagementStore {
    var modalPresentationStyle: DemoManagementSettings.ModalPresentationStyle {
        get {
            userDefaults.string(forKey: Keys.modalPresentationStyle.rawValue).flatMap {
                DemoManagementSettings.ModalPresentationStyle(rawValue: $0)
            } ?? .popover
        }
        set { userDefaults.set(newValue.rawValue, forKey: Keys.modalPresentationStyle.rawValue)}
    }

    var demoDomain: String {
        get { userDefaults.string(forKey: Keys.demoDomain.rawValue) ?? "" }
        set { userDefaults.set(newValue, forKey: Keys.demoDomain.rawValue) }
    }

    var isModal: Bool {
        get { userDefaults.bool(forKey: Keys.isModal.rawValue) }
        set { userDefaults.set(newValue, forKey: Keys.isModal.rawValue) }
    }

    var replaceDismissButton: Bool {
        get { userDefaults.bool(forKey: Keys.replaceDismissButton.rawValue) }
        set { userDefaults.set(newValue, forKey: Keys.replaceDismissButton.rawValue) }
    }

    var dismissButtonTitle: String {
        get { userDefaults.string(forKey: Keys.dismissButtonTitle.rawValue) ?? "" }
        set { userDefaults.set(newValue, forKey: Keys.dismissButtonTitle.rawValue) }
    }
}

#Preview {
    Form {
        DemoManagementSettings()

        DeveloperStettings()
    }
}
