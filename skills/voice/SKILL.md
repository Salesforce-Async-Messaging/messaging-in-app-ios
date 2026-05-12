---
name: salesforce-messaging-voice
description: >-
  Add voice calling to a Salesforce Messaging for In-App iOS SDK integration.
  Use when the user mentions voice, voice call, voice modality, phone call,
  audio call, multimedia, add a call button, or voice in the navigation bar.
---

# Salesforce Messaging for In-App iOS SDK -- Voice

You add voice calling to an existing Messaging for In-App integration. This skill
uses a **fetch-and-copy** pattern: you fetch tested, working voice UI files from the
public example app and write them into the customer's project. You do NOT regenerate
these files -- you copy them exactly as fetched.

## Code Generation Rules

These rules are mandatory for ALL code you generate or copy.

1. **Fetch before writing.** Fetch every file listed in the file table below from the
   public GitHub example app. Write each file exactly as fetched -- do NOT modify the
   contents. The only file you generate yourself is the `NavigationBarBuilder` subclass.

2. **Minimal changes to existing code.** All voice files go into their own `Voice/`
   folder in the customer's project. The only changes to the customer's existing code
   are wiring the builder into their `Interface` call and setting the `ConversationClient`.

3. **Never invent type names.** Verify against the fetched files or
   `reference/api-surface.md` in the features skill.

4. **Imports.** Voice files use three SDK modules:
   ```swift
   import SMIClientCore
   import SMIClientUI
   import SMIMultimediaCommon
   ```
   `SMIMultimediaCommon` (protocols/types) is bundled with `Swift-InAppMessaging`.
   `SMIMultimediaCore` (voice implementation) is a SEPARATE package -- see Prerequisites.

5. **Line length limit.** Keep all lines under 160 characters. Break long lines.

6. **Handle actor isolation.** If the project uses `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`
   (Xcode 26 default):
   - Mark `NavigationBarBuilder.init()` as `nonisolated`.

## Prerequisites

Confirm the user has all of these before writing any code:

- **Existing messaging integration.** The SDK must already be added and the chat UI
  must be working. If not, use the setup skill first.
- **Voice plugin dependency.** The `SMIMultimediaCore` SPM package must be added to the
  project. This is a SEPARATE package from `Swift-InAppMessaging` -- voice will not work
  without it. The repository URL is:
  `https://github.com/Salesforce-Async-Messaging/SMIMultimediaCore-iOS.swift`
  The product to link is `SMIMultimediaCore`. The version MUST match the SDK version
  (e.g. if `Swift-InAppMessaging` is 1.11.1, use `SMIMultimediaCore` 1.11.1).
  Without this package, `CoreFactory.isMultimediaAvailable` returns `false` and the
  voice modality will not function.
  **This is a manual step the user must do in Xcode** (File > Add Package Dependencies).
  You cannot add SPM packages programmatically. Ask the user to confirm they have added
  it before proceeding. If unsure, check the project's `Package.resolved` or
  `project.pbxproj` for `SMIMultimediaCore`.
- **Voice enabled in Salesforce.** The embedded service deployment must have voice
  enabled. If voice is not enabled, the voice button will never activate.
- **Microphone permission.** `NSMicrophoneUsageDescription` must be set in `Info.plist`.
  If missing, the app will crash when joining a voice session.

## Step 1: Fetch and Copy Voice Files

Fetch ALL 10 files listed below from the public GitHub example app. The base URL is:
`https://raw.githubusercontent.com/Salesforce-Async-Messaging/messaging-in-app-ios/master/examples/Shared/Voice/`

