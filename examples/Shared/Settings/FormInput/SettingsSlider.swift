//
//  SettingsSlider.swift
//  SMITestApp
//
//  Created by Jeremy Wright on 2024-09-12.
//

import SwiftUI

struct SettingsSlider: View {
    let upperBound: Double
    let lowerBound: Double
    let step: Double
    let label: String
    let developerOnly: Bool
    var binding: Binding<Double>

    init(_ label: String, developerOnly: Bool = false, value: Binding<Double>, lowerBound: Double, upperBound: Double, step: Double) {
        self.label = label
        self.developerOnly = developerOnly
        self.lowerBound = lowerBound
        self.upperBound = upperBound
        self.step = step
        self.binding = value
    }

    @State var currentValue: String = ""
    @StateObject private var developerStore: DeveloperStore = DeveloperStore()
    var shouldRender: Bool { !developerOnly || (developerOnly && developerStore.isDeveloperMode ) }

    var body: some View {
        if shouldRender {
            VStack(alignment: .leading) {
                SettingsTextField(label, value: $currentValue, enabled: false, copyable: false)
                Slider(value: binding, in: lowerBound ... upperBound, step: step).accessibility(identifier: "\(label).input")
                    .onChange(of: binding.wrappedValue) { newValue in
                        currentValue = "Current Value: \(newValue)"
                    }
            }
            .onAppear(perform: {
                currentValue = "Current Value: \(binding.wrappedValue)"
            })
        }
    }
}

struct SettingsSliderPreview: PreviewProvider {
    struct ContainerView: View {
        @State var value: Double = 50

        var body: some View {
            Form {
                SettingsSlider("Test Slider", value: $value, lowerBound: 0, upperBound: 100, step: 1)
                SettingsSlider("Only available in Developer Mode", developerOnly: true, value: $value, lowerBound: 0, upperBound: 100, step: 1)
                DeveloperStettings()
            }
        }
    }

    static var previews: some View {
        ContainerView()
    }
}
