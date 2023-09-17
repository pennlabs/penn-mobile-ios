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

struct AppFeature {
    let identifier: FeatureIdentifier
    let shortName: LocalizedStringKey
    let longName: LocalizedStringKey
    let color: Color
    let image: FeatureImage
    let content: AnyView
    
    enum FeatureImage {
        case app(String)
        case system(String)
    }
    
    init<Content: View>(_ identifier: FeatureIdentifier, shortName: LocalizedStringKey, longName: LocalizedStringKey, color: Color, image: FeatureImage, @ViewBuilder content: () -> Content) {
        self.identifier = identifier
        self.shortName = shortName
        self.longName = longName
        self.color = color
        self.image = image
        self.content = AnyView(content())
    }
    
    init<ViewController: UIViewController>(_ identifier: FeatureIdentifier, shortName: LocalizedStringKey, longName: LocalizedStringKey, color: Color, image: FeatureImage, controller: ViewController.Type) {
        self.init(identifier, shortName: shortName, longName: longName, color: color, image: image) {
            ViewControllerView<ViewController>()
                .edgesIgnoringSafeArea(.all)
        }
    }
    
    init<Content: View>(_ identifier: FeatureIdentifier, name: LocalizedStringKey, color: Color, image: FeatureImage, @ViewBuilder content: () -> Content) {
        self.init(identifier, shortName: name, longName: name, color: color, image: image, content: content)
    }
    
    init<ViewController: UIViewController>(_ identifier: FeatureIdentifier, name: LocalizedStringKey, color: Color, image: FeatureImage, controller: ViewController.Type) {
        self.init(identifier, shortName: name, longName: name, color: color, image: image, controller: controller)
    }
    
    struct ViewControllerView<ViewController: UIViewController>: UIViewControllerRepresentable {
        func makeUIViewController(context: Context) -> UINavigationController {
            UINavigationController(rootViewController: ViewController())
        }
        
        func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
    }
}

let features: [AppFeature] = [
    AppFeature(.dining, name: "Dining", color: .baseOrange, image: .app("Dining_Grey")) {
        DiningView()
    },
    AppFeature(.gsr, shortName: "GSR", longName: "GSR Booking", color: .baseGreen, image: .app("GSR_Grey"), controller: GSRTabController.self),
    AppFeature(.laundry, name: "Laundry", color: .baseBlue, image: .app("Laundry_Grey"), controller: LaundryTableViewController.self)
]

let tabBarFeatures: [FeatureIdentifier] = [.dining, .gsr, .laundry]
