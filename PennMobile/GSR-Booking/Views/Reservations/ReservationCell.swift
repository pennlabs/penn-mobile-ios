//
//  ReservationCell.swift
//  PennMobile
//
//  Created by Khoi Dinh on 12/10/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//
import SwiftUI
import Kingfisher

struct ReservationCell: View {
    @EnvironmentObject var vm: GSRViewModel
    @Environment(\.presentToast) var presentToast
    let reservation: GSRReservation
    
    let height: CGFloat = 100
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                KFImage(URL(string: reservation.gsr.imageUrl))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 120, height: 80)
                    .scaledToFill()
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                VStack(alignment: .leading) {
                    Text(reservation.roomName)
                        .font(.subheadline)
                        .foregroundStyle(.labelPrimary)
                    
                    Text("\(reservation.start.gsrTimeString) - \(reservation.end.gsrTimeString)")
                        .font(.subheadline)
                        .padding(.vertical, 3)
                        .padding(.horizontal, 6)
                        .foregroundColor(.labelPrimary)
                        .background(Color.secondary)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                .padding(.leading, 16)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .frame(height: height)
            .cornerRadius(8)
            .transition(.blurReplace)
        }
        .padding()
    }
}

