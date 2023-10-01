//
//  ViewExtensions.swift
//  PennMobile
//
//  Created by Anthony Li on 9/1/23.
//  Copyright © 2023 PennLabs. All rights reserved.
//

import SwiftUI

struct WidgetBackground<Style: ShapeStyle>: ViewModifier {
    var background: Style
    
    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            return content.containerBackground(background, for: .widget)
        } else {
            return content.background(background)
        }
    }
}

struct WidgetPadding: ViewModifier {
    var edges: Edge.Set
    var length: CGFloat?
    
    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            return content
        } else {
            return content.padding(edges, length)
        }
    }
}

extension View {
    /// Applies a widget background, dynamically choosing between containerBackground on iOS 17
    /// and a standard background on iOS 16.
    func widgetBackground<Style: ShapeStyle>(_ background: Style) -> some View {
        modifier(WidgetBackground(background: background))
    }
    
    /// Applies padding to the view on iOS 16 or below.
    ///
    /// The system will automatically apply padding on iOS 17, so we ignore these values
    /// if we're running on iOS 17 or later.
    func widgetPadding(_ edges: Edge.Set = .all, _ length: CGFloat? = nil) -> some View {
        modifier(WidgetPadding(edges: edges, length: length))
    }
}
