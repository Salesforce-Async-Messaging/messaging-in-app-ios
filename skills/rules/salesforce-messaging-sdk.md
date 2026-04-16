---
globs: ["**/*.swift"]
---
<!--
  Cursor:     keep frontmatter as-is (globs applies rule to all Swift files)
  Windsurf:   replace frontmatter with: trigger: glob / file_patterns: ["**/*.swift"]
  Claude Code / Copilot: remove the frontmatter delimiters and paste content
              into CLAUDE.md or .github/copilot-instructions.md
  See README.md for full installation instructions.
-->

# Salesforce Messaging SDK -- Code Generation Rules

These rules apply ONLY when the file imports `SMIClientCore` or `SMIClientUI`.
If the file does not import either module, skip these rules entirely.

## 1. Fetch examples before writing code

Before generating any code that uses SDK types, fetch the relevant example file from:
`https://raw.githubusercontent.com/Salesforce-Async-Messaging/messaging-in-app-ios/master/examples/`

If you cannot fetch the file, STOP and tell the user you need network access.
Do NOT generate SDK code from memory.

### Feature-to-example mapping

| Feature | Example file path (under `examples/`) |
|---------|---------------------------------------|
| SwiftUI integration | `MessagingUIExample/Views/ContentView.swift` |
| UIKit integration | `MessagingUIExample/Views/UIKitMIAW.swift` |
| View replacement | `Shared/Delegates/Providers/TestEntryViewBuilder.swift` |
| Entry container | `Shared/ReplacementUI/Views/EntryContainerReplacement.swift` |
| Text message handling | `Shared/ReplacementUI/Models/ConversationEntry/TextMessageReplacement.swift` |
| User verification | `Shared/Delegates/CoreDelegate/GlobalCoreDelegateHandler+UserVerification.swift` |
| Hidden pre-chat | `Shared/Delegates/CoreDelegate/GlobalCoreDelegateHandler+HiddenPreChat.swift` |
| Pre-populated pre-chat | `Shared/Delegates/Providers/TestPrePopulatedPreChatProvider.swift` |
| Templated URLs | `Shared/Delegates/CoreDelegate/GlobalCoreDelegateHandler+TemplatedURL.swift` |
| Delegate registration | `Shared/Delegates/CoreDelegate/GlobalCoreDelegateHandler.swift` |
| Conversation delegate | `Shared/Delegates/CoreDelegate/GlobalCoreDelegateHandler+ConversationClient.swift` |
| Navigation bar | `Shared/Delegates/Providers/TestNavBarBuilder.swift` |

## 2. Both imports are always required

```swift
import SMIClientCore
import SMIClientUI
```

`Configuration`, `ConversationEntry`, `TextMessage`, `ParticipantRole` are in `SMIClientCore`.
`UIConfiguration`, `Interface`, `ChatFeedViewBuilder` are in `SMIClientUI`.

## 3. Never fabricate type names

| Wrong (fabricated) | Correct (real) |
|--------------------|----------------|
| `EntryPayloadText` | `TextMessage` |
| `ParticipantRole.endUser` | `ParticipantRole.user` or `entry.sender.isLocal` |
| `EntryPayloadImage` | `AttachmentEntry` |

### Payload types by format

| Format | Cast `entry.payload` to |
|--------|------------------------|
| `.textMessage` | `TextMessage` |
| `.attachments` | `AttachmentEntry` |
| `.selections` | `ChoicesResponse` |
| `.inputs` | `FormInputs` |
| `.result` | `FormResponseResult` |
| `.richLink` | `RichLinkMessage` |
| `.quickReplies` | `QuickReply` |
| `.listPicker` | `ListPicker` |
| `.carousel` | `Carousel` |

## 4. Correct sender origin pattern

```swift
if entry.sender.role == .system {
    // system message
} else if entry.sender.isLocal {
    // sent by the local user
} else {
    // received from remote (agent, bot, etc.)
}
```

## 5. SPM product name

The SPM product name is `Swift-InAppMessaging`, NOT `SMIClientUI`.
The module names for imports remain `SMIClientCore` and `SMIClientUI`.

## 6. Register delegates before presenting UI

Delegates are registered via method calls with a `queue:` parameter, NOT property assignment.
Set all delegates BEFORE the chat UI is presented:
```swift
core.setPreChatDelegate(delegate: self, queue: .main)
core.setTemplatedUrlDelegate(delegate: self, queue: .main)
core.setUserVerificationDelegate(delegate: self, queue: .main)
client.addDelegate(delegate: self, queue: .main)
```

NEVER write `core.preChatDelegate = self` — that property does not exist.

## 7. Minimal changes only

Do not restructure, refactor, or reorganize existing code. Do not add decorative UI
or boilerplate beyond what was asked for. Do not implement optional protocol members
just to return `nil` or no-op values. If the example omits something, you omit it too.

## 8. Self-review before responding

After generating or editing SDK code, check your output before presenting it:

1. Both `import SMIClientCore` and `import SMIClientUI` present?
2. Every type name exists in the fetched example or the API surface reference?
3. No optional protocol members implemented just to return `nil`?
4. Code follows the fetched example pattern -- no improvisation?
5. No unnecessary files, decorative UI, or boilerplate added?
6. Delegates registered before the UI is presented?
7. If `UIConfiguration` is created: `conversationId` is a persisted UUID, NOT `UUID()` inline?

If any check fails, fix the code before responding.
