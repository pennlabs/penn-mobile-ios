//
//  GSRLocationCell.swift
//  PennMobile
//
//  Created by Kaitlyn Kwan on 3/2/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI
import Kingfisher
import PennMobileShared

struct GSRLocationCell: View {
    let location: GSRLocation
    let openRoomCount: Int?
    
    var body: some View {
        HStack {
            KFImage(URL(string: location.imageUrl))
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 120, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading, spacing: 6) {
                Text(location.name)
                    .font(.system(size: 18))
                if let openRoomCount {
                    GSROpenRoomsBadge(openRoomCount: openRoomCount)
                } else {
                    ProgressView()
                }
            }
            .padding(.leading, 16)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .bold()
        }
        .frame(height: 100)
        .contentShape(.rect)
    }
}
