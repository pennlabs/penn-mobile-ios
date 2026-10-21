//
//  HomeSectionView.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 10/16/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import SwiftUI
import PennMobileShared

struct HomeSectionView<Item, Content: View>: View {
    let result: BackendFetchedResult<Item>?
    let description: LocalizedStringResource
    let content: (Item) -> Content
    
    init(_ result: BackendFetchedResult<Item>?, description: LocalizedStringResource, @ViewBuilder content: @escaping (Item) -> Content) {
        self.result = result
        self.description = description
        self.content = content
    }
    
    var body: some View {
        Group {
            switch result {
            case .success(let value):
                content(value)
            case .failure(let error):
                HomeCardView {
                    VStack {
                        Image(systemName: "pc")
                            .font(.system(size: 60))
                            .symbolRenderingMode(.multicolor)
                            .padding(.bottom, 4)
                        Text("Couldn't load \(description) :(")
                            .fontWeight(.bold)
                        Text(error.localizedDescription)
                            .font(.caption)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 24)
                }
                .multilineTextAlignment(.center)
            case .pending, nil:
                EmptyView()
            }
        }
    }
}
