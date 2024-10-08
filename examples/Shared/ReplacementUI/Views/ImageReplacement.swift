//
//  ImageReplacement.swift
//  IAMessagingTestApp
//
//  Created by Jeremy Wright on 2024-07-22.
//  Copyright © 2024 Salesforce.com. All rights reserved.
//

import SwiftUI
import SMIClientCore
import SMIClientUI

struct ImageReplacement: View {
    @EnvironmentObject var chatFeedProxy: ChatFeedProxy
    @State var image: UIImage?

    let asset: ImageAsset
    let borderColor: Color

    init(asset: ImageAsset, borderColor: Color = Color(.systemYellow)) {
        self.asset = asset
        self.borderColor = borderColor
    }

    func fetch() {
        asset.fetchContent(completion: { _ in
            if let data = asset.file {
                image = UIImage(data: data)
            }
        })
    }

    private let placeholder: UIImage = UIImage.smiBranded(.iconImagePlaceholder) ?? UIImage()

    var body: some View {
            Image(uiImage: image ?? placeholder)
                .resizable()
                .scaledToFit()
                .frame(width: chatFeedProxy.screenSize.width * 0.6)
                .overlay(
                    Border().stroke(borderColor, lineWidth: 1)
                )
        .onAppear(perform: fetch)
    }
}
