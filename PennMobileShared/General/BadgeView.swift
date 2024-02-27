//
//  BadgeView.swift
//  PennMobileShared
//
//  Created by Jordan H on 2/26/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import SwiftUI

public struct BadgeModifier: ViewModifier {
    public var text: String
    public var badgeColor: Color = .red
    public var textColor: Color = .white
    public var enabled: Bool = true

    public func body(content: Content) -> some View {
        if enabled {
            content
                .overlay(
                    ZStack {
                        Circle()
                            .fill(badgeColor)
                            .frame(width: 20, height: 20)
                        
                        Text(text)
                            .foregroundColor(textColor)
                            .font(.system(size: 12))
                    }
                    .offset(x: 10, y: -10),
                    alignment: .topTrailing
                )
        } else {
            content
        }
    }
}

public extension View {
    func customBadge(_ text: String, badgeColor: Color = .red, textColor: Color = .white, enabled: Bool = true) -> some View {
        self.modifier(BadgeModifier(text: text, badgeColor: badgeColor, textColor: textColor, enabled: enabled))
    }
}

#Preview {
    Image(systemName: "bell.fill")
        .font(.system(size: 50))
        .foregroundColor(.black)
        .customBadge("3")
}
