//
//  GSRBookingToolbarView.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 3/22/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI
import PennMobileShared

struct GSRBookingToolbarView: View {
    @EnvironmentObject var vm: GSRViewModel
    @Environment(\.presentToast) var presentToast

    var body: some View {
        ZStack {
            if vm.quickBookPhase == .picking {
                // Tapping outside the picker closes it
                Rectangle()
                    .foregroundStyle(.clear)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        vm.endQuickBook(clearSelection: true)
                    }
            }
            VStack {
                Spacer()
                HStack(spacing: 12) {
                    if vm.quickBookPhase == .picking {
                        QuickBookTimelinePicker()
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    } else if vm.quickBookPhase == .browsing {
                        QuickBookResultsBar()
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    } else if !vm.selectedTimeslots.isEmpty {
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
                        Button {
                            vm.startQuickBook()
                        } label: {
                            Label("Find me a room", systemImage: "wand.and.sparkles")
                                .foregroundStyle(Color.black)
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
    }
}
