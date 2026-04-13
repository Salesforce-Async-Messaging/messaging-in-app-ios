//
//  VoiceTranscriptEntry.swift
//

import Foundation
import Combine

final class VoiceTranscriptEntry: ObservableObject, Identifiable {
    let identifier: String
    let senderName: String
    let isLocal: Bool
    let timestamp: Date

    @Published var text: String
    @Published var isFinal: Bool

    var id: String { identifier }

    init(identifier: String, senderName: String, isLocal: Bool, text: String, isFinal: Bool, timestamp: Date) {
        self.identifier = identifier
        self.senderName = senderName
        self.isLocal = isLocal
        self.text = text
        self.isFinal = isFinal
        self.timestamp = timestamp
    }
}
