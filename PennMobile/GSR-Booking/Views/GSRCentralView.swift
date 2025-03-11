//
//  GSRCentralView.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 2/19/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI

struct GSRCentralView: View {
    
    @State var loggedIn = false
    var body: some View {
        if loggedIn {
            Text("TODO: Scaffolding")
                .navigationBarTitleDisplayMode(.inline)
        } else {
            GSRGuestLandingPage()
                .navigationBarHidden(true)
        }
        
    }
}

#Preview {
    GSRCentralView()
}
