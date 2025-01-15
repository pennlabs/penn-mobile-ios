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
    
    @ObservedObject var vm = RefactorDiningViewModel()
    
    var body: some View {
        List {
            Section(header:
                Text("Dining Balance")
                    .font(.title2)
                    .bold()
                    .padding(.vertical, 12)
                    .foregroundStyle(.primary)
            ) {
                RefactorDiningBalanceView()
            }
            
            Section(header:
                Text("Favorites")
                    .font(.title2)
                    .bold()
                    .padding(.vertical, 12)
                    .foregroundStyle(.primary)
            ) {
                Text("FavoritesView")
            }
            
            Section(header:
                Text("Dining Halls")
                    .font(.title2)
                    .bold()
                    .padding(.vertical, 12)
                    .foregroundStyle(.primary)
            ) {
                ForEach(vm.diningHalls) { hall in
                    NavigationLink {
                        RefactorDiningHallDetailView(hall)
                            .navigationTitle(hall.name)
                    } label: {
                        RefactorDiningHallStatusView(hall)
                    }
                }
            }
            
            Section(header:
                Text("Retail Dining")
                    .font(.title2)
                    .bold()
                    .padding(.vertical, 12)
                    .foregroundStyle(.primary)
            ) {
                ForEach(vm.retailDining) { hall in
                    NavigationLink {
                        RefactorDiningHallDetailView(hall)
                            .navigationTitle(hall.name)
                    } label: {
                        RefactorDiningHallStatusView(hall)
                    }
                }
            }
        }
        .listStyle(.plain)
        .onAppear {
            Task {
                await vm.refresh()
                print("Finished refreshing")
            }
        }
    }
}

//struct DiningSection<Content: View>: View {
//    let title: String
//    let content: () -> Content
//    
//    
//    init(title: String, @ViewBuilder content: @escaping () -> Content) {
//        self.title = title
//        self.content = content
//    }
//    
//    var body: some View {
//        
//        
//    }
//}

#Preview {
    RefactorDiningView()
}
