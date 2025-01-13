//
//  RefactorDiningView.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 11/17/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import SwiftUI
import Foundation

struct RefactorDiningView: View {
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, pinnedViews: [.sectionHeaders]) {
                DiningSection(title: "Dining Balance") {
                    RefactorDiningBalanceView()
                }
                DiningSection(title: "Favorites") {
                    Text("FavoritesView")
                }
                DiningSection(title: "Dining Halls") {
                    Text("HallsView")
                }
                DiningSection(title: "Retail Dining") {
                    Text("RetailView")
                }
            }
            .onAppear {
                
                Task {
                    if case .success(let halls) = await RefactorDiningAPI.instance.getDiningHalls() {
                        let halls: [RefactorDiningHall] = halls
                    } else {
                        print("failed")
                    }
                }
            }
            
        }
    }
}

struct DiningSection<Content: View>: View {
    let title: String
    let content: () -> Content
    
    
    init(title: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }
    
    var body: some View {
        Section(header:
        HStack {
            Text("\(title)")
                .font(.title2)
                .bold()
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
            Spacer()
        }
            .background {
                Rectangle()
                    .foregroundStyle(.background)
                    .frame(minWidth: UIScreen.main.bounds.width)
            }
                
        ) {
            VStack(alignment: .leading) {
                Divider()
                content()
            }
            .padding(.horizontal, 16)
        }
        
    }
}

#Preview {
    RefactorDiningView()
}
