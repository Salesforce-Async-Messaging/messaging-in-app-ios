//
//  VoiceAudioRenderer.swift
//

import Foundation
import Combine
import AVFAudio
import SMIMultimediaCommon

@MainActor
final class VoiceAudioRenderer: ObservableObject, AudioProcessReceiver {
    @Published public private(set) var bars: [Float]

    private let isCentralized: Bool
    private let smoothingFactor: Float

    init(isCentralized: Bool = false, initialbarCount: Int = 3, smoothingFactor: Float = 0.3) {
        self.isCentralized = isCentralized
        self.smoothingFactor = smoothingFactor
        self.bars = [Float](repeating: 0, count: initialbarCount)
    }

    nonisolated func render(buffer: AVAudioPCMBuffer) {}
    nonisolated func receive(normalizedChannels: [Float]) {
        DispatchQueue.main.async {
            var interim = normalizedChannels

            if self.isCentralized {
                interim.sort(by: >)
                interim = Self.centralize(interim)
            }

            self.bars = zip(self.bars, interim).map { old, new in
                Self.smooth(old: old, new: new, factor: self.smoothingFactor)
            }
        }
    }

    @inline(__always) private nonisolated static func centralize(_ data: [Float]) -> [Float] {
        var centeredBands = [Float](repeating: 0, count: data.count)
        var leftIndex = data.count / 2
        var rightIndex = leftIndex

        for (index, value) in data.enumerated() {
            if index % 2 == 0 {
                centeredBands[rightIndex] = value
                rightIndex += 1
            } else {
                leftIndex -= 1
                centeredBands[leftIndex] = value
            }
        }

        return centeredBands
    }

    @inline(__always) private nonisolated static func smooth(old: Float, new: Float, factor: Float) -> Float {
        let delta = new - old
        return old + (delta * easeInOutCubic(value: factor))
    }

    /// From: https://easings.net/#easeInOutCubic
    @inline(__always) private nonisolated static func easeInOutCubic(value: Float) -> Float {
        value < 0.5 ? 4 * value * value * value : 1 - pow(-2 * value + 2, 3) / 2
    }
}
