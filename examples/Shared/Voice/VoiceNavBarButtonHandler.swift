//
//  VoiceNavBarButtonHandler.swift
//

import SwiftUI
import Combine
import SMIClientCore
import SMIMultimediaCommon

class VoiceNavBarButtonHandler: NSObject {
    private let modalityObserver = VoiceModalityObserver()
    private var voiceButtonCancellables = Set<AnyCancellable>()
    private var expandedState = VoiceSheetExpandedState()
    private weak var presentedVoiceController: UIViewController?

    var client: ConversationClient? {
        didSet {
            guard let client = client else { return }
            client.addDelegate(delegate: modalityObserver, queue: .main)
            client.core?.multimediaClient?.add(delegate: self, queue: .main)
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
        guard let client = client,
              presentedVoiceController == nil else { return }

        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)

        if let session = client.core?.multimediaClient?.currentSession {
            handleSession(session)
        } else {
            client.changeModalities([.voice])
        }
    }

    private func handleSession(_ session: MultimediaSessionProtocol) {
        switch session.state {
        case .initial:
            session.join { error in
                if let error = error {
                    print("Multimedia Join Result: \(error)")
                }
            }
            presentVoiceControlPanel()
        case .connecting, .connected:
            presentVoiceControlPanel()
        default:
            client?.changeModalities([.voice])
        }
    }

    private func presentVoiceControlPanel() {
        guard let client = client,
              presentedVoiceController == nil else { return }

        expandedState.isExpanded = true

        let controller = UIHostingController(
            rootView: VoiceControlPanel(client: client, expandedState: expandedState)
        )
        controller.modalPresentationStyle = .pageSheet

        configureSheetDetents(for: controller)

        guard let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
              let rootViewController = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController
        else { return }

        var topViewController = rootViewController
        while let presented = topViewController.presentedViewController {
            topViewController = presented
        }

        presentedVoiceController = controller
        topViewController.present(controller, animated: true)
    }

    private func configureSheetDetents(for controller: UIViewController) {
        guard let sheetController = controller.sheetPresentationController else { return }

        let compactIdentifier = UISheetPresentationController.Detent.Identifier("compact")
        let compactDetent = UISheetPresentationController.Detent.custom(identifier: compactIdentifier) { _ in
            return VoiceControlPanel.Constants.compactDetentHeight
        }

        sheetController.detents = [compactDetent, .large()]
        sheetController.selectedDetentIdentifier = .large
        sheetController.prefersGrabberVisible = true
        sheetController.prefersScrollingExpandsWhenScrolledToEdge = false
        sheetController.largestUndimmedDetentIdentifier = compactIdentifier
        sheetController.prefersEdgeAttachedInCompactHeight = true
        sheetController.delegate = self
    }
}

// MARK: - Multimedia Client Delegate

extension VoiceNavBarButtonHandler: MultimediaClientDelegate {
    func client(_ client: any MultimediaClientProtocol, didUpdateSession session: any MultimediaSessionProtocol) {
        handleSession(session)
    }
}

// MARK: - Sheet Delegate

extension VoiceNavBarButtonHandler: UISheetPresentationControllerDelegate {
    func sheetPresentationControllerDidChangeSelectedDetentIdentifier(
        _ sheetPresentationController: UISheetPresentationController
    ) {
        expandedState.isExpanded = sheetPresentationController.selectedDetentIdentifier == .large
    }
}

// MARK: - Shared State

final class VoiceSheetExpandedState: ObservableObject {
    @Published var isExpanded: Bool = true
}
