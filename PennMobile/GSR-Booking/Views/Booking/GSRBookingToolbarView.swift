//
//  GSRBookingToolbarView.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 3/22/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI
import PennMobileShared

enum QuickBookStatus {
    case closed, search, explore
}

struct GSRBookingToolbarView: View {
    @EnvironmentObject var vm: GSRViewModel
    @Environment(\.presentToast) var presentToast
    @State var quickBookStatus = QuickBookStatus.closed
    
    var body: some View {
        ZStack {
            if quickBookStatus == .search {
                Rectangle()
                    .foregroundStyle(.clear)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.snappy(duration: 0.2)) {
                            quickBookStatus = .closed
                        }
                    }
                    
            }
            VStack {
                Spacer()
                HStack(spacing: 12) {
                    if !vm.selectedTimeslots.isEmpty && quickBookStatus == .closed {
                        Button {
                            Task {
                                do {
                                    try await vm.book()
                                } catch {
                                    presentToast(ToastConfiguration(message: "\(error.localizedDescription)"))
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
                    } else if !vm.sortedStartTime.isEmpty {
                        Button {
                            withAnimation(.snappy(duration: 0.3)) {
                                vm.clearSortedFilters()
                            }
                        } label: {
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
                    } else {
                        RoomFinderSelectionPanel(vm: vm, status: $quickBookStatus)
                            .transition(.move(edge: .leading).combined(with: .opacity))
                    }
                }
            }
        }
    }
}
