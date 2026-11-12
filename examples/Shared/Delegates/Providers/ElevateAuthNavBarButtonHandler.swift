//
//  ElevateAuthNavBarButtonHandler.swift
//

import UIKit
import SMIClientCore

class ElevateAuthNavBarButtonHandler: NSObject {
    var client: ConversationClient?

    func addButton(to navigationItem: UINavigationItem) {
        let elevateButton = UIBarButtonItem(
            image: UIImage(systemName: "person.badge.shield.checkmark"),
            style: .plain,
            target: self,
            action: #selector(elevateButtonTapped)
        )
        elevateButton.accessibilityLabel = "Elevate Auth"

        if let existing = navigationItem.rightBarButtonItems {
            navigationItem.rightBarButtonItems = existing + [elevateButton]
        } else {
            navigationItem.rightBarButtonItem = elevateButton
        }
    }

    @objc private func elevateButtonTapped() {
        guard let core = client?.core else { return }

        core.elevateAuth { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.presentAlert(title: "Elevate Auth Failed", message: error.localizedDescription)
                } else {
                    self?.presentAlert(title: "Elevate Auth", message: "The session is user verified.")
                }
            }
        }
    }

    private func presentAlert(title: String, message: String) {
        guard let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
              let rootViewController = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController
        else { return }

        var topViewController = rootViewController
        while let presented = topViewController.presentedViewController {
            topViewController = presented
        }

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        topViewController.present(alert, animated: true)
    }
}
