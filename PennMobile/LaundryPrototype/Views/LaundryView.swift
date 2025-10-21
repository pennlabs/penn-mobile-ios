//
//  LaundryView.swift
//  PennMobile
//
//  Created by Nathan Aronson on 10/3/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI

struct LaundryView: View {
    
    // MARK: - Properties
    @StateObject private var laundryViewModel: LaundryViewModel = LaundryViewModel()
    @State private var isShowingSelect: Bool = false
    
    // MARK: - Computed Properteies
    private var selectionMessage: String {
        let count = laundryViewModel.selectedHalls.count
        if count == 0 { return "No laundry rooms selected" }
        return "\(count) room\(count > 1 ? "s" : "") selected"
    }
    
    // MARK: - Body
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
            LaundrySelectView(isShowingSelect: $isShowingSelect).environmentObject(laundryViewModel)
        }
        .task {
            await laundryViewModel.loadLaundryHalls()
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        LaundryView()
    }
}
