//
//  CardHeaderView.swift
//  PennMobile
//
//  Created by Dominic Holmes on 2/23/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import Foundation
#if canImport(SwiftUI)
import SwiftUI
#endif

@available(iOS 13, *)
struct CardHeaderView: View {
    
    let color: Color
    let icon: CardHeaderTitleView.IconType
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .leading) {
            CardHeaderTitleView(color: color, icon: icon, title: title)
            Text(subtitle)
                .fontWeight(.medium)
        }
    }
}

@available(iOS 13, *)
struct CardHeaderTitleView: View {
    enum IconType {
        case dollars, swipes, predictions
    }
    
    let color: Color
    let icon: IconType
    let title: String
    
    private func imageName(for icon: IconType) -> String {
        switch icon {
        case .dollars: return "dollarsign.circle.fill"
        case .swipes: return "creditcard.fill"
        case .predictions: return "wand.and.rays"
        }
    }
    
    var body: some View {
        HStack {
            Image(systemName: imageName(for: icon))
            Text(title)
        }
        .font(Font.body.weight(.medium))
        .foregroundColor(color)
    }
}

@available(iOS 13, *)
struct CardHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        CardHeaderView(color: .blue, icon: .predictions, title: "Predictions", subtitle: "These are your predictions! Pretty cool that they even wrap onto new lines.")
    }
}
