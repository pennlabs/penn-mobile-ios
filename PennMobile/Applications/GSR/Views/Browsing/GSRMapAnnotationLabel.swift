//
//  GSRMapAnnotationLabel.swift
//  PennMobile
//
//  Created by Khoi Dinh on 10/3/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI
import Kingfisher
import PennMobileShared

struct GSRMapAnnotationLabel: View {
    let location: GSRLocation
    
    var body: some View {
        VStack(spacing: 4) {
            KFImage(URL(string: location.imageUrl))
                .placeholder { ProgressView() }
                .resizable()
                .scaledToFill()
                .frame(width: 45, height: 45)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            Text(location.name)
                .font(.caption2.weight(.semibold))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .frame(maxWidth: 100)
        }
        .shadow(radius: 2)
        .padding(1)
        .frame(maxWidth: 100, maxHeight: 50)
    }
}
