//
//  WrappedKeyboardDismiss.swift
//

import SwiftUI

struct WrappedKeyboardDismiss: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content
                .scrollDismissesKeyboard(.immediately)
        } else {
            content
        }
    }
}

extension View {
    func wrappedKeyboardDismiss() -> some View {
        modifier(WrappedKeyboardDismiss())
    }
}