| File | URL suffix | Purpose |
|------|-----------|---------|
| `VoiceModalityObserver.swift` | `VoiceModalityObserver.swift` | Detects voice support via `ConversationClientDelegate` |
| `VoiceNavBarButtonHandler.swift` | `VoiceNavBarButtonHandler.swift` | Manages nav bar voice button and sheet presentation |
| `VoiceControlPanel.swift` | `VoiceControlPanel.swift` | Voice call UI: mute, end call, timer, live transcript |
| `VoiceAudioRenderer.swift` | `VoiceAudioRenderer.swift` | Processes audio buffer data for visualization |
| `VoiceAudioVisualizer.swift` | `VoiceAudioVisualizer.swift` | Animated audio level bars |
| `VoiceTranscriptProvider.swift` | `VoiceTranscriptProvider.swift` | Listens for streaming tokens and final messages |
| `VoiceTranscriptEntry.swift` | `VoiceTranscriptEntry.swift` | Model for a single transcript line |
| `VoiceTranscriptFeedView.swift` | `VoiceTranscriptFeedView.swift` | Renders the live transcript feed |
| `VoiceCircleIcon.swift` | `VoiceCircleIcon.swift` | Reusable circular button component |
| `VoiceColors.swift` | `VoiceColors.swift` | Self-contained voice UI color palette |

Do NOT fetch `VoiceSettings.swift` -- it depends on example-app-specific types
(`SettingsStore`, `SettingsSection`, `SettingsToggle`) that do not exist in the
customer's project.

Write all 10 files into a new `Voice/` folder in the customer's project.
Do NOT modify the file contents -- write them exactly as fetched.

## Step 2: Fetch and Add Image Assets

Fetch 3 SVG image assets and their `Contents.json` files. The base URL is:
`https://raw.githubusercontent.com/Salesforce-Async-Messaging/messaging-in-app-ios/master/examples/MessagingUIExample/Assets.xcassets/`

| Asset folder | Files to fetch |
|-------------|---------------|
| `actionEndVoice.imageset/` | `Contents.json`, `actionEndVoice.svg` |
| `actionMute.imageset/` | `Contents.json`, `actionMute.svg` |
| `actionUnmute.imageset/` | `Contents.json`, `actionUnmute.svg` |

Write each imageset folder into the customer's `Assets.xcassets/` directory.

If the fetch fails for SVG files, tell the customer to download them manually from:
`https://github.com/Salesforce-Async-Messaging/messaging-in-app-ios/tree/master/examples/MessagingUIExample/Assets.xcassets`

## Step 3: Create the NavigationBarBuilder

This is the ONE file you generate (not copy). Create it in the `Voice/` folder.

BEFORE generating this file, fetch the example that demonstrates the pattern:
`https://raw.githubusercontent.com/Salesforce-Async-Messaging/messaging-in-app-ios/master/examples/Shared/Delegates/Providers/TestNavBarBuilder.swift`

Study how `TestNavBarBuilder` uses `VoiceNavBarButtonHandler`:
- It creates a `voiceHandler` property
- It forwards the `ConversationClient` via a `client` property
- In the `handleNavigation` closure, it calls `voiceHandler.addButton(to: navigationItem)`
  when the screen is `.chatFeed`

Generate this file in the customer's `Voice/` folder:

```swift
import SMIClientCore
import SMIClientUI

class VoiceNavigationBarBuilder: NavigationBarBuilder {
    private let voiceHandler = VoiceNavBarButtonHandler()

    var client: ConversationClient? {
        didSet { voiceHandler.client = client }
    }

    override init() {
        super.init()
        self.handleNavigation = { [weak self] screenType, navigationItem in
            if screenType == .chatFeed {
                self?.voiceHandler.addButton(to: navigationItem)
            }
        }
    }
}
```

If the project uses `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` (Xcode 26), mark
`init()` as `nonisolated`.

**If the customer already has a `NavigationBarBuilder`:** Do NOT create a new one.
Instead, add the voice handler to their existing builder:
1. Add `private let voiceHandler = VoiceNavBarButtonHandler()` as a property.
2. Add a `client` property that forwards to `voiceHandler.client`.
3. In their existing `handleNavigation` closure, add:
   ```swift
   if screenType == .chatFeed {
       voiceHandler.addButton(to: navigationItem)
   }
   ```

## Step 4: Wire It Up

Make exactly TWO edits to the customer's existing chat view:

1. **Add a property** for the builder (skip if they already have a `NavigationBarBuilder`):
   ```swift
   private let voiceNavBuilder = VoiceNavigationBarBuilder()
   ```

