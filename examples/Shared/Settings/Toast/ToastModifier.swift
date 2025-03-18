//
//  ToastModifier.swift
//  MessagingUIExample
//
//  From: https://ondrej-kvasnovsky.medium.com/how-to-build-a-simple-toast-message-view-in-swiftui-b2e982340bd
//


import SwiftUI

struct ToastModifier: ViewModifier {
  
    @Binding var toast: Toast?
    @State private var workItem: DispatchWorkItem?
  
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(
                ZStack {
                    mainToastView()
                        .offset(y: 32)
                }.animation(.spring(), value: toast)
            )
            .onChange(of: toast) { value in
                showToast()
            }
    }
  
    @ViewBuilder func mainToastView() -> some View {
        if let toast = toast {
            VStack {
                ToastView(
                    style: toast.style,
                    message: toast.message,
                    width: toast.width
                ) {
                    dismissToast()
                }
                Spacer()
            }
        }
    }
  
    private func showToast() {
        guard let toast = toast else { return }
    
        UIImpactFeedbackGenerator(style: .light)
            .impactOccurred()
    
        if toast.duration > 0 {
            workItem?.cancel()
      
            let task = DispatchWorkItem {
                dismissToast()
            }
      
            workItem = task
            DispatchQueue.main.asyncAfter(deadline: .now() + toast.duration, execute: task)
        }
    }
  
    private func dismissToast() {
        withAnimation {
            toast = nil
        }
    
        workItem?.cancel()
        workItem = nil
    }
}

extension View {
    func toastView(toast: Binding<Toast?>) -> some View {
        self.modifier(ToastModifier(toast: toast))
    }
}
