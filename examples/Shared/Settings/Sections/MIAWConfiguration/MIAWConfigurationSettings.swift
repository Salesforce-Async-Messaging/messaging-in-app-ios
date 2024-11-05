//
//  MIAWConfigurationSettings.swift
//

import SwiftUI
import SMIClientCore
import SMIClientUI

typealias MIAWConfigurationStore = SettingsStore<MIAWConfigurationSettings.SettingsKeys>

struct MIAWConfigurationSettings: View {
    static let header = "MIAW Configuration"

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

    var body: some View {
        SettingsSection(Self.header) {
            SettingsPicker("Connection Environment", developerOnly: true, value: $store.connectionEnvironment)
            SettingsTextField("Domain",
                              placeholder: "Enter your Domain",
                              value: $store.domain,
                              enabled: store.connectionEnvironment.editableDomain)
            
            SettingsTextField("Organization Id",
                              placeholder: "Enter your Organization Id",
                              value: $store.organizationId,
                              enabled: store.connectionEnvironment.editableOrganizationId)
            
            SettingsTextField("Developer Name", placeholder: "Enter your Developer Name", value: $store.developerName)
            
            SettingsToggle("Attachment UI Enabled", developerOnly: true, isOn: $store.enableAttachmentUI)
            SettingsToggle("Transcript Enabled", developerOnly: true, isOn: $store.enableTranscriptUI)
            SettingsToggle("User Verifcation Required", isOn: $store.userVerificationRequired)
            SettingsPicker("URL Display Mode", value: $store.URLDisplayMode)
        }
    }
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

    var userVerificationRequired: Bool {
        get {
            guard let environment = environments[connectionEnvironment.rawValue] else { return false }
            return environment.userVerificationRequired
        }
        set {
            guard var environment = environments[connectionEnvironment.rawValue] else { return }
            environment.userVerificationRequired = newValue
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
}

// MARK: - Convenience Computed Vars
extension MIAWConfigurationStore {
    var config: Configuration {
        Configuration(serviceAPI: serviceAPIURL,
                      organizationId: organizationId,
                      developerName: developerName,
                      userVerificationRequired: userVerificationRequired)
    }

    var serviceAPIURL: URL {
        var serviceAPI = domain

        serviceAPI = serviceAPI.replacingOccurrences(of: "https://", with: "")
        serviceAPI = serviceAPI.replacingOccurrences(of: "http://", with: "")

        var sanitizedURL = "https://" + serviceAPI

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
