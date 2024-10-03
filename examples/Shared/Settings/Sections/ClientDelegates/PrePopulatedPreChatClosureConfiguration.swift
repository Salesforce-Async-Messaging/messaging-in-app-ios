//
//  PrePopulatedPreChatClosureConfiguration.swift
//

import SwiftUI

struct PrePopulatedPreChatClosureConfiguration: View {
    @StateObject var delegateManagementStore: DelegateManagementStore = DelegateManagementStore()
    @State var key: String = ""
    @State var value: String = ""

    let instructions: String = "To add a new Pre Populated Pre-Chat pair to be used; fill in the values below and click \"Create New\"."
    let header: String = "Pre Populated Pre-Chat Input"
    let keyLabel: String = "Pre Populated Pre-Chat Name"
    let valueLabel: String = "Value"

    var body: some View {
        Form {
            SettingsKeyValueManager(pairs: $delegateManagementStore.prePopPreChatValues,
                                    instructions: instructions,
                                    header: header,
                                    keyLabel: keyLabel,
                                    valueLabel: valueLabel) { key, value in

                PrePopulatedPreChatKeyValuePair(key: key, value: value)
            } row: { index, pair in

                PrePopulatedPreChatClosureConfigurationRow(pair: pair, keyLabel: keyLabel, valueLabel: valueLabel, header: index == 0)
            }
        }
    }
}

private struct PrePopulatedPreChatClosureConfigurationRow: View {
    @StateObject var delegateManagementStore: DelegateManagementStore = DelegateManagementStore()
    @State var toggle: Bool = true

    var pair: PrePopulatedPreChatKeyValuePair
    let keyLabel: String
    let valueLabel: String
    let header: Bool

    init(pair: PrePopulatedPreChatKeyValuePair, keyLabel: String, valueLabel: String, header: Bool = false) {
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
            Divider()
            SettingsToggle("Editable", isOn: $toggle)
                .onChange(of: toggle) { newValue in
                    let newPair = PrePopulatedPreChatKeyValuePair(key: pair.key, value: pair.value, isEditable: newValue)
                    if let index = delegateManagementStore.prePopPreChatValues.firstIndex(where: { $0.key == pair.key }) {
                        delegateManagementStore.prePopPreChatValues[index] = newPair
                    }
                }
        }
        .onAppear(perform: {
            toggle = pair.isEditable
        })
    }
}

#Preview {
    PrePopulatedPreChatClosureConfiguration()
}
