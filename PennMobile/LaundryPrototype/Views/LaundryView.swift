//
//  LaundryView.swift
//  PennMobile
//
//  Created by Nathan Aronson on 10/3/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI

struct LaundryView: View {
    
    @StateObject private var laundryViewModel: LaundryViewModel = LaundryViewModel()
    @State private var isShowingSelect: Bool = false
    
    private var selectionMessage: String {
        if laundryViewModel.selectedHalls.count == 0 { return "No laundry rooms selected" }
        return "\(laundryViewModel.selectedHalls.count) of 3 rooms selected"
    }
    
    private var sortedSelectedHalls: [Int] {
        guard case let .success(halls) = laundryViewModel.laundryHallIds else { return [] }
        let selected = halls.filter { laundryViewModel.selectedHalls.contains($0.hallId) }
        
        return selected.sorted {
            if $0.location == $1.location {
                return $0.name < $1.name
            }
            return $0.location < $1.location
        }.map { $0.hallId }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 6) {
                ForEach(sortedSelectedHalls, id: \.self) { hallId in
                    HomeCardView {
                        LaundryRoomView(hallId: hallId)
                            .environmentObject(laundryViewModel)
                    }
                    .padding(.bottom, 16)
                }
                if(laundryViewModel.selectedHalls.count <  3) {
                    Text(selectionMessage)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Button(action: {
                        isShowingSelect = true
                    }) {
                        Text("Select a room")
                            .font(.subheadline)
                            .bold()
                    }
                }
            }.padding(.top, 32)
        }
        .navigationTitle("Laundry")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isShowingSelect = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $isShowingSelect) {
            LaundrySelectView(isShowingSelect: $isShowingSelect).environmentObject(laundryViewModel)
        }
        .task {
            await laundryViewModel.loadLaundryHalls()
        }
        .refreshable {
            if case .loading = laundryViewModel.laundryHallIds {
                return
            }
            await laundryViewModel.loadLaundryHalls()
        }
    }
}

#Preview {
    NavigationStack {
        LaundryView()
    }
}
