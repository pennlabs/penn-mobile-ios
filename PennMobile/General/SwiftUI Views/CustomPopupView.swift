//
//  CustomPopupView.swift
//  PennMobile
//
//  Created by Christina Qiu on 1/26/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

#if canImport(SwiftUI)
import SwiftUI
import PennMobileShared
#endif

// Global state for the popup
class PopupManager: ObservableObject {
    @Published var isShown: Bool = false
    @Published var image: Image = Image(systemName: "star")
    @Published var title: String = ""
    @Published var message: String = ""
    // Add more properties as needed for buttons and actions
}
// Popup View
struct CustomPopupView: View {
    @Binding var isShown: Bool
    var image: Image
    var title: String
    var message: String
    var confirmAction: () -> Void
    var body: some View {
        ZStack {
            // Scrim
            Color(hex: 0x5F5F64)
                .opacity(0.2)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 18) {
                // Optional image
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .foregroundColor(.blue)
                Text(title).font(.headline)
                Text(message)
                    .font(.subheadline)
                    .multilineTextAlignment(.leading)
                Button(action: confirmAction) {
                    Text("Confirm")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: 300)
                        .background(RoundedRectangle(cornerRadius: 50).fill(Color.blue))
                }
                .padding(.horizontal, 24)
                Button("Cancel") {
                    isShown = false
                }
            }
            .frame(maxWidth: 280)
            .padding(.horizontal, 24)
            .padding(.vertical, 32)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 3)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

    }
}
// Usage in ContentView
struct ContentView: View {
    @EnvironmentObject var popupManager: PopupManager
    var body: some View {
        ZStack {
            // Your app’s content goes here
            if popupManager.isShown {
                CustomPopupView(isShown: $popupManager.isShown, 
                                image: popupManager.image,
                                title: popupManager.title,
                                message: popupManager.message,
                                confirmAction: {
                                    // Define the confirm action here
                                    popupManager.isShown = false
                                })
                .transition(.scale)
            }
        }
    }
}

extension Color {
    init(hex: Int, alpha: Double = 1.0) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: alpha
        )
    }
}

#Preview {
    
    CustomPopupView(isShown: .constant(true),
                    image: Image(systemName: "star"),
                    title: "Sample Title",
                    message: "This is a sample message. Text text text text text text.",
                    confirmAction: {})
}
