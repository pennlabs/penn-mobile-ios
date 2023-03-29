//
//  UIKit Views.swift
//  PennMobile
//
//  Created by CHOI Jongmin on 3/6/2020.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import SwiftUI

struct ActivityIndicatorView: UIViewRepresentable {

    @Binding var animating: Bool
    let style: UIActivityIndicatorView.Style

    func makeUIView(context: Context) -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(style: style)
        indicator.color = .labelPrimary
        return indicator
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
        animating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}

struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { uiView.effect = effect }
}
