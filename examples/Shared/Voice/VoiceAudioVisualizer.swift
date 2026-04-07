//
//  VoiceAudioVisualizer.swift
//

import SwiftUI
import SMIMultimediaCommon
import SMIClientUI

struct VoiceAudioVisualizer: View {
    private let width: CGFloat
    private let height: CGFloat
    private let origin: MultimediaParticipantOrigin
    weak var audioTrack: AudioTrackProtocol?

    @StateObject private var renderEngine: VoiceAudioRenderer
    @State private var animationPhase: Int = 0
    @State private var animationTask: Task<Void, Never>?

    private enum Constants {
        static let fractionalMaxBarHeight = 0.75
        static let fractionalMinBarHeight = 0.2
        static let fractionalBarWidthRange = 0.1
        static let fractionalBarWidth = 0.1
        static let defaultSize: CGFloat = 125
        static let animationDuration: TimeInterval = 500
        static let normalizedChannelCount: Int = 3
        static let localSmoothingFactor: Double = 0.1
        static let remoteSmoothingFactor: Double = 1
    }

    init(_ origin: MultimediaParticipantOrigin,
         audioTrack: (any AudioTrackProtocol)?,
         width: CGFloat = Constants.defaultSize,
         height: CGFloat = Constants.defaultSize) {
        let smoothingFactor = origin == .local ? Constants.localSmoothingFactor : Constants.remoteSmoothingFactor
        let renderEngine = VoiceAudioRenderer(isCentralized: true, smoothingFactor: Float(smoothingFactor))

        _renderEngine = StateObject(wrappedValue: renderEngine)

        self.width = width
        self.height = height
        self.audioTrack = audioTrack
        self.origin = origin
    }

    var body: some View {
        bars()
            .onAppear {
                audioTrack?.add(processReceiver: renderEngine)
                audioTrack?.start(emitBuffer: false, normalizedChannelCount: Constants.normalizedChannelCount)
                startAnimation(duration: Constants.animationDuration)
            }
            .onDisappear {
                audioTrack?.remove(processReceiver: renderEngine)
                stopAnimation()
            }
    }

    @ViewBuilder
    private func bars() -> some View {
        let barWidth = self.width * Constants.fractionalBarWidth
        let barMinHeight = self.height * Constants.fractionalMinBarHeight

        HStack(spacing: barWidth) {
            ForEach(0 ..< renderEngine.bars.count, id: \.self) { index in
                RoundedRectangle(cornerRadius: barMinHeight)
                    .fill(Color.smiBranded(.surface))
                    .opacity(1)
                    .frame(
                        width: barWidth,
                        height: (height - barMinHeight) * CGFloat(renderEngine.bars[index]) + barMinHeight
                    )
            }.frame(width: barWidth)
        }
        .frame(width: self.width, height: self.height)
        .background(origin == .remote
                     ? Color.smiBranded(.onSurface)
                     : Color.smiBranded(.onBackground))
        .clipShape(Circle())
    }

    private func startAnimation(duration: TimeInterval) {
        animationTask?.cancel()
        animationPhase = 0
        animationTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: UInt64(duration * Double(NSEC_PER_SEC)))
                animationPhase += 1
            }
        }
    }

    private func stopAnimation() {
        animationTask?.cancel()
    }
}
