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
@available(iOS 13, *)
struct AlertModifier: ViewModifier {
    
    @Binding var show: Bool
    
    var type: NetworkingError
    
    var alertDescription: String {
        switch type {
        case .noInternet:
            return "No Internet Connection"
        default:
            return "Unable to connect to the API.\nPlease refresh and try again."
        }
    }
    
    func body(content: Content) -> some View {
        GeometryReader { geo in
            ZStack {
                content
                if self.show {
                    VStack {
                        Text(self.alertDescription)
                            .frame(width: geo.size.width, height: 70, alignment: .center)
                            .font(Font(UIFont.primaryInformationFont!))
                                .foregroundColor(.white)
                            .background(Color.baseRed)
                        
                        Spacer()
                    }
                    .animation(.easeInOut(duration: 1.0))
                    .transition(AnyTransition.move(edge: .top))
                    .onTapGesture {
                        withAnimation {
                            self.show = false
                        }
                    }.onAppear(perform: {
                        print("doing somethign")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                self.show = false
                            }
                        }
                    })
                }
            }
        }
    }
}

@available(iOS 13, *)
extension View {
    func alert(type: NetworkingError, show: Binding<Bool>) -> some View {
        self.modifier(AlertModifier(show: show, type: type))
    }
}
