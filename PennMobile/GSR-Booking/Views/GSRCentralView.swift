//
//  GSRCentralView.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 2/19/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI

struct GSRCentralView: View {
    @State var selectedTab: GSRTab = GSRTab.book
    @StateObject var vm = GSRViewModel()
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.presentToast) var presentToast
    @State var showErrorRefresh: Bool = false
    
    @Sendable func handleInitialState() async {
        do {
            try await vm.fetchInitialState()
            withAnimation {
                self.showErrorRefresh = false
            }
        } catch {
            presentToast(.init(message: String.LocalizationValue(error.localizedDescription)))
            withAnimation {
                self.showErrorRefresh = true
            }
        }
    }
    
    var body: some View {
        if authManager.state.isLoggedIn {
            VStack(spacing: 0) {
                VStack {
                    HStack {
                        Spacer()
                        ForEach(GSRTab.allCases, id: \.rawValue) { tab in
                            Text(tab.titleText)
                                .foregroundStyle(selectedTab == tab ? Color("baseLabsBlue") : Color.primary)
                                .font(.title3)
                            // make hit target larger using horizontal padding
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .onTapGesture {
                                    withAnimation(.snappy(duration: 0.3)) {
                                        selectedTab = tab
                                    }
                                }
                            Spacer()
                        }
                    }
                    Rectangle()
                        .frame(maxHeight: 1)
                        .foregroundStyle(Color(UIColor.systemGray))
                }
                Group {
                    switch selectedTab {
                    case .book:
                        ZStack (alignment: .bottomTrailing){
                            if (vm.isMapView) {
                                GSRMapView(selectedTab: $selectedTab)
                                    .environmentObject(vm)
                            } else {
                                GSRListView(selectedTab: $selectedTab)
                                    .environmentObject(vm)
                            }
                            Button {
                                vm.isMapView.toggle()
                            } label : {
                                Label {
                                    Text(vm.isMapView ? "List View" : "Map View")
                                } icon: {
                                    Image(systemName: vm.isMapView ? "list.bullet": "map.fill")
                                }
                                .foregroundColor(Color.primary)
                                .frame(minWidth: 125, minHeight: 20, alignment: .center)
                                .padding(.horizontal, 12.5)
                                .padding(.vertical, 14)
                            }
                            .background {
                                Capsule()
                                    .fill(.ultraThinMaterial)
                            }
                            .overlay {
                                Capsule().stroke(.secondary)
                            }
                            .padding(.trailing, 20)
                            .padding(.bottom, 20)
                        }
                        
                    case .reservations:
                        ReservationsView()
                            .transition(.blurReplace)
                    }
                }
                .environmentObject(vm)
                .navigationBarTitleDisplayMode(.inline)
                .task(handleInitialState)
                .toolbar {
                    if showErrorRefresh {
                        ToolbarItem(placement: .primaryAction) {
                            Button {
                                Task(operation: handleInitialState)
                            } label: {
                                Image(systemName: "arrow.clockwise")
                            }
                        }
                    }
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
