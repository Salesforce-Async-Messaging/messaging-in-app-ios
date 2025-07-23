//
//  TestNavBarBuilder.swift
//  MessagingUIExample
//
//  Created by Nigel Brown on 2025-06-19.
//

import SwiftUI
import SMIClientCore
import SMIClientUI

struct TestNavBarBuilder: NavigationBarBuilder {
    private let navBarReplacementStore: NavBarReplacementStore = NavBarReplacementStore()

    var handleNavigation: HandleNavigationClosure {
        return { screenType, navigationItem in

            let rawScreenType = NavBarReplacementCategory.type(screenType).rawValue

            if let shouldReplace = navBarReplacementStore.navBarReplacements[rawScreenType]?.shouldReplace, shouldReplace {
                NavBarReplacementCategory.type(screenType).updateNavigationItem(navigationItem)
            }
        }
    }
}
