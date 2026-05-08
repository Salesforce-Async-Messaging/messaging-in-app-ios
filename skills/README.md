# Salesforce Messaging for In-App iOS -- AI Skills

This folder contains **AI Skills** that give coding assistants deep knowledge of the
Salesforce Messaging for In-App iOS SDK. When installed in a project, the AI can guide
initial integration, implement any documented feature, customize the UI, and troubleshoot
issues -- using real API signatures and working example code from the public example app.

## Installation

### Cursor

Copy the `skills/` folder into your project's `.cursor/skills/` directory and the
auto-rule into `.cursor/rules/`:
```bash
cp -r skills/ /path/to/YourApp/.cursor/skills/salesforce-messaging-ios/
cp skills/rules/salesforce-messaging-sdk.md /path/to/YourApp/.cursor/rules/
```

### Claude Code

Copy the `skills/` folder into your project's `.claude/skills/` directory:
```bash
cp -r skills/ /path/to/YourApp/.claude/skills/salesforce-messaging-ios/
```

### Other AI tools

Copy the `skills/` folder into wherever your tool discovers skill or instruction
files. The `SKILL.md` files use standard frontmatter (`name` and `description`)
for discovery. If your tool uses an always-on rules file, append the contents of
`rules/salesforce-messaging-sdk.md` to it.

## Structure

```
skills/
  setup/
    SKILL.md                        -- Initial SDK integration workflow
  features/
    SKILL.md                        -- Feature/customization router
    reference/
      api-surface.md                -- All public types and protocols
      features.md                   -- Feature implementation recipes
      customization.md              -- UI customization recipes
  troubleshooting/
    SKILL.md                        -- Issue triage decision tree
    reference/
      troubleshooting.md            -- Symptom-based fixes
  rules/
    salesforce-messaging-sdk.md     -- Optional auto-rule for code generation
  README.md                         -- This file
```

### Three skills, split by user intent

| Skill | When it activates | What it does |
|-------|-------------------|-------------|
| **setup** | "Add the SDK", "integrate messaging", "set up in-app chat" | Guides initial integration step by step |
| **features** | "Add push notifications", "customize colors", "replace views" | Routes to the right recipe, enforces example-first code gen |
| **troubleshooting** | "It's not working", "build error", "blank screen" | Triage checklist, then symptom-specific fixes |

## How It Works

The skills are designed around one principle: **the AI follows proven examples, not its
own training data.** Every feature recipe starts with "fetch this example file from
GitHub" and the AI must read the real, tested code before generating anything.

The example app is in the public repo:
`https://github.com/Salesforce-Async-Messaging/messaging-in-app-ios`

When the example app is updated, the AI automatically gets the latest code on the
next fetch. The skills themselves rarely need updating.

### What the AI can help with

**Setup:**
- "Add Salesforce messaging to my app"
- "Set up the In-App SDK with SwiftUI"
- "Show me how to present the chat modally in UIKit"
- "Add the SDK via Swift Package Manager"

**Features:**
- "Set up push notifications for messaging"
- "Implement user verification with JWT"
- "Pre-fill the pre-chat form with the user's name and email"
- "Send hidden pre-chat fields to Salesforce"
- "Hide the chat button outside business hours"
- "Let users download a conversation transcript"
- "Close a conversation programmatically"

**Customization:**
- "Change the chat header color to match our brand"
- "Override the chat feed title string"
- "Replace the send button icon"
- "Replace the typing indicator with a custom animation"
- "Customize the navigation bar for the pre-chat screen"

**Troubleshooting:**
- "The chat view isn't showing up"
- "Push notifications aren't working"
- "My pre-chat delegate isn't being called"
- "I'm getting a build error after adding the SDK"
- "The conversation starts a new chat every time instead of resuming"

### What the AI cannot do

- Set up a Salesforce org or embedded service deployment
- Create APNs certificates or push notification keys
- Debug Salesforce-side configuration (routing, bot flows, agent availability)
- Generate the `config.json` file (download it from the Salesforce org)

## Resources

- [Developer Guide](https://developer.salesforce.com/docs/service/messaging-in-app/overview)
- [iOS Reference Documentation](https://salesforce-async-messaging.github.io/messaging-in-app-ios/)
- [Salesforce Org Setup](https://help.salesforce.com/s/articleView?id=sf.miaw_setup_stages.htm)
- [Release Notes](https://github.com/Salesforce-Async-Messaging/messaging-in-app-ios/releases)
- [Example Apps](https://github.com/Salesforce-Async-Messaging/messaging-in-app-ios/tree/master/examples)
