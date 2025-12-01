//
//  MessagingSessionWidgetView.swift
//  MessagingUIExample
//
//  Created on 2025-11-25.
//  Copyright © 2025 Salesforce.com. All rights reserved.
//

import SwiftUI
import UIKit
import Combine
import SMIClientCore

// SwiftUI wrapper for the UIKit-based messaging session widget
struct MessagingSessionWidgetView: UIViewControllerRepresentable {
    let conversationClient: ConversationClient
    let widgetType: MessagingSessionWidgetType
    let openChatAction: () -> Void
    let controller: WidgetViewController

    init(conversationClient: ConversationClient, widgetType: MessagingSessionWidgetType, openChatAction: @escaping () -> Void) {
        self.conversationClient = conversationClient
        self.widgetType = widgetType
        self.openChatAction = openChatAction
        self.controller =  WidgetViewController(
            conversationClient: conversationClient,
            widgetType: widgetType,
            openChatAction: openChatAction)
    }

    func makeUIViewController(context: Context) -> WidgetViewController {
        controller
    }
    
    func updateUIViewController(_ uiViewController: WidgetViewController, context: Context) {
        uiViewController.updateContent()
    }

    func feedVisibillity(_ visible: Bool) {
        controller.isChatFeedVisible = visible
    }
}

// UIKit view controller that displays the widget
class WidgetViewController: UIViewController {
    
    // MARK: - Properties
    private let conversationClient: ConversationClient
    private let widgetType: MessagingSessionWidgetType
    private let openChatAction: () -> Void
    
    private var containerView: UIView!
    private var closeButton: UIButton!
    private var chatIconView: UIImageView!
    private var infoLabel: UILabel!
    private var unreadBadge: UIView!
    private var unreadLabel: UILabel!

    var unreadCount: Int = 0
    var queuePosition: Int? = nil
    var sessionStatus: String = "Session Status: Unknown"
    var agentName: String?

    public var isChatFeedVisible: Bool = false

    // MARK: - Constants
    private enum Constants {
        static let widgetWidth: CGFloat = 200
        static let widgetHeight: CGFloat = 80
        static let cornerRadius: CGFloat = 12
        static let padding: CGFloat = 12
        static let buttonSize: CGFloat = 24
        static let iconSize: CGFloat = 32
        static let badgeSize: CGFloat = 20
        static let offsetX: CGFloat = -20
        static let offsetY: CGFloat = -20
    }
    
    // MARK: - Initialization
    init(conversationClient: ConversationClient,
         widgetType: MessagingSessionWidgetType,
         openChatAction: @escaping () -> Void) {
        self.conversationClient = conversationClient
        self.widgetType = widgetType
        self.openChatAction = openChatAction

        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        updateContent()

        // Register the delegate
        conversationClient.addDelegate(delegate: self, queue: .main)

        // Determine the starting state of the session
        conversationClient.entries(withLimit: 0, fromTimestamp: nil, direction: .descending, behaviour: .localOnly) { entries, _, error in
            if error == nil {
                guard let entry = entries?.first(where: { ($0.payload as? SessionStatusChanged) != nil }) else {
                    return
                }
                if let payload = entry.payload as? SessionStatusChanged {
                    self.sessionStatus = self.readableSessionStatus(sessionStatus: payload.sessionStatus)
                    self.updateContent()
                }
            }
        }

        // See if there are any active participants in the conversation
        conversationClient.conversation { conversation, error in
            if error == nil {
                guard let participants = conversation?.participants else {
                    return
                }
                for participant in participants {
                    if participant.role == .agent || participant.role == .chatbot {
                        self.agentName = participant.displayName
                        return
                    }
                }
            }
        }
    }
    
