//
//  SettingsPicker.swift
//  SMITestApp
//
//  Created by Jeremy Wright on 2024-09-10.
//

import SwiftUI

struct SettingsPicker<E>: View where E: RawRepresentable, E: Identifiable, E: Hashable, E: CaseIterable {
    let label: String
    let value: Binding<E>
    let developerOnly: Bool
    private let keys: [E]

    init(_ label: String, developerOnly: Bool = false, value: Binding<E>) {
        self.label = label
        self.value = value
        self.developerOnly = developerOnly
        self.keys = E.allCases as? [E] ?? []
    }

    @StateObject private var developerStore: DeveloperStore = DeveloperStore()
    var shouldRender: Bool { !developerOnly || (developerOnly && developerStore.isDeveloperMode ) }

    var body: some View {
        if shouldRender {
            VStack(alignment: .leading) {
                Text(label)
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.bold)

                Picker(
                    selection: value,
                    label: Text(label)
                ) {
                    ForEach(keys) {
                        Text($0.rawValue as? String ?? "").tag($0)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .accessibility(identifier: "\(label).input")
            }
        }
    }
}

@available(iOS 17, *)
#Preview {
    enum SettingsPickerTestEnum: String, CaseIterable, Identifiable {
        public var id: String { rawValue }
        case first
        case second
        case third
    }

    @Previewable @AppStorage("SettingsPickerTestKey") var settingsPickerTestKey = SettingsPickerTestEnum.second

    return Form {
        SettingsPicker<SettingsPickerTestEnum>("Test Picker", value: $settingsPickerTestKey)
        SettingsPicker<SettingsPickerTestEnum>("Developer Only", developerOnly: true, value: $settingsPickerTestKey)

        DeveloperStettings()
    }
}
