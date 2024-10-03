//
//  MessagingUIExampleApp.swift
//

import SwiftUI

@main
struct MessagingUIExampleApp: App {
    @StateObject var uiOverrideStore: UIOverrideStore = UIOverrideStore()
    @StateObject var loggingStore: LoggingStore = LoggingStore()

    var body: some Scene {
        WindowGroup {
            ContentView().onAppear(perform: {
                uiOverrideStore.updateUserInterfaceStyle()
                loggingStore.updateLoggingSettings()
            })
        }
    }
}
