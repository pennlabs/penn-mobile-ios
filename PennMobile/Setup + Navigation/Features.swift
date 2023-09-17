//
//  Features.swift
//  PennMobile
//
//  Created by Anthony Li on 9/17/23.
//  Copyright © 2023 PennLabs. All rights reserved.
//

import SwiftUI

enum FeatureIdentifier: Hashable {
    case dining
    case gsr
    case laundry
    case fitness
    case news
    case contacts
    case courseSchedule
    case pennCourseAlert
    case events
    case about
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

let features: [AppFeature] = [
    AppFeature(.dining, name: "Dining", color: .baseOrange, image: .app("Dining_Grey")) {
        NavigationStack {
            DiningView()
                .navigationTitle(Text("Dining"))
        }
    },
    AppFeature(.gsr, shortName: "GSR", longName: "GSR Booking", color: .baseGreen, image: .app("GSR_Grey"), controller: GSRTabController.self),
    AppFeature(.laundry, name: "Laundry", color: .baseBlue, image: .app("Laundry_Grey"), controller: LaundryTableViewController.self),
]

let tabBarFeatures: [FeatureIdentifier] = [.dining, .gsr, .laundry]
