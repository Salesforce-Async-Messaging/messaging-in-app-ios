# Troubleshooting Reference

Common issues organized by symptom, with concrete fixes.

## Code Generation Rules

1. Every file using SDK types must import BOTH `SMIClientCore` and `SMIClientUI`.
2. Never invent type names. Verify against `../features/reference/api-surface.md`.
3. The SPM product name is `Swift-InAppMessaging`, NOT `SMIClientUI`.
4. Minimal changes only. Fix the specific issue -- do not refactor or reorganize.

---

## Build Errors

### "No such module 'SMIClientUI'" or "No such module 'SMIClientCore'"

**Cause:** The SDK dependency is not properly linked.

**Fix (SPM):**
1. Verify `https://github.com/Salesforce-Async-Messaging/Swift-Package-InAppMessaging` is listed
   in project settings > Package Dependencies.
2. Check that **`Swift-InAppMessaging`** (the product name) is added to the app target
   under "Frameworks, Libraries, and Embedded Content." The product name is NOT `SMIClientUI` --
   the package exposes a single product called `Swift-InAppMessaging`.
3. If adding via `project.pbxproj`, verify `productName = "Swift-InAppMessaging"` in the
   `XCSwiftPackageProductDependency` entry.
4. If the project was originally multiplatform (`SDKROOT = auto`), change to `SDKROOT = iphoneos`.
5. Clean the build folder (Cmd+Shift+K) and rebuild.

**Fix (CocoaPods):**
1. Verify `pod 'Messaging-InApp-UI'` is in the Podfile.
2. Run `pod install` (not `pod update` unless a version change is needed).
3. Open the `.xcworkspace` file (not `.xcodeproj`).
4. Clean the build folder and rebuild.

### "Missing package product 'SMIClientUI'" or "Missing package product"

**Cause:** The `productName` in `XCSwiftPackageProductDependency` is wrong.

**Fix:**
1. The correct product name is **`Swift-InAppMessaging`**, not `SMIClientUI`.
2. Update the `XCSwiftPackageProductDependency` entry in `project.pbxproj`:
   change `productName = SMIClientUI` to `productName = "Swift-InAppMessaging"`.
3. Update all related comments in `PBXBuildFile` and `PBXFrameworksBuildPhase` entries.
4. Run `xcodebuild -resolvePackageDependencies` and rebuild.

### SPM resolve fails with "already exists in file system"

**Cause:** Stale binary artifact cache from a previous SDK version.

**Fix:**
```bash
rm -rf ~/Library/Caches/org.swift.swiftpm/artifacts/https___salesforce_async_messaging*
rm -rf ~/Library/Caches/org.swift.swiftpm/artifacts/https___github_com_sqlcipher*
```
Re-run `xcodebuild -resolvePackageDependencies`.

### Linker errors ("Undefined symbols")

**Cause:** Missing transitive dependencies or architecture mismatch.

**Fix:**
1. Ensure building for a supported architecture (arm64 for device, x86_64/arm64 for simulator).
2. If using CocoaPods, run `pod deintegrate && pod install` to reset.
3. Check that `Build Active Architecture Only` is set correctly.
4. Verify the minimum deployment target is iOS 16.0 or later.

### "Duplicate symbols" or "Multiple commands produce"

**Cause:** The SDK is linked through multiple paths (e.g., both SPM and CocoaPods).

**Fix:** Use only one package manager. Remove duplicate references.

### "Type 'MyClass' does not conform to protocol 'ObservableObject'"

**Cause:** The project uses `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` (Xcode 26 default).
Actor isolation prevents automatic `ObservableObject` conformance synthesis for classes
that hold SDK state or are used as coordinators.

**Fix:** Replace `ObservableObject` with the `@Observable` macro:
```swift
// WRONG under SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor
class ChatCoordinator: ObservableObject {
    @Published var transcriptURL: URL?
}
// In view: @StateObject private var coordinator = ChatCoordinator(...)

// CORRECT
@Observable
class ChatCoordinator {
    var transcriptURL: URL?
}
// In view: @State private var coordinator = ChatCoordinator(...)
// Or, when initializing with a non-literal value in init():
// self._coordinator = State(initialValue: ChatCoordinator(...))
```

### "has different actor isolation from nonisolated overridden declaration"

**Cause:** The project uses `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` (Xcode 26 default)
and a subclass of an SDK type (e.g., `NavigationBarBuilder`) overrides a `nonisolated` method.

**Fix:** Mark the overridden initializer or method as `nonisolated`:
```swift
class MyNavBarBuilder: NavigationBarBuilder {
    nonisolated override init() {
        super.init()
    }
}
```

