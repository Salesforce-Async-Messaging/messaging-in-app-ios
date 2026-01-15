//
//  VoiceColors.swift
//

import SwiftUI

/// Self-contained color palette for the Voice UI.
/// Values match the default SMI branding tokens and support light/dark mode.
enum VoiceColors {

    // MARK: - Surface (backgrounds, button fills, visualizer bars)

    static let surface = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0x1A / 255.0, green: 0x1B / 255.0, blue: 0x1E / 255.0, alpha: 1)
            : .white
    })

    // MARK: - On Surface (primary text, button borders/icons, visualizer background)

    static let onSurface = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0xC9 / 255.0, green: 0xC7 / 255.0, blue: 0xC5 / 255.0, alpha: 1)
            : UIColor(red: 0x2B / 255.0, green: 0x28 / 255.0, blue: 0x26 / 255.0, alpha: 1)
    })

    // MARK: - On Background (secondary text, local visualizer background)

    static let onBackground = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0xB0 / 255.0, green: 0xAD / 255.0, blue: 0xAB / 255.0, alpha: 1)
            : UIColor(red: 0x70 / 255.0, green: 0x6E / 255.0, blue: 0x6B / 255.0, alpha: 1)
    })
}
