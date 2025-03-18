//
//  Toast.swift
//  MessagingUIExample
//
//  From: https://ondrej-kvasnovsky.medium.com/how-to-build-a-simple-toast-message-view-in-swiftui-b2e982340bd
//

import SwiftUI

struct Toast: Equatable {
    enum Style {
      case error
      case warning
      case success
      case info
    }

  var style: Style
  var message: String
  var duration: Double = 2
  var width: Double = .infinity
}

extension Toast.Style {
    var color: Color {
        switch self {
        case .error: .red
        case .warning: .yellow
        case .info: .blue
        case .success: .green
        }
    }

    var image: Image {
        switch self {
        case .error: return Image(systemName: "xmark.circle.fill")
        case .warning: return Image(systemName: "exclamationmark.triangle.fill")
        case .info: return Image(systemName: "info.circle.fill")
        case .success: return Image(systemName: "checkmark.circle.fill")
        }
    }
}
