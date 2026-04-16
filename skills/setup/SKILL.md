---
name: salesforce-messaging-setup
description: >-
  Set up and integrate the Salesforce Messaging for In-App iOS SDK into an app.
  Use when the user wants to add the SDK, install the dependency, configure
  messaging, present the chat UI, or do initial integration with SwiftUI or UIKit.
---

# Salesforce Messaging for In-App iOS SDK -- Initial Setup

You guide the initial integration of the Salesforce Messaging for In-App iOS SDK
into a customer's iOS app. Follow the steps below exactly. Do not skip steps.

## Code Generation Rules

These rules are mandatory for ALL code you generate.

1. **Minimal changes only.** Make the smallest change to achieve the goal. Do not
   restructure, refactor, rename, or reorganize existing code. Do not add decorative
   UI, placeholder screens, or boilerplate. Integrate into the user's existing view
   hierarchy -- do not replace it. If you can edit an existing file, do not create a new one.

2. **Fetch examples before writing code.** Before generating any code that uses SDK
   types, you MUST fetch the relevant example file from the public GitHub example app.
   The base URL for raw files is:
   `https://raw.githubusercontent.com/Salesforce-Async-Messaging/messaging-in-app-ios/master/examples/`
   If you cannot fetch the file, STOP and tell the user you need network access.
   Do NOT generate SDK code from memory.

3. **Never invent type names.** Do not fabricate class names, enum cases, property names,
   or protocol signatures. Common mistakes:
   - `EntryPayloadText` does not exist -- use `TextMessage`
   - `ParticipantRole.endUser` does not exist -- use `entry.sender.isLocal`
   - `EntryPayloadImage` does not exist -- use `ImageAsset`

4. **Both imports required.** Every file using SDK types must have:
   ```swift
   import SMIClientCore
   import SMIClientUI
   ```
   `Configuration`, `ConversationEntry`, `TextMessage` live in `SMIClientCore`.
   `UIConfiguration`, `Interface`, `ChatFeedViewBuilder` live in `SMIClientUI`.

5. **Do NOT generate unnecessary code.** Never implement optional protocol properties or
   methods just to return `nil` or no-op values. If the example omits something, you omit
   it too.

6. **Handle actor isolation.** If the project uses `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`
   (Xcode 26 default):
   - Mark overridden initializers and methods as `nonisolated` when subclassing SDK types
     (e.g. `NavigationBarBuilder`).
   - Use `@Observable` instead of `ObservableObject` for any coordinator or view model
     class that holds SDK state. Use `@State` instead of `@StateObject`, and
     `State(initialValue:)` in `init()` when a non-literal initial value is needed.

## Prerequisites

Confirm the user has all of these before writing any code:

- **Salesforce configuration**: a `config.json` downloaded from the org, OR the service API
  URL, org ID, and developer name from the embedded service deployment.
- **Published deployment**: the Embedded Service deployment must be published in the
  Salesforce org. An unpublished deployment causes a blank or stalled chat view.
- **iOS 16.0+ deployment target**: verify before adding the SDK.

If the user is missing their configuration values, stop and tell them to download
`config.json` from Salesforce Setup > Messaging Settings before continuing.

## Step 1: Assess the Project

Search the project to determine:
- **SwiftUI vs UIKit**: look for `@main` + `App` protocol (SwiftUI) or `AppDelegate`/`SceneDelegate` (UIKit)
- **Package manager**: check for `Package.swift` (SPM) or `Podfile` (CocoaPods)
- **Existing SDK imports**: search for `SMIClientUI` or `SMIClientCore`
- **Navigation pattern**: `NavigationStack`/`NavigationView` (SwiftUI) or `UINavigationController` (UIKit)
- **Minimum deployment target**: the SDK requires iOS 16.0 or later

## Step 2: Add the Dependency

**MUST check the latest SDK version first.** Fetch the tags page to find the current
latest release:
`https://github.com/Salesforce-Async-Messaging/Swift-Package-InAppMessaging/tags`

