//
//  ToastView.swift
//  MessagingUIExample
//
//  From: https://ondrej-kvasnovsky.medium.com/how-to-build-a-simple-toast-message-view-in-swiftui-b2e982340bd
//


import SwiftUI

struct ToastView: View {
  
    var style: Toast.Style
    var message: String
    var width = CGFloat.infinity
    var onCancelTapped: (() -> Void)
  
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            style.image
                .foregroundColor(style.color)
            Text(message)
                .font(Font.caption)
                .foregroundColor(Color(.darkText))

            Spacer(minLength: 10)
      
            Button {
                onCancelTapped()
            } label: {
                Image(systemName: "xmark")
                    .foregroundColor(Color(.darkText))
            }
        }
        .padding()
        .frame(minWidth: 0, maxWidth: width)
        .background(Color(.white))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .opacity(0.1)
        )
        .padding(.horizontal, 16)
    }
}
