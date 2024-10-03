//
//  CommonText.swift
//

import SwiftUI

struct LabelledText: View {
    let label: String
    let lineLimit: Int
    let text: String

    init(_ label: String, text: String, lineLimit: Int = 1) {
        self.label = label
        self.text = text
        self.lineLimit = lineLimit
    }

    private var labelView: some View {
        HStack {
            Text(label)
                .font(.system(.title3, design: .rounded))
                .fontWeight(.bold)
        }
    }

    var body: some View {
        VStack(alignment: .leading) {
            labelView
            Text(text)
                .minimumScaleFactor(0.1)
                .lineLimit(lineLimit)
                .foregroundColor(text.isEmpty ? .gray : .primary)
        }    }
}

#Preview {
    Form {
        LabelledText("Labelled Text", text: "Hello World", lineLimit: 5)
    }
}
