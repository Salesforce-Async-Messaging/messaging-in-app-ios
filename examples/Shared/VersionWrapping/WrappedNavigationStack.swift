//
//  WrappedNavigationStack.swift
//

import SwiftUI

struct WrappedNavigationStack<Content: View>: View {
    let content: () -> Content

    init(@ViewBuilder _ content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                content()
            }
        } else {
            NavigationView {
                content()
            }
        }
    }
}

#Preview {
    WrappedNavigationStack {
        Text("Hello World")
            .navigationTitle("Example")
    }
}