Use that version as the `minimumVersion`. Never hardcode an older version or guess.

**CRITICAL:** The SPM product name is **`Swift-InAppMessaging`**, NOT `SMIClientUI`.
The package exposes a single library product called `Swift-InAppMessaging` which bundles
`SMIClientCore`, `SMIClientUI`, and `SMIClientCoreWrapper` together. Code still uses
`import SMIClientUI` and `import SMIClientCore` -- those are the module names.

### SPM (preferred)

The SDK repo is `https://github.com/Salesforce-Async-Messaging/Swift-Package-InAppMessaging`.

**Always wire up the package by editing `project.pbxproj` directly** as part of the setup
workflow. Do not ask the user to do this in Xcode — do it yourself. The Xcode UI is an
alternative the user can use if they prefer, but the skill always performs these edits.

**Step 2a: Detect the current state**

Read `project.pbxproj` and check for each of these conditions:

| Condition | What to do |
|-----------|-----------|
| No `XCRemoteSwiftPackageReference` for the SDK URL | Full setup: all 6 edits below |
| Reference exists but `packageProductDependencies` is empty | Linking only: edits 1–3 below |
| Reference exists and product is in `packageProductDependencies` | Already done, skip |

**Step 2b: Generate IDs**

Run this command 3 times to generate the required unique IDs:
```bash
uuidgen | tr -d '-' | cut -c1-24 | tr '[:lower:]' '[:upper:]'
```
Assign them:
- `<PKG_REF_ID>` — for the `XCRemoteSwiftPackageReference` entry
- `<PRODUCT_DEP_ID>` — for the `XCSwiftPackageProductDependency` entry
- `<BUILD_FILE_ID>` — for the `PBXBuildFile` entry

**Step 2c: Make the 6 edits to `project.pbxproj`**

> **Indentation warning:** `project.pbxproj` uses real tab characters (`\t`), not spaces.
> The Read tool renders tabs as spaces, which is misleading. Before editing, always run
> `python3 -c "with open('project.pbxproj') as f: [print(repr(l)) for l in f.readlines()[N:N+5]]"`
> on the target lines to confirm exact bytes. Edit failures are almost always a tab/space mismatch.

**Edit 1 — Add `PBXBuildFile` entry** (insert before `/* Begin PBXFileSystemSynchronizedRootGroup section */`
or after `/* End PBXFileReference section */`):
```
/* Begin PBXBuildFile section */
		<BUILD_FILE_ID> /* Swift-InAppMessaging in Frameworks */ = {isa = PBXBuildFile; productRef = <PRODUCT_DEP_ID> /* Swift-InAppMessaging */; };
/* End PBXBuildFile section */
```

**Edit 2 — Add to `PBXFrameworksBuildPhase.files`** (match the `isa = PBXFrameworksBuildPhase;`
entry to avoid hitting `PBXResourcesBuildPhase` or `PBXSourcesBuildPhase`):
```
			files = (
				<BUILD_FILE_ID> /* Swift-InAppMessaging in Frameworks */,
			);
```

**Edit 3 — Add to `PBXNativeTarget.packageProductDependencies`:**
```
			packageProductDependencies = (
				<PRODUCT_DEP_ID> /* Swift-InAppMessaging */,
			);
```

**Edit 4 — Add `packageReferences` to `PBXProject`** (before the `targets = (` line):
```
			packageReferences = (
				<PKG_REF_ID> /* XCRemoteSwiftPackageReference "Swift-Package-InAppMessaging" */,
			);
```

**Edit 5 — Add `XCRemoteSwiftPackageReference` section** (before `/* Begin XCBuildConfiguration section */`):
```
/* Begin XCRemoteSwiftPackageReference section */
		<PKG_REF_ID> /* XCRemoteSwiftPackageReference "Swift-Package-InAppMessaging" */ = {
			isa = XCRemoteSwiftPackageReference;
			repositoryURL = "https://github.com/Salesforce-Async-Messaging/Swift-Package-InAppMessaging";
			requirement = {
				kind = upToNextMajorVersion;
				minimumVersion = <LATEST_VERSION>;
			};
		};
/* End XCRemoteSwiftPackageReference section */
```

