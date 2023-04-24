//
//  MainNavigationView.swift
//  PennMobile
//
//  Created by Anthony Li on 4/23/23.
//  Copyright © 2023 PennLabs. All rights reserved.
//

import SwiftUI

extension Feature: Identifiable {
    var id: String {
        rawValue
    }
    
    var tabName: String {
        switch self {
        case .studyRoomBooking:
            return "GSR"
        default:
            return rawValue
        }
    }
    
    var tabImage: String {
        switch self {
        case .home:
            return "house.fill"
        case .dining:
            return "fork.knife"
        case .studyRoomBooking:
            return "building.columns.fill"
        case .laundry:
            return "washer.fill"
        case .news:
            return "newspaper.fill"
        case .contacts:
            return "phone.fill"
        case .courseSchedule:
            return "books.vertical.fill"
        case .events:
            return "calendar"
        case .fitness:
            return "dumbbell.fill"
        case .more:
            return "ellipsis"
        default:
            return "circle.fill"
        }
    }
    
    var view: any View {
        switch self {
        case .dining:
            return DiningVenueView()
                .navigationTitle(Text("Dining"))
                .environmentObject(DiningViewModelSwiftUI.instance)
        case .more:
            return PreferencesView()
        case .courseSchedule:
            return CoursesView().environmentObject(CoursesViewModel.shared)
        default:
            return VStack {
                Text(rawValue)
                NavigationLink("Test", value: 2)
            }.navigationDestination(for: Int.self) {
                Text("\($0)")
            }
        }
    }
}

struct MainNavigationView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @State var currentTab = Feature.home
    @State var currentPath = NavigationPath()
    
    func transition(to feature: Feature) {
        if UserDefaults.standard.getTabPreferences().contains(feature) {
            currentPath = NavigationPath()
            currentTab = feature
        } else {
            var path = NavigationPath()
            path.append(feature)
            currentPath = path
            currentTab = .more
        }
    }
    
    var body: some View {
        TabView(selection: Binding<Feature> {
            currentTab
        } set: { feature in
            transition(to: feature)
        }) {
            ForEach(UserDefaults.standard.getTabPreferences()) { feature in
                NavigationStack(path: $currentPath) {
                    AnyView(feature.view)
                    .navigationDestination(for: Feature.self) { feature in
                        AnyView(feature.view)
                    }
                }
                .tabItem {
                    Label(feature.tabName, systemImage: feature.tabImage)
                }
                .tag(feature)
            }
        }
    }
}
