//
//  GSRReservationContentView.swift
//  PennMobile
//
//  Created by Khoi Dinh on 3/26/26.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI

struct GSRReservationContentView: View {
    let model: GSRReservation
    let roomName: String?
    
    var body: some View {
        let gsrLocation = model.gsr.name
        
        VStack(spacing: 0) {
                GSRReservationHeaderView(model: model, roomName: roomName)

                VStack(alignment: .leading, spacing: 24) {

                    if let ownerName = model.ownerName {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Booking Owner")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.secondary)

                            HStack(spacing: 8) {
                                Image(systemName: "person.fill") 
                                    .font(.system(size: 18))
                                    .foregroundColor(.indigo)
                                
                                Text(ownerName)
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.primary)
                            }
                        }
                    }

                    GSRBookingDetailsView(model: model)

                    Divider()

                    GSRCalendarSectionView(
                        model: model,
                        gsrLocation: gsrLocation,
                        roomName: roomName
                    )
                    
                    Divider()
                }
                .padding(.horizontal)
                .padding(.top, 20)
                .padding(.bottom, 30)
            }
            .ignoresSafeArea(edges: .top)
        
    }
}
