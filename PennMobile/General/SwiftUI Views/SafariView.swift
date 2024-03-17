//
//  SafariView.swift
//  PennMobile
//
//  Created by Anthony Li on 3/17/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import SwiftUI
import SafariServices

struct SafariView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}

struct SafariModifier: ViewModifier {
    @Binding var isPresented: Bool
    var url: URL?
    
    func body(content: Content) -> some View {
        if let url {
            AnyView(content.sheet(isPresented: $isPresented) {
                SafariView(url: url)
                    .ignoresSafeArea()
            })
        } else {
            AnyView(content)
        }
    }
}

extension View {
    func safari(isPresented: Binding<Bool>, url: URL?) -> some View {
        modifier(SafariModifier(isPresented: isPresented, url: url))
    }
}
