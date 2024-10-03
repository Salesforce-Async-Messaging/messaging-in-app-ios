//
//  SettingsStore.swift
//

import Foundation
import Combine

class SettingsStore<Keys: Settings>: ObservableObject {
    let userDefaults: UserDefaults = UserDefaults.standard

    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(userDefaultsDidChange(_:)), name: UserDefaults.didChangeNotification, object: nil)
        registerDefaults()
        handleDerivedValues()
        update()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func registerDefaults() {
        userDefaults.register(defaults: defaults())
    }

    func reset() {
        Keys.allCases.forEach { key in
            if key.resettable {
                if let enumKey = key.rawValue as? String {
                    UserDefaults.standard.set(key.defaultValue, forKey: enumKey)
                }
            }
        }

        Keys.handleReset()
    }

    func defaults() -> [String: Any] {
        var defaults: [String: Any] = [:]
        Keys.allCases.forEach {
            let key: String = $0.rawValue as? String ?? ""
            defaults[key] = $0.defaultValue
        }

        return defaults
    }

    @objc func userDefaultsDidChange(_ notification: Notification) {
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }

    func handleDerivedValues() {}
    func update() {}
}
