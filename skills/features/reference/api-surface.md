# API Surface Reference

> **Last verified against:** SDK v1.10.x — update this line when verifying against a new release.
> Check [release notes](https://github.com/Salesforce-Async-Messaging/messaging-in-app-ios/releases)
> for new types or signature changes before generating code.

Public types, protocols, and initializers for the Salesforce Messaging for In-App iOS SDK.
Use this file to verify type names, method signatures, and enum cases. Do NOT invent
types that are not listed here.

## Code Generation Rules

1. Never fabricate class names, enum cases, property names, or protocol signatures.
2. Every file must import BOTH `SMIClientCore` and `SMIClientUI`.
3. If you need a type and cannot find it here, fetch the example app code to verify.
4. `ParticipantRole` is an `NS_TYPED_ENUM` (struct with static properties), NOT a Swift enum.
   `.endUser` does not exist -- use `.user` or `entry.sender.isLocal`.

---

## Configuration (SMIClientCore)

**Swift name:** `Configuration`
**Obj-C name:** `SMICoreConfiguration`

### Initializers

```swift
init?(url: URL)
init?(url: URL, userVerificationRequired: Bool)

init(serviceAPI: URL, organizationId: String, developerName: String)
init(serviceAPI: URL, organizationId: String, developerName: String,
     userVerificationRequired: Bool)
```

### Properties
| Property | Type | Description |
|----------|------|-------------|
| `serviceAPI` | `URL` | Salesforce endpoint URL |
| `organizationId` | `String` | 15-character Salesforce org ID |
| `developerName` | `String` | API name for the embedded service deployment |
| `userVerificationRequired` | `Bool` | Whether user verification is enabled |
| `remoteLocaleMap` | `[String: String]?` | Maps device locales to server locales |

### JSON Config File Format
```json
{
    "Url": "https://your-domain.salesforce-scrt.com",
    "OrganizationId": "00Dxx0000000000",
    "DeveloperName": "Your_Deployment_Name"
}
```

---

## UIConfiguration (SMIClientUI)

**Extends:** `Configuration`
**Conforms to:** `ObservableObject`

### Initializers

```swift
init(configuration: Configuration,
     conversationId: UUID,
     remoteLocaleMap: [String: String]? = nil,
     urlDisplayMode: UrlDisplayMode = .inlineBrowser)
```

### Properties
| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `conversationId` | `UUID` | -- | Identifies the conversation |
| `createConversationOnSubmit` | `Bool` | `true` | Create conversation when pre-chat is submitted |
| `urlDisplayMode` | `UrlDisplayMode` | `.inlineBrowser` | How URLs open |
| `transcriptConfiguration` | `TranscriptConfiguration` | -- | Transcript download settings |
| `attachmentConfiguration` | `AttachmentConfiguration` | -- | File attachment settings |
| `agentConfiguration` | `AgentConfiguration` | -- | Agent UI settings |
| `conversationOptionsConfiguration` | `ConversationOptionsConfiguration` | -- | End-chat button settings |
| `liquidGlassConfiguration` | `LiquidGlassConfiguration` | -- | iOS 26 liquid glass branding |

### Sub-Configurations

**TranscriptConfiguration:**
```swift
TranscriptConfiguration(allowTranscriptDownload: Bool)
```

**AttachmentConfiguration:**
```swift
AttachmentConfiguration(endUserToAgent: Bool)
AttachmentConfiguration(endUserToAgent: Bool, allowedFileTypes: AllowedFileTypes?)
```

**AllowedFileTypes:**
```swift
AllowedFileTypes(image: [String]?, video: [String]?, audio: [String]?,
                 text: [String]?, other: [String]?)
```

**AgentConfiguration:**
```swift
AgentConfiguration(useProgressIndicators: Bool, useHumanAgentAvatar: Bool)
```

**ConversationOptionsConfiguration:**
```swift
ConversationOptionsConfiguration(allowEndChat: Bool)
```

**LiquidGlassConfiguration:**
```swift
LiquidGlassConfiguration(allowBrandingForLiquidGlass: Bool)
```

**UrlDisplayMode:**
```swift
enum UrlDisplayMode: String {
    case externalBrowser
    case inlineBrowser
}
```

---

## Interface (SMIClientUI)

SwiftUI `View` for embedding the chat experience.

### Initializer

```swift
public init(_ config: UIConfiguration,
            navigationTitle: Binding<String?> = .constant(nil),
            preChatFieldValueProvider: PreChatFieldValueClosure? = nil,
            chatFeedViewBuilder: ChatFeedViewBuilder? = nil,
            navigationBarBuilder: NavigationBarBuilder? = nil)
```

### Type Aliases
```swift
public typealias PreChatFieldValueClosure =
    ((_ preChatFields: [PreChatField]) async throws -> [PreChatField])
```

### Class Properties
```swift
static var sdkVersion: String?
```

---

## InterfaceViewController (SMIClientUI)

`UIViewController` for UIKit push-navigation.

### Initializers

```swift
@objc public convenience init(_ config: UIConfiguration, isModal: Bool = false)

public convenience init(_ config: UIConfiguration,
                        isModal: Bool = false,
                        preChatFieldValueProvider: Interface.PreChatFieldValueClosure? = nil,
                        chatFeedViewBuilder: ChatFeedViewBuilder? = nil,
                        navigationBarBuilder: NavigationBarBuilder? = nil)
```

### Properties
| Property | Type | Description |
|----------|------|-------------|
| `currentScreen` | `NavigationScreenType` | Current visible screen |

---

## ModalInterfaceViewController (SMIClientUI)

`UINavigationController` subclass for modal presentation.

### Initializer

```swift
public init(_ config: UIConfiguration,
            preChatFieldValueProvider: Interface.PreChatFieldValueClosure? = nil,
            chatFeedViewBuilder: ChatFeedViewBuilder? = nil,
            navigationBarBuilder: NavigationBarBuilder? = nil)
```

### Properties
| Property | Type | Description |
|----------|------|-------------|
| `modalDismissButton` | `UIBarButtonItem?` | Custom dismiss button |
| `currentScreen` | `NavigationScreenType` | Current visible screen |

---

## CoreFactory (SMIClientCore)

Singleton factory for creating CoreClient instances.

### Methods

```swift
static func create(withConfig config: Configuration) -> CoreClient
static func provide(deviceToken: String)
```

### Properties
```swift
static var sdkVersion: String?
```

---

## CoreClient (SMIClientCore)

Main SDK client protocol. Returned by `CoreFactory.create(withConfig:)`.

### Key Methods
```swift
func start()
func stop()
func conversationClient(with conversationId: UUID) -> ConversationClient
func retrieveRemoteConfiguration(completion: @escaping (RemoteConfiguration?, Error?) -> Void)
func retrieveBusinessHours(completion: @escaping (BusinessHoursInfo?, Error?) -> Void)
func conversations(withLimit: Int, sortedByActivityDirection: SortDirection,
                   completion: @escaping ([Conversation]?, Error?) -> Void)
func conversations(withLimit: Int, olderThanConversation: Conversation?,
                   forceRefresh: Bool, completion: @escaping ([Conversation]?, Error?) -> Void)
func closeConversation(withIdentifier: UUID, completion: @escaping (Error?) -> Void)
func destroyStorage(andAuthorization: Bool, completion: @escaping (Error?) -> Void)
func markAsRead(entry: ConversationEntry)
func deregisterDeviceWithCompletion(_ completion: @escaping (Error?) -> Void)
func revokeTokenAndDeregisterDevice(completion: @escaping (Error?) -> Void)
func revokeTokenWithCompletion(_ completion: @escaping (Error?) -> Void)
```

### Delegate Registration Methods

Delegates are registered via method calls, not property assignment. All methods require
a `queue` parameter specifying the dispatch queue for callbacks.

```swift
func setPreChatDelegate(delegate: HiddenPreChatDelegate, queue: DispatchQueue)
func setTemplatedUrlDelegate(delegate: TemplatedUrlDelegate, queue: DispatchQueue)
func setUserVerificationDelegate(delegate: UserVerificationDelegate, queue: DispatchQueue)
```

**NEVER write:** `core.preChatDelegate = self` — that property does not exist.
**Always write:** `core.setPreChatDelegate(delegate: self, queue: .main)`

---

## ConversationClient (SMIClientCore)

Per-conversation client. Obtained via `CoreClient.conversationClient(with:)`.

### Key Methods
```swift
func create()
func create(remoteConfig: RemoteConfiguration)
func send(message: String)
func send(file: URL, fileName: String, message: String?)
func send(reply: Choice)
func send(form: FormMessage)
func sendTypingEvent()
func endSession(completion: @escaping (Error?) -> Void)
func closeConversation(completion: @escaping (Error?) -> Void)
func submit(remoteConfig: RemoteConfiguration)
func submit(remoteConfig: RemoteConfiguration, createConversationOnSubmit: Bool)
func retrieveTranscript(completion: @escaping (Data?, Error?) -> Void)
func entries(withLimit: Int, fromTimestamp: Date?, direction: SortDirection,
             behaviour: FetchBehaviour, completion: @escaping ([ConversationEntry]?, Error?) -> Void)
func addDelegate(delegate: ConversationClientDelegate, queue: DispatchQueue)
```

### Properties
```swift
var core: CoreClient { get }
```

---

## Delegate Protocols

### UserVerificationDelegate
```swift
protocol UserVerificationDelegate {
    func core(_ core: CoreClient,
              userVerificationChallengeWith reason: UserVerificationChallengeReason) async -> UserVerification?
}
```

### HiddenPreChatDelegate
```swift
protocol HiddenPreChatDelegate {
    func core(_ core: CoreClient,
              conversation: Conversation,
              didRequestPrechatValues hiddenPreChatFields: [HiddenPreChatField]) async -> [HiddenPreChatField]?
}
```

Note: The `conversation` parameter and the optional return type are required. Omitting either will cause a compile error.

### TemplatedUrlDelegate
```swift
protocol TemplatedUrlDelegate {
    func core(_ core: CoreClient,
              didRequestTemplatedValues values: SMITemplateable) async -> SMITemplateable
}
```

### ConversationClientDelegate
Key methods (all optional):
```swift
func client(_ client: ConversationClient, didReceiveEntries entries: [ConversationEntry], paged: Bool)
func client(_ client: ConversationClient, didUpdateEntries entries: [ConversationEntry])
func client(_ client: ConversationClient, didUpdateActiveParticipants participants: [Participant])
func client(_ client: ConversationClient, didChangeNetworkState state: NetworkState)
func client(_ client: ConversationClient, didError error: Error)
func client(_ client: ConversationClient, didCreateConversation conversation: Conversation)
```

---

## ChatFeedViewBuilder (SMIClientUI)

Protocol for replacing chat feed views.

```swift
protocol ChatFeedViewBuilder {
    typealias RenderModeClosure = (_ model: ChatFeedModel) -> ChatFeedRenderMode
    typealias AccessibilityLabelClosure = (_ model: ChatFeedModel) -> String?
    typealias CompleteViewClosure = (_ model: ChatFeedModel, _ client: ConversationClient?) -> any View

    var renderMode: RenderModeClosure? { get }
    var accessibilityLabel: AccessibilityLabelClosure? { get }
    var completeView: CompleteViewClosure? { get }
}
```

### ChatFeedRenderMode
```swift
enum ChatFeedRenderMode {
    case existing
    case replace
    case none
}
```

### ChatFeedModel Subtypes
| Type | Description |
|------|-------------|
| `ConversationEntryModel` | Messages, attachments, forms, rich links, etc. |
| `TypingIndicatorModel` | Agent/bot typing indicator |
| `ProgressIndicatorModel` | Progress/loading indicator |
| `DateBreakModel` | Date separator |
| `PreChatReceiptModel` | Pre-chat submission receipt |
| `ConversationClosedModel` | Conversation closed state |
| `QueuePositionModel` | Queue position display |

---

## ConversationEntry Types (SMIClientCore)

Do not invent type names. Use only the types listed here.

### Participant (protocol)

```swift
protocol Participant {
    var subject: String { get }
    var role: ParticipantRole { get }
    var isLocal: Bool { get }
    var displayName: String? { get }
}
```

### ParticipantRole (NS_TYPED_ENUM -- NOT a Swift enum)

`ParticipantRole` is bridged as a struct with static properties:

```swift
ParticipantRole.system
ParticipantRole.user        // NOT .endUser
ParticipantRole.agent
ParticipantRole.chatbot
ParticipantRole.router
ParticipantRole.supervisor
```

### Correct sender origin pattern
```swift
if entry.sender.role == .system {
    // system message
} else if entry.sender.isLocal {
    // sent by the local user
} else {
    // received from remote (agent, bot, etc.)
}
```

### Payload Types

| Format / Type | Payload Type |
|---------------|-------------|
| `.textMessage` | `TextMessage` |
| `.attachments` | `AttachmentEntry` |
| `.selections` | `ChoicesResponse` |
| `.inputs` | `FormInputs` |
| `.result` | `FormResponseResult` |
| `.richLink` | `RichLinkMessage` |
| `.quickReplies` | `QuickReply` |
| `.listPicker` | `ListPicker` |
| `.carousel` | `Carousel` |
| `.participantChanged` (type) | `ParticipantChanged` |
| `.sessionStatusChanged` (type) | `SessionStatusChanged` |

### ConversationFormatTypes

```swift
enum ConversationFormatTypes {
    case textMessage
    case attachments
    case inputs
    case result
    case carousel
    case selections
    case richLink
    case quickReplies
    case listPicker
    case webView
    case unspecified
}
```

### ConversationEntryTypes

```swift
enum ConversationEntryTypes {
    case participantChanged
    case sessionStatusChanged
}
```

---

## ConversationEntry (SMIClientCore)

Represents a single message or event in a conversation.

### Key Properties
| Property | Type | Description |
|----------|------|-------------|
| `sender` | `Participant` | Who sent the entry |
| `format` | `ConversationFormatTypes` | Determines which payload type to cast to |
| `type` | `ConversationEntryTypes` | Entry type for event entries |
| `timestamp` | `Date` | When the entry was created |

### Reading payload

Always gate on `entry.format` before casting — casting without checking returns `nil`:
```swift
switch entry.format {
case .textMessage:
    if let text = entry.payload as? TextMessage { ... }
case .attachments:
    if let attachment = entry.payload as? AttachmentEntry { ... }
default:
    break
}
```

See the Payload Types table in the ConversationFormatTypes section above for all mappings.

---

## PreChatField (SMIClientCore)

A visible pre-chat form field. Used in `PreChatFieldValueClosure` to pre-populate the form.

### Key Properties
| Property | Type | Description |
|----------|------|-------------|
| `name` | `String` | API name matching the Salesforce pre-chat field configuration |
| `value` | `String` | Current value — set this to pre-populate the field |
| `isEditable` | `Bool` | Whether the user can edit this field in the form |

**Note:** Non-editable fields must still pass all validation rules (character limits,
required fields, data type). Validation failure silently prevents form submission.

---

## HiddenPreChatField (SMIClientCore)

A hidden pre-chat field passed to `HiddenPreChatDelegate`. Never shown to the user.

### Key Properties
| Property | Type | Description |
|----------|------|-------------|
| `name` | `String` | API name matching the Salesforce hidden pre-chat field configuration |
| `value` | `String` | Value to inject — set this in the delegate method |

---

## BusinessHoursInfo (SMIClientCore)

Returned by `CoreClient.retrieveBusinessHours`. Returns `nil` when business hours
are not configured in the Salesforce org.

```swift
func isWithinBusinessHours(comparisonTime: Date?) -> Bool
```

Pass `nil` to check against the current time.

---

## RemoteConfiguration (SMIClientCore)

Returned by `CoreClient.retrieveRemoteConfiguration`. Contains server-side settings
including pre-chat field definitions. Do not construct manually.

Pass to `ConversationClient` to start a conversation with server-side config:
```swift
client.submit(remoteConfig: remoteConfig)
client.submit(remoteConfig: remoteConfig, createConversationOnSubmit: Bool)
client.create(remoteConfig: remoteConfig)
```

---

## SortDirection (SMIClientCore)

```swift
enum SortDirection {
    case ascending
    case descending
}
```

Used in `CoreClient.conversations(withLimit:sortedByActivityDirection:)` and
`ConversationClient.entries(withLimit:fromTimestamp:direction:behaviour:completion:)`.

---

## Conversation (SMIClientCore)

Returned by `CoreClient.conversations(...)` and passed to `HiddenPreChatDelegate`.

### Key Properties
| Property | Type | Description |
|----------|------|-------------|
| `identifier` | `UUID` | Unique conversation ID |
| `status` | `ConversationStatus` | Current conversation status |
| `lastActiveEntry` | `ConversationEntry?` | Most recent entry (has a `timestamp` property) |

---

## ChatFeedProxy (SMIClientUI)

An `ObservableObject` injected by the SDK as an `@EnvironmentObject` into replacement views.
You do not create this — the SDK provides it automatically.

### Key Properties
| Property | Type | Description |
|----------|------|-------------|
| `screenSize` | `CGSize` | Current screen dimensions (use for relative width calculations) |

Used in `EntryContainerReplacement` to size message bubbles relative to screen width.
If your replacement view needs `chatFeedProxy`, declare it:
```swift
@EnvironmentObject var chatFeedProxy: ChatFeedProxy
```
Do NOT add this unless the example you are following uses it.

---

## NavigationBarBuilder (SMIClientUI)

Base class for customizing the navigation bar.

```swift
open class NavigationBarBuilder {
    public typealias HandleNavigationClosure =
        (_ screen: NavigationScreenType, _ navigationItem: UINavigationItem) -> Void
    public var handleNavigation: HandleNavigationClosure?
}
```

### NavigationScreenType
```swift
enum NavigationScreenType {
    case chatFeed
    case form
    case confirmation
    case information
    case preChat
    case attachment
    case transcripts
    case optionsMenu
}
```

---

## Logging

```swift
SMIClientCore.Logging.level: LoggingLevel  // .debug or .none
SMIClientUI.Logging.level: LoggingLevel    // .debug or .none
```
