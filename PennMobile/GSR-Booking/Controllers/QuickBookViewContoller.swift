//
//  QuickBookViewContoller.swift
//  PennMobile
//
//  Created by Kaitlyn Kwan on 11/15/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import Foundation
import SwiftUI

struct QuickBookViewContoller: UIViewControllerRepresentable {
    
    @Binding var isPresented: Bool
    func makeUIViewController(context: Context) -> QuickBookingViewController {
        let custViewController = QuickBookingViewController()
        custViewController.modalPresentationStyle = .overCurrentContext
        custViewController.present(custViewController, animated: true)
        return custViewController
    }
    
    func updateUIViewController(_ uiViewController: QuickBookingViewController, context: Context) {
            
    }
    
    typealias UIViewControllerType = QuickBookingViewController
}

struct ContentView: View {
    @State var val: Bool = true
    var body: some View {
        QuickBookViewContoller(isPresented: $val)
        
    }
}
