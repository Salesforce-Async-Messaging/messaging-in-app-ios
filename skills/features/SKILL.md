---
name: salesforce-messaging-features
description: >-
  Implement features and customize the Salesforce Messaging for In-App iOS SDK.
  Use when the user mentions push notifications, user verification, pre-chat,
  hidden pre-chat, branding, colors, strings, icons, replace views, custom chat UI,
  ChatFeedViewBuilder, navigation bar, business hours, transcripts, conversation
  management, conversation lists, templated URLs, auto-response, logging,
  locale mapping, delegate registration, ConversationClientDelegate, file attachments,
  allowed file types, attachment configuration, end chat, close conversation,
  agent avatar, progress indicator, liquid glass, iOS 26, or conversation options.
---

# Salesforce Messaging for In-App iOS SDK -- Features & Customization

You help implement features and customize the UI for the Salesforce Messaging for
In-App iOS SDK. Follow the workflow below for every request.

## Code Generation Rules

These rules are mandatory for ALL code you generate.

1. **Fetch examples before writing code.** Before generating any code that uses SDK
   types, you MUST fetch the relevant example file from the public GitHub example app.
   The base URL for raw files is:
   `https://raw.githubusercontent.com/Salesforce-Async-Messaging/messaging-in-app-ios/master/examples/`
   If you cannot fetch the file, STOP and tell the user you need network access.
   Do NOT generate SDK code from memory.

2. **Minimal changes only.** Make the smallest change to achieve the goal. Do not
   restructure, refactor, or reorganize existing code. Do not add decorative UI or
   boilerplate. If you can edit an existing file, do not create a new one.

3. **Never invent type names.** Do not fabricate class names, enum cases, or property
   names. Verify against the fetched example or `reference/api-surface.md`.
   Common mistakes:
   - `EntryPayloadText` does not exist -- use `TextMessage`
   - `ParticipantRole.endUser` does not exist -- use `entry.sender.isLocal`
   - `EntryPayloadImage` does not exist -- use `ImageAsset`

4. **Both imports required.** Every file using SDK types must have:
   ```swift
   import SMIClientCore
   import SMIClientUI
   ```

5. **Do NOT generate unnecessary code.** If the example omits a protocol property or
   method, you omit it too. Never implement optional members just to return `nil`.

6. **Handle actor isolation.** If the project uses `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`
   (Xcode 26 default):
   - Mark overridden initializers and methods as `nonisolated` when subclassing SDK types.
   - Use `@Observable` instead of `ObservableObject` for any coordinator or view model
     class that holds SDK state. Use `@State` instead of `@StateObject`, and
     `State(initialValue:)` in `init()` when a non-literal initial value is needed.

## Workflow: How to Handle Any Feature Request

Follow these 6 steps for every feature or customization request.

### Step 1: Identify the feature

Find the matching feature in the table below.

### Step 2: Read the reference section

Read the corresponding section in the reference file listed in the table.
The reference section tells you which example file to fetch.

### Step 3: Fetch the example

Fetch the example file URL listed in the reference section. Read the example code.
If you cannot fetch it, STOP and tell the user you need network access.

### Step 4: Follow the example pattern

Study the fetched example. Generate code that follows its pattern exactly.
Adapt only the parts specific to the user's project (class names, config values, etc.).

### Step 5: Generate minimal code

Write only the code needed. Do not add anything the example does not demonstrate.

## Feature Routing Table

### Features
| Request | Read this reference section |
|---------|---------------------------|
| Pre-chat forms, bot support, estimated wait time | `reference/features.md` -- Features That Work Automatically |
| File attachments / allowed file types | `reference/features.md` -- Attachment Configuration |
| Push notifications | `reference/features.md` -- Push Notifications |
| User verification / JWT | `reference/features.md` -- User Verification |
| Hidden pre-chat fields | `reference/features.md` -- Hidden Pre-Chat |
| Pre-populate pre-chat form | `reference/features.md` -- Populate Pre-Chat Fields |
| Auto-response / templated URLs | `reference/features.md` -- Auto-Response Component |
| Business hours | `reference/features.md` -- Business Hours |
| Conversation management | `reference/features.md` -- Manage Conversations |
| Conversation lists | `reference/features.md` -- Conversation Lists |
| Transcripts | `reference/features.md` -- Transcripts |
| Clear local storage | `reference/features.md` -- Clear Local Storage |
| Logging | `reference/features.md` -- Logging |
| Remote locale mapping | `reference/features.md` -- Remote Locale Mapping |
| Delegate registration | `reference/features.md` -- Delegate Registration Pattern |
| Conversation events | `reference/features.md` -- Conversation Client Delegate |
| End chat button / allow end chat | `reference/features.md` -- Conversation UI Options |
| Agent avatar / progress indicators | `reference/features.md` -- Conversation UI Options |
| iOS 26 liquid glass branding | `reference/features.md` -- Liquid Glass (iOS 26) |

### Customization
| Request | Read this reference section |
|---------|---------------------------|
| Colors / branding | `reference/customization.md` -- Colors |
| Strings / UI text | `reference/customization.md` -- Strings |
| Icons / images | `reference/customization.md` -- Icons |
| Replace chat feed views | `reference/customization.md` -- View Replacement |
| Navigation bar | `reference/customization.md` -- Navigation Bar Customization |

### Type Verification
| Need | Reference |
|------|-----------|
| Verify a type name, method signature, or enum case | `reference/api-surface.md` |

## Step 6: Self-Review

Before presenting the code to the user, review your output against this checklist.
If any check fails, fix the code before responding.

1. Both `import SMIClientCore` and `import SMIClientUI` are present in every file
   that uses SDK types?
2. Every type name, enum case, and method signature in your code exists in the
   fetched example or `reference/api-surface.md`?
3. No optional protocol properties or methods were implemented just to return `nil`,
   empty collections, or no-op values? If the example omits it, you omit it too.
4. All delegates are registered BEFORE the UI is presented?
5. The generated code follows the exact pattern from the fetched example -- no
   improvisation or invented patterns?
6. No new files were created when an edit to an existing file would have sufficed?
7. No decorative UI, boilerplate, or unnecessary comments were added?
8. If the project uses `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`:
   - SDK type subclass overrides (e.g. `NavigationBarBuilder.init()`) are marked `nonisolated`?
   - Any coordinator/view model holding SDK state uses `@Observable` + `@State`, not
     `ObservableObject` + `@StateObject`?

## External Documentation

- [Developer Guide](https://developer.salesforce.com/docs/service/messaging-in-app/overview)
- [iOS Reference Docs](https://salesforce-async-messaging.github.io/messaging-in-app-ios/)
- [Salesforce Org Setup](https://help.salesforce.com/s/articleView?id=sf.miaw_setup_stages.htm)
- [Release Notes](https://github.com/Salesforce-Async-Messaging/messaging-in-app-ios/releases)
