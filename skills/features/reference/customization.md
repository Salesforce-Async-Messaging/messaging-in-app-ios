# Customization Reference

How to customize colors, strings, icons, chat feed views, and the navigation bar.

## Code Generation Rules

These rules apply to ALL code generated from this reference file.

1. BEFORE generating code, fetch the example file listed in each section.
2. Follow the pattern in the fetched example exactly.
3. Never invent type names, enum cases, or method signatures.
4. Every file must import BOTH `SMIClientCore` and `SMIClientUI`.
5. Do NOT add code beyond what the example demonstrates.
6. If you cannot fetch the example, STOP and tell the user you need network access.

The example app base URL for raw files is:
`https://raw.githubusercontent.com/Salesforce-Async-Messaging/messaging-in-app-ios/master/examples/`

---

## Colors

No code generation needed. Colors are customized via Asset Catalog color sets.

**Doc:** [ios-colors.html](https://developer.salesforce.com/docs/service/messaging-in-app/guide/ios-colors.html)
**Example:** [SMI.Error.colorset](https://github.com/Salesforce-Async-Messaging/messaging-in-app-ios/tree/master/examples/MessagingUIExample/Assets.xcassets/SMI.Error.colorset)

### How it works

Create color sets in the app's Asset catalog using the SDK's token names. The SDK
automatically picks them up. Always test in both light and dark mode.

### Implementation

1. In Xcode, open the app's Asset catalog.
2. Click **+** and select **Color Set**.
3. Name it with the **exact** token name (e.g., `SMI.primary`). Case matters.
4. Set colors for **Any Appearance** (light) and **Dark Appearance**.

**CRITICAL:** All color set names use uppercase `SMI.` prefix (e.g., `SMI.primary`,
NOT `smi.primary`). The asset catalog lookup is case-sensitive. Wrong case means the
SDK silently ignores custom colors.

### Generic branding tokens

| Token | Description |
|-------|-------------|
| `SMI.primary` | Primary brand color |
| `SMI.primaryVariant` | Variant of the primary color |
| `SMI.onPrimary` | Text/icon color on primary surfaces |
| `SMI.secondary` | Secondary brand color |
| `SMI.onSecondary` | Text/icon color on secondary surfaces |
| `SMI.secondaryActive` | Secondary color for active elements |
| `SMI.surface` | Primary surface color |
| `SMI.onSurface` | Text color on surfaces |
| `SMI.surfaceVariant` | Variant surface color (borders, dividers) |
| `SMI.background` | Background color |
| `SMI.onBackground` | Color for elements on background |
| `SMI.error` | Error feedback color |
| `SMI.tertiary` | Tertiary brand color |

### Detailed branding tokens

These override specific elements and take precedence over generic tokens.
Full list: [ios-colors-detailed-branding-tokens.html](https://developer.salesforce.com/docs/service/messaging-in-app/guide/ios-colors-detailed-branding-tokens.html)

| Token | Generic Token | Description |
|-------|---------------|-------------|
| `SMI.sentBubbleBackground` | secondary | User-sent message bubble background |
| `SMI.sentBubbleText` | onSecondary | User-sent message text color |
| `SMI.receivedBubbleBackground` | surface | Received message bubble background |
| `SMI.receivedBubbleBorder` | surfaceVariant | Incoming chat bubble border |
| `SMI.receivedBubbleText` | onSurface | Received message text color |
| `SMI.inputBackground` | surface | Text input area background |
| `SMI.inputBorder` | surfaceVariant | Text input border color |
| `SMI.inputText` | onSurface | Text input text color |
| `SMI.inputPlaceholder` | onBackground | Placeholder text color |
| `SMI.navigationBackground` | primary | Navigation header background |
| `SMI.navigationText` | onPrimary | Navigation header text color |
| `SMI.navigationIcon` | onPrimary | Navigation header icon color |
| `SMI.chatBackground` | background | Chat window background color |
| `SMI.timestamp` | onBackground | Timestamp text color |
| `SMI.typingIndicatorText` | onBackground | Typing indicator color |

### iOS 26 and Liquid Glass

On iOS 26, the SDK applies a translucent liquid glass material to surfaces by default.
This is **intentional** — it gives the chat UI the native iOS 26 appearance. However,
it means `SMI.*` color assets may appear faint or have no visible effect, because the
glass material takes visual precedence over solid colors.

To disable liquid glass and restore solid surfaces with full brand color control:
```swift
uiConfig.liquidGlassConfiguration = LiquidGlassConfiguration(allowBrandingForLiquidGlass: false)
```

The same `SMI.*` asset catalog token names apply regardless of whether liquid glass is
on or off — no color set renames are needed if you toggle this flag.

---

## Strings

No code generation needed. Strings are customized via `Localizable.strings`.

**Doc:** [ios-strings.html](https://developer.salesforce.com/docs/service/messaging-in-app/guide/ios-strings.html)
**Example:** [Localizable.strings](https://github.com/Salesforce-Async-Messaging/messaging-in-app-ios/blob/master/examples/MessagingUIExample/Localizable.strings)

### How it works

Create a `Localizable.strings` file in the app and override the SDK's string keys.
The SDK checks the app bundle first, then falls back to its own strings.

### Implementation

1. Create a `Localizable.strings` file in the Xcode project (if it doesn't exist).
2. Add overrides using the SDK's string keys:
```
"SMI.Chat.Feed.Title" = "Support Chat";
"SMI.Chat.Feed.InputPlaceholder" = "Type a message...";
"SMI.PreChat.Submit" = "Start Chat";
```
3. For per-locale overrides, create locale-specific `.lproj` directories.

### Common string keys

| Key | Default | Description |
|-----|---------|-------------|
| `SMI.Chat.Feed.Title` | "Chat" | Chat feed navigation title |
| `SMI.Chat.Feed.InputPlaceholder` | "Type a message" | Text input placeholder |
| `SMI.PreChat.Submit` | "Submit" | Pre-chat form submit button |
| `SMI.PreChat.Title` | "Pre-Chat" | Pre-chat form title |
| `SMI.Error.Generic` | "Something went wrong" | Generic error message |
| `SMI.BusinessHours.Closed` | -- | Business hours closed banner text |

Full list: [iOS Reference Documentation](https://salesforce-async-messaging.github.io/messaging-in-app-ios/).

---

## Icons

No code generation needed. Icons are customized via Asset Catalog image sets.

**Doc:** [ios-icons.html](https://developer.salesforce.com/docs/service/messaging-in-app/guide/ios-icons.html)
**Example:** [Assets.xcassets](https://github.com/Salesforce-Async-Messaging/messaging-in-app-ios/tree/master/examples/MessagingUIExample/Assets.xcassets)

### Implementation

1. In Xcode, open the app's Asset catalog.
2. Click **+** and select **Image Set**.
3. Name it with the SDK keyword (e.g., `SMI.actionSend`).
4. Add 1x, 2x, and 3x images.
5. Set **Render As** to **Template Image** to respect tint color.

### Icon tokens

| Keyword | Description |
|---------|-------------|
| `SMI.actionCancel` | Cancel action icon |
| `SMI.actionDismiss` | Dismiss current view icon |
| `SMI.actionJumpTo` | Jump-to action icon |
| `SMI.actionMenu` | Text input menu button icon |
| `SMI.actionParticipantMenu` | Participant client menu icon |
| `SMI.actionSearch` | Message search icon |
| `SMI.actionSend` | Send button icon |
| `SMI.actionShare` | Share action icon |
| `SMI.avatarBot` | Default bot avatar in chat feed |
| `SMI.avatarUser` | User avatar in search results |
| `SMI.backButtonArrow` | Custom back button arrow |
| `SMI.chevronRight` | Link preview navigation chevron |
| `SMI.iconCheckMark` | Confirmed action icon |
| `SMI.iconClock` | Business hours banner icon |
| `SMI.iconCSV` | CSV file type icon |
| `SMI.iconDelivered` | Message delivered status icon |
| `SMI.iconError` | Error state icon |
| `SMI.iconExcel` | Excel file type icon |
| `SMI.iconFailed` | Message send failure icon |
| `SMI.iconForm` | Form message icon in feed |
| `SMI.iconFormCalendar` | Date form type icon |
| `SMI.iconFormFailed` | Form submit error icon |
| `SMI.iconFormOptionSelected` | Selected option in form menu |
| `SMI.iconImagePlaceholder` | Image placeholder in feed |
| `SMI.iconMessageBadge` | Message overlay badge in feed |
| `SMI.iconOffline` | Offline state icon |
| `SMI.iconPreChatReceipt` | Pre-chat receipt checklist icon |
| `SMI.iconRead` | Message read status icon |
| `SMI.iconSending` | Message in transit icon |
| `SMI.iconSent` | Message sent status icon |
| `SMI.iconTxt` | Text file type icon |
| `SMI.iconWord` | Word file type icon |
| `SMI.iconXML` | XML file type icon |

---

## View Replacement (Bring Your Own UI)

Min SDK version: 1.7.0

BEFORE generating any view replacement code, fetch ALL of these example files:

Builder:
`https://raw.githubusercontent.com/Salesforce-Async-Messaging/messaging-in-app-ios/master/examples/Shared/Delegates/Providers/TestEntryViewBuilder.swift`

Entry container (origin/layout):
`https://raw.githubusercontent.com/Salesforce-Async-Messaging/messaging-in-app-ios/master/examples/Shared/ReplacementUI/Views/EntryContainerReplacement.swift`

Text message model:
`https://raw.githubusercontent.com/Salesforce-Async-Messaging/messaging-in-app-ios/master/examples/Shared/ReplacementUI/Models/ConversationEntry/TextMessageReplacement.swift`

Text bubble view:
`https://raw.githubusercontent.com/Salesforce-Async-Messaging/messaging-in-app-ios/master/examples/Shared/ReplacementUI/Views/TextReplacement.swift`

Replacement categories:
`https://raw.githubusercontent.com/Salesforce-Async-Messaging/messaging-in-app-ios/master/examples/Shared/Enums/UIReplacementCategory.swift`

Browse the full replacement UI directory for additional patterns:
`https://github.com/Salesforce-Async-Messaging/messaging-in-app-ios/tree/master/examples/Shared/ReplacementUI`

### What the examples demonstrate
- Implementing `ChatFeedViewBuilder` with `renderMode`, `accessibilityLabel`, and `completeView` closures
- Returning `.existing` (default view), `.replace` (custom view), or `.none` (hidden)
- Casting `ChatFeedModel` to specific subtypes (`ConversationEntryModel`, `TypingIndicatorModel`, etc.)
- Using `entry.sender.isLocal` and `entry.sender.role == .system` for message origin
- Casting `entry.payload` to the correct payload type based on `entry.format`

### Sender origin pattern (from EntryContainerReplacement.swift)
```swift
if entry.sender.role == .system {
    // system message
} else if entry.sender.isLocal {
    // sent by the local user
} else {
    // received from remote (agent, bot, etc.)
}
```

### Replaceable element types

| ChatFeedModel Type | What It Represents |
|---|---|
| `ConversationEntryModel` | All conversation entries (messages, forms, etc.) |
| `TypingIndicatorModel` | Agent/bot typing indicator |
| `ProgressIndicatorModel` | Progress/loading indicator |
| `DateBreakModel` | Date separator between messages |
| `PreChatReceiptModel` | Pre-chat submission receipt |
| `ConversationClosedModel` | Conversation closed state |
| `QueuePositionModel` | Queue position display |

### Payload types by format (for ConversationEntryModel)

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

### Event payload types by entry type

| Entry Type | Cast `entry.payload` to |
|-----------|------------------------|
| `.participantChanged` | `ParticipantChanged` |
| `.sessionStatusChanged` | `SessionStatusChanged` |

### Adapt for the user's project
- Pass the builder: `Interface(uiConfig, chatFeedViewBuilder: MyViewBuilder())`
- Only replace the specific elements the user wants to customize
- Return `.existing` for everything else

### Common mistakes
- Do NOT implement `accessibilityLabel` unless providing a real value (it defaults to `nil`)
- Do NOT fabricate type names. `EntryPayloadText` does not exist -- use `TextMessage`.
  `ParticipantRole.endUser` does not exist -- use `entry.sender.isLocal`.

Do NOT add code beyond what the examples demonstrate.
If you cannot fetch the examples, STOP and tell the user you need network access.

---

## Navigation Bar Customization

BEFORE generating any code, fetch these examples:

Builder:
`https://raw.githubusercontent.com/Salesforce-Async-Messaging/messaging-in-app-ios/master/examples/Shared/Delegates/Providers/TestNavBarBuilder.swift`

Categories:
`https://raw.githubusercontent.com/Salesforce-Async-Messaging/messaging-in-app-ios/master/examples/Shared/Enums/NavBarReplacementCategory.swift`

### What the examples demonstrate
- Subclassing `NavigationBarBuilder`
- Setting the `handleNavigation` closure to customize `UINavigationItem` per screen
- Handling different `NavigationScreenType` values

### Customizable screens

| Screen | Description |
|--------|-------------|
| `.chatFeed` | Main chat feed view |
| `.form` | Secure form view |
| `.confirmation` | Confirmation screen |
| `.information` | Information screen |
| `.preChat` | Pre-chat form |
| `.attachment` | Attachment viewer |
| `.transcripts` | Transcript view |
| `.optionsMenu` | Options menu |

### Adapt for the user's project
- Pass the builder: `Interface(uiConfig, navigationBarBuilder: MyNavBarBuilder())`
- If the project uses `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`, mark the overridden
  `init()` as `nonisolated`

### Adding, replacing, or removing nav bar buttons

The SDK may set its own buttons (e.g. the options menu) on `navigationItem` before or
alongside your `handleNavigation` callback. Choose the right approach based on intent:

**Add a button alongside existing SDK buttons** — read the current array and append:
```swift
var items = navigationItem.rightBarButtonItems ?? []
items.append(UIBarButtonItem(primaryAction: action))
navigationItem.rightBarButtonItems = items
```

**Replace all buttons** — assign directly, discarding whatever the SDK set:
```swift
navigationItem.rightBarButtonItem = UIBarButtonItem(primaryAction: action)
```

**Remove all buttons** — set to an empty array:
```swift
navigationItem.rightBarButtonItems = []
```

Use the **append** pattern when the user wants to add a button and keep the SDK's
existing buttons (e.g. the options menu). Use **replace** or **remove** only when
the goal is to take full control of the nav bar for that screen.

### Dynamic titles
The example app demonstrates updating the nav bar title dynamically with the active
agent's name by combining `NavigationBarBuilder` with `ConversationClientDelegate`.
If the user wants this, also fetch:
`https://raw.githubusercontent.com/Salesforce-Async-Messaging/messaging-in-app-ios/master/examples/Shared/Delegates/CoreDelegate/GlobalCoreDelegateHandler+ConversationClient.swift`

Do NOT add code beyond what the examples demonstrate.
If you cannot fetch the examples, STOP and tell the user you need network access.
