# Feature Reference

Every section below follows the same pattern: fetch the example first, follow the
pattern in the example, adapt for the user's project, and do not add anything extra.

## Code Generation Rules

These rules apply to ALL code generated from this reference file.

1. BEFORE generating code, fetch the example file listed in each section.
2. Follow the pattern in the fetched example exactly.
3. Never invent type names, enum cases, or method signatures.
4. Every file must import BOTH `SMIClientCore` and `SMIClientUI`.
5. Do NOT add code beyond what the example demonstrates.
6. If the fetch fails, use `reference/api-surface.md` as your source of truth.
   Do NOT generate SDK code purely from memory.

The example app base URL for raw files is:
`https://raw.githubusercontent.com/Salesforce-Async-Messaging/messaging-in-app-ios/master/examples/`

---

## Features That Work Automatically (No Code Needed)

The UI SDK provides these features out of the box when configured in the Salesforce org.
Do NOT write code to implement them unless the user specifically asks to customize them
via view replacement.

- **Pre-chat forms** -- automatically presented if configured in the Salesforce deployment
- **Bot support** -- automatically handled by the UI SDK
- **File attachments** -- automatically enabled (see Attachment Configuration below to restrict types)
- **Estimated wait time / queue position** -- automatically displayed in the chat feed

If a user asks about one of these, explain that it works automatically and only
requires Salesforce org configuration, not SDK code.

**Bot flow timing:** If the user needs a bot to receive pre-chat data before the
conversation starts, set `createConversationOnSubmit = true` on `UIConfiguration`.
This ensures the conversation (and bot flow) only begins after the pre-chat form is
submitted, not when the UI is first presented:
```swift
uiConfig.createConversationOnSubmit = true
```

---

## Attachment Configuration

No dedicated example file. This is a `UIConfiguration` property.

BEFORE generating any code, fetch this example to see how configuration properties
are set in context:
`https://raw.githubusercontent.com/Salesforce-Async-Messaging/messaging-in-app-ios/master/examples/Shared/Settings/Sections/FileTypeManagement/FileTypeSettings.swift`

### What to configure

Enable or disable user-to-agent file attachments:
```swift
uiConfig.attachmentConfiguration = AttachmentConfiguration(endUserToAgent: true)
```

Restrict allowed file types:
```swift
let allowedTypes = AllowedFileTypes(
    image: ["png", "jpg", "jpeg", "gif"],
    video: ["mp4", "mov"],
    audio: ["m4a", "mp3"],
    text: ["txt", "csv"],
    other: ["pdf"]
)
uiConfig.attachmentConfiguration = AttachmentConfiguration(
    endUserToAgent: true,
    allowedFileTypes: allowedTypes
)
```

Pass `nil` for any category to allow all types in that category. Pass an empty
array to block that category entirely.

### Common mistakes
- File attachments must also be enabled in the Salesforce org.
- If `endUserToAgent` is `false`, the attachment button is hidden.

---

## Push Notifications

Min SDK version: 1.0.0

The example app does not include push notification handling. Use the inline patterns below.

