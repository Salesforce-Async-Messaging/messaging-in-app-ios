//
//  UIKitSessionWidget.swift
//  MessagingUIExample
//
//  Created by Aaron Eisses on 2025-11-26.
//

import SwiftUI
import SMIClientUI
import SMIClientCore
import WebKit

struct UIKitSessionWidget: UIViewControllerRepresentable {
    typealias UIViewControllerType = Controller

    func makeUIViewController(context: Context) -> Controller {
        Controller()
    }

    func updateUIViewController(_ uiViewController: Controller, context: Context) {}

    class Controller: UIViewController, UINavigationControllerDelegate {

         static let selectedWidgetType: MessagingSessionWidgetType = .sessionStatus

        enum Constants {
            static let widgetOffsetX: CGFloat = -20
            static let widgetOffsetY: CGFloat = -20
        }

        let demoManagementStore: DemoManagementStore = DemoManagementStore()
        let configurationStore: MIAWConfigurationStore = MIAWConfigurationStore()
        let conversationManagementStore: ConversationManagementStore = ConversationManagementStore()
        let uiReplacementStore: UIReplacementStore = UIReplacementStore()
        let remoteLocaleStore: RemoteLocaleStore = RemoteLocaleStore()

        let uiConfiguration: UIConfiguration
        var messagingSessionWidget: MessagingSessionWidget?
        private var widgetHostingController: UIHostingController<AnyView>?

        init() {
            self.uiConfiguration = UIConfiguration(configuration: configurationStore.config,
                                                   conversationId: conversationManagementStore.conversationUUID,
                                                   remoteLocaleMap: remoteLocaleStore.remoteLocaleMap,
                                                   urlDisplayMode: configurationStore.URLDisplayMode)

            uiConfiguration.conversationOptionsConfiguration = ConversationOptionsConfiguration(allowEndChat: configurationStore.enableEndSessiontUI)
            uiConfiguration.transcriptConfiguration = TranscriptConfiguration(allowTranscriptDownload: configurationStore.enableTranscriptUI)
            uiConfiguration.attachmentConfiguration = AttachmentConfiguration(endUserToAgent: configurationStore.enableAttachmentUI)

            GlobalCoreDelegateHandler.shared.registerDelegates(CoreFactory.create(withConfig: uiConfiguration))
            super.init(nibName: nil, bundle: nil)
        }

        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

        override func loadView() {
            guard let url = URL(string: "https://\(demoManagementStore.demoDomain)") else {
                super.loadView()
                return
            }

            let webView = WKWebView()
            webView.load(URLRequest(url: url))
            webView.allowsBackForwardNavigationGestures = true

            view = webView
        }

        override func viewDidLoad() {
            super.viewDidLoad()
            self.navigationController?.delegate = self
            setupFloatingButton()
        }

        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)

            // Make sure the SSE stream is closed when we leave the UIKitSessionWidget view
            let coreClient = CoreFactory.create(withConfig: uiConfiguration)
            coreClient.stop()
        }

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)

            // Make sure the SSE stream is open when the screen first appears
            let coreClient = CoreFactory.create(withConfig: uiConfiguration)
            coreClient.start()
        }

        func setupFloatingButton() {
            // Create conversation client and widget
            let conversationClient: ConversationClient = CoreFactory.create(withConfig: uiConfiguration).conversationClient(with: conversationManagementStore.conversationUUID)
            messagingSessionWidget = MessagingSessionWidget(
                conversationClient: conversationClient,
                openChatFeed: { [weak self] in
                    self?.openChatFeed()
                }
            )

            guard let widget = messagingSessionWidget else { return }

            // Select which widget view to display
            // Uncomment one of the following lines to select the widget type:
            let widgetView: AnyView
            // widgetView = AnyView(widget.queuePositionView())  // Queue position widget
            // widgetView = AnyView(widget.sessionStatusView())     // Session status widget (currently selected)
            widgetView = AnyView(widget.agentNameView())     // Agent name with unread counter widget

            // Create hosting controller for SwiftUI view
            let hostingController = UIHostingController(rootView: widgetView)
            hostingController.view.backgroundColor = .clear
            hostingController.view.translatesAutoresizingMaskIntoConstraints = false

            // Add as child view controller
            addChild(hostingController)
            view.addSubview(hostingController.view)
            hostingController.didMove(toParent: self)

            // Position widget in lower right corner
            NSLayoutConstraint.activate([
                hostingController.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: Constants.widgetOffsetX),
                hostingController.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: Constants.widgetOffsetY),
                hostingController.view.widthAnchor.constraint(equalToConstant: 200),
                hostingController.view.heightAnchor.constraint(equalToConstant: 80)
            ])

            self.widgetHostingController = hostingController
        }

        private func openChatFeed() {
            let coreClient: CoreClient = CoreFactory.create(withConfig: uiConfiguration)
            coreClient.stop()
            messagingSessionWidget?.feedVisibillity(true)

            let testEntryViewBuilder = GlobalCoreDelegateHandler.shared.viewBuilder
            let testNavBarBuilder = GlobalCoreDelegateHandler.shared.navBarBuilder
            let testPrePopulatedPreChatProvider = GlobalCoreDelegateHandler.shared.prePopulatedPreChatProvider.closure

            // We will only show the modalInterface. This give us accces to the back button so we know when to start the back ground SSE
            let controller = ModalInterfaceViewController(uiConfiguration,
                                                          preChatFieldValueProvider: testPrePopulatedPreChatProvider,
                                                          chatFeedViewBuilder: testEntryViewBuilder,
                                                          navigationBarBuilder: testNavBarBuilder)

            controller.modalPresentationStyle = demoManagementStore.modalPresentationStyle.systemValue
            // Override the back button in the chat feed, so we know when the chat feed is minimized
            controller.modalDismissButton = UIBarButtonItem(title: demoManagementStore.dismissButtonTitle,
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(dismissChatFeed(sender:)))

            self.present(controller, animated: true)

            let popover: UIPopoverPresentationController? = controller.popoverPresentationController
            popover?.permittedArrowDirections = .any
            popover?.sourceView = self.view
            popover?.sourceRect = CGRect(x: view.bounds.width - 220, y: view.bounds.height - 100, width: 200, height: 80)
        }

        @objc private func dismissChatFeed(sender: UIBarButtonItem) {
            self.dismiss(animated: true)
            // Wait for the feed to close before starting the stream
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [self] in
                let coreClient: CoreClient = CoreFactory.create(withConfig: uiConfiguration)
                coreClient.start()
                messagingSessionWidget?.feedVisibillity(false)
            }
        }
    }
}

#Preview {
    UIKitSessionWidget()
}
