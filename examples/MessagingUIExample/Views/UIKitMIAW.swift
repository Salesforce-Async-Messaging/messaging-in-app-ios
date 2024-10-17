//
//  UIKitMIAW.swift
//  MessagingUIExample
//
//  Created by Jeremy Wright on 2024-10-07.
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
        }

        let demoManagementStore: DemoManagementStore = DemoManagementStore()
        let configurationStore: MIAWConfigurationStore = MIAWConfigurationStore()
        let conversationManagementStore: ConversationManagementStore = ConversationManagementStore()
        let uiReplacementStore: UIReplacementStore = UIReplacementStore()
        let remoteLocaleStore: RemoteLocaleStore = RemoteLocaleStore()

        let uiConfiguration: UIConfiguration

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

        func setupFloatingButton() {
            self.view.addSubview(floatingButton)

            NSLayoutConstraint.activate([
                floatingButton.heightAnchor.constraint(equalToConstant: Constants.chatButtonHeight),
                floatingButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: Constants.chatButtonY),
                floatingButton.widthAnchor.constraint(equalToConstant: Constants.chatButtonWidth),
                floatingButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: Constants.chatButtonX)
            ])
        }

        @objc func startInApp(sender: UIButton!) {
            let testEntryViewBuilder = GlobalCoreDelegateHandler.shared.viewBuilder
            let testPrePopulatedPreChatProvider = GlobalCoreDelegateHandler.shared.prePopulatedPreChatProvider.closure

            if demoManagementStore.isModal {
                let controller = ModalInterfaceViewController(uiConfiguration,
                                                              preChatFieldValueProvider: testPrePopulatedPreChatProvider,
                                                              chatFeedViewBuilder: testEntryViewBuilder)

                controller.modalPresentationStyle = demoManagementStore.modalPresentationStyle.systemValue
                if demoManagementStore.replaceDismissButton {
                    controller.modalDismissButton = UIBarButtonItem(title: demoManagementStore.dismissButtonTitle,
                                                                    style: .plain,
                                                                    target: self,
                                                                    action: #selector(dismissAction(sender:)))
                }

                self.present(controller, animated: true)

                let popover: UIPopoverPresentationController? = controller.popoverPresentationController
                popover?.permittedArrowDirections = .any
                popover?.sourceView = self.view
                popover?.sourceRect = sender.frame

                return
            }

            let controller = InterfaceViewController(uiConfiguration,
                                                     preChatFieldValueProvider: testPrePopulatedPreChatProvider,
                                                     chatFeedViewBuilder: testEntryViewBuilder)

            self.navigationController?.pushViewController(controller, animated: true)
        }

        @objc private func dismissAction(sender: UIBarButtonItem) {
            self.dismiss(animated: true)
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
