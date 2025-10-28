//
//  MIAWConfigurationSettings.swift
//

import SwiftUI
import SMIClientCore
import SMIClientUI

typealias MIAWConfigurationStore = SettingsStore<MIAWConfigurationSettings.SettingsKeys>

struct MIAWConfigurationSettings: View {
    static let header = "MIAW Configuration"
    var reset: (() -> Void)?
    var instructions: String = "Use the tab below view to choose the current MIAW Connection Environment."
    var note: String = "The selected environment is applied to all demos! Changing the environment will wipe the database and delete all conversations."

    enum SettingsKeys: String, Settings {
        public var id: String { rawValue }

        var defaultValue: Any {
            switch self {
            case .connectionEnvironment: return ConnectionEnvironment.allCases.first!.rawValue
            case .environments:
                var result: [String: ConnectionConfigurationModel] = [:]
                ConnectionEnvironment.allCases.forEach {
                    result[$0.rawValue] = $0.defaultValue
                }

                return result.rawValue
            }
        }

        var resettable: Bool { false }

        static func handleReset() {}

        case connectionEnvironment
        case environments
    }

    @StateObject var store: MIAWConfigurationStore = MIAWConfigurationStore()
    @StateObject var developerStore: DeveloperStore = DeveloperStore()
    @State private var toast: Toast?

    var body: some View {
        SettingsSection(Self.header) {
            Instructions(instructions: instructions, note:note, section: false)

            SettingsPicker("Connection Environment", developerOnly: false, value: $store.connectionEnvironment).onChange(of: store.connectionEnvironment) {
                reset?()
            }

            SettingsTextField("Domain",
                              placeholder: "Enter your Domain",
                              value: $store.domain,
                              enabled: store.connectionEnvironment.editableDomain)

            if store.connectionEnvironment.sslToggle {
                SettingsToggle("Requres SSL", developerOnly: true, isOn: $store.useSSL)
            }

            SettingsTextField("Organization Id",
                              placeholder: "Enter your Organization Id",
                              value: $store.organizationId,
                              enabled: store.connectionEnvironment.editableOrganizationId)

            SettingsTextField("Developer Name",
                              placeholder: "Enter your Developer Name",
                              value: $store.developerName,
                              enabled: store.connectionEnvironment.editableDeveloperName)

            SettingsToggle("Attachment UI Enabled", developerOnly: true, isOn: $store.enableAttachmentUI)
            SettingsNavigationLink("Allowed File Types", developerOnly: true) {
                FileTypeSettings(miawConfigurationStore: store)
            }
            SettingsToggle("Transcript Enabled", developerOnly: true, isOn: $store.enableTranscriptUI)
            SettingsToggle("Progress Indicator for Agents", developerOnly: true, isOn: $store.useProgressIndicatorsForAgents)
            SettingsToggle("End Session Enabled", developerOnly: true, isOn: $store.enableEndSessiontUI)
            SettingsPicker("Authorization Method", developerOnly: true, value: $store.authorizationMethod)
            SettingsPicker("URL Display Mode", developerOnly: true, value: $store.URLDisplayMode)
        }
    }
}

extension UrlDisplayMode: DeveloperToggle {
    var developerOnly: Bool { true }
}

// MARK: - UserDefault Wrappers
extension MIAWConfigurationStore {
    var connectionEnvironment: ConnectionEnvironment {
        get {
            userDefaults.string(forKey: Keys.connectionEnvironment.rawValue).flatMap { string in
                ConnectionEnvironment.allCases.first(where: {
                    $0.rawValue == string
                })
            } ?? ConnectionEnvironment.allCases.first!
        }

        set { userDefaults.set(newValue.rawValue, forKey: Keys.connectionEnvironment.rawValue)}
    }

    var organizationId: String {
        get { return environments[connectionEnvironment.rawValue]?.organizationId ?? "" }
        set {
            guard var environment = environments[connectionEnvironment.rawValue] else { return }
            environment.organizationId = newValue
            environments[connectionEnvironment.rawValue] = environment
        }
    }

    var domain: String {
        get { return environments[connectionEnvironment.rawValue]?.domain ?? "" }
        set {
            guard var environment = environments[connectionEnvironment.rawValue] else { return }
            environment.domain = newValue
            environments[connectionEnvironment.rawValue] = environment
        }
    }

    var developerName: String {
        get { return environments[connectionEnvironment.rawValue]?.developerName ?? "" }
        set {
            guard var environment = environments[connectionEnvironment.rawValue] else { return }
            environment.developerName = newValue
            environments[connectionEnvironment.rawValue] = environment
        }
    }

    var authorizationMethod: AuthorizationMethod {
        get { environments[connectionEnvironment.rawValue]?.authorizationMethod ?? .unverified }
        set {
            guard var environment = environments[connectionEnvironment.rawValue] else { return }
            environment.authorizationMethod = newValue
            environments[connectionEnvironment.rawValue] = environment
        }
    }

    var useSSL: Bool {
        get {
            guard let environment = environments[connectionEnvironment.rawValue] else { return false }
            return environment.useSSL
        }
        set {
            guard var environment = environments[connectionEnvironment.rawValue] else { return }
            environment.useSSL = newValue
            environments[connectionEnvironment.rawValue] = environment
        }
    }

