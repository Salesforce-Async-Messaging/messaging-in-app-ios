//
//  VoiceControlPanel.swift
//

import SwiftUI
import SMIClientCore
import SMIClientUI
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
        static let compactDetentFraction: CGFloat = 0.15
    }

    private let client: ConversationClient
    @StateObject private var multimediaClient: MultimediaClient
    @Environment(\.dismiss) private var dismiss
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @State private var isExpanded: Bool = true
    @State private var isMuted: Bool = false
    @State private var hasJoined: Bool = false

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
        .voiceSheetPresentation(isExpanded: $isExpanded)
        .environmentObject(multimediaClient)
    }

    init(client: ConversationClient) {
        self.client = client
        _multimediaClient = StateObject(wrappedValue: MultimediaClient(client.core?.multimediaClient))
    }

    private var compactLayout: some View {
        VStack {
            Spacer()
            HStack(spacing: Constants.spacing) {
                audioMeter(.remote, size: Constants.buttonSize)

                titleAndTimer
                    .frame(maxWidth: .infinity, alignment: .leading)

                muteButton()
                endCallButton()
            }
            .padding(.horizontal, Constants.horizontalPadding)
            Spacer()
        }
        .frame(maxHeight: .infinity)
        .background(Color.smiBranded(.voiceSheetMinimizedBackground), ignoresSafeAreaEdges: .all)
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

            Spacer()

            HStack(spacing: Constants.buttonSpacing) {
                muteButton()
                endCallButton()
            }
            .padding(.bottom, isLandscape ? Constants.landscapeSectionSpacing : Constants.buttonBottomPadding)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.smiBranded(.voiceSheetExpandedBackground))
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
                .foregroundStyle(Color.smiBranded(.voiceTextPrimary))

            TimelineView(.periodic(from: .now, by: 1.0)) { context in
                Text(formattedElapsedTime(at: context.date))
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(Color.smiBranded(.voiceTextPrimary))
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
        .foregroundStyle(Color.smiBranded(.voiceTextSecondary))
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
                       backgroundColor: Color.smiBranded(.voiceButtonBorder),
                       foregroundColor: Color.smiBranded(.voiceButtonIcon),
                       size: Constants.buttonSize,
                       style: .outlined(lineWidth: 1),
                       iconPadding: Constants.buttonIconPadding)
                .background(Circle().fill(Color.smiBranded(.voiceButtonBackground)))
        }
    }

    @ViewBuilder
    private func endCallButton() -> some View {
        Button {
            dismiss()
        } label: {
            VoiceCircleIcon(image: Image("actionEndVoice"),
                       backgroundColor: Color.smiBranded(.voiceButtonBorder),
                       foregroundColor: Color.smiBranded(.voiceButtonIcon),
                       size: Constants.buttonSize,
                       style: .outlined(lineWidth: 1),
                       iconPadding: Constants.buttonIconPadding)
                .background(Circle().fill(Color.smiBranded(.voiceButtonBackground)))
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

// MARK: - Sheet Presentation

private struct VoiceSheetPresentationModifier: ViewModifier {
    @Binding var isExpanded: Bool

    private var sheetBackground: Color {
        isExpanded
            ? Color.smiBranded(.voiceSheetExpandedBackground)
            : Color.smiBranded(.voiceSheetMinimizedBackground)
    }

    func body(content: Content) -> some View {
        if #available(iOS 16.4, *) {
            VoiceExpandedDetentWrapper(isExpanded: $isExpanded) {
                content
            }
            .presentationDragIndicator(.visible)
            .presentationBackground(sheetBackground)
            .presentationBackgroundInteraction(.enabled(upThrough: .fraction(VoiceControlPanel.Constants.compactDetentFraction)))
            .interactiveDismissDisabled()
        } else {
            VoiceExpandedDetentWrapper(isExpanded: $isExpanded) {
                content
            }
            .presentationDragIndicator(.visible)
            .interactiveDismissDisabled()
        }
    }
}

@available(iOS 16, *)
private struct VoiceExpandedDetentWrapper<Content: View>: View {
    @Binding var isExpanded: Bool
    @State private var selectedDetent: PresentationDetent = .large
    let content: () -> Content

    var body: some View {
        content()
            .presentationDetents([.fraction(VoiceControlPanel.Constants.compactDetentFraction), .large], selection: $selectedDetent)
            .onChange(of: selectedDetent) { _, newValue in
                isExpanded = newValue == .large
            }
    }
}

extension View {
    fileprivate func voiceSheetPresentation(isExpanded: Binding<Bool>) -> some View {
        modifier(VoiceSheetPresentationModifier(isExpanded: isExpanded))
    }
}
