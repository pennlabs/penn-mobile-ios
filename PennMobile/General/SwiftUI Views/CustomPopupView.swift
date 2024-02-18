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
    @Published var button1: String = ""
    @Published var button2: String = ""
    @Published var action1:  () -> Void = {}
    @Published var action2:  () -> Void = {}
    // Add more properties as needed for buttons and actions
}
// Popup View
struct CustomPopupView: View {
    @Binding var isShown: Bool
    var image: Image?
    var title: String
    var message: String
    var button1: String?
    var button2: String?
    var action1: () -> Void
    var action2: () -> Void
    var body: some View {
        if isShown {
            ZStack {
                // Scrim
                Color.black
                    .opacity(0.2)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 18) {
                    // Optional image
                    image?
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                        .foregroundColor(Color("navigation"))
                    Text(title).font(.headline)
                    Text(message)
                        .font(.subheadline)
                        .multilineTextAlignment(.leading)
                    Button(action: action1) {
                        Text(button1 != nil ? button1! : "Confirm")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: 300)
                            .background(RoundedRectangle(cornerRadius: 50).fill(Color("navigation")))
                    }
                    .padding(.horizontal, 24)
                    if button2 != nil {
                        Button(action: action2) {
                            Text(button2!)
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
}

struct CustomPopupView_Previews: PreviewProvider, View {
    @State private var isShown = true
    
    var body: some View {
        CustomPopupView(isShown: $isShown, title: "Sample title", message: "This is a sample message. Text text text text text text.",
            button1: "See My Listings",
            button2: "Cancel",
            action1: {isShown = false},
            action2: {isShown = false}
        )
    }
    
    static var previews: some View {
        Self()
    }
}