### Prerequisites
1. Set up Apple Push Notifications (APNs) per Apple documentation.
2. Upload push notification keys to Salesforce. See
   [Set Push Notifications for Enhanced In-App Chat](https://help.salesforce.com/s/articleView?id=service.miaw_inapp_push.htm).

### Implementation

Pass the device token to the SDK:
```swift
import SMIClientCore

func application(_ application: UIApplication,
                 didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
    CoreFactory.provide(deviceToken: token)
}
```

Handle notification tap to open the correct conversation:
```swift
func userNotificationCenter(_ center: UNUserNotificationCenter,
                            didReceive response: UNNotificationResponse,
                            withCompletionHandler completionHandler: @escaping () -> Void) {
    let userInfo = response.notification.request.content.userInfo
    if let aps = userInfo["aps"] as? [String: AnyObject],
       let conversationId = aps["conversationId"] as? String,
       let uuid = UUID(uuidString: conversationId) {
        // Present Interface/InterfaceViewController with a UIConfiguration
        // using this uuid as the conversationId
    }
    completionHandler()
}
```

Suppress notifications when the app is in the foreground:
```swift
func userNotificationCenter(_ center: UNUserNotificationCenter,
                            willPresent notification: UNNotification,
                            withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    if UIApplication.shared.applicationState != .background {
        completionHandler([])
        return
    }
    completionHandler([.badge, .sound, .list, .banner])
}
```

Deregister: call `CoreClient.deregisterDeviceWithCompletion`,
`revokeTokenAndDeregisterDevice`, or `revokeTokenWithCompletion`.

### Common mistakes
- Forgetting to call `CoreFactory.provide(deviceToken:)` after registration.
- Not converting `Data` to a hex string before passing to the SDK.
- Not extracting `conversationId` from the notification payload to route to the correct conversation.

---

## User Verification

Min SDK version: 1.2.0

### Prerequisites
- Upload verification keys to Salesforce. See
  [User Verification in Salesforce Help](https://help.salesforce.com/s/articleView?id=service.user_verification.htm).

BEFORE generating any code, fetch these examples:
`https://raw.githubusercontent.com/Salesforce-Async-Messaging/messaging-in-app-ios/master/examples/Shared/Delegates/CoreDelegate/GlobalCoreDelegateHandler+UserVerification.swift`

Also fetch the delegate registration pattern:
`https://raw.githubusercontent.com/Salesforce-Async-Messaging/messaging-in-app-ios/master/examples/Shared/Delegates/CoreDelegate/GlobalCoreDelegateHandler.swift`

### What the examples demonstrate
- Implementing `UserVerificationDelegate` with `core(_:userVerificationChallengeWith:)`
- Handling `.expired` and `.malformed` challenge reasons by returning `nil`
- Returning a `UserVerification` object with a JWT

**Note:** The example imports `SalesforceSDKCore` and uses patterns specific to the
Salesforce Mobile SDK (`configStore.authorizationMethod`, `PassthroughVerification`,
`AuthHelper`). These do NOT apply to most customer apps. Extract only the
`UserVerificationDelegate` conformance and the `.JWT` code path. Ignore the
`.passthrough` path and any `SalesforceSDKCore` imports.

### Adapt for the user's project
- Create the delegate implementation in its own file (e.g. `UserVerificationHandler.swift`)
- Set `userVerificationRequired: true` on the `Configuration` object
- Register `core.setUserVerificationDelegate(delegate: self, queue: .main)` BEFORE presenting the UI
- The user must provide their own JWT-fetching logic
- Add `core.revokeTokenAndDeregisterDevice` on logout

### Common mistakes
- Mixing verified and unverified users in the same deployment is not supported.
- Using the same `conversationId` across verified and unverified sessions causes access issues.
- Not handling `.expired` / `.malformed` reasons (return `nil` to stop retrying).
- Forgetting to revoke the token when the user logs out.

Do NOT add code beyond what the example demonstrates.
If you cannot fetch the example, use `reference/api-surface.md` as your source of truth.

---

## Hidden Pre-Chat

Min SDK version: 1.2.0

BEFORE generating any code, fetch these examples:
`https://raw.githubusercontent.com/Salesforce-Async-Messaging/messaging-in-app-ios/master/examples/Shared/Delegates/CoreDelegate/GlobalCoreDelegateHandler+HiddenPreChat.swift`

Also fetch the delegate registration pattern:
`https://raw.githubusercontent.com/Salesforce-Async-Messaging/messaging-in-app-ios/master/examples/Shared/Delegates/CoreDelegate/GlobalCoreDelegateHandler.swift`

### What the examples demonstrate
- Implementing `HiddenPreChatDelegate` with `core(_:conversation:didRequestPrechatValues:)`
- The method receives a `Conversation` and an array of `[HiddenPreChatField]`
- Setting values on `HiddenPreChatField` objects by matching `field.name`
- Returning the modified array as `[HiddenPreChatField]?` (optional)

### Adapt for the user's project
- Create the delegate implementation in its own file (e.g. `HiddenPreChatHandler.swift`)
- Register `core.setPreChatDelegate(delegate: self, queue: .main)` BEFORE presenting the UI
- The `name` property must match the field API name configured in the Salesforce org
- Do NOT hardcode specific field name/value pairs. The field names depend on the
  customer's Salesforce org configuration which you do not know. Instead, leave a
  commented-out TODO example showing the pattern:
  ```swift
  // TODO: Set your hidden pre-chat field values below.
  // Field names must match the API names configured in your Salesforce org.
  // hiddenPreChatFields.first(where: { $0.name == "YourFieldName" })?.value = "your value"
  ```

### Common mistakes
- Hidden pre-chat fields must be configured in Salesforce first.
- Registering the delegate after the conversation has already started.

Do NOT add code beyond what the example demonstrates.
If you cannot fetch the example, use `reference/api-surface.md` as your source of truth.

---

## Populate Pre-Chat Fields

Min SDK version: 1.5.0

BEFORE generating any code, fetch this example:
`https://raw.githubusercontent.com/Salesforce-Async-Messaging/messaging-in-app-ios/master/examples/Shared/Delegates/Providers/TestPrePopulatedPreChatProvider.swift`

### What the example demonstrates
- Creating a struct with a `closure` property that returns `Interface.PreChatFieldValueClosure`
- Iterating `preChatFields` and setting `.value` and `.isEditable`
- Matching fields by `field.name`

### Adapt for the user's project
- Create the provider in its own file (e.g. `PreChatFieldProvider.swift`) following the
  example's struct pattern with a `closure` property
- Pass `provider.closure` when creating
  `Interface(uiConfig, preChatFieldValueProvider: provider.closure)`
- The `name` property matches the field name from the Salesforce pre-chat configuration
- Do NOT hardcode specific field name/value pairs. The field names depend on the
  customer's Salesforce org configuration. Instead, leave a commented-out TODO
  example showing the pattern:
  ```swift
  // TODO: Set your pre-chat field values below.
  // Field names must match the names configured in your Salesforce org.
  // preChatFields.first(where: { $0.name == "YourFieldName" })?.value = "your value"
  // field?.isEditable = true
  ```

### Common mistakes
- Non-editable fields must still pass validation (character limits, required fields, data types).
  If validation fails, the form won't submit and an error logs to the console.

Do NOT add code beyond what the example demonstrates.
If you cannot fetch the example, use `reference/api-surface.md` as your source of truth.

---

## Auto-Response Component (Templated URLs)

Min SDK version: 1.2.0

BEFORE generating any code, fetch this example:
`https://raw.githubusercontent.com/Salesforce-Async-Messaging/messaging-in-app-ios/master/examples/Shared/Delegates/CoreDelegate/GlobalCoreDelegateHandler+TemplatedURL.swift`

Also fetch the delegate registration pattern:
`https://raw.githubusercontent.com/Salesforce-Async-Messaging/messaging-in-app-ios/master/examples/Shared/Delegates/CoreDelegate/GlobalCoreDelegateHandler.swift`

### What the example demonstrates
- Implementing `TemplatedUrlDelegate` with `core(_:didRequestTemplatedValues:)`
- Setting values on the `SMITemplateable` object using `setValue(_:forKey:)`
- Returning the modified values

### Adapt for the user's project
- Create the delegate implementation in its own file (e.g. `TemplatedUrlHandler.swift`)
- Register `core.setTemplatedUrlDelegate(delegate: self, queue: .main)` BEFORE presenting the UI
- The keys must match the template parameter names configured in the auto-response component in Salesforce

### Common mistakes
- The UI SDK automatically displays the auto-response. You only need the delegate to pass
  dynamic URL parameters.

Do NOT add code beyond what the example demonstrates.
If you cannot fetch the example, use `reference/api-surface.md` as your source of truth.

---

## Business Hours

Min SDK version: 1.3.0

The example app does not include a business hours example. Use the inline pattern below.

### Implementation

```swift
let core = CoreFactory.create(withConfig: config)
core.retrieveBusinessHours { businessHoursInfo, error in
    guard let info = businessHoursInfo else { return }

    if info.isWithinBusinessHours(comparisonTime: nil) {
        // Show the chat button
    } else {
        // Hide the chat button or show an "offline" message
    }
}
```

When using the UI SDK, the SDK automatically shows a banner in the chat window
outside of business hours.

### Common mistakes
- Business hours must be configured in Salesforce for the deployment.
- `isWithinBusinessHours(comparisonTime: nil)` checks against the current time.
- The method returns hours for the next 24 hours only.

---

## Manage Conversations

Min SDK version: 1.0.0

BEFORE generating any code, fetch this example:
`https://raw.githubusercontent.com/Salesforce-Async-Messaging/messaging-in-app-ios/master/examples/Shared/Settings/Sections/ConversationManagement/ConversationManagementSettings.swift`

### What the example demonstrates
- Closing a conversation via `ConversationClient.closeConversation` or `CoreClient.closeConversation`
- Ending a session via `ConversationClient.endSession`

### Key concepts
Conversation lifecycle has 4 stages:
1. **Creation** -- a new conversation starts
2. **Session** -- one or more messaging sessions (ending a session does not end the conversation)
3. **Closing** -- explicitly closed; no new messages can be sent
4. **Persistence** -- history is preserved and queryable

### Conversation ID rules
- Must be a randomly-generated UUID v4
- Must not be a customer ID or business identifier
- Must be persisted by the app for conversation resumption
- Cannot be transferred between verified and unverified users
- Cannot be moved between staging and production orgs

Do NOT add code beyond what the example demonstrates.
If you cannot fetch the example, use `reference/api-surface.md` as your source of truth.

---

## Conversation Lists

Min SDK version: 1.3.0

BEFORE generating any code, fetch this example:
`https://raw.githubusercontent.com/Salesforce-Async-Messaging/messaging-in-app-ios/master/examples/Shared/Settings/Sections/ConversationManagement/ConversationPicker.swift`

### What the example demonstrates
- Querying conversations from the server with `core.conversations(withLimit:olderThanConversation:forceRefresh:)`
- Querying from local cache with `core.conversations(withLimit:sortedByActivityDirection:)`
- Pagination using `olderThanConversation`

### Adapt for the user's project
- Use the remote query method first to populate the local cache
- Use the local method for subsequent lookups
- The user must build their own UI to display the conversation list

Do NOT add code beyond what the example demonstrates.
If you cannot fetch the example, use `reference/api-surface.md` as your source of truth.

---

## Transcripts

Min SDK version: 1.5.0

The example app does not include a transcript example. Use the inline patterns below.

### Implementation

Enable transcript download in the configuration:
```swift
uiConfig.transcriptConfiguration = TranscriptConfiguration(allowTranscriptDownload: true)
```

Retrieve a transcript programmatically:
```swift
let client = core.conversationClient(with: conversationId)
client.retrieveTranscript { pdfData, error in
    guard let data = pdfData else { return }
    // Save or share the PDF
}
```

### Common mistakes
- Transcript download must also be enabled in Salesforce. See
  [Allow End Users to Download a Transcript](https://help.salesforce.com/s/articleView?id=service.miaw_download_transcript.htm).
- The API returns a PDF document. The app decides what to do with it.

---

## Clear Local Storage

Min SDK version: 1.5.1

BEFORE generating any code, fetch this example:
`https://raw.githubusercontent.com/Salesforce-Async-Messaging/messaging-in-app-ios/master/examples/Shared/Settings/Sections/DatabaseManagement/DatabaseManagementSettings.swift`

### What the example demonstrates
- Calling `core.destroyStorage(andAuthorization:)` with a completion handler
- The difference between `andAuthorization: true` (full reset) and `false` (preserve auth)

### Common mistakes
- This is destructive and irreversible. Unverified conversations become permanently inaccessible.
- If `andAuthorization: true`, the user must re-authenticate for user-verified sessions.

Do NOT add code beyond what the example demonstrates.
If you cannot fetch the example, use `reference/api-surface.md` as your source of truth.

---

## Conversation UI Options

Min SDK version: 1.0.0
No dedicated example file. These are `UIConfiguration` properties set before presenting the UI.

### End chat button
```swift
uiConfig.conversationOptionsConfiguration = ConversationOptionsConfiguration(allowEndChat: true)
```
Shows a menu in the chat header that lets the user end the conversation. The Salesforce
org must also permit end-user conversation closure.

### Agent avatar and progress indicators
```swift
uiConfig.agentConfiguration = AgentConfiguration(
    useProgressIndicators: true,
    useHumanAgentAvatar: true
)
```
`useProgressIndicators`: shows a loading indicator while waiting for an agent response.
`useHumanAgentAvatar`: shows the agent's profile photo in the chat feed if available.

---

## Liquid Glass (iOS 26)

No dedicated example file. This is a `UIConfiguration` property.
Only applies on iOS 26 and later — has no effect on earlier OS versions.

```swift
uiConfig.liquidGlassConfiguration = LiquidGlassConfiguration(allowBrandingForLiquidGlass: true)
```

When `true`, the SDK uses iOS 26's liquid glass material for UI surfaces. Set to `false`
to keep solid surfaces consistent with brand colors.

### Common mistakes
- `SMI.*` color assets still apply on top of liquid glass when enabled.
- Safe to set unconditionally — ignored below iOS 26.

---

## Logging

BEFORE generating any code, fetch this example:
`https://raw.githubusercontent.com/Salesforce-Async-Messaging/messaging-in-app-ios/master/examples/Shared/Settings/Sections/Logging/LoggingSettings.swift`

### What the example demonstrates
- Setting `SMIClientCore.Logging.level` and `SMIClientUI.Logging.level`
- Available levels: `.debug` and `.none`

### Adapt for the user's project
- Set to `.debug` for troubleshooting, `.none` for production

Do NOT add code beyond what the example demonstrates.
If you cannot fetch the example, use `reference/api-surface.md` as your source of truth.

---

## Remote Locale Mapping

BEFORE generating any code, fetch this example:
`https://raw.githubusercontent.com/Salesforce-Async-Messaging/messaging-in-app-ios/master/examples/Shared/Settings/Sections/RemoteLocale/RemoteLocaleSettings.swift`

### What the example demonstrates
- Passing a `remoteLocaleMap` dictionary when creating `UIConfiguration`
- Mapping device locales (e.g., `"en"`) to Salesforce locale values (e.g., `"en_US"`)

### Adapt for the user's project
- The user provides the locale mappings for their Salesforce org

Do NOT add code beyond what the example demonstrates.
If you cannot fetch the example, use `reference/api-surface.md` as your source of truth.

---

## Delegate Registration Pattern

BEFORE generating any code that involves delegates, fetch this example:
`https://raw.githubusercontent.com/Salesforce-Async-Messaging/messaging-in-app-ios/master/examples/Shared/Delegates/CoreDelegate/GlobalCoreDelegateHandler.swift`

### What the example demonstrates
- Creating a centralized delegate handler class
- Registering all delegates via method calls BEFORE the user interacts with the chat:
  - `core.setPreChatDelegate(delegate: self, queue: .main)`
  - `core.setTemplatedUrlDelegate(delegate: self, queue: .main)`
  - `core.setUserVerificationDelegate(delegate: self, queue: .main)`
  - `client.addDelegate(delegate: self, queue: .main)`
- Obtaining the `CoreClient` from a `ConversationClient` via `client.core`

**SwiftUI note:** In SwiftUI, "before presenting the UI" means registering
delegates in `.onAppear` of the view that contains the `Interface`, or during
the creation of the `CoreClient`. The delegate must be set before the SDK
makes its first network request, not necessarily before the SwiftUI view
appears on screen.

### Adapt for the user's project
- Create each delegate implementation in its own dedicated file (e.g.
  `UserVerificationHandler.swift`, `HiddenPreChatHandler.swift`). Do not add delegate
  classes inline in the user's existing view files -- keep them separate for clarity.
- Delegate handler classes should subclass `NSObject` only -- do NOT make them conform
  to `ObservableObject` or use `@Observable`. They are not view models. Follow the
  example pattern: `class MyHandler: NSObject, UserVerificationDelegate { ... }`.

**IMPORTANT: Creating the delegate file is not enough -- you MUST also wire it up.**
Every delegate requires TWO changes:

1. **The handler file** -- create the delegate class in its own `.swift` file.
2. **The view that presents the chat** -- add these edits:
   - Add a `private let` property for the handler
   - Add a `private let` property for the `CoreClient` (created in `init()`)
   - In `.onAppear`, register the delegate on the `CoreClient`

Example wiring in a SwiftUI view:
```swift
struct MyChatView: View {
    private let myHandler = HiddenPreChatHandler()
    private let coreClient: CoreClient

    init(config: Configuration) {
        self.coreClient = CoreFactory.create(withConfig: config)
    }

    var body: some View {
        Interface(uiConfig)
            .onAppear {
                coreClient.setPreChatDelegate(
                    delegate: myHandler,
                    queue: .main
                )
            }
    }
}
```

Both the handler AND the `CoreClient` must be retained for the lifetime of the
chat view. Do NOT create the `CoreClient` as a local variable inside `.onAppear`
-- it will be deallocated and the chat view will go blank silently.

Do NOT add code beyond what the example demonstrates.

---

## Conversation Client Delegate

BEFORE generating any code, fetch this example:
`https://raw.githubusercontent.com/Salesforce-Async-Messaging/messaging-in-app-ios/master/examples/Shared/Delegates/CoreDelegate/GlobalCoreDelegateHandler+ConversationClient.swift`

### What the example demonstrates
- Conforming to `ConversationClientDelegate`
- Handling `didUpdateActiveParticipants` to track agent/bot presence

**Note:** The example only shows `didUpdateActiveParticipants`. For other methods
(e.g. `didReceiveEntries`, `didCreateConversation`, `didUpdateUnreadMessageCount`),
refer to `reference/api-surface.md` for the full method signatures. The most commonly
needed method is `didReceiveEntries` for monitoring incoming messages:
```swift
func client(_ client: ConversationClient,
            didReceiveEntries entries: [ConversationEntry],
            paged: Bool)
```

### Adapt for the user's project
- Create the delegate in its own file (e.g. `ConversationEventHandler.swift`)
- Register via `client.addDelegate(delegate: self, queue: .main)`
- Only implement the delegate methods the user actually needs

Do NOT add code beyond what the example demonstrates.
If you cannot fetch the example, use `reference/api-surface.md` for method signatures.
