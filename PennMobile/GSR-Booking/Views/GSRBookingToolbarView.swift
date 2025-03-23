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
    
    var body: some View {
        HStack(spacing: 12) {
            Button {
                withAnimation(.snappy(duration: 0.2)) {
                }
            } label: {
                Label("Find me a room", systemImage: "wand.and.sparkles")
                    .font(.body)
                    .foregroundStyle(Color(UIColor.systemGray))
                    .padding(8)
                    .background {
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundStyle(Color.white)
                            .shadow(radius: 2)
                    }
            }
            
            if !vm.selectedTimeslots.isEmpty {
                Button {
                    
                } label: {
                    Text("Book")
                        .font(.body)
                        .bold()
                        .foregroundStyle(Color.white)
                        .padding(8)
                        .padding(.horizontal, 24)
                        .background {
                            RoundedRectangle(cornerRadius: 8)
                                .foregroundStyle(Color("gsrBlue"))
                                .shadow(radius: 2)
                        }
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .background(.background)
    }
}
