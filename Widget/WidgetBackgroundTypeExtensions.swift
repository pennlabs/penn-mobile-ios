//
//  WidgetBackgroundType.swift
//  PennMobile
//
//  Created by Anthony Li on 10/31/22.
//  Copyright © 2022 PennLabs. All rights reserved.
//

import SwiftUI

extension WidgetBackgroundType: View {
    public var body: some View {
        Group {
            switch self {
            case .unknown, .whiteGray:
                Color.uiCardBackground
            case .whiteBlack:
                Color("White/Black")
            case .gradient:
                LinearGradient(colors: [Color("Gradient1"), Color("Gradient2")], startPoint: .bottomLeading, endPoint: .top)
            }
        }
    }
    
    var prefersGrayscaleContent: Bool {
        self == .gradient
    }
}