---

## Configuration Errors

### Chat view shows but no messages are sent/received

**Cause:** Invalid configuration values.

**Fix:**
1. Verify `organizationId` is a valid 15-character Salesforce org ID (starts with `00D`).
2. Verify `developerName` matches the API name of the embedded service deployment (not the label).
3. Verify `serviceAPI` URL is correct and reachable from the device.
4. If using a JSON config file, verify correct keys: `"Url"`, `"OrganizationId"`, `"DeveloperName"`.

### "Invalid config" or `nil` from `Configuration(url:)`

**Cause:** The config JSON file is missing, malformed, or not in the app bundle.

**Fix:**
1. Check the file is added to the app target (File Inspector > Target Membership).
2. Verify the JSON is valid (no trailing commas, correct key names).
3. Verify the file name and extension match `Bundle.main.url(forResource:withExtension:)`.

### Config values stop working after a Salesforce sandbox refresh

**Cause:** Refreshing a Salesforce sandbox changes the org ID. The old config values in the
app are now invalid.

**Fix:** Download a fresh `config.json` from the refreshed sandbox org and update the app.
All three values may change: org ID, developer name, and service URL.

### Conversation starts fresh every time instead of resuming

**Cause:** A new UUID is generated each time the UI is presented.

**Fix:** Persist the `conversationId` UUID and reuse it:
```swift
let key = "savedConversationId"
let conversationId: UUID
if let savedString = UserDefaults.standard.string(forKey: key),
   let savedUUID = UUID(uuidString: savedString) {
    conversationId = savedUUID
} else {
    conversationId = UUID()
    UserDefaults.standard.set(conversationId.uuidString, forKey: key)
}
```

---

## Runtime Errors

### Chat view appears but stays blank / loading forever

**Cause:** Network connectivity issue, invalid credentials, or SSE connection failure.

**Fix:**
1. Check the device has network connectivity.
2. Enable debug logging and look for connection errors in the console.
3. Verify the `serviceAPI` URL is correct and uses HTTPS.
4. Check if the Salesforce deployment is active and properly configured.
5. Verify the embedded service deployment is published in the org.

### Chat view goes blank shortly after appearing

**Cause:** `CoreClient` was created as a local variable and deallocated before the SDK
could finish connecting.

**Fix:** Store the `CoreClient` as a property on a persistent object (view model,
coordinator, or app delegate), not inside a function body:
```swift
// WRONG — deallocated when showChat() returns
func showChat() {
    let core = CoreFactory.create(withConfig: config)
    core.setPreChatDelegate(delegate: self, queue: .main)
    ...
}

// CORRECT — retained for the lifetime of the containing object
class ChatCoordinator {
    let core = CoreFactory.create(withConfig: config)
    ...
}
```

### "Error" banner appears in the chat view

**Cause:** Various server-side or client-side errors.

**Fix:**
1. Enable debug logging to see the specific error.
2. Common causes: deployment not active, bot not configured, routing not set up.
3. These are typically Salesforce org configuration issues, not SDK issues.

### Recurring SDK crashes with no obvious cause

**Cause:** A known bug in an older SDK version.

**Fix:** Upgrade to the latest SDK release. Check the release notes for crash fixes in
recent versions before investigating further.

### SDK crashes on launch

**Cause:** Usually a CoreData migration issue or keychain access problem.

**Fix:**
1. If upgrading the SDK version, the encrypted CoreData store may need migration.
2. Try calling `destroyStorage(andAuthorization: true)` to reset the local database.
3. Ensure the app's keychain sharing entitlement is consistent across builds.

---

## Push Notifications

### Notifications not received

**Cause:** Multiple possible causes in the APNs chain.

