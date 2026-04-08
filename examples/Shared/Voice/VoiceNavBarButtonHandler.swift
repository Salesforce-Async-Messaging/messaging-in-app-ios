//
//  VoiceNavBarButtonHandler.swift
//

import SwiftUI
import Combine
import SMIClientCore

class VoiceNavBarButtonHandler: NSObject {
    private let modalityObserver = VoiceModalityObserver()
    private var voiceButtonCancellables = Set<AnyCancellable>()

    var client: ConversationClient? {
        didSet {
            guard let client = client else { return }
            client.addDelegate(delegate: modalityObserver, queue: .main)
            client.conversation { [weak self] conversation, _ in
                guard let conversation = conversation else { return }
                self?.modalityObserver.updateVoiceSupport(from: conversation.supportedModalities)
            }
        }
    }

    func addButton(to navigationItem: UINavigationItem) {
        voiceButtonCancellables.removeAll()
        modalityObserver.voiceSupported = false

        let voiceButton = UIBarButtonItem(
            image: UIImage(systemName: "phone.fill"),
            style: .plain,
            target: self,
            action: #selector(voiceButtonTapped)
        )
        voiceButton.isEnabled = false

        modalityObserver.$voiceSupported
            .receive(on: DispatchQueue.main)
            .sink { [weak voiceButton] supported in
                voiceButton?.isEnabled = supported
            }
            .store(in: &voiceButtonCancellables)

        if let existing = navigationItem.rightBarButtonItem {
            navigationItem.rightBarButtonItems = [existing, voiceButton]
        } else {
            navigationItem.rightBarButtonItem = voiceButton
        }

        client?.conversation { [weak self] conversation, _ in
            guard let conversation = conversation else { return }
            self?.modalityObserver.updateVoiceSupport(from: conversation.supportedModalities)
        }
    }

    @objc private func voiceButtonTapped() {
        guard let client = client else { return }
        client.changeModalities([.voice])

        let controller = UIHostingController(rootView: VoiceControlPanel(client: client))
        controller.modalPresentationStyle = .pageSheet

        guard let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
              let rootViewController = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController
        else { return }

        var topViewController = rootViewController
        while let presented = topViewController.presentedViewController {
            topViewController = presented
        }
        topViewController.present(controller, animated: true)
    }
}
