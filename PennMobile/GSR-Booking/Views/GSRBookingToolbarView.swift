//
//  GSRBookingToolbarView.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 3/22/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI

struct GSRBookingToolbarView: View {
    @EnvironmentObject var vm: GSRViewModel
    @Environment(\.presentToast) var presentToast
    @State var startedQuickBook = false
    
    var body: some View {
        HStack(spacing: 12) {
            if !vm.selectedTimeslots.isEmpty {
                Button {
                    Task {
                        do {
                            try await vm.book()
                        } catch {
                            presentToast(ToastConfiguration({
                                Text(error.localizedDescription)
                            }))
                        }
                    }
                } label: {
                    Text("Book")
                        .font(.body)
                        .bold()
                        .foregroundStyle(Color.white)
                        .padding(12)
                        .padding(.horizontal, 24)
                        .background {
                            RoundedRectangle(cornerRadius: 12)
                                .foregroundStyle(Color("gsrBlue"))
                                .shadow(radius: 2)
                        }
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
            } else {
                RoomFinderSelectionPanel(isEnabled: $startedQuickBook)
                .transition(.move(edge: .leading).combined(with: .opacity))
            }
        }
        .fullScreenCover(isPresented: $startedQuickBook) {
            Rectangle()
                .foregroundStyle(Color.black.opacity(0.001))
                .onTapGesture {
                    withAnimation(.snappy(duration: 0.2)) {
                        startedQuickBook = false
                    }
                }
            .presentationBackground(.black.opacity(0.0))
        }
        
    }
}
