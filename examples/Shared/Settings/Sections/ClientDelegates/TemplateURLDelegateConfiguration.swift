//
//  TemplateURLDelegateConfiguration.swift
//

import SwiftUI

struct TemplateURLDelegateConfiguration: View {
    @StateObject var delegateManagementStore: DelegateManagementStore = DelegateManagementStore()
    @State var key: String = ""
    @State var value: String = ""

    private let instructions: String = "To add a new template pair to be used in the TemplatedURL delegate; fill in the values below and click \"Create New\"."
    private let header: String = "Templated URL Input"
    private let keyLabel: String = "Templated Parameter Key"
    private let valueLabel: String = "Replacement Value"

    var body: some View {
        Form {
            SettingsKeyValueManager(pairs: $delegateManagementStore.templatedURLValues,
                                    instructions: instructions,
                                    header: header,
                                    keyLabel: keyLabel,
                                    valueLabel: valueLabel) { key, value in

                BasicKeyValuePair(key: key, value: value)
            } row: { index, pair in

                KeyValuePairRow(pair: pair, keyLabel: keyLabel, valueLabel: valueLabel, header: index == 0)
            }
        }
    }
}

#Preview {
    TemplateURLDelegateConfiguration()
}
