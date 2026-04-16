---
name: salesforce-messaging-troubleshooting
description: >-
  Troubleshoot and debug issues with the Salesforce Messaging for In-App iOS SDK.
  Use when the user reports something is broken, not working, an error, a crash,
  a blank screen, build failure, push notifications not received, delegate not called,
  conversation not resuming, or any SDK issue they need help debugging.
---

# Salesforce Messaging for In-App iOS SDK -- Troubleshooting

You help diagnose and fix issues with the Salesforce Messaging for In-App iOS SDK.
Follow the triage steps below in order. Do not skip steps.

## Code Generation Rules

When generating fix code:

1. **Minimal changes only.** Fix the specific issue. Do not refactor or reorganize.
2. **Both imports required.** Every file using SDK types must have both
   `import SMIClientCore` and `import SMIClientUI`.
3. **Never invent type names.** If unsure, check `reference/troubleshooting.md` or
   the features skill's `reference/api-surface.md`.
4. The SPM product name is **`Swift-InAppMessaging`**, NOT `SMIClientUI`.

## Triage: Follow These Steps In Order

When a user reports something is broken, work through these checks sequentially.

### Check 1: Enable debug logging

If not already enabled, suggest the user add:
```swift
SMIClientCore.Logging.level = .debug
SMIClientUI.Logging.level = .debug
```
Check the Xcode console for SDK error messages (prefixed with `SMI`). Look specifically
for lines containing `error`, `failed`, or `invalid` — these identify the root cause.

### Check 2: Verify imports

Are both `import SMIClientCore` and `import SMIClientUI` present in every file
that uses SDK types?

- `Configuration`, `ConversationEntry`, `TextMessage` live in `SMIClientCore`
- `UIConfiguration`, `Interface`, `ChatFeedViewBuilder` live in `SMIClientUI`

### Check 3: Verify configuration values

- `organizationId` -- valid 15-character Salesforce org ID (starts with `00D`)?
- `developerName` -- matches the API name (not the label) of the deployment?
- `serviceAPI` -- correct URL, uses HTTPS, reachable from the device?
- If using JSON config: file is valid JSON, included in app target, correct keys
  (`"Url"`, `"OrganizationId"`, `"DeveloperName"`)?

### Check 4: Verify delegate registration

If the issue involves delegates (pre-chat, user verification, templated URLs):
- Is the delegate set BEFORE the UI is presented?
- Does the class conform to the correct protocol?
- Is the delegate being retained (not deallocated)?

### Check 5: Verify conversation ID

- Is it a valid UUID v4 (randomly generated)?
- Is it persisted for conversation resumption?
- Is it NOT a business ID (user ID, account number)?
- Is it NOT shared between verified and unverified sessions?

### Check 6: Verify SDK version

Does the SDK version meet the minimum for the feature being used?

| Feature | Min Version |
|---------|-------------|
| Push notifications | 1.0.0 |
| User verification | 1.2.0 |
| Hidden pre-chat | 1.2.0 |
| Templated URLs | 1.2.0 |
| Business hours | 1.3.0 |
| Conversation lists | 1.3.0 |
| Pre-chat pre-population | 1.5.0 |
| Transcripts | 1.5.0 |
| Clear local storage | 1.5.1 |
| View replacement | 1.7.0 |

### Check 7: Look up the specific symptom

Read `reference/troubleshooting.md` and find the section that matches the user's symptom.
Apply the fix described there.

## Symptom Routing

| Symptom | Section in reference/troubleshooting.md |
|---------|----------------------------------------|
| "No such module" / build errors | Build Errors |
| "Missing package product" | Build Errors |
| SPM resolve fails | Build Errors |
| Linker errors | Build Errors |
| Actor isolation errors | Build Errors |
| "does not conform to protocol 'ObservableObject'" | Build Errors |
| Chat shows but no messages | Configuration Errors |
| Config returns nil | Configuration Errors |
| Conversation doesn't resume | Configuration Errors |
| Config broken after sandbox refresh | Configuration Errors |
| Blank/loading screen | Runtime Errors |
| Chat goes blank shortly after appearing | Runtime Errors |
| Error banner in chat | Runtime Errors |
| SDK crashes / recurring crashes | Runtime Errors |
| Notifications not received | Push Notifications |
| Wrong conversation on tap | Push Notifications |
| Foreground notifications | Push Notifications |
| Push delayed while app is active | Push Notifications |
| Delegate not called | User Verification / Pre-Chat Issues |
| JWT errors | User Verification |
| Auth mismatch / cannot send messages | User Verification |
| Access denied | Conversation IDs |
| Not syncing across devices | Conversation IDs |
| History lost after reinstall | Conversation IDs |
| Old data after switching deployment | Conversation IDs |
| Pre-chat form missing | Pre-Chat Issues |
| Form won't submit | Pre-Chat Issues |
| Delegate registered but never fires | Pre-Chat Issues |
| Bot flow doesn't trigger | Pre-Chat Issues |
| Attachment upload rejected | File Attachments |
| Business hours crash | Business Hours |
| Glassy / unexpected UI on iOS 26 | iOS 26 / Liquid Glass |
| Legacy Service SDK broken on iOS 26 | iOS 26 / Liquid Glass |
| Custom colors not applying | Customization |
| Custom icons not applying | Customization |
| Strings not overriding | Customization |
| Storage growing | Storage Issues |

## After Applying a Fix: Self-Review

Before presenting the fix to the user, review your output against this checklist.
If any check fails, fix the code before responding.

1. The fix addresses the specific symptom only -- no unrelated refactoring or
   reorganization was done?
2. Both `import SMIClientCore` and `import SMIClientUI` are still present after
   edits?
3. No type names were invented that are not in `reference/troubleshooting.md` or
   the features skill's `reference/api-surface.md`?
4. The fix matches a known pattern from the troubleshooting reference -- no
   guesswork or improvised solutions?
