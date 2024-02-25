//
//  CustomPopupView.swift
//  PennMobile
//
//  Created by Christina Qiu on 1/26/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import SwiftUI
import PennMobileShared

// Global state for the popup
class PopupManager: ObservableObject {
    @Published var isShown: Bool = false
    @Published var image: Image = Image(systemName: "star")
    @Published var title: String = ""
    @Published var message: String = ""
    @Published var button1: String?
    @Published var button2: String?
    @Published var action1: (() -> Void)?
    @Published var action2: (() -> Void)?
    // Add more properties as needed for buttons and actions
    
    public init() {
        isShown = false
        image = Image(systemName: "star")
        title = ""
        message = ""
    }
    
    public init(image: Image? = nil, title: String, message: String, button1: String? = nil, action1: (() -> Void)? = nil, button2: String? = nil, action2: (() -> Void)? = nil) {
        isShown = false
        set(image: image, title: title, message: message, button1: button1, action1: action1, button2: button2, action2: action2)
    }
    
    public func set(image: Image? = nil, title: String, message: String, button1: String? = nil, action1: (() -> Void)? = nil, button2: String? = nil, action2: (() -> Void)? = nil) {
        self.image = image ?? Image(systemName: "star")
        self.title = title
        self.message = message
        self.button1 = button1
        self.button2 = button2
        self.action1 = action1
        self.action2 = action2
    }
}

// Popup View
struct CustomPopupView: View {
    @ObservedObject var popupManager: PopupManager
    
    var body: some View {
        ZStack {
            // Scrim
            Color.black
                .opacity(0.2)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 18) {
                // Optional image
                popupManager.image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .foregroundColor(Color("navigation"))
                Text(popupManager.title)
                    .font(.headline)
                Text(popupManager.message)
                    .font(.subheadline)
                    .multilineTextAlignment(.leading)
                Button(action: {
                    withAnimation {
                        popupManager.isShown = false
                    }
                    if popupManager.action1 != nil {
                        popupManager.action1!()
                    }
                }) {
                    Text(popupManager.button1 ?? "Confirm")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: 300)
                        .background(RoundedRectangle(cornerRadius: 50).fill(Color("navigation")))
                }
                .padding(.horizontal, 24)
                if popupManager.button2 != nil {
                    Button(action: {
                        withAnimation {
                            popupManager.isShown = false
                        }
                        if popupManager.action2 != nil {
                            popupManager.action2!()
                        }
                    }) {
                        Text(popupManager.button2!)
                    }
                }
            }
            .frame(maxWidth: 280)
            .padding(.horizontal, 24)
            .padding(.vertical, 32)
            .background(Color("uiCardBackground"))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 3)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}

#Preview {
    @StateObject var popupManager = PopupManager(
        title: "Sample title",
        message: "This is a sample message.",
        button1: "See My Listings",
        button2: "Cancel")
    popupManager.action1 = { popupManager.isShown = false }
    popupManager.action2 = { popupManager.isShown = false }
    popupManager.isShown = true

    return CustomPopupView(popupManager: popupManager)
}
