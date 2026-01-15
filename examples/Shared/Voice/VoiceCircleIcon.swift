//
//  VoiceCircleIcon.swift
//

import SwiftUI

struct VoiceCircleIcon: View {
    enum Style {
        case filled
        case outlined(lineWidth: CGFloat = 1.5)
    }

    var image: Image?
    var backgroundColor: Color
    var foregroundColor: Color
    var size: CGFloat = 24
    var style: Style = .filled
    var iconPadding: CGFloat = 4

    var body: some View {
        ZStack {
            switch style {
            case .filled:
                Circle().fill(backgroundColor)
            case .outlined(let lineWidth):
                Circle().stroke(backgroundColor, lineWidth: lineWidth)
            }
            image?
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .foregroundColor(foregroundColor)
                .padding(iconPadding)
        }
        .frame(width: size, height: size)
    }
}
