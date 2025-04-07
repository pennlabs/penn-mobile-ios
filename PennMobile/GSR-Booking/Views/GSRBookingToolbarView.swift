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
            Button {
                withAnimation(.snappy(duration: 0.2)) {
                    startedQuickBook = true
                    DispatchQueue.main.schedule(after: .init(.now().advanced(by: .seconds(4)))) {
                        withAnimation {
                            startedQuickBook = false
                        }
                    }
                }
            } label: {
                Label("Find me a room", systemImage: "wand.and.sparkles")
                    .font(.body)
                    .foregroundStyle(Color(UIColor.systemGray))
                    .opacity(startedQuickBook ? 0 : 1)
                    .padding(8)
                    .background {
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundStyle(Color.white)
                            .shadow(radius: 2)
                    }
                    .allowsHitTesting(!startedQuickBook)
                    .overlay {
                        if startedQuickBook {
                            HStack {
                                Button {
                                    withAnimation {
                                        startedQuickBook = false
                                    }
                                } label: {
                                    Text("30")
                                }
                                Divider()
                                Button {
                                    withAnimation {
                                        startedQuickBook = false
                                    }
                                } label: {
                                    Text("60")
                                }
                                Divider()
                                Button {
                                    withAnimation {
                                        startedQuickBook = false
                                    }
                                } label: {
                                    Text("90")
                                }
                            }
                            .foregroundStyle(Color(UIColor.systemGray))
                            .padding(8)
                        }
                    }
            }
            
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
