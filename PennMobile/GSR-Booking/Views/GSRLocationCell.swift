//
//  LocationCell.swift
//  PennMobile
//
//  Created by Kaitlyn Kwan on 3/2/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI

struct GSRLocationCell : View {
    let height: CGFloat = 110
    
    fileprivate var location: GSRLocation
    
    init(location: GSRLocation) {
        self.location = location
    }
    
    var body: some View {
        HStack {
            if let imageUrl = URL(string: location.imageUrl) {
                AsyncImage(url: imageUrl) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 120, height: 80)
                        .scaledToFill()
                        .clipShape(RoundedRectangle(cornerRadius: 8))

                } placeholder: {
                    ProgressView().progressViewStyle(CircularProgressViewStyle())
                        .frame(width: 80, height: 80)
                }
            }
            Text(location.name)
                .font(.system(size: 18))
                .foregroundColor(.labelPrimary)
                .padding(.leading, 16)
            Spacer()
        }
        .padding(.horizontal, 8)
        .frame(height: height)
        .cornerRadius(8)
        .shadow(radius: 4)
    }
}
