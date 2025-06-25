//
//  NavigationTitleReplacementStore.swift
//  SMITestApp
//
//  Created by Nigel Brown on 2025-06-24.
//

import Foundation
import Combine
import SwiftUI

class NavigationTitleReplacementManager: ObservableObject {
    @Published var title: String?
    private var timerSubscription: AnyCancellable?
    var navigationTitleReplacementStore: NavigationTitleReplacementStore = NavigationTitleReplacementStore()

    init() {
        if navigationTitleReplacementStore.titleReplacementEnabled {
            startTimer()
        } else {
            stopTimer()
        }
    }

    deinit {
        stopTimer()
    }

    func startTimer() {
        // Create a timer that fires every 5 seconds
        timerSubscription = Timer.publish(every: 5, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                // Update the title with current time
                let dateFormatter = DateFormatter()
                dateFormatter.timeStyle = .medium
                self?.title = "Updated at: \(dateFormatter.string(from: Date()))"
            }
    }

    func stopTimer() {
        timerSubscription?.cancel()
        timerSubscription = nil
        title = nil
    }
}

extension NavigationTitleReplacementStore {
    private static let manager = NavigationTitleReplacementManager()

    var titleReplacementEnabled: Bool {
        get { userDefaults.bool(forKey: Keys.titleReplacementEnabled.rawValue) }
        set {
            userDefaults.set(newValue, forKey: Keys.titleReplacementEnabled.rawValue)
        }
    }

    var title: String? {
        get { NavigationTitleReplacementStore.manager.title }
        set { NavigationTitleReplacementStore.manager.title = newValue }
    }

    func startTimer() {
        NavigationTitleReplacementStore.manager.startTimer()
    }

    func stopTimer() {
        NavigationTitleReplacementStore.manager.stopTimer()
    }
}
