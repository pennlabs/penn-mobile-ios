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
    
    var selectionMessage: String {
//        if laundryHallIds.isEmpty {
//            return "No laundry rooms selected"
//        } else {
//            return "\(laundryHallIds.count) of 3 rooms selected"
//        }
        return "TODO"
    }
        
    var body: some View {
        ScrollView {
            VStack(spacing: 6) {
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
            }.padding(.top, 30)
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
            LaundrySelectView(isShowingSelect: $isShowingSelect)
        }
        .task {
            await laundryViewModel.loadLaundryHalls()
        }
    }
}

#Preview {
    NavigationStack {
        LaundryView()
    }
}
