//
//  AlertModifier.swift
//  PennMobile
//
//  Created by CHOI Jongmin on 11/6/2020.
//  Copyright © 2020 PennLabs. All rights reserved.
//

#if canImport(SwiftUI)
import SwiftUI
#endif

// https://trailingclosure.com/notification-banner-using-swiftui/

@available(iOS 14, *)
struct AlertBanner: View {
    init(for type: NetworkingError) {
        self.type = type
    }
    
    var type: NetworkingError
    
    var alertDescription: String {
        switch type {
        case .noInternet:
            return "No Internet Connection"
        default:
            return "Unable to connect to the API.\nPlease refresh and try again."
        }
    }
    
    var body: some View {
        GeometryReader { geo in
            Text(self.alertDescription)
                .frame(width: geo.size.width, height: 70, alignment: .center)
                .font(Font(UIFont.primaryInformationFont))
                    .foregroundColor(.white)
                .background(Color.baseRed)
        }
    }
}

@available(iOS 14, *)
struct AlertModifier: ViewModifier {
    @Binding var type: NetworkingError?
    
    var alertDescription: String {
        switch type {
        case .noInternet:
            return "No Internet Connection"
        default:
            return "Unable to connect to the API.\nPlease refresh and try again."
        }
    }
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if let type = type {
                AlertBanner(for: type)
                    .animation(.easeInOut(duration: 1.0))
                    .transition(AnyTransition.move(edge: .top))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                self.type = nil
                            }
                        }
                    }
                    .onTapGesture {
                        withAnimation {
                            self.type = nil
                        }
                    }
            }
        }
    }
}

@available(iOS 14, *)
extension View {
    func alert(show type: Binding<NetworkingError?>) -> some View {
        self.modifier(AlertModifier(type: type))
    }
}