    var URLDisplayMode: UrlDisplayMode {
        get {
            guard let environment = environments[connectionEnvironment.rawValue] else { return .inlineBrowser }
            return UrlDisplayMode(rawValue: environment.URLDisplayMode) ?? .inlineBrowser
        }

        set {
            guard var environment = environments[connectionEnvironment.rawValue] else { return }
            environment.URLDisplayMode = newValue.rawValue
            environments[connectionEnvironment.rawValue] = environment
        }
    }

    var enableAttachmentUI: Bool {
        get {
            guard let environment = environments[connectionEnvironment.rawValue] else { return false }
            return environment.enableAttachmentUI
        }
        set {
            guard var environment = environments[connectionEnvironment.rawValue] else { return }
            environment.enableAttachmentUI = newValue
            environments[connectionEnvironment.rawValue] = environment
        }
    }

    var enableImages: Bool {
        get {
            guard let environment = environments[connectionEnvironment.rawValue] else { return false }
            return environment.enableImages
        }
        set {
            guard var environment = environments[connectionEnvironment.rawValue] else { return }
            environment.enableImages = newValue
            environments[connectionEnvironment.rawValue] = environment
        }
    }

    var enableVideos: Bool {
        get {
            guard let environment = environments[connectionEnvironment.rawValue] else { return false }
            return environment.enableVideos
        }
        set {
            guard var environment = environments[connectionEnvironment.rawValue] else { return }
            environment.enableVideos = newValue
            environments[connectionEnvironment.rawValue] = environment
        }
    }

    var enableAudio: Bool {
        get {
            guard let environment = environments[connectionEnvironment.rawValue] else { return false }
            return environment.enableAudio
        }
        set {
            guard var environment = environments[connectionEnvironment.rawValue] else { return }
            environment.enableAudio = newValue
            environments[connectionEnvironment.rawValue] = environment
        }
    }

    var enableText: Bool {
        get {
            guard let environment = environments[connectionEnvironment.rawValue] else { return false }
            return environment.enableText
        }
        set {
            guard var environment = environments[connectionEnvironment.rawValue] else { return }
            environment.enableText = newValue
            environments[connectionEnvironment.rawValue] = environment
        }
    }

    var enableOther: Bool {
        get {
            guard let environment = environments[connectionEnvironment.rawValue] else { return false }
            return environment.enableOther
        }
        set {
            guard var environment = environments[connectionEnvironment.rawValue] else { return }
            environment.enableOther = newValue
            environments[connectionEnvironment.rawValue] = environment
        }
    }

    var enableEndSessiontUI: Bool {
        get {
            guard let environment = environments[connectionEnvironment.rawValue] else { return false }
            return environment.enableEndSessionUI
        }
        set {
            guard var environment = environments[connectionEnvironment.rawValue] else { return }
            environment.enableEndSessionUI = newValue
            environments[connectionEnvironment.rawValue] = environment
        }
    }

    var enableTranscriptUI: Bool {
        get {
            guard let environment = environments[connectionEnvironment.rawValue] else { return false }
            return environment.enableTranscriptUI
        }
        set {
            guard var environment = environments[connectionEnvironment.rawValue] else { return }
            environment.enableTranscriptUI = newValue
            environments[connectionEnvironment.rawValue] = environment
        }
    }

    var useProgressIndicatorsForAgents: Bool {
        get {
            guard let environment = environments[connectionEnvironment.rawValue] else { return false }
            return environment.useProgressIndicatorForAgents
        }
        set {
            guard var environment = environments[connectionEnvironment.rawValue] else { return }
            environment.useProgressIndicatorForAgents = newValue
            environments[connectionEnvironment.rawValue] = environment
        }
    }

    func allowedFileTypes() -> AllowedFileTypes {
        guard let environment = environments[connectionEnvironment.rawValue] else { return AllowedFileTypes() }
        return AllowedFileTypes(image: environment.enableImages ? FileTypeSettings.defaultImageExtensions : [],
                                video: environment.enableVideos ? FileTypeSettings.defaultVideoExtensions : [],
                                audio: environment.enableAudio ? FileTypeSettings.defaultAudioExtensions : [],
                                text: environment.enableText ? FileTypeSettings.defaultTextExtensions : [],
                                other: environment.enableOther ? FileTypeSettings.defaultOtherExtensions : [])

    }
}

// MARK: - Convenience Computed Vars
extension MIAWConfigurationStore {
    var config: Configuration {
        Configuration(serviceAPI: serviceAPIURL,
                      organizationId: organizationId,
                      developerName: developerName,
                      userVerificationRequired: authorizationMethod == .passthrough || authorizationMethod == .userVerified)
    }

    var serviceAPIURL: URL {
        var serviceAPI = domain
        let useSSL = useSSL

        serviceAPI = serviceAPI.replacingOccurrences(of: "https://", with: "")
        serviceAPI = serviceAPI.replacingOccurrences(of: "http://", with: "")

        var sanitizedURL = (useSSL ? "https://" : "http://") + serviceAPI

        sanitizedURL = sanitizedURL.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let defaultURL = URL(string: "invalid://noop") else { fatalError("Invalid URL") }

        let url = URL(string: sanitizedURL) ?? defaultURL
        return url
    }
}

extension UrlDisplayMode: @retroactive CaseIterable, @retroactive Identifiable {
    public static var allCases: [UrlDisplayMode] = [.externalBrowser, .inlineBrowser]

    public var id: String { rawValue }
}

#Preview {
    Form {
        MIAWConfigurationSettings()
        DeveloperStettings()
    }
}
