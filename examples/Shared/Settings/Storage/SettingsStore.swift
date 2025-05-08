//
//  SettingsStore.swift
//

import Foundation
import Combine

class SettingsStore<Keys: Settings>: ObservableObject {
    let userDefaults: UserDefaults = UserDefaults.standard
    let version: UInt = 6
    let versionKey: String = "version"

    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(userDefaultsDidChange(_:)), name: UserDefaults.didChangeNotification, object: nil)
        checkVersion()
        registerDefaults()
        handleDerivedValues()
        update()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // Just checks the hardcoded version number against what is stored in the settings
    func checkVersion() {
        let result = userDefaults.integer(forKey: versionKey)
        if result != version {
            let domain = Bundle.main.bundleIdentifier!
            UserDefaults.standard.removePersistentDomain(forName: domain)
            UserDefaults.standard.synchronize()
        }
    }

    func registerDefaults() {
        userDefaults.register(defaults: defaults())
        userDefaults.set(version, forKey: versionKey)
    }

    func reset() {
        Keys.allCases.forEach { key in
            if key.resettable {
                if let enumKey = key.rawValue as? String {
                    userDefaults.set(key.defaultValue, forKey: enumKey)
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
