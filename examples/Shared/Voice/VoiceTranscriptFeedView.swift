//
//  VoiceTranscriptFeedView.swift
//

import SwiftUI

struct VoiceTranscriptFeedView: View {
    private enum Constants {
        static let cardCornerRadius: CGFloat = 12
        static let cardPadding: CGFloat = 14
        static let crossFadeDuration: Double = 0.4
        static let innerShadowRadius: CGFloat = 8
        static let innerShadowStrokeWidth: CGFloat = 4
    }

    var entries: [VoiceTranscriptEntry]
    var agentDisplayName: String

    private var currentEntry: VoiceTranscriptEntry? { entries.last }

    var body: some View {
        ScrollView(showsIndicators: false) {
            ZStack(alignment: .topLeading) {
                if let entry = currentEntry {
                    VoiceTranscriptEntryView(entry: entry, agentDisplayName: agentDisplayName)
                        .padding(Constants.cardPadding)
                        .id(entry.identifier)
                        .transition(.asymmetric(
                            insertion: .opacity.animation(.easeIn(duration: Constants.crossFadeDuration).delay(Constants.crossFadeDuration)),
                            removal: .opacity.animation(.easeOut(duration: Constants.crossFadeDuration))
                        ))
                }
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .animation(.easeInOut(duration: Constants.crossFadeDuration), value: currentEntry?.identifier)
        .background(
            RoundedRectangle(cornerRadius: Constants.cardCornerRadius)
                .fill(VoiceColors.surface.opacity(0.6))
        )
        .clipShape(RoundedRectangle(cornerRadius: Constants.cardCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: Constants.cardCornerRadius)
                .stroke(VoiceColors.onSurface.opacity(0.15), lineWidth: Constants.innerShadowStrokeWidth)
                .blur(radius: Constants.innerShadowRadius)
                .mask(
                    LinearGradient(
                        stops: [
                            .init(color: .white, location: 0),
                            .init(color: .white.opacity(0.5), location: 0.25),
                            .init(color: .clear, location: 0.45)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: Constants.cardCornerRadius))
        )
    }
}

// MARK: - Entry View

private struct VoiceTranscriptEntryView: View {
    private enum Constants {
        static let lineSpacing: CGFloat = 8
        static let wordRevealDuration: Double = 0.08
    }

    @ObservedObject var entry: VoiceTranscriptEntry

    let agentDisplayName: String

    @State private var confirmedWords: [String] = []
    @State private var incomingWords: [String] = []
    @State private var incomingOpacity: Double = 1.0

    private var senderDisplayName: String {
        entry.isLocal ? "You" : agentDisplayName
    }

    var body: some View {
        let textColor = VoiceColors.onSurface
        var combined = Text(senderDisplayName + ": ").fontWeight(.semibold).foregroundColor(textColor)

        if !confirmedWords.isEmpty {
            // swiftlint:disable:next shorthand_operator
            combined = combined + Text(confirmedWords.joined(separator: " ")).foregroundColor(textColor)
        }

        if !incomingWords.isEmpty {
            let separator = confirmedWords.isEmpty ? "" : " "
            // swiftlint:disable:next shorthand_operator
            combined = combined + Text(separator + incomingWords.joined(separator: " "))
                .foregroundColor(textColor.opacity(incomingOpacity))
        }

        return combined
            .font(.headline)
            .lineSpacing(Constants.lineSpacing)
            .frame(maxWidth: .infinity, alignment: .leading)
            .onChange(of: entry.text) { _, text in
                revealWords(from: text)
            }
            .onAppear {
                if !entry.text.isEmpty {
                    confirmedWords = entry.text.split(separator: " ").map(String.init)
                }
            }
    }

    private func revealWords(from text: String) {
        let allWords = text.split(separator: " ").map(String.init)

        confirmedWords.append(contentsOf: incomingWords)
        incomingWords = []

        let confirmedPrefix = Array(allWords.prefix(confirmedWords.count))

        if allWords.count > confirmedWords.count && confirmedPrefix == confirmedWords {
            incomingWords = Array(allWords.suffix(from: confirmedWords.count))
            incomingOpacity = 0
            DispatchQueue.main.async {
                withAnimation(.linear(duration: Constants.wordRevealDuration)) {
                    incomingOpacity = 1.0
                }
            }
        } else {
            confirmedWords = allWords
            incomingOpacity = 1.0
        }
    }
}
