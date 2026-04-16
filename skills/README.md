# Salesforce Messaging for In-App iOS -- AI Skills

This folder contains **AI Skills** that give coding assistants deep knowledge of the
Salesforce Messaging for In-App iOS SDK. When installed in a project, the AI can guide
initial integration, implement any documented feature, customize the UI, and troubleshoot
issues -- using real API signatures and working example code from the public example app.

## Installation

Copy the `ios-sdk-integration-skill` folder to wherever your AI tool discovers skill or
instruction files. The `SKILL.md` files use standard frontmatter (`name` and `description`)
for discovery by any tool that supports it.

### Cursor

Skills (agent-invoked, on-demand guidance):
```bash
cp -r ios-sdk-integration-skill/ /path/to/YourApp/.cursor/skills/ios-sdk-integration-skill/
```

Auto-rule (applied to all Swift files that import the SDK):
```bash
cp ios-sdk-integration-skill/rules/salesforce-messaging-sdk.md /path/to/YourApp/.cursor/rules/
```

### Claude Code

Claude Code loads `.claude/rules/` files as project instructions automatically. Copy the
skill files there so they are available as context for every conversation:

```bash
mkdir -p /path/to/YourApp/.claude/rules/ios-sdk-integration-skill
cp -r ios-sdk-integration-skill/ /path/to/YourApp/.claude/rules/ios-sdk-integration-skill/
```

The auto-rule can also be added directly to `CLAUDE.md`:
```bash
cat ios-sdk-integration-skill/rules/salesforce-messaging-sdk.md >> /path/to/YourApp/CLAUDE.md
```

Note: Claude Code ignores the `globs` frontmatter key — the rules file content applies to
all conversations in the project. The `name`/`description` frontmatter in `SKILL.md` files
is treated as plain text; Claude will still follow the instructions.

### Windsurf

Windsurf loads rules from `.windsurf/rules/`. Copy the auto-rule there:
```bash
cp ios-sdk-integration-skill/rules/salesforce-messaging-sdk.md /path/to/YourApp/.windsurf/rules/salesforce-messaging-sdk.md
```

For the full skill content:
```bash
cp -r ios-sdk-integration-skill/ /path/to/YourApp/.windsurf/rules/ios-sdk-integration-skill/
```

Note: Windsurf uses different frontmatter keys (`trigger`, `file_patterns`) rather than
`globs`. The `globs` key in the rules file will be ignored — Windsurf will apply the rule
to all files. See `rules/salesforce-messaging-sdk.md` for the Windsurf-compatible
frontmatter to use instead.

### GitHub Copilot

GitHub Copilot does not have a native skills concept. Append the auto-rule to your
repository's custom instructions file:
```bash
cat ios-sdk-integration-skill/rules/salesforce-messaging-sdk.md >> /path/to/YourApp/.github/copilot-instructions.md
```

### Other AI tools

Copy the folder to wherever the tool discovers skill or instruction files. The `SKILL.md`
files use standard frontmatter (`name` and `description`) for discovery. If the tool uses
an always-on rules file, use `rules/salesforce-messaging-sdk.md` as the starting point.

## Structure

```
ios-sdk-integration-skill/
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