**Edit 6 — Add `XCSwiftPackageProductDependency` section** (before `/* Begin XCBuildConfiguration section */`,
after Edit 5):
```
/* Begin XCSwiftPackageProductDependency section */
		<PRODUCT_DEP_ID> /* Swift-InAppMessaging */ = {
			isa = XCSwiftPackageProductDependency;
			package = <PKG_REF_ID> /* XCRemoteSwiftPackageReference "Swift-Package-InAppMessaging" */;
			productName = "Swift-InAppMessaging";
		};
/* End XCSwiftPackageProductDependency section */
```

**Step 2d: Resolve packages**

After editing, run:
```bash
xcodebuild -resolvePackageDependencies -project <Project>.xcodeproj -scheme <Scheme>
```
Confirm the output includes `Swift-InAppMessaging` in the resolved packages list.
If resolution fails with "already exists in file system" errors, clear the SPM artifact cache:
```bash
rm -rf ~/Library/Caches/org.swift.swiftpm/artifacts/https___salesforce_async_messaging*
rm -rf ~/Library/Caches/org.swift.swiftpm/artifacts/https___github_com_sqlcipher*
```
Then re-run the resolve command.

**Platform settings** -- the SDK is iOS-only. If the project is multiplatform (`SDKROOT = auto`):
- `SDKROOT = iphoneos`
- `SUPPORTED_PLATFORMS = "iphoneos iphonesimulator"`
- `TARGETED_DEVICE_FAMILY = "1,2"`
- Remove `XROS_DEPLOYMENT_TARGET` and `MACOSX_DEPLOYMENT_TARGET` if present.

### CocoaPods

Add to Podfile:
```ruby
pod 'Messaging-InApp-UI'
```
Run `pod install` and open the `.xcworkspace`.

## Step 3: Create the Configuration and Present the UI

This step depends on whether the project uses SwiftUI or UIKit. Fetch the
corresponding example file BEFORE writing any code.

### SwiftUI Projects

BEFORE generating any code, fetch this example:
`https://raw.githubusercontent.com/Salesforce-Async-Messaging/messaging-in-app-ios/master/examples/MessagingUIExample/Views/ContentView.swift`

**IMPORTANT: Reading ContentView.swift correctly.**
ContentView.swift uses example-app-specific store classes (`MIAWConfigurationStore`,
`ConversationManagementStore`, `UIReplacementStore`, `RemoteLocaleStore`, etc.). These
classes do NOT exist in the user's project. Do NOT copy or reference them.

Extract ONLY these patterns from ContentView.swift:
- How `UIConfiguration` is created from a `Configuration` and a `conversationId`
- How `Interface(uiConfig)` is returned as the view

Replace all store references with the user's own config values and a managed `conversationId`.

**Note on `GlobalCoreDelegateHandler`:** ContentView.swift calls
`GlobalCoreDelegateHandler.shared.registerDelegates(client)` in `.onAppear`. This is
an example-app singleton — the customer does not have this class. For a basic integration
with no delegates, omit this entirely. If the customer needs delegates (pre-chat, user
verification, etc.), refer them to the Delegate Registration Pattern in the features skill.

Adapt for the user's project:
- Ask the user: "Do you have a Salesforce config JSON file, or do you have the
  org ID, developer name, and endpoint URL?"
- Use their existing navigation structure -- do not replace it
- If they want conversation resumption, persist the `conversationId` UUID

### UIKit Projects

BEFORE generating any code, fetch this example:
`https://raw.githubusercontent.com/Salesforce-Async-Messaging/messaging-in-app-ios/master/examples/MessagingUIExample/Views/UIKitMIAW.swift`

What the example demonstrates:
- Creating the configuration
- Using `InterfaceViewController` for push navigation
- Using `ModalInterfaceViewController` for modal presentation

