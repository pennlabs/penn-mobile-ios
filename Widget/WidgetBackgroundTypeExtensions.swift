//
//  WidgetBackgroundType.swift
//  PennMobile
//
//  Created by Anthony Li on 10/31/22.
//  Copyright © 2022 PennLabs. All rights reserved.
//

import SwiftUI

extension WidgetBackgroundType: ShapeStyle, @unchecked Sendable {
    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        switch self {
        case .unknown, .whiteGray:
            return AnyShapeStyle(Color.uiCardBackground)
        case .whiteBlack:
            return AnyShapeStyle(Color("White/Black"))
        case .gradient:
            return AnyShapeStyle(LinearGradient(colors: [Color("Gradient1"), Color("Gradient2")], startPoint: .bottomLeading, endPoint: .top))
        }
    }

    var prefersGrayscaleContent: Bool {
        self == .gradient
    }
}
