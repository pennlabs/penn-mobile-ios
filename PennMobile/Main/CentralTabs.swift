//
//  CentralTabs.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 10/16/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import SwiftUI
import PennMobileShared

struct CentralTabs: View {
    let tabs: [FeatureIdentifier] = [.gsr]
    
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            ForEach(tabs) { tab in
                if let feature = features.first(where: { $0.id == tab }) {
                    feature.content
                        .tabItem {
                            switch feature.image {
                            case .app(let string):
                                Label(feature.shortName, image: string)
                            case .system(let string):
                                Label(feature.shortName, systemImage: string)
                            }
                        }
                }
            }
        }
        
    }
}
