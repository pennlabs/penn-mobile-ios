//
//  LocationCell.swift
//  PennMobile
//
//  Created by Kaitlyn Kwan on 3/2/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI
import Kingfisher

struct GSRLocationCell: View {
    let height: CGFloat = 100
    
    fileprivate var location: GSRLocation
    
    init(location: GSRLocation) {
        self.location = location
    }
    
    var body: some View {
        HStack {
            KFImage(URL(string: location.imageUrl))
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 120, height: 80)
                .scaledToFill()
                .clipShape(RoundedRectangle(cornerRadius: 8))
            Text(location.name)
                .font(.system(size: 18))
                .padding(.leading, 16)
            Spacer()
            Image(systemName: "chevron.right")
                .bold()
        }
        .frame(height: height)
        .cornerRadius(8)
    }
}