Adapt for the user's project:
- Use their existing `UINavigationController` -- do not create a new one
- Ask whether they want push or modal presentation

### Configuration Values

**From JSON file** (recommended):
```swift
guard let url = Bundle.main.url(forResource: "config", withExtension: "json"),
      let config = Configuration(url: url) else {
    fatalError("Invalid Salesforce config file")
}
```

**Programmatic:**
```swift
let config = Configuration(
    serviceAPI: URL(string: "https://your-domain.salesforce-scrt.com")!,
    organizationId: "00Dxx0000000000",
    developerName: "Your_Deployment_Name"
)
```

### Conversation ID Management

The `conversationId` UUID controls which conversation the user sees. This MUST
be managed correctly -- ask the user how they want conversations to work before
generating code.

**Resume the same conversation** (most common): persist the UUID so the user
returns to their existing conversation on each app launch.
```swift
let conversationKey = "salesforce_conversation_id"
let conversationId: UUID

if let savedId = UserDefaults.standard.string(forKey: conversationKey),
   let uuid = UUID(uuidString: savedId) {
    conversationId = uuid
} else {
    conversationId = UUID()
    UserDefaults.standard.set(conversationId.uuidString, forKey: conversationKey)
}
```

**Start a new conversation**: generate a fresh UUID. If the app has a "New Chat"
button, it should generate a new UUID and save it, replacing the old one.
```swift
func startNewConversation() -> UUID {
    let conversationKey = "salesforce_conversation_id"
    let newId = UUID()
    UserDefaults.standard.set(newId.uuidString, forKey: conversationKey)
    return newId
}
```

**Rules:**
- A conversation ID is a randomly-generated UUID v4 -- never use a customer ID,
  account number, or other business identifier
- Each conversation ID is permanently linked to the user who created it
- Do not share IDs between verified and unverified sessions
- Do not reuse IDs across different Salesforce orgs or deployments
- If the app has multiple user accounts, key the stored UUID by user ID -- a single
  global key means different users see each other's conversation

Then wrap in UIConfiguration using the managed conversation ID:
```swift
let uiConfig = UIConfiguration(
    configuration: config,
    conversationId: conversationId
)
```

Do NOT use `UUID()` directly in the UIConfiguration initializer -- this creates a
new conversation every time the view is created. Always manage the ID as shown above.

Do NOT add code beyond what the examples demonstrate.
If you cannot fetch the examples, STOP and tell the user you need network access.

## Step 4: Validate

After generating the integration code, verify:
1. `import SMIClientUI` and `import SMIClientCore` resolve without errors
2. Config values are real (not placeholder strings)
3. The app builds successfully
4. The chat view presents when triggered
5. If `conversationId` is persisted, reopening resumes the same conversation

## Step 5: Self-Review

Before presenting the code to the user, review your output against this checklist.
If any check fails, fix the code before responding.

1. Both `import SMIClientCore` and `import SMIClientUI` are present in every file
   that uses SDK types?
2. Were the `project.pbxproj` edits made directly (not delegated to the user)?
   Is `Swift-InAppMessaging` present in `packageProductDependencies` for the target?
3. If SPM was modified: the product name is `Swift-InAppMessaging`, not `SMIClientUI`?
3. Configuration values are the user's real values, not example placeholders like
   `"00Dxx0000000000"` or `"Your_Deployment_Name"`?
4. The `conversationId` is properly managed -- NOT `UUID()` inline in the
   UIConfiguration initializer? It must be persisted (e.g. UserDefaults) and
   reused for conversation resumption, with a clear path to create new
   conversations when needed?
5. Only the necessary files were created or edited -- nothing extra was added?
6. The generated code matches the pattern from the fetched ContentView.swift or
   UIKitMIAW.swift example -- no improvisation or invented patterns?
7. The user's existing view hierarchy was not replaced -- the SDK was integrated
   into it?
8. The project's minimum deployment target is iOS 16.0 or later?