2. **Pass it to Interface** and set the `ConversationClient`.

   **IMPORTANT:** Use the SAME `UIConfiguration` object for both `Interface` and
   `CoreFactory.create`. This ensures the factory returns the same `CoreClient`
   instance the `Interface` uses internally -- the one with the multimedia extension.

   The customer's code may already have a `UIConfiguration` stored in a variable with
   a different name (e.g. `config`, `uiConfig`, `chatConfig`). Search for where
   `UIConfiguration(` is created and reuse that existing variable -- do NOT create a
   second one.

   **SwiftUI:**
   ```swift
   let uiConfig = UIConfiguration(
       configuration: config,
       conversationId: conversationId
   )
   Interface(uiConfig, navigationBarBuilder: voiceNavBuilder)
       .onAppear {
           let client = CoreFactory.create(withConfig: uiConfig)
               .conversationClient(with: conversationId)
           voiceNavBuilder.client = client
       }
   ```

   **UIKit (push):**
   ```swift
   let viewController = InterfaceViewController(uiConfig, navigationBarBuilder: voiceNavBuilder)
   let client = CoreFactory.create(withConfig: uiConfig)
       .conversationClient(with: conversationId)
   voiceNavBuilder.client = client
   navigationController?.pushViewController(viewController, animated: true)
   ```

   **UIKit (modal):**
   ```swift
   let viewController = ModalInterfaceViewController(uiConfig, navigationBarBuilder: voiceNavBuilder)
   let client = CoreFactory.create(withConfig: uiConfig)
       .conversationClient(with: conversationId)
   voiceNavBuilder.client = client
   present(viewController, animated: true)
   ```

## Step 5: Verify Info.plist

Check that `NSMicrophoneUsageDescription` exists in the customer's `Info.plist`.
If missing, add it:
```xml
<key>NSMicrophoneUsageDescription</key>
<string>Microphone access is needed for voice calls with support agents.</string>
```

## Step 6: Tell the Customer What Was Added

After completing all steps, tell the customer:

- A `Voice/` folder was added with 10 source files and a `VoiceNavigationBarBuilder`.
- Three image assets (`actionEndVoice`, `actionMute`, `actionUnmute`) were added to
  `Assets.xcassets`.
- A voice button appears in the chat navigation bar when the Salesforce deployment
  supports voice. The button auto-enables when voice becomes available and auto-disables
  when it is not.
- Tapping the button switches the conversation modality to voice and presents a voice
  control panel with mute, end call, an elapsed time timer, and a live transcript.
- They can customize the button placement by modifying `VoiceNavigationBarBuilder` or
  moving the `voiceHandler.addButton(to:)` call to a different trigger.
- They can customize the voice UI colors by editing `VoiceColors.swift`.

## Self-Review

Before presenting the result to the user, check:

1. The `SMIMultimediaCore` package is listed as a dependency in the project?
2. All 10 voice files were written to the `Voice/` folder exactly as fetched?
3. The 3 image assets were written to `Assets.xcassets/`?
4. The `VoiceNavigationBarBuilder` follows the pattern from `TestNavBarBuilder.swift`?
5. Only TWO edits were made to the customer's existing code (property + Interface wiring)?
6. The SAME `UIConfiguration` object is passed to both `Interface` and `CoreFactory.create`?
7. `NSMicrophoneUsageDescription` is in `Info.plist`?
8. If the project uses `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`: `init()` is `nonisolated`?
9. No fetched voice files were modified?

If any check fails, fix it before responding.

## Common Mistakes

- **Voice button appears but nothing happens when tapped.** The `SMIMultimediaCore` SPM
  package is not linked. Without it, `multimediaClient` is `nil` and `changeModalities`
  silently fails. Add `https://github.com/Salesforce-Async-Messaging/SMIMultimediaCore-iOS.swift`
  as a package dependency with version matching the SDK version.
- **Voice button never enables.** Voice is not enabled in the Salesforce org deployment.
  The button relies on `didUpdateSupportedModalities` -- if the deployment does not
  support voice, the delegate never fires with `.voice`.
- **App crashes when joining voice.** `NSMicrophoneUsageDescription` is missing from
  `Info.plist`.
- **Import errors on `SMIMultimediaCommon`.** This module is bundled with the
  `Swift-InAppMessaging` SPM package. If it cannot be found, the customer may need to
  clean the build folder (Cmd+Shift+K) and rebuild.
