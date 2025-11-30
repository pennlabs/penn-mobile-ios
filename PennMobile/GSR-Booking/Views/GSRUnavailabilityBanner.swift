//
//  GSRUnavailabilityBanner.swift
//  PennMobile
//
//  Created by Anthony Li on 11/30/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI

struct GSRUnavailabilityBanner: View {
    var body: some View {
        HomeCardView {
            HStack(alignment: .top) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .imageScale(.large)
                    .foregroundStyle(.red)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Some GSRs may be temporarily unavailable in Penn Mobile.")
                        .fontWeight(.medium)
                    
                    Text("We appreciate your patience as we work to resolve this over the coming days.")
                        .font(.caption)
                    
                    Text("In the meantime, you can use [LibCal](https://libcal.library.upenn.edu) or [Wharton Spaces](https://apps.wharton.upenn.edu/gsr/) to book a GSR.")
                        .font(.caption)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    GSRUnavailabilityBanner()
        .padding()
}
