//
//  UIKitMIAW.swift
//  MessagingUIExample
//
//  Created by Jeremy Wright on 2024-10-07.
//  Copyright © 2024 Salesforce.com. All rights reserved.
//

import SwiftUI
import SMIClientUI
import SMIClientCore
import WebKit

struct UIKitMIAW: UIViewControllerRepresentable {
    typealias UIViewControllerType = Controller

    func makeUIViewController(context: Context) -> Controller {
        Controller()
    }

    func updateUIViewController(_ uiViewController: Controller, context: Context) {}

    class Controller: UIViewController {
        enum Constants {
            static let chatButtonWidth: CGFloat = 60
            static let chatButtonHeight: CGFloat = 60
            static let chatButtonX: CGFloat = -30
            static let chatButtonY: CGFloat = -50
            static let widgetOffsetX: CGFloat = -20
            static let widgetOffsetY: CGFloat = -20
            static let widgetHeight: CGFloat = 80
            static let widgetWidth: CGFloat = 200
        }

        let demoManagementStore: DemoManagementStore = DemoManagementStore()
        let configurationStore: MIAWConfigurationStore = MIAWConfigurationStore()
        let conversationManagementStore: ConversationManagementStore = ConversationManagementStore()
        let uiReplacementStore: UIReplacementStore = UIReplacementStore()
        let remoteLocaleStore: RemoteLocaleStore = RemoteLocaleStore()

        let uiConfiguration: UIConfiguration
        var messagingSessionWidget: MessagingSessionWidget?
        private var widgetHostingController: UIHostingController<AnyView>?

        private lazy var floatingButton: RoundedButton = {
            var view = RoundedButton(image: "demoChatButton")
            view.translatesAutoresizingMaskIntoConstraints = false
            view.addTarget(self, action: #selector(startInApp), for: .touchUpInside)
            return view
        }()

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

            setupFloatingButton()
        }

        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)

            // Make sure the SSE stream is closed when we leave the UIKitSessionWidget view
            if demoManagementStore.isSessionWidgetEnabled {
                let coreClient = CoreFactory.create(withConfig: uiConfiguration)
                coreClient.stop()
            }
        }

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)

            // Make sure the SSE stream is open when the screen first appears
            if demoManagementStore.isSessionWidgetEnabled {
                let coreClient = CoreFactory.create(withConfig: uiConfiguration)
                coreClient.start()
            }
        }

        func setupFloatingButton() {
            if demoManagementStore.isSessionWidgetEnabled {
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
                    hostingController.view.widthAnchor.constraint(equalToConstant: Constants.widgetWidth),
                    hostingController.view.heightAnchor.constraint(equalToConstant: Constants.widgetHeight)
                ])

                self.widgetHostingController = hostingController
            } else {
                self.view.addSubview(floatingButton)

                NSLayoutConstraint.activate([
                    floatingButton.heightAnchor.constraint(equalToConstant: Constants.chatButtonHeight),
                    floatingButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: Constants.chatButtonY),
                    floatingButton.widthAnchor.constraint(equalToConstant: Constants.chatButtonWidth),
                    floatingButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: Constants.chatButtonX)
                ])
            }
        }

        @objc func startInApp(sender: UIButton!) {
            openChatFeed()
        }

        private func openChatFeed() {
            let testEntryViewBuilder = GlobalCoreDelegateHandler.shared.viewBuilder
            let testNavBarBuilder = GlobalCoreDelegateHandler.shared.navBarBuilder
            let testPrePopulatedPreChatProvider = GlobalCoreDelegateHandler.shared.prePopulatedPreChatProvider.closure

            if demoManagementStore.isModal || demoManagementStore.isSessionWidgetEnabled {
                let controller = ModalInterfaceViewController(uiConfiguration,
                                                              preChatFieldValueProvider: testPrePopulatedPreChatProvider,
                                                              chatFeedViewBuilder: testEntryViewBuilder,
                                                              navigationBarBuilder: testNavBarBuilder)

                controller.modalPresentationStyle = demoManagementStore.modalPresentationStyle.systemValue
                if demoManagementStore.replaceDismissButton || demoManagementStore.isSessionWidgetEnabled {
                    controller.modalDismissButton = UIBarButtonItem(title: demoManagementStore.dismissButtonTitle,
                                                                    style: .plain,
                                                                    target: self,
                                                                    action: #selector(dismissAction(sender:)))
                }

                self.present(controller, animated: true)

                let popover: UIPopoverPresentationController? = controller.popoverPresentationController
                popover?.permittedArrowDirections = .any
                popover?.sourceView = self.view
                popover?.sourceRect = CGRect(x: view.bounds.width - 220, y: view.bounds.height - 100, width: 200, height: 80)

                return
            }

            let controller = InterfaceViewController(uiConfiguration,
                                                     preChatFieldValueProvider: testPrePopulatedPreChatProvider,
                                                     chatFeedViewBuilder: testEntryViewBuilder)

            self.navigationController?.pushViewController(controller, animated: true)
        }

        @objc private func dismissAction(sender: UIBarButtonItem) {
            self.dismiss(animated: true)

            if demoManagementStore.isSessionWidgetEnabled {
                // Wait for the feed to close before starting the stream
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [self] in
                    let coreClient: CoreClient = CoreFactory.create(withConfig: uiConfiguration)
                    coreClient.start()
                    messagingSessionWidget?.feedVisibillity(false)
                }
            }
        }
    }
}

class RoundedButton: UIButton {

    internal enum Image {
        static let demoChatButton: String = "download-button"
        static let cornerRadius: CGFloat = 30
    }

    internal enum Shadow {
        static let opacity: Float = 0.4
        static let radius: CGFloat = 4
        static let offset: CGSize = CGSize(width: 0.0, height: 3.0)
    }

    internal enum Constant {
        static let insertionIndex: UInt32 = 0
    }

    let image: NSString
    private var imageLayer: CALayer!
    private var shadowLayer: CALayer!

    override func draw(_ rect: CGRect) {
        addShadowsLayers(rect)
    }

    init(image: NSString) {
         self.image = image

        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addShadowsLayers(_ rect: CGRect) {

        if self.imageLayer == nil {
            let imageLayer = CALayer()
            imageLayer.frame = rect
            imageLayer.contents = UIImage(named: image as String)?.cgImage
            imageLayer.cornerRadius = Image.cornerRadius
            imageLayer.masksToBounds = true
            layer.insertSublayer(imageLayer, at: Constant.insertionIndex)
            self.imageLayer = imageLayer
        }

        if self.shadowLayer == nil {
            let shadowLayer = CALayer()
            shadowLayer.masksToBounds = false
            shadowLayer.shadowColor = UIColor.black.cgColor
            shadowLayer.shadowOffset = Shadow.offset
            shadowLayer.shadowOpacity = Shadow.opacity
            shadowLayer.shadowRadius = Shadow.radius
            shadowLayer.shadowPath = UIBezierPath(roundedRect: rect, cornerRadius: Image.cornerRadius).cgPath
            layer.insertSublayer(shadowLayer, at: Constant.insertionIndex)
            self.shadowLayer = shadowLayer
        }
    }
}

#Preview {
    UIKitMIAW()
}
