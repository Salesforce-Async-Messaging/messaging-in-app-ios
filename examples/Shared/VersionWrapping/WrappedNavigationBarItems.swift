//
//  WrappedNavigationBarItems.swift
//

import SwiftUI

struct WrappedNavigationBarItems<L: View, T: View>: ViewModifier {
    let leading: () -> L
    let trailing: () -> T

    init(leading: @escaping () -> L, trailing: @escaping () -> T) {
        self.leading = leading
        self.trailing = trailing
    }

    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        leading()
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        trailing()
                    }
                }
        } else {
            content
                .navigationBarItems(leading: leading(), trailing: trailing())
        }
    }
}

extension View {
    func wrappedNavigationBarItems<L: View, T: View>(leading: @escaping () -> L, trailing: @escaping () -> T) -> some View where L: View, T: View {
        modifier(WrappedNavigationBarItems(leading: leading, trailing: trailing))
    }

    func wrappedNavigationBarItems<T: View>(trailing: @escaping () -> T) -> some View where T: View {
        modifier(WrappedNavigationBarItems(leading: {EmptyView()}, trailing: trailing))
    }
}
