//
//  HiddenPreChatDelegateConfiguration.swift
//

import SwiftUI

struct HiddenPreChatDelegateConfiguration: View {
    @StateObject var delegateManagementStore: DelegateManagementStore = DelegateManagementStore()
    @State var key: String = ""
    @State var value: String = ""
    let instructions: String = "To add a new Hidden Pre-Chat pair to be used; fill in the values below and click \"Create New\"."
    let header: String = "Hidden Pre-Chat Input"
    let keyLabel: String = "Hidden Pre-Chat Name"
    let valueLabel: String = "Value"

    var body: some View {
        Form {
            SettingsKeyValueManager(pairs: $delegateManagementStore.hiddenPreChatValues,
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
    HiddenPreChatDelegateConfiguration()
}
