# Messaging for In-App iOS SDK: Simple UI SDK Example

A simple messaging app that uses the UI SDK to start a messaging session with an agent. To get started, download and open the app. Go to the settings and fill in a **Connection Environment** with the information from your embedded service deployment. Since this example uses the UI SDK, the basic user experience, including any pre-chat form fields, is handled by the SDK. This example includes basic implementations for user verification, hidden pre-chat, and an auto-response component (such as a survey link). To learn more about the UI SDK, see [Use the UI SDK for iOS](https://developer.salesforce.com/docs/service/messaging-in-app/guide/ios-ui-sdk.html).

## Customization

This app provides an example of how you can customize strings and branding colors. Specifically, the chat title string and the color for error messages have been changed.

To undo these customizations, simply remove the corresponding items from the `Localizable.strings` file and the `Assets` catalog.
