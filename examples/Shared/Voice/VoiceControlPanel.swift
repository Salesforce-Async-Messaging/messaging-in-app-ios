//
//  VoiceControlPanel.swift
//

import SwiftUI
import SMIClientCore
import SMIMultimediaCommon

struct VoiceControlPanel: View {
    internal enum Constants {
        static let horizontalPadding: CGFloat = 16
        static let verticalPadding: CGFloat = 12
        static let spacing: CGFloat = 12
        static let buttonSize: CGFloat = 44
        static let buttonIconPadding: CGFloat = 10
        static let buttonSpacing: CGFloat = 48
        static let buttonBottomPadding: CGFloat = 28
        static let expandedIconSize: CGFloat = 112
        static let landscapeIconSize: CGFloat = 60
        static let expandedTopPadding: CGFloat = 40
        static let landscapeTopPadding: CGFloat = 16
        static let titleTimerSpacing: CGFloat = 8
        static let sectionSpacing: CGFloat = 32
        static let visualizerBottomSpacing: CGFloat = 64
        static let visualizerBottomLandscapeSpacing: CGFloat = 24
        static let landscapeSectionSpacing: CGFloat = 12
        static let timerFormat = "%02d:%02d"
        static let compactDetentHeight: CGFloat = 80
    }

    private let client: ConversationClient
    @StateObject private var multimediaClient: MultimediaClient
    @StateObject private var transcriptProvider: VoiceTranscriptProvider
    @ObservedObject private var expandedState: VoiceSheetExpandedState
    @Environment(\.dismiss) private var dismiss
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @State private var isMuted: Bool = false
    @State private var hasJoined: Bool = false

    private var isExpanded: Bool { expandedState.isExpanded }

    var body: some View {
        Group {
            if isExpanded {
                expandedLayout
            } else {
                compactLayout
            }
        }
        .onChange(of: multimediaClient.session.state) { _, newValue in
            handleStateChange(newValue)
        }
        .onAppear { handleStateChange(multimediaClient.session.state) }
        .onDisappear { endCallIfNeeded() }
        .environmentObject(multimediaClient)
    }

    init(client: ConversationClient, expandedState: VoiceSheetExpandedState) {
        self.client = client
        self.expandedState = expandedState
        _multimediaClient = StateObject(wrappedValue: MultimediaClient(client.core?.multimediaClient))
        _transcriptProvider = StateObject(wrappedValue: VoiceTranscriptProvider(client: client))
    }

