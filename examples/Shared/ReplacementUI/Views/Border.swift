//
//  Border.swift
//  MessagingUIExample
//
//  Created by Jeremy Wright on 2024-07-26.
//  Copyright © 2024 Salesforce.com. All rights reserved.
//

import SwiftUI

struct Border: Shape {
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(rect: rect)
        return Path(path.cgPath)
    }
}
