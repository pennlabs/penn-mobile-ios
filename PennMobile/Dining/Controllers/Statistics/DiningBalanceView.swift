//
//  DiningBalanceView.swift
//  PennMobile
//
//  Created by Dominic Holmes on 2/21/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import Foundation
#if canImport(SwiftUI)
import SwiftUI
#endif

@available(iOS 13.0, *)
struct DiningBalanceView: View {
    let description: String
    let image: Image
    @State var balance: Double
    
    // By default, remove trailing zeros
    var specifier: String = "%g"
    var color: Color = .blue
    
    var body: some View {
        CardView {
            VStack(alignment: .trailing) {
                HStack {
                    self.image.font(Font.system(size: 24).weight(.bold))
                    Spacer()
                    Text("\(self.balance, specifier: self.specifier)")
                        .font(.system(size: 24, design: .rounded))
                        .fontWeight(.bold)
                }
                .foregroundColor(self.color)
                Text(self.description)
                    .font(.subheadline)
                    .opacity(0.5)
            }
            .padding()
        }
    }
}

@available(iOS 13.0, *)
struct DiningBalanceView_Previews: PreviewProvider {
    static var previews: some View {
        DiningBalanceView(description: "Dining Dollars", image: Image(systemName: "lock"), balance: 123.54)
    }
}
