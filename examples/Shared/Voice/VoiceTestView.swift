//
//  VoiceTestView.swift
//

import SwiftUI
import SMIClientCore
import SMIClientUI
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

struct VoiceOverlayModifier: ViewModifier {
    private enum Constants {
        static let voiceButtonSize: CGFloat = 56
        static let voiceButtonPadding: CGFloat = 20
        static let voiceIconSize: CGFloat = 24
        static let inputBarClearance: CGFloat = 60
    }

    let config: UIConfiguration

    @StateObject private var modalityObserver = VoiceModalityObserver()
    @StateObject private var voiceStore = VoiceStore()
    @State private var conversationClient: ConversationClient?
    @State private var showVoiceSheet: Bool = false

    func body(content: Content) -> some View {
        ZStack(alignment: .bottomTrailing) {
            content

            if voiceStore.enableVoiceFAB, let client = conversationClient {
                voiceButton(client: client)
            }
        }
        .sheet(isPresented: $showVoiceSheet) {
            if let client = conversationClient {
                VoiceControlPanel(client: client)
            }
        }
        .onChange(of: modalityObserver.voiceSupported) { _, voiceSupported in
            if !voiceSupported {
                showVoiceSheet = false
            }
        }
        .onAppear {
            if voiceStore.enableVoiceFAB {
                setupClients()
            }
        }
    }

    @ViewBuilder
    private func voiceButton(client: ConversationClient) -> some View {
        Button {
            showVoiceSheet = true
            client.changeModalities([.voice])
        } label: {
            Image(systemName: "phone.fill")
                .resizable()
                .scaledToFit()
                .frame(width: Constants.voiceIconSize, height: Constants.voiceIconSize)
                .foregroundColor(.white)
                .frame(width: Constants.voiceButtonSize, height: Constants.voiceButtonSize)
                .background(modalityObserver.voiceSupported ? Color.green : Color.gray)
                .clipShape(Circle())
                .shadow(radius: 4)
        }
        .disabled(!modalityObserver.voiceSupported)
        .padding(Constants.voiceButtonPadding)
        .padding(.bottom, Constants.inputBarClearance)
    }

    private func setupClients() {
        let core = CoreFactory.create(withConfig: config)
        let client = core.conversationClient(with: config.conversationId)
        client.addDelegate(delegate: modalityObserver, queue: .main)
        self.conversationClient = client

        client.conversation { [weak modalityObserver] conversation, _ in
            guard let conversation = conversation else { return }
            modalityObserver?.updateVoiceSupport(from: conversation.supportedModalities)
        }
    }
}

extension View {
    func withVoiceOverlay(config: UIConfiguration) -> some View {
        modifier(VoiceOverlayModifier(config: config))
    }
}
