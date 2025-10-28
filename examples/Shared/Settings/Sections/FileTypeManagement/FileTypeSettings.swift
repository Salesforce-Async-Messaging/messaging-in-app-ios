//  DateBreakReplacement.swift
//  MessagingUIExample
//
//  Created by Aaron Eisses on 2025-09-08.
//  Copyright © 2025 Salesforce.com. All rights reserved.
//

import SwiftUI
import SMIClientUI

struct FileTypeSettings: View {
    static let header: String = "Allowed File Types"
    @StateObject var miawConfigurationStore: MIAWConfigurationStore

    enum SettingsKeys: String, Settings {
        public var id: String { rawValue }

        var defaultValue: Any {
            switch self {
            case .enableImages:
                return false
            case .enableVideos:
                return false
            case .enableAudio:
                return false
            case .enableText:
                return false
            case .enableOther:
                return false
            }
        }

        var resettable: Bool {
            switch self {
            case .enableImages: false
            case .enableVideos: false
            case .enableAudio: false
            case .enableText: false
            case .enableOther: false
            }
        }

        static func handleReset() {}

        case enableImages
        case enableVideos
        case enableAudio
        case enableText
        case enableOther
    }

    static let defaultImageExtensions = ["png", "jpg", "jpeg", "gif", "bmp", "tiff"]
    static let defaultVideoExtensions = ["mp4", "m4v", "avi", "mov", "qt", "wmv", "flv", "webm", "mkv", "3gp", "ogv", "mpg", "mpeg"]
    static let defaultAudioExtensions = ["mp3", "m4a", "aac", "wav", "wave", "flac", "ogg", "oga", "wma", "amr", "opus"]
    static let defaultTextExtensions = ["txt", "csv", "text"]
    static let defaultOtherExtensions = ["pdf", "xml", "doc", "docx", "xls", "xlsx"]

    var body: some View {
        Form {
            Section(header: Text(Self.header)) {
                Instructions(
                    instructions:
                        "Configure which file types are allowed for attachment uploads." +
                        "This affects the file picker and attachment functionality in the chat feed.",
                    note: "Changes will apply to new conversations. Existing conversations will use their current settings.",
                    section: false
                )

                VStack(alignment: .leading, spacing: 8) {
                    Text("Current Configuration:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)

                SettingsToggle("Images", isOn: $miawConfigurationStore.enableImages)
                    .help("Allow image files (PNG, JPEG, GIF, BMP, TIFF)")
                SettingsToggle("Videos", isOn: $miawConfigurationStore.enableVideos)
                    .help("Allow video files (MP4, AVI, MOV, WebM, MKV, etc.)")
                SettingsToggle("Audio", isOn: $miawConfigurationStore.enableAudio)
                    .help("Allow audio files (MP3, WAV, AAC, FLAC, OGG, etc.)")
                SettingsToggle("Text Files", isOn: $miawConfigurationStore.enableText)
                    .help("Allow text files (TXT, CSV)")
                SettingsToggle("Other Files", isOn: $miawConfigurationStore.enableOther)
                    .help("Allow other files (PDF, XML, DOC, XLS, etc.)")
                .foregroundColor(.blue)
                .padding(.top, 8)
            }
        }
    }
}

#Preview {
    Form {
        FileTypeSettings(miawConfigurationStore: MIAWConfigurationStore())
    }
}
