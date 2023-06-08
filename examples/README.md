# Messaging for In-App SDK: iOS Examples

We provide the following example apps to demonstrate common uses for the Messaging for In-App SDK.

- [Simple UI SDK Example](./MessagingBasicExample/): A simple messaging app that uses the UI SDK to start a messaging session with an agent. The example uses the out-of-the-box UI provided by the UI SDK.
- [Simple Core SDK Example](./MessagingCoreExample/): A simple messaging app that uses the Core SDK to start a messaging session with an agent. This example creates a basic custom UI and accesses the lower-level Core SDK.

## Customization

The [Simple UI SDK Example](./MessagingBasicExample/) provides an example of how you can customize strings and branding colors. Specifically, the chat title string and the color for error messages have been changed.

To undo these customizations, simply remove the corresponding items from the `Localizable.strings` file and the `Assets` catalog.
