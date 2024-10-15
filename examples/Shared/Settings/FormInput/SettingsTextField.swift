//
//  SettingsTextField.swift
//  SMITestApp
//
//  Created by Jeremy Wright on 2024-09-10.
//

import SwiftUI

struct SettingsTextField: View {
    let label: String
    let placeholder: String
    let enabled: Bool
    let value: Binding<String>
    let lineLimit: Int
    let copyable: Bool
    let developerOnly: Bool

    @StateObject private var developerStore: DeveloperStore = DeveloperStore()
    var shouldRender: Bool { !developerOnly || (developerOnly && developerStore.isDeveloperMode ) }

    init(_ label: String,
         developerOnly: Bool = false,
         placeholder: String = "",
         value: Binding<String>,
         enabled: Bool = true,
         lineLimit: Int = 1,
         copyable: Bool = true) {

        self.label = label
        self.developerOnly = developerOnly
        self.placeholder = placeholder
        self.value = value
        self.enabled = enabled
        self.lineLimit = lineLimit
        self.copyable = copyable
    }

    var body: some View {
        if shouldRender {
            VStack(alignment: .leading) {
                labelView
                inputView
            }
        }
    }

    private var labelView: some View {
        Text(label)
            .font(.system(.title3, design: .rounded))
            .fontWeight(.bold)
    }

    private var inputView: some View {
        HStack {
            if !enabled {
                Text(value.wrappedValue.isEmpty ? placeholder : value.wrappedValue)
                    .minimumScaleFactor(0.1)
                    .lineLimit(lineLimit)
                    .disabled(!enabled)
                    .foregroundColor(value.wrappedValue.isEmpty ? .gray : .primary)
            } else {
                TextField(placeholder, text: value)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocorrectionDisabled()
                    .autocapitalization(.none)
                    .accessibilityIdentifier("\(label).input")
                    .minimumScaleFactor(0.1)
                    .lineLimit(lineLimit)
            }

            Spacer()

            if copyable && !value.wrappedValue.isEmpty {
                SettingsButton {
                    UIPasteboard.general.string = value.wrappedValue
                } label: {
                    Image(.copyFilled)
                        .resizable()
                        .frame(width: 20, height: 20)
                }
            }
        }
    }
}

@available(iOS 17, *)
#Preview {
    @Previewable @State var editable: String = "This is editable and will shrink"
    @Previewable @State var editableWithPlaceholder: String = ""
    @Previewable @State var notEditable: String = "This is not editable. It will not be cropped even though it is a super long string"
    @Previewable @State var notEditableWithPlaceholder: String = ""

    return Form {
        SettingsTextField("Editable", value: $editable)
        SettingsTextField("Editable (Placeholder)", placeholder: "Placeholder", value: $editableWithPlaceholder)
        SettingsTextField("Not Editable", value: $notEditable, enabled: false, lineLimit: 2)
        SettingsTextField("Not Editable (Placeholder)", placeholder: "Placeholder", value: $notEditableWithPlaceholder, enabled: false, lineLimit: 2)
        SettingsTextField("Developer Only", developerOnly: true, placeholder: "Placeholder", value: $notEditableWithPlaceholder, enabled: false, lineLimit: 2)

        DeveloperStettings()
    }
}
