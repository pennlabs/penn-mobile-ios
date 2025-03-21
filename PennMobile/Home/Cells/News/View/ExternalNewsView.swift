//
//  ExternalNewsView.swift
//  PennMobile
//
//  Created by Jacky on 2/9/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//


// MARK: - replaces NewsViewController (3 segmented news view), also updated to reference this in Features

import SwiftUI

struct ExternalNewsView: View {
    
    // same three urls for the 3 news organizations
    private let urls = [
        URL(string: "http://thedp.com/")!,
        URL(string: "http://thedp.com/blog/under-the-button/")!,
        URL(string: "http://34st.com/")!
    ]
    
    @State private var selectedIndex = 0
    
    var body: some View {
        VStack {
            Picker("News Source", selection: $selectedIndex) {
                Text("theDP").tag(0)
                Text("UTB").tag(1)
                Text("34th Street").tag(2)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            NewsWebView(url: urls[selectedIndex])
        }
        .navigationTitle("News")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            print("this opneed")
        }
    }
}