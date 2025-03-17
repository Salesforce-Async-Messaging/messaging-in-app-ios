//
//  Instructions.swift
//  MessagingUIExample
//
//  Created by Jeremy Wright on 2025-03-13.
//

import SwiftUI

struct Instructions: View {
    static private let title: String = "Info"
    static private let topHeader: String = "Instructions"
    static private let bottomHeader: String = "Note"

    var instructions: String
    var note: String?
    var section: Bool = true

    var body: some View {
        if section {
            SettingsSection(Self.title) {
                LabelledText(Self.topHeader, text: instructions, lineLimit: 5)
                if let note = note {
                    LabelledText(Self.bottomHeader, text: note, lineLimit: 5)
                }
            }
        } else {
            LabelledText(Self.topHeader, text: instructions, lineLimit: 5)
            if let note = note {
                LabelledText(Self.bottomHeader, text: note, lineLimit: 5)
            }
        }
    }
}

#Preview {
    Instructions(instructions: "These are a set of instructions.", note: "Some additional info.")
}
