//
//  GSRBookingToolbarView.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 3/22/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI

struct GSRBookingToolbarView: View {
    let hasSelection: Bool
    let hasSortFilters: Bool
    let onBook: () -> Void
    let onResetFilters: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            if hasSelection {
                Button(action: onBook) {
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
            } else if hasSortFilters {
                Button(action: onResetFilters) {
                    Label("Reset Filters", systemImage: "trash")
                        .font(.body)
                        .foregroundStyle(Color(UIColor.systemGray))
                        .padding(12)
                        .background {
                            RoundedRectangle(cornerRadius: 12)
                                .foregroundStyle(Color.white)
                                .shadow(radius: 2)
                        }
                }
                .transition(.move(edge: .leading).combined(with: .opacity))
            }
        }
    }
}
