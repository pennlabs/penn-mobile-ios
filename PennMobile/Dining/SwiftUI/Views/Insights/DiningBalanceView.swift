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

@available(iOS 14.0, *)
struct DiningBalanceView: View {
    let description: String
    let image: Image
    var balance: Double
    
    // By default, remove trailing zeros
    var specifier: String = "%g"
    var color: Color = .blue
    
    var formattedBalance: String {
        let b: Double = balance
        return String(format: "\(self.specifier)", b)
    }
    
    var body: some View {
        CardView {
            VStack(alignment: .trailing) {
                HStack {
                    self.image.font(Font.system(size: 24).weight(.bold))
                    Spacer()
                    Text(self.formattedBalance)
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

@available(iOS 14.0, *)
struct BlankDiningBalanceView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.gray.opacity(0.0))
                .shadow(color: Color.black.opacity(0.0), radius: 4, x: 2, y: 2)
            VStack(alignment: .trailing) {
                HStack {
                    Image(systemName:" ").font(Font.system(size: 24).weight(.bold))
                    Spacer()
                    Text(" ")
                        .font(.system(size: 24, design: .rounded))
                        .fontWeight(.bold)
                }
                Text(" ")
                    .font(.subheadline)
                    .opacity(0.5)
            }
            .padding()
        }
    }
}

@available(iOS 14.0, *)
struct DiningBalanceView_Previews: PreviewProvider {
    static var previews: some View {
        DiningBalanceView(description: "Dining Dollars", image: Image(systemName: "dollarsign.circle.fill"), balance: 427.84, specifier: "%.2f")
    }
}
