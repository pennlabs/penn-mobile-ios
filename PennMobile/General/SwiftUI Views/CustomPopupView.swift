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
    @Published var disableBackground: Bool = false
    @Published var image: Image = Image(systemName: "star")
    @Published var title: String = ""
    @Published var message: String = ""
    @Published var button1: String?
    @Published var button2: String?
    @Published var action1: (() -> Void)?
    @Published var action2: (() -> Void)?
    @Published var autoHide: Bool = true
    
    public init() {
        isShown = false
        image = Image(systemName: "star")
        title = ""
        message = ""
        autoHide = true
    }
    
    public init(image: Image? = nil, title: String, message: String, button1: String? = nil, action1: (() -> Void)? = nil, button2: String? = nil, action2: (() -> Void)? = nil, autoHide: Bool = true) {
        isShown = false
        set(image: image, title: title, message: message, button1: button1, action1: action1, button2: button2, action2: action2, autoHide: autoHide)
    }
    
    public func show() {
        if !isShown {
            // https://www.hackingwithswift.com/quick-start/swiftui/how-to-dismiss-the-keyboard-for-a-textfield
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        
        withAnimation {
            self.isShown = true
        }
    }
    
    public func hide() {
        withAnimation {
            self.isShown = false
        }
    }
    
    public func set(image: Image? = nil, title: String, message: String, button1: String? = nil, action1: (() -> Void)? = nil, button2: String? = nil, action2: (() -> Void)? = nil, autoHide: Bool? = nil) {
        withAnimation {
            self.image = image ?? Image(systemName: "star")
            self.title = title
            self.message = message
            self.button1 = button1
            self.button2 = button2
            self.action1 = action1
            self.action2 = action2
            if let autoHide {
                self.autoHide = autoHide
            }
        }
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
                    if popupManager.autoHide {
                        popupManager.hide()
                    } else {
                        popupManager.autoHide = true
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
                        if popupManager.autoHide {
                            popupManager.hide()
                        } else {
                            popupManager.autoHide = true
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
        .edgesIgnoringSafeArea(.all)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}

#Preview {
    @Previewable @StateObject var popupManager = PopupManager(
        title: "Sample title",
        message: "This is a sample message.",
        button1: "See My Listings",
        button2: "Cancel")
    popupManager.show()

    return CustomPopupView(popupManager: popupManager)
}
