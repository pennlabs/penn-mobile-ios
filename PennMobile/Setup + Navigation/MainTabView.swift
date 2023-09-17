//
//  MainTabView.swift
//  PennMobile
//
//  Created by Anthony Li on 9/17/23.
//  Copyright © 2023 PennLabs. All rights reserved.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            Text("Home")
                .tabItem {
                    Label("Home", image: "Home_Grey")
                }
            
            ForEach(tabBarFeatures, id: \.self) { identifier in
                let feature = features.first(where: { $0.identifier == identifier })!
                feature.content.tabItem {
                    switch feature.image {
                    case .app(let image):
                        Label(feature.shortName, image: image)
                    case .system(let image):
                        Label(feature.shortName, systemImage: image)
                    }
                }
            }
            
            Text("More")
                .tabItem {
                    Label("More", image: "More_Grey")
                }
        }
    }
}
