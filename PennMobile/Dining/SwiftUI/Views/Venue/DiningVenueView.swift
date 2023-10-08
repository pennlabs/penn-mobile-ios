//
//  DiningVenueView.swift
//  PennMobile
//
//  Created by CHOI Jongmin on 9/6/2020.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import SwiftUI

struct DiningVenueView: View {
    enum RefreshState {
        case refreshing(Task<Void, Never>?)
        case refreshed
    }

    @EnvironmentObject var diningVM: DiningViewModelSwiftUI
    @StateObject var diningAnalyticsViewModel = DiningAnalyticsViewModel()
    @State var refreshState = RefreshState.refreshing(nil)
    @State var widgetsNeedRefresh = true

    @State private var favoritesEditMode: EditMode = .inactive

    func triggerRefresh() {
        if case .refreshing(let task) = refreshState {
            task?.cancel()
        }

        refreshState = .refreshing(Task {
            let venueTask = Task {
                await diningVM.refreshVenues()
            }

            let balanceTask = Task {
                await diningVM.refreshBalance()
            }

            let menuTask = Task {
                await diningVM.refreshMenus(cache: true)
            }

            let analyticsTask = Task {
                // Only refresh widgets once
                await diningAnalyticsViewModel.refresh(refreshWidgets: widgetsNeedRefresh)
                if !Task.isCancelled {
                    widgetsNeedRefresh = false
                }
            }

            await venueTask.value
            await balanceTask.value
            await menuTask.value
            await analyticsTask.value

            refreshState = .refreshed
        })
    }

    var body: some View {
        let refreshConfiguration: CustomHeader.RefreshConfiguration
        switch refreshState {
        case .refreshed:
            refreshConfiguration = .refreshed(triggerRefresh)
        default:
            refreshConfiguration = .refreshing
        }

        return List {
            Section(header: CustomHeader(name: "Dining Balance", refreshConfiguration: refreshConfiguration).environmentObject(diningAnalyticsViewModel), content: {
                Section(header: DiningViewHeader().environmentObject(diningAnalyticsViewModel), content: {})
            })

            Section(header: CustomHeader(name: "Favorites")) {
                ForEach(diningVM.favoriteVenues, id: \.id) { venue in
                    if favoritesEditMode == .active {
                        HStack {
                            Button(action: { diningVM.removeVenuesFromFavorites(indexSet: .init(integer: diningVM.favoriteVenues.firstIndex(where: { $0.id == venue.id })!)) }) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundStyle(.red)
                            }
                            DiningVenueRow(for: venue)
                                .padding(.vertical, 4)
                            Spacer()
                            Image(systemName: "text.justify")
                                .foregroundStyle(.secondary)
                            }
                    } else {
                        if favoritesEditMode == .active {
                            DiningVenueRow(for: venue)
                                .padding(.vertical, 4)
                        } else {
                            NavigationLink(destination: DiningVenueDetailView(for: venue).environmentObject(diningVM)) {
                                DiningVenueRow(for: venue)
                                    .padding(.vertical, 4)
                            }
                        }
                    }
                }
                .onDelete(perform: diningVM.removeVenuesFromFavorites)
                .onMove(perform: diningVM.moveFavorite)
                
                Button(action: { favoritesEditMode = .active }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                        VStack(alignment: .leading) {
                            Text(diningVM.favoriteVenues.isEmpty ? "Add venues to favorites" : "Edit favorites")
                                .foregroundStyle(.blue)
                            Text(diningVM.favoriteVenues.isEmpty ? "Tap here, or swipe left on a venue" : "Tap here, or swipe left on a venue")
                                .foregroundStyle(.secondary)
                                .font(.caption)
                        }
                    }
                }
                .listRowSeparator(.hidden)
                    
            }
            .environment(\.editMode, $favoritesEditMode)
            
            ForEach(diningVM.ordering, id: \.self) { venueType in
                Section(header: CustomHeader(name: venueType.fullDisplayName).environmentObject(diningAnalyticsViewModel)) {
                    ForEach(diningVM.diningVenues[venueType] ?? []) { venue in
                        if favoritesEditMode == .active {
                            HStack {
                                Button(action: { diningVM.addVenueToFavorites(venue: venue) }) {
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundStyle(.green)
                                }
                                DiningVenueRow(for: venue)
                                    .padding(.vertical, 4)
                            }
                        } else {
                            NavigationLink(destination: DiningVenueDetailView(for: venue).environmentObject(diningVM)) {
                                DiningVenueRow(for: venue)
                                    .padding(.vertical, 4)
                            }
                            .swipeActions(edge: .trailing) {
                                Button(action: { diningVM.addVenueToFavorites(venue: venue) }) {
                                    Image(systemName: "star.fill")
                                }
                                .tint(.blue)
                            }
                        }
                    }
                }
            }
        }
        .overlay(alignment: .bottom) {
            if favoritesEditMode == .active {
                Button(action: { favoritesEditMode = .inactive }) {
                    Text("Done")
                        .bold()
                        .foregroundStyle(.white)
                        .padding(.horizontal)
                }
                .buttonBorderShape(.capsule)
                .buttonStyle(.borderedProminent)
                .tint(.blue)
                .padding(.bottom)
                .transition(.move(edge: .bottom))
            }
        }
        .onAppear {
            triggerRefresh()
        }
        .navigationBarHidden(false)
        .listStyle(.plain)
    }
}