**Fix:**
1. Verify APNs is configured in Apple Developer portal.
2. Verify push notification keys are uploaded to Salesforce.
3. Verify `CoreFactory.provide(deviceToken:)` is called with the correct hex string.
4. Check that the device token is being passed (add a breakpoint in `didRegisterForRemoteNotificationsWithDeviceToken`).
5. Verify the device has notifications enabled in Settings.
6. Test with a physical device (APNs doesn't work in the Simulator for production certs).

### Notification tap doesn't open the correct conversation

**Cause:** Not extracting `conversationId` from the notification payload.

**Fix:** Extract `conversationId` from `aps` in the notification's `userInfo` dictionary and
create a `UIConfiguration` with that UUID.

### Notifications show when the app is in the foreground

**Cause:** Missing foreground notification handling.

**Fix:** Implement `userNotificationCenter(_:willPresent:withCompletionHandler:)` and suppress
notifications when the app is active.

### Push notifications delayed or not delivered while the app is active

**Cause:** The SDK maintains an SSE (Server-Sent Events) stream while the app is in the
foreground. The server delivers messages over this stream instead of push — notifications
are intentionally suppressed while the connection is live. This is expected behavior.

**Note:** A ~10 second delivery delay is expected while the SSE stream is re-establishing
after the app returns to the foreground. This is by design, not a bug.

**Fix:** No SDK code change needed. Suppress foreground push banners using
`userNotificationCenter(_:willPresent:withCompletionHandler:)` — messages arrive via SSE
while the app is open.

---

## User Verification

### Delegate method never called

**Cause:** Delegate not registered, or `userVerificationRequired` not set.

**Fix:**
1. Verify `userVerificationRequired: true` is set on the Configuration.
2. Verify `core.setUserVerificationDelegate(delegate: self, queue: .main)` is called before the UI is presented.
3. Verify the delegate class conforms to `UserVerificationDelegate`.

### "Expired" or "Malformed" challenge reason keeps firing

**Cause:** The JWT is invalid or expired.

**Fix:**
1. Verify the JWT is valid and not expired at the time of delivery.
2. For `.expired` or `.malformed` reasons, return `nil` to stop the retry loop.
3. Check that the JWT signing keys match what's uploaded to Salesforce.

### Cannot switch between verified and unverified users

**Cause:** This is not supported.

**Fix:** The implementation must be designed for either verified or unverified users,
not both. Do not reuse conversation IDs across verified/unverified sessions.

### User cannot send messages / authentication error even with a valid JWT

**Cause:** The SDK's `userVerificationRequired` flag does not match the channel's
authentication mode configured in the Salesforce org.

**Fix:**
1. If the Salesforce channel is "Verified users only", set `userVerificationRequired: true`
   on the `Configuration` object.
2. If the channel is "Unauthenticated", do not set `userVerificationRequired: true`.
3. Mismatches produce silent failures — enable debug logging and look for auth errors.
4. Validate the JWT at jwt.io to confirm it is well-formed and not expired.

---

## Conversation IDs

### "Access denied" or conversation not found

**Cause:** Using a conversation ID from a different deployment, org, or user type.

**Fix:**
1. Conversation IDs are permanently linked to the user who created them.
2. Do not reuse IDs across deployments, orgs, or verified/unverified sessions.
3. Do not use business IDs (user IDs, account numbers) as conversation IDs.
4. Generate a fresh UUID v4 for each new conversation.

### Conversations not syncing across devices

**Cause:** User verification is not enabled.

**Fix:** Cross-device sync requires user verification. Unverified conversations
are device-local only.

### Conversation history lost after app reinstall

**Cause:** Unverified conversation history is device-local only and is not recoverable
after a reinstall.

**Fix:** Post-reinstall history requires user verification — verified conversations are
server-stored and can be resumed on any device. For unverified sessions, this is
expected behavior and cannot be avoided.

### Old conversation data appears after switching to a different deployment

**Cause:** Local conversation data from the previous deployment is still in the SDK
database.

**Fix:** Call `destroyStorage(andAuthorization: true)` when switching deployments or orgs.
Do not reuse conversation IDs across different deployments.

---

## Pre-Chat Issues

### Pre-chat form not appearing

**Cause:** Pre-chat not configured in Salesforce, or remote configuration not fetched.

**Fix:**
1. Verify pre-chat fields are configured in the Salesforce org.
2. The UI SDK automatically presents the pre-chat form if configured.
3. If using hidden pre-chat fields, the delegate must be set before the conversation starts.

### Hidden pre-chat delegate not called

**Cause:** Delegate not registered before the conversation begins.

**Fix:**
1. Call `core.setPreChatDelegate(delegate: self, queue: .main)` before presenting the UI.
2. Verify the class conforms to `HiddenPreChatDelegate`.
3. Verify hidden pre-chat fields are configured in Salesforce.

### Hidden pre-chat delegate registered but methods never fire

**Cause:** The delegate object itself is being deallocated. The SDK does not retain the
delegate — if the object goes out of scope after registration, callbacks silently stop.

**Fix:** Ensure the object conforming to `HiddenPreChatDelegate` is held as a stored
property, not a local variable, for the lifetime of the conversation.

### Pre-populated fields not appearing / form won't submit

**Cause:** Validation errors on non-editable pre-populated fields.

**Fix:**
1. Non-editable fields must pass all validation rules (character limits, required, data type).
2. Check the Xcode console for validation error messages.
3. Ensure the `name` property matches the field API name in Salesforce.

### Bot flow doesn't trigger / conversation starts without pre-chat context

**Cause:** The conversation is created before pre-chat is submitted, so the bot receives
no pre-chat data to route on.

**Fix:** Set `createConversationOnSubmit = true` on `UIConfiguration`:
```swift
uiConfig.createConversationOnSubmit = true
```
This ensures the conversation (and bot flow) only starts after pre-chat is submitted.
Also verify the bot and routing rules are configured in the Salesforce deployment.

---

## File Attachments

### Attachment button is visible but uploads are rejected by the server

**Cause:** The SDK's `attachmentConfiguration` controls button visibility, but file sharing
must also be enabled in the Salesforce org deployment. The server rejects uploads when
the org does not have file sharing turned on regardless of the SDK config.

**Fix:**
1. Enable file sharing in the Salesforce org deployment settings.
2. Verify the allowed file types in `AllowedFileTypes` match what the org permits.
3. If uploads are rejected with an error in the chat feed, the issue is org configuration,
   not SDK code.

---

## Business Hours

### App crashes when calling `retrieveBusinessHours`

**Cause:** A bug in earlier SDK versions.

**Fix:** Upgrade to the latest SDK release. This crash was resolved in a recent version.

### `retrieveBusinessHours` returns nil / business hours not working

**Cause:** Business hours are not configured in the Salesforce org for the deployment.

**Fix:** Configure business hours in the Salesforce org under the deployment settings.
The SDK returns `nil` when the org has no business hours configured — this is not an error.

---

## iOS 26 / Liquid Glass

### Chat UI looks unexpectedly glassy or transparent on iOS 26

**Cause:** The SDK applies iOS 26's liquid glass material when
`LiquidGlassConfiguration` is enabled.

**Fix:** Disable liquid glass:
```swift
uiConfig.liquidGlassConfiguration = LiquidGlassConfiguration(allowBrandingForLiquidGlass: false)
```

### Legacy Salesforce Service SDK (Snap-ins / embedded chat) looks broken on iOS 26

**Note:** The legacy Service SDK is not being updated for iOS 26. Migrate to
Messaging for In-App (MIAW) to receive ongoing iOS compatibility updates. There is
no workaround for the legacy SDK on iOS 26.

---

## Customization

### Custom colors not applying

**Cause:** Asset catalog color set names are case-sensitive. A wrong-case name (e.g.,
`smi.primary` instead of `SMI.primary`) is silently ignored by the SDK.

**Fix:**
1. All color set names must use the uppercase `SMI.` prefix exactly as documented.
2. Verify the asset catalog is in the **main app bundle**, not a framework target.
3. Clean the build folder (Cmd+Shift+K) and rebuild.
4. **iOS 26 only:** Liquid glass is the intended default on iOS 26 and makes surfaces
   translucent, which can make `SMI.*` colors appear faint or have no visible effect.
   This is expected behavior — the glass material takes visual precedence over solid colors.
   To disable it and restore solid surfaces with full brand color control:
   ```swift
   uiConfig.liquidGlassConfiguration = LiquidGlassConfiguration(allowBrandingForLiquidGlass: false)
   ```

### Custom icons not applying

**Cause:** Image set name is wrong, or the render mode is not set to Template Image.

**Fix:**
1. Verify the image set name matches the exact SDK keyword (e.g., `SMI.actionSend`).
2. In the asset catalog, set **Render As** to **Template Image** so the SDK's tint
   color is respected.
3. Verify the asset catalog is in the main app bundle.

### `Localizable.strings` overrides not applying

**Cause:** The strings file is not in the app target, or keys do not match exactly.

**Fix:**
1. Verify the file is added to the app target (File Inspector > Target Membership).
2. Keys must match exactly, including the `SMI.` prefix and capitalization
   (e.g., `"SMI.Chat.Feed.Title"`).
3. Clean the build folder and rebuild.

---

## Storage Issues

### App storage growing unexpectedly

**Cause:** Conversation history accumulates in the encrypted CoreData store.

**Fix:** Call `destroyStorage(andAuthorization: false)` periodically to clear conversation
cache while preserving authentication.

### Data not cleared after calling destroyStorage

**Cause:** The SDK stores some data in the keychain, which `destroyStorage` does not
clear unless `andAuthorization: true`.

**Fix:** Use `destroyStorage(andAuthorization: true)` for a complete reset. This
requires re-authentication for verified users.
