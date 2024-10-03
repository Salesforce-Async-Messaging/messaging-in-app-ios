//
//  KeyValuePairRow.swift
//

import SwiftUI

struct KeyValuePairRow: View {
    let pair: BasicKeyValuePair
    let keyLabel: String
    let valueLabel: String
    let header: Bool

    init(pair: BasicKeyValuePair, keyLabel: String, valueLabel: String, header: Bool = false) {
        self.pair = pair
        self.keyLabel = keyLabel
        self.valueLabel = valueLabel
        self.header = header
    }

    var body: some View {
        if header {
            Section(header: Text("Configured Pairs")) {
                content
            }
        } else {
            Section {
                content
            }
        }
    }

    var content: some View {
        VStack(alignment: .leading) {
            LabelledText(keyLabel, text: pair.key)
            Divider()
            LabelledText(valueLabel, text: pair.value)
        }
    }
}

#Preview {
    Form {
        KeyValuePairRow(pair: BasicKeyValuePair(key: "Hi", value: "How Are You"),
                        keyLabel: "This is the Key Label",
                        valueLabel: "This is the value Label",
                        header: true)

        KeyValuePairRow(pair: BasicKeyValuePair(key: "This Entry", value: "Has no header"),
                        keyLabel: "This is the Key Label",
                        valueLabel: "This is the value Label")
    }
}
