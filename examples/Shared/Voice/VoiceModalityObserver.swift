//
//  VoiceModalityObserver.swift
//

import Foundation
import SMIClientCore
import SMIMultimediaCommon

final class VoiceModalityObserver: NSObject, ObservableObject, ConversationClientDelegate {
    @Published var voiceSupported: Bool = false

    func updateVoiceSupport(from supportedModalities: [Modality]) {
        DispatchQueue.main.async {
            self.voiceSupported = supportedModalities.contains(.voice)
        }
    }

    func client(_ client: ConversationClient, didUpdateSupportedModalities supportedModalities: [Modality]) {
        updateVoiceSupport(from: supportedModalities)
    }

    func client(_ client: ConversationClient, didUpdate conversation: Conversation) {
        updateVoiceSupport(from: conversation.supportedModalities)
    }
}
