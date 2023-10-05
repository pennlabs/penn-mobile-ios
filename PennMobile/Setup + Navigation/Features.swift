//
//  Features.swift
//  PennMobile
//
//  Created by Anthony Li on 9/17/23.
//  Copyright © 2023 PennLabs. All rights reserved.
//

import SwiftUI

enum FeatureIdentifier: String, Hashable {
    case dining = "Dining"
    case gsr = "Study Room Booking"
    case laundry = "Laundry"
    case fitness = "Fitness"
    case news = "News"
    case contacts = "Penn Contacts"
    case courseSchedule = "Course Schedule"
    case pennCourseAlert = "Penn Course Alert"
    case events = "Events"
    case about = "About"
}

struct AppFeature: Identifiable {
    let id: FeatureIdentifier
    let shortName: LocalizedStringKey
    let longName: LocalizedStringKey
    let color: Color
    let image: FeatureImage
    let content: AnyView
    
    enum FeatureImage {
        case app(String)
        case system(String)
    }
    
    init<Content: View>(_ id: FeatureIdentifier, shortName: LocalizedStringKey, longName: LocalizedStringKey, color: Color, image: FeatureImage, @ViewBuilder content: () -> Content) {
        self.id = id
        self.shortName = shortName
        self.longName = longName
        self.color = color
        self.image = image
        self.content = AnyView(content())
    }
    
    init<ViewController: UIViewController>(_ id: FeatureIdentifier, shortName: LocalizedStringKey, longName: LocalizedStringKey, color: Color, image: FeatureImage, controller: ViewController.Type) {
        self.init(id, shortName: shortName, longName: longName, color: color, image: image) {
            NavigationStack {
                ViewControllerView<ViewController>()
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationTitle(Text(longName))
            }
        }
    }
    
    init<Content: View>(_ id: FeatureIdentifier, name: LocalizedStringKey, color: Color, image: FeatureImage, @ViewBuilder content: () -> Content) {
        self.init(id, shortName: name, longName: name, color: color, image: image, content: content)
    }
    
    init<ViewController: UIViewController>(_ id: FeatureIdentifier, name: LocalizedStringKey, color: Color, image: FeatureImage, controller: ViewController.Type) {
        self.init(id, shortName: name, longName: name, color: color, image: image, controller: controller)
    }
    
    struct ViewControllerView<ViewController: UIViewController>: UIViewControllerRepresentable {
        func makeUIViewController(context: Context) -> ViewController {
            ViewController()
        }
        
        func updateUIViewController(_ uiViewController: ViewController, context: Context) {}
    }
}

extension AppFeature.FeatureImage: View {
    var body: some View {
        switch self {
        case .app(let name):
            Image(name).resizable()
        case .system(let systemName):
            Image(systemName: systemName).resizable()
        }
    }
}

let features: [AppFeature] = [
    AppFeature(.dining, name: "Dining", color: .baseOrange, image: .app("Dining_Grey")) {
        NavigationStack {
            DiningView()
                .navigationTitle(Text("Dining"))
        }
    },
    AppFeature(.gsr, shortName: "GSR", longName: "GSR Booking", color: .baseGreen, image: .app("GSR_Grey"), controller: GSRTabController.self),
    AppFeature(.laundry, name: "Laundry", color: .baseBlue, image: .app("Laundry_Grey"), controller: LaundryTableViewController.self),
    AppFeature(.news, name: "News", color: .baseRed, image: .system("newspaper"), controller: NewsViewController.self),
    AppFeature(.contacts, shortName: "Contacts", longName: "Penn Contacts", color: .baseYellow, image: .system("phone.fill"), controller: ContactsTableViewController.self),
    AppFeature(.courseSchedule, shortName: "Courses", longName: "Course Schedule", color: .basePurple, image: .system("calendar")) {
        CoursesView().environmentObject(CoursesViewModel.shared)
    },
    AppFeature(.pennCourseAlert, shortName: "PCA", longName: "Penn Course Alert", color: .baseLabsBlue, image: .system("bell.fill"), controller: CourseAlertController.self),
    AppFeature(.events, shortName: "Events", longName: "Penn Events", color: .baseGreen, image: .system("ticket"), controller: PennEventsTableViewController.self),
    AppFeature(.fitness, name: "Fitness", color: .baseRed, image: .system("dumbbell.fill"), controller: FitnessViewController.self),
    AppFeature(.about, name: "About", color: .baseBlue, image: .system("info.circle"), controller: AboutViewController.self)
]
