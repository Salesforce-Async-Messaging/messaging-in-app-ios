//
//  SettingsKeyValueManager.swift
//  SMITestApp
//
//  Created by Jeremy Wright on 2024-09-25.
//

import SwiftUI

struct SettingsKeyValueManager<PairType: KeyValuePair, Row: View>: View {
    let pairs: Binding<[PairType]>
    @State var key: String = ""
    @State var value: String = ""
    @State var canCreate: Bool = false

    let instructions: String
    let header: String
    let keyLabel: String
    let valueLabel: String
    let add: (_ key: String, _ value: String) -> PairType
    var row: (_ index: [PairType].Index, _ element: [PairType].Element) -> Row

    var isValid: Bool {
        if value.isEmpty || key.isEmpty { return false }
        if pairs.wrappedValue.contains(where: { $0.key == key }) { return false }
        return true
    }

    init(pairs: Binding<[PairType]>,
         instructions: String,
         header: String,
         keyLabel: String,
         valueLabel: String,
         add: @escaping (_ key: String, _ value: String) -> PairType,
         @ViewBuilder row: @escaping (_ index: [PairType].Index, _ element: [PairType].Element) -> Row) {

        self.pairs = pairs
        self.instructions = instructions
        self.header = header
        self.keyLabel = keyLabel
        self.valueLabel = valueLabel
        self.add = add
        self.row = row
    }

    var body: some View {
        Group {
            Instructions(instructions: instructions, note: "You cannot have duplicate entries with the same \"\(keyLabel)\"")

            SettingsSection(header) {
                SettingsTextField(keyLabel, placeholder: "Enter Key", value: $key)
                    .onChange(of: key) {
                        canCreate = isValid
                    }

                SettingsTextField(valueLabel, placeholder: "Enter Value", value: $value)
                    .onChange(of: value) {
                        canCreate = isValid
                    }

                SettingsButton {
                    pairs.wrappedValue.append(add(key, value))
                    key = ""
                    value = ""

                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                } label: {
                    Text("Create New")
                }
                .disabled(!canCreate)

                if !pairs.wrappedValue.isEmpty {
                    SettingsButton {
                        pairs.wrappedValue.removeAll()
                        canCreate = isValid
                    } label: {
                        Text("Delete All")
                    }
                }
            }

            if !pairs.wrappedValue.isEmpty {
                ForEach(Array(pairs.wrappedValue.enumerated()), id: \.offset) { index, pair in
                    row(index, pair)
                }
                .onDelete(perform: { indexSet in
                    pairs.wrappedValue.remove(atOffsets: indexSet)
                    canCreate = isValid
                })
            }
        }
    }
}

struct SettingsKeyValueManagerPreview: PreviewProvider {
    struct ContainerView: View {
        @State var pairs: [BasicKeyValuePair] = []
        let instructions = "This is a preview of a form to manage key value pair settings"
        let header = "This is the header that shows on the list"
        let keyLabel = "This is the key of the pair"
        let valueLabel = "This is the value of the pair"

        var body: some View {
            SettingsKeyValueManager(pairs: $pairs, instructions: instructions, header: header, keyLabel: keyLabel, valueLabel: valueLabel) { key, value in
                BasicKeyValuePair(key: key, value: value)
            } row: { index, element in
                KeyValuePairRow(pair: element, keyLabel: keyLabel, valueLabel: valueLabel, header: index == 0)
            }
        }
    }

    static var previews: some View {
        Form {
            ContainerView()
        }
    }
}
