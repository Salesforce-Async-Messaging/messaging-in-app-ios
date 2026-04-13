//
//  VoiceTranscriptProvider.swift
//

import Foundation
import Combine
import SMIClientCore

final class VoiceTranscriptProvider: NSObject, ObservableObject {
    @Published private(set) var entries: [VoiceTranscriptEntry] = []

    private weak var client: ConversationClient?

    init(client: ConversationClient) {
        self.client = client
        super.init()
        client.addDelegate(delegate: self, queue: .main)
    }

    deinit {
        client?.removeDelegate(delegate: self)
    }
}

// MARK: - ConversationClientDelegate

extension VoiceTranscriptProvider: ConversationClientDelegate {

    func client(_ client: ConversationClient, didReceiveEntries entries: [ConversationEntry], paged: Bool) {
        for entry in entries {
            handleReceivedEntry(entry)
        }
    }

    func client(_ client: ConversationClient, didUpdateEntries entries: [ConversationEntry]) {
        for entry in entries {
            handleUpdatedEntry(entry)
        }
    }

    // MARK: - Entry Processing

    private func handleReceivedEntry(_ entry: ConversationEntry) {
        if entry.type == .streamingToken {
            handleStreamingToken(entry)
        } else if entry.type == .message {
            handleMessage(entry)
        }
    }

    private func handleUpdatedEntry(_ entry: ConversationEntry) {
        if entry.type == .streamingToken {
            handleStreamingTokenUpdate(entry)
        } else if entry.type == .message {
            handleMessageUpdate(entry)
        }
    }

    private func handleStreamingToken(_ entry: ConversationEntry) {
        guard let composedToken = entry.payload as? ComposedStreamingToken,
              let formatText = composedToken.derivedValue as? EntryFormatText,
              let text = formatText.text as String? else { return }

        let targetIdentifier = composedToken.targetMessageIdentifier

        if let existing = entries.first(where: { $0.identifier == targetIdentifier }) {
            objectWillChange.send()
            existing.text = text
        } else {
            let transcriptEntry = VoiceTranscriptEntry(
                identifier: targetIdentifier,
                senderName: entry.senderDisplayName,
                isLocal: entry.sender.isLocal,
                text: text,
                isFinal: false,
                timestamp: entry.timestamp as Date
            )
            entries.append(transcriptEntry)
        }
    }

    private func handleStreamingTokenUpdate(_ entry: ConversationEntry) {
        guard let composedToken = entry.payload as? ComposedStreamingToken,
              let formatText = composedToken.derivedValue as? EntryFormatText,
              let text = formatText.text as String? else { return }

        let targetIdentifier = composedToken.targetMessageIdentifier

        if let existing = entries.first(where: { $0.identifier == targetIdentifier }) {
            objectWillChange.send()
            existing.text = text
        }
    }

    private func handleMessage(_ entry: ConversationEntry) {
        if let existing = entries.first(where: { $0.identifier == entry.identifier }) {
            objectWillChange.send()
            if let textMessage = entry.payload as? TextMessage {
                existing.text = textMessage.text as String
            }
            existing.isFinal = true
            return
        }

        guard let textMessage = entry.payload as? TextMessage else { return }

        let transcriptEntry = VoiceTranscriptEntry(
            identifier: entry.identifier,
            senderName: entry.senderDisplayName,
            isLocal: entry.sender.isLocal,
            text: textMessage.text as String,
            isFinal: true,
            timestamp: entry.timestamp as Date
        )
        entries.append(transcriptEntry)
    }

    private func handleMessageUpdate(_ entry: ConversationEntry) {
        guard let existing = entries.first(where: { $0.identifier == entry.identifier }),
              let textMessage = entry.payload as? TextMessage else { return }

        objectWillChange.send()
        existing.text = textMessage.text as String
        existing.isFinal = true
    }
}
