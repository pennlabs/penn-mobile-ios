//
//  GSRReservationHeaderView.swift
//  PennMobile
//
//  Created by Khoi Dinh on 3/26/26.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI
import Kingfisher

struct GSRReservationHeaderView: View {
    let model: GSRReservation
    let roomName: String?
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            KFImage(URL(string: model.gsr.imageUrl))
                .resizable()
                .scaledToFill()
                .frame(width: UIScreen.main.bounds.width)
                .clipped()

            LinearGradient(
                gradient: Gradient(colors: [
                    .black.opacity(0.6), .black.opacity(0.2),
                    .clear, .black.opacity(0.3), .black
                ]),
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(roomName ?? model.roomName)
                    .foregroundColor(.white)
                    .font(.system(size: 38, weight: .bold))
                    .lineLimit(2)
                    .minimumScaleFactor(0.5)

                Text(model.gsr.name)
                    .foregroundColor(.white)
                    .font(.system(size: 22, weight: .semibold))
                    .lineLimit(2)
                    .minimumScaleFactor(0.5)
            }
            .padding()
        }
        .frame(height: UIScreen.main.bounds.height * 0.38)
        .clipped()
    }
}
