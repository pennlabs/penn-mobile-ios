//
//  GSRCentralView.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 2/19/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI

struct GSRCentralView: View {
    static let debug = true
    
    @State var loggedIn = false
    @State var selectedTab: GSRTab = GSRTab.book
    @StateObject var vm = GSRViewModel()
    
    var body: some View {
        if loggedIn || GSRCentralView.debug {
            VStack {
                HStack {
                    Spacer()
                    ForEach(GSRTab.allCases, id: \.rawValue) { tab in
                        Text(tab.titleText)
                            .foregroundStyle(selectedTab == tab ? Color("baseLabsBlue") : Color.primary)
                            // make hit target larger using horizontal padding
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .onTapGesture {
                                withAnimation {
                                    selectedTab = tab
                                }
                            }
                        Spacer()
                    }
                }
                Rectangle()
                    .frame(maxHeight: 2)
                    .foregroundStyle(Color(UIColor.systemGray))
                Group {
                    switch selectedTab {
                    case .book:
                        List(vm.availableLocations, id: \.lid) { location in
                            NavigationLink(destination: EmptyFile()) {
                                GSRLocationCell(location: location)
                            }
                        }
                        .listStyle(PlainListStyle())

                        
                        
                    case .reservations:
                        Image(systemName: "circle.fill")
                    }
                }
                .environmentObject(vm)
                .navigationBarTitleDisplayMode(.inline)
                .padding()
                .onAppear {
                    vm.checkWhartonStatus()
                }
            }
            .ignoresSafeArea(edges: .horizontal)
        } else {
            GSRGuestLandingPage()
            .navigationBarHidden(true)
        }
    }
}

enum GSRTab: Int, Equatable, CaseIterable {
    case book = 0
    case reservations = 1
    
    var titleText: String {
        switch self {
        case .book:
            "Book"
        case .reservations:
            "Reservations"
        }
    }
}

#Preview {
    GSRCentralView()
}