struct CustomHeader: View {
    enum RefreshConfiguration {
        case noRefresh
        case refreshing
        case refreshed(() -> Void)
    }

    let name: String
    var refreshConfiguration = RefreshConfiguration.noRefresh
    @State var didError = false
    @State var showMissingDiningTokenAlert = false
    @State var showDiningLoginView = false
    @State var buttonAngle: Angle = .zero
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @EnvironmentObject var diningAnalyticsViewModel: DiningAnalyticsViewModel
    func showCorrectAlert () -> Alert {
        if !Account.isLoggedIn {
            return Alert(title: Text("You must log in to access this feature."), message: Text("Please login on the \"More\" tab."), dismissButton: .default(Text("Ok")))
        } else {
            return Alert(title: Text("\"Penn Mobile\" requires you to login to Campus Express to use this feature."),
                         message: Text("Would you like to continue to campus express?"),
                         primaryButton: .default(Text("Continue"), action: {showDiningLoginView = true}),
                         secondaryButton: .cancel({ presentationMode.wrappedValue.dismiss() }))
        }
    }

    func animateButton(refreshing: Bool) {
        if refreshing {
            withAnimation(.linear(duration: 1).repeatForever(autoreverses: reduceMotion || Int.random(in: 0..<50) == 0)) {
                buttonAngle = .degrees(-360)
            }
        } else {
            withAnimation {
                buttonAngle = .zero
            }
        }
    }

    var body: some View {
        let isRefreshing: Bool
        if case .refreshing = refreshConfiguration {
            isRefreshing = true
        } else {
            isRefreshing = false
        }

        return HStack {
            Text(name)
                .font(.system(size: 21, weight: .semibold))
                .foregroundColor(.primary)
            Spacer()
            switch refreshConfiguration {
            case .refreshed, .refreshing:
                Button(action: {
                    guard case .refreshed(let refresh) = refreshConfiguration else {
                        return
                    }

                    guard Account.isLoggedIn, KeychainAccessible.instance.getDiningToken() != nil, let diningExpiration = UserDefaults.standard.getDiningTokenExpiration(), Date() <= diningExpiration else {
                        print("Should show alert")
                        showMissingDiningTokenAlert = true
                        return
                    }

                    refresh()
                }, label: {
                    Image(systemName: "arrow.counterclockwise.circle.fill")
                        .imageScale(.large)
                        .rotationEffect(reduceMotion ? .zero : buttonAngle)
                        .opacity(reduceMotion ? 1 + (buttonAngle.degrees / 360) : (isRefreshing ? 0.5 : 1))
                        .accessibilityLabel(Text(isRefreshing ? "Refreshing" : "Refresh"))
                })
            default:
                Group {}
            }
        }
        .padding()
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        .background(Color(UIColor.uiBackground))
        // Default Text Case for Header is Caps Lock
        .textCase(nil)
        .sheet(isPresented: $showDiningLoginView) {
            DiningLoginNavigationView()
                .environmentObject(diningAnalyticsViewModel)
        }
        .onAppear {
            animateButton(refreshing: isRefreshing)
        }
        .onChange(of: isRefreshing) { refreshing in
            animateButton(refreshing: refreshing)
        }

        // Note: The Alert view is soon to be deprecated, but .alert(_:isPresented:presenting:actions:message:) is available in iOS15+
        .alert(isPresented: $showMissingDiningTokenAlert) {
            showCorrectAlert()
        }

        // iOS 15+ implementation
        /* .alert(Account.isLoggedIn ? "\"Penn Mobile\" requires you to login to Campus Express to use this feature." : "You must log in to access this feature.", isPresented: $showMissingDiningTokenAlert
        ) {
            if (!Account.isLoggedIn) {
                Button("OK") {}
            } else {
                Button("Continue") { showDiningLoginView = true }
                Button("Cancel") { presentationMode.wrappedValue.dismiss() }
            }
        } message: {
            if (!Account.isLoggedIn) {
                Text("Please login on the \"More\" tab.")
            } else {
                Text("Would you like to continue to Campus Express?")
            }
        } */
    }
}
