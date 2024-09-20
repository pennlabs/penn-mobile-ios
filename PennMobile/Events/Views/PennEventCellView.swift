//
//  PennEventCellView.swift
//  PennMobile
//
//  Created by Jacky on 3/3/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import SwiftUI
import Kingfisher

struct PennEventCellView: View {
    
    var event: PennEvent
    
    @Environment(\.colorScheme) var colorScheme
    
    var shadowColor: Color {
        colorScheme == .dark ? .white.opacity(0.2) : .black.opacity(0.2)
    }
    
    var body: some View {
        ZStack {
            if let imageUrl = event.imageUrl {
                KFImage(event.imageUrl)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 190)
                    .cornerRadius(10)
                    .clipped()
            } else {
                Image("pennmobile")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 190)
                    .cornerRadius(10)
                    .clipped()
            }
            
            // gradient overlay
            LinearGradient(
                gradient: Gradient(colors: [.clear, .black.opacity(0.7)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .cornerRadius(10)
            
            // text
            VStack {
                Spacer()
                HStack {
                    Text(event.eventTitle)
                        .font(.headline)
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Spacer()
                    
                }
                HStack {
                    Text(event.eventLocation)
                        .font(.caption)
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Spacer()
                }
            }
            .padding()
        }
        .frame(height: 190)
        .cornerRadius(10)
        .padding(.horizontal, 15)
        .shadow(color: shadowColor, radius: 10)
    }
}

#Preview {
    PennEventCellView(event: PennEvent())
}