    // MARK: - Setup
    private func setupViews() {
        view.backgroundColor = .clear
        
        // Set view to match container size
        view.translatesAutoresizingMaskIntoConstraints = false
        
        // Container view
        containerView = UIView()
        containerView.backgroundColor = .systemBackground
        containerView.layer.cornerRadius = Constants.cornerRadius
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowOpacity = 0.2
        containerView.layer.shadowRadius = 4
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        
        // Close button (X)
        closeButton = UIButton(type: .system)
        closeButton.setTitle("✕", for: .normal)
        closeButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(closeButton)
        
        // Chat icon
        chatIconView = UIImageView()
        chatIconView.image = UIImage(systemName: "message.fill")
        chatIconView.tintColor = .systemBlue
        chatIconView.contentMode = .scaleAspectFit
        chatIconView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(chatIconView)
        
        // Info label
        infoLabel = UILabel()
        infoLabel.font = .systemFont(ofSize: 14, weight: .medium)
        infoLabel.textColor = .label
        infoLabel.numberOfLines = 2
        infoLabel.textAlignment = .left
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(infoLabel)
        
        // Unread badge (only for agent name view)
        unreadBadge = UIView()
        unreadBadge.backgroundColor = .systemRed
        unreadBadge.layer.cornerRadius = Constants.badgeSize / 2
        unreadBadge.isHidden = true
        unreadBadge.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(unreadBadge)
        
        unreadLabel = UILabel()
        unreadLabel.font = .systemFont(ofSize: 12, weight: .bold)
        unreadLabel.textColor = .white
        unreadLabel.textAlignment = .center
        unreadLabel.translatesAutoresizingMaskIntoConstraints = false
        unreadBadge.addSubview(unreadLabel)
        
        // Tap gesture to open chat
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(widgetTapped))
        containerView.addGestureRecognizer(tapGesture)
        containerView.isUserInteractionEnabled = true
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // View controller view constraints
            view.widthAnchor.constraint(equalToConstant: Constants.widgetWidth),
            view.heightAnchor.constraint(equalToConstant: Constants.widgetHeight),
            
            // Container view
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: view.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Close button
            closeButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            closeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            closeButton.widthAnchor.constraint(equalToConstant: Constants.buttonSize),
            closeButton.heightAnchor.constraint(equalToConstant: Constants.buttonSize),
            
            // Chat icon
            chatIconView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constants.padding),
            chatIconView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            chatIconView.widthAnchor.constraint(equalToConstant: Constants.iconSize),
            chatIconView.heightAnchor.constraint(equalToConstant: Constants.iconSize),
            
            // Info label
            infoLabel.leadingAnchor.constraint(equalTo: chatIconView.trailingAnchor, constant: 12),
            infoLabel.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -8),
            infoLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            // Unread badge
            unreadBadge.topAnchor.constraint(equalTo: containerView.topAnchor, constant: -4),
            unreadBadge.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: -4),
            unreadBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: Constants.badgeSize),
            unreadBadge.heightAnchor.constraint(equalToConstant: Constants.badgeSize),
            
            // Unread label
            unreadLabel.centerXAnchor.constraint(equalTo: unreadBadge.centerXAnchor),
            unreadLabel.centerYAnchor.constraint(equalTo: unreadBadge.centerYAnchor),
            unreadLabel.leadingAnchor.constraint(equalTo: unreadBadge.leadingAnchor, constant: 4),
            unreadLabel.trailingAnchor.constraint(equalTo: unreadBadge.trailingAnchor, constant: -4)
        ])
    }

    // MARK: - Actions
    @objc private func closeButtonTapped() {
        conversationClient.closeConversation(completion: { error in
            if error != nil {
                print(error ?? "")
            }
        })
    }
    
    @objc private func widgetTapped() {
        unreadCount = 0
        updateContent()
        openChatAction()
    }
    
    // MARK: - Content Updates
    func updateContent() {
        DispatchQueue.main.async {
            switch self.widgetType {
            case .queuePosition:
                if let position = self.queuePosition {
                    self.infoLabel.text = "Queue Position: \(position)"
                } else {
                    self.infoLabel.text = "Queue Position: ?"
                }
                self.unreadBadge.isHidden = true

            case .sessionStatus:
                self.infoLabel.text = self.sessionStatus
                self.unreadBadge.isHidden = true

            case .agentName:
                let name = self.agentName ?? "No Agent"
                self.infoLabel.text = "Agent:\n\(name)"

                // Show unread badge if there are unread messages
                if self.unreadCount > 0 {
                    self.unreadBadge.isHidden = false
                    self.unreadLabel.text = self.unreadCount > 99 ? "99+" : "\(self.unreadCount)"
                } else {
                    self.unreadBadge.isHidden = true
                }
            }
            self.view.layoutSubviews()
        }
    }

    func readableSessionStatus(sessionStatus: SessionStatus) -> String {
        switch sessionStatus {
        case .unknown:
            return "Session Status: Unknown"
        case .active:
            return "Session Status: Active"
        case .inactive:
            return "Session Status: InActive"
        case .ended:
            return "Session Status: Ended"
        default:
            return "Session Status: Unknown"
        }
    }
}

