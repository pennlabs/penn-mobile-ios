//
//  BadgeView.swift
//  PennMobileShared
//
//  Created by Jordan H on 2/26/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import SwiftUI

public struct BadgeModifier: ViewModifier {
    public let text: String?
    public let imageStr: String?
    public let badgeColor: Color
    public let textColor: Color
    public let enabled: Bool
    public let action: (() -> Void)?
    
    public init(text: String? = nil, imageStr: String? = nil, badgeColor: Color = .red, textColor: Color = .white, enabled: Bool = true, action: (() -> Void)? = nil) {
        self.text = text
        self.imageStr = imageStr
        self.badgeColor = badgeColor
        self.textColor = textColor
        self.enabled = enabled
        self.action = action
    }
    
    @ViewBuilder
    func badgeView() -> some View {
        ZStack {
            Circle()
                .fill(badgeColor)
                .frame(width: 20, height: 20)

            if let text = text {
                Text(text)
                    .foregroundColor(textColor)
                    .font(.system(size: 12))
            } else if let imageStr = imageStr {
                Image(systemName: imageStr)
                    .resizable()
                    .foregroundColor(textColor)
                    .frame(width: 10, height: 10)
            }
        }
        .offset(x: 10, y: -10)
    }
    
    public func body(content: Content) -> some View {
        if enabled {
            if let action = action {
                content
                    .overlay(
                        Button(action: action) {
                            badgeView()
                        },
                        alignment: .topTrailing
                    )
            } else {
                content
                    .overlay(
                        badgeView(),
                        alignment: .topTrailing
                    )
            }
        } else {
            content
        }
    }
}

public extension View {
    func customBadge(_ text: String, badgeColor: Color = .red, textColor: Color = .white, enabled: Bool = true, action: (() -> Void)? = nil) -> some View {
        self.modifier(BadgeModifier(text: text, badgeColor: badgeColor, textColor: textColor, enabled: enabled, action: action))
    }
    
    func customBadge(imageStr: String, badgeColor: Color = .red, textColor: Color = .white, enabled: Bool = true, action: (() -> Void)? = nil) -> some View {
        self.modifier(BadgeModifier(imageStr: imageStr, badgeColor: badgeColor, textColor: textColor, enabled: enabled, action: action))
    }
}

#Preview {
    Image(systemName: "bell.fill")
        .font(.system(size: 50))
        .foregroundColor(.black)
        .customBadge("3")
}