    private var compactLayout: some View {
        HStack(spacing: Constants.spacing) {
            audioMeter(.remote, size: Constants.buttonSize)

            titleAndTimer
                .frame(maxWidth: .infinity, alignment: .leading)

            muteButton()
            endCallButton()
        }
        .padding(.horizontal, Constants.horizontalPadding)
        .padding(.vertical, Constants.verticalPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(VoiceColors.surface, ignoresSafeAreaEdges: .all)
    }

    private var isLandscape: Bool { verticalSizeClass == .compact }

    private var expandedLayout: some View {
        VStack(spacing: 0) {
            titleAndTimer
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, Constants.horizontalPadding)
                .padding(.top, isLandscape ? Constants.landscapeTopPadding : Constants.expandedTopPadding)

            statusText
                .padding(.vertical, isLandscape ? Constants.landscapeSectionSpacing : Constants.sectionSpacing)

            audioMeter(.remote, size: isLandscape ? Constants.landscapeIconSize : Constants.expandedIconSize)
                .padding(.bottom, isLandscape ? Constants.visualizerBottomLandscapeSpacing : Constants.visualizerBottomSpacing)

            VoiceTranscriptFeedView(
                entries: transcriptProvider.entries,
                agentDisplayName: multimediaClient.session.displayName
            )
            .padding(.horizontal, Constants.horizontalPadding)
            .padding(.bottom, isLandscape ? Constants.landscapeSectionSpacing : Constants.sectionSpacing)
            .layoutPriority(1)

            HStack(spacing: Constants.buttonSpacing) {
                muteButton()
                endCallButton()
            }
            .padding(.bottom, isLandscape ? Constants.landscapeSectionSpacing : Constants.buttonBottomPadding)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(VoiceColors.surface)
        .contentShape(Rectangle())
        .onTapGesture {}
    }

    @ViewBuilder
    private func audioMeter(_ origin: MultimediaParticipantOrigin, size: CGFloat) -> some View {
        let participant = origin == .local ? multimediaClient.session.localParticipant : multimediaClient.session.remoteParticipants.first

        if let track = participant?.audioStream?.tracks.first {
            VoiceAudioVisualizer(origin, audioTrack: track, width: size, height: size)
        } else {
            VoiceAudioVisualizer(origin, audioTrack: nil, width: size, height: size)
        }
    }

    @ViewBuilder
    private var titleAndTimer: some View {
        VStack(alignment: .leading, spacing: Constants.titleTimerSpacing) {
            Text(multimediaClient.session.displayName)
                .font(.headline.weight(.semibold))
                .foregroundStyle(VoiceColors.onSurface)

            TimelineView(.periodic(from: .now, by: 1.0)) { context in
                Text(formattedElapsedTime(at: context.date))
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(VoiceColors.onSurface)
                    .monospacedDigit()
            }
        }
    }

    private var statusText: some View {
        Group {
            if multimediaClient.session.state == .disconnecting {
                Text("Ending Voice...")
            } else if multimediaClient.session.remoteParticipants.isEmpty {
                Text("Start talking to initiate a new chat")
            } else {
                Text(" ")
            }
        }
        .font(.subheadline)
        .foregroundStyle(VoiceColors.onBackground)
    }

    private func formattedElapsedTime(at date: Date) -> String {
        guard let connectionDate = multimediaClient.session.connectionDate else {
            return String(format: Constants.timerFormat, 0, 0)
        }
        let elapsedSeconds = Int(date.timeIntervalSince(connectionDate))
        let minutes = elapsedSeconds / 60
        let seconds = elapsedSeconds % 60
        return String(format: Constants.timerFormat, minutes, seconds)
    }

    @ViewBuilder
    private func muteButton() -> some View {
        Button {
            isMuted.toggle()
        } label: {
            VoiceCircleIcon(image: Image(isMuted ? "actionMute" : "actionUnmute"),
                       backgroundColor: VoiceColors.onSurface,
                       foregroundColor: VoiceColors.onSurface,
                       size: Constants.buttonSize,
                       style: .outlined(lineWidth: 1),
                       iconPadding: Constants.buttonIconPadding)
                .background(Circle().fill(VoiceColors.surface))
        }
    }

    @ViewBuilder
    private func endCallButton() -> some View {
        Button {
            dismiss()
        } label: {
            VoiceCircleIcon(image: Image("actionEndVoice"),
                       backgroundColor: VoiceColors.onSurface,
                       foregroundColor: VoiceColors.onSurface,
                       size: Constants.buttonSize,
                       style: .outlined(lineWidth: 1),
                       iconPadding: Constants.buttonIconPadding)
                .background(Circle().fill(VoiceColors.surface))
        }
    }

    // MARK: - Session State Management

    private func handleStateChange(_ newState: MultimediaConnectionState) {
        switch newState {
        case .initial:
            multimediaClient.session.wrappedSession?.join(nil) { error in
                if let error = error {
                    print("Multimedia Join Result: \(error)")
                }
            }
        case .connecting, .connected:
            hasJoined = true
        case .disconnected:
            if hasJoined {
                dismiss()
            }
        default:
            break
        }
    }

    private func endCallIfNeeded() {
        let state = multimediaClient.session.state
        guard state == .connecting || state == .connected || state == .disconnecting else { return }
        client.changeModalities([.messaging])
    }
}

