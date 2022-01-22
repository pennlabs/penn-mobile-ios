//
//  AnalyticsCardView.swift
//  PennMobile
//
//  Created by Andrew Antenberg on 11/21/21.
//  Copyright © 2021 PennLabs. All rights reserved.
//

import SwiftUI

struct AnalyticsCardView: View {
    var text: String
    var color: Color = .blue
    
    var body: some View {
        
            NavigationLink(destination: Text("Hello, Jong Min"), label: {
                CardView {
                HStack {
                    Text(self.text)
                        .font(.system(size: 24, design: .rounded))
                        .bold()
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .padding()
                .foregroundColor(self.color).font(Font.system(size: 24).weight(.bold))
                }
            })
    }
}

struct AnalyticsCardView_Previews: PreviewProvider {
    static var previews: some View {
        AnalyticsCardView(text: "Analytics")
    }
}